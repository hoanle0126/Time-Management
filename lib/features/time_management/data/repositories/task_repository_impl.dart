import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

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
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      print("Đang lưu task: ${task.title}"); // <--- Thêm dòng này
      await localDataSource.cacheTask(taskModel);

      if (await networkInfo.isConnected) {
        await remoteDataSource.addTask(taskModel);
      }
      print("Lưu thành công!");
      return const Right(null);
    } catch (e) {
      print("LỖI LƯU HIVE: $e");
      return Left(CacheFailure());
    }
  }

  // --- Các hàm dưới đây phải implement để thỏa mãn Interface ---

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    // Tạm thời để trống (stub), ta sẽ code logic sau
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateTask(TaskEntity task) async {
    // Tạm thời để trống (stub)
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> syncData() async {
    // Tạm thời để trống (stub)
    return const Right(null);
  }
}
