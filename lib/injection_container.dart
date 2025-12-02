import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

// Import Core
import 'core/error/exceptions.dart';
import 'core/error/failures.dart';
import 'core/network/network_info.dart';

// Import Features
import 'features/time_management/domain/entities/task_entity.dart';
import 'features/time_management/domain/repositories/task_repository.dart';
import 'features/time_management/presentation/bloc/task_bloc.dart';
import 'features/time_management/data/models/task_model.dart';

// Khai báo biến Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Time Management

  // 1. Bloc
  // Đăng ký Factory để tạo mới Bloc mỗi khi cần
  sl.registerFactory(
    () => TaskBloc(repository: sl()),
  );

  // 2. Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // 3. Data Sources
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(taskBox: sl()),
  );

  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(),
  );

  //! Core
  // Đăng ký NetworkInfo (Dùng bản mới check Connectivity)
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  // Đăng ký thư viện Connectivity
  sl.registerLazySingleton(() => Connectivity());

  //! External
  // Mở Hive Box (Đổi tên box để reset dữ liệu cũ bị lỗi)
  var taskBox = await Hive.openBox<TaskModel>('tasks_final_v1');
  sl.registerLazySingleton(() => taskBox);
}

// ==========================================================
// CÁC CLASS IMPLEMENTATION (ĐỂ CHẠY ĐƯỢC NGAY TẠI ĐÂY)
// ==========================================================

// 1. NETWORK INFO IMPL (Đã fix lỗi Web)
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    // Logic mới của connectivity_plus: check xem kết quả có phải là 'none' không
    return result != ConnectivityResult.none;
  }
}

// 2. LOCAL DATA SOURCE (Đã thêm Delete/Update)
abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getLastTasks();
  Future<void> cacheTask(TaskModel task);
  Future<void> deleteTask(String id); // Mới thêm
  Future<void> markAsUnsynced(String taskId);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Box<TaskModel> taskBox;

  TaskLocalDataSourceImpl({required this.taskBox});

  @override
  Future<void> cacheTask(TaskModel task) async {
    // Hive put: Nếu ID đã tồn tại thì nó tự Update, chưa có thì Thêm mới
    await taskBox.put(task.id, task);
  }

  @override
  Future<List<TaskModel>> getLastTasks() async {
    return taskBox.values.toList();
  }

  @override
  Future<void> deleteTask(String id) async {
    await taskBox.delete(id);
  }

  @override
  Future<void> markAsUnsynced(String taskId) async {
    // Tạm thời chưa cần dùng logic sync
  }
}

// 3. REMOTE DATA SOURCE (Stub giả lập)
abstract class TaskRemoteDataSource {
  Future<void> addTask(TaskModel task);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  @override
  Future<void> addTask(TaskModel task) async {
    // Giả lập gọi API mất 1 giây
    await Future.delayed(const Duration(seconds: 1));
  }
}

// 4. REPOSITORY IMPL (Đã kết nối đầy đủ CRUD)
class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() async {
    try {
      final localTasks = await localDataSource.getLastTasks();
      return Right(localTasks);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      await localDataSource.cacheTask(taskModel);

      // Nếu có mạng thì gọi remote (Tạm thời bỏ qua để test offline cho mượt)
      /*
      if (await networkInfo.isConnected) {
        await remoteDataSource.addTask(taskModel);
      }
      */
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      await localDataSource.deleteTask(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateTask(TaskEntity task) async {
    try {
      // Trong Hive, update chính là cacheTask (ghi đè lên ID cũ)
      final taskModel = TaskModel.fromEntity(task);
      await localDataSource.cacheTask(taskModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> syncData() async {
    return const Right(null);
  }
}
