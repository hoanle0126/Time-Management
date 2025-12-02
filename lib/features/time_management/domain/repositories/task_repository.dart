// lib/features/time_management/domain/repositories/task_repository.dart
import 'package:dartz/dartz.dart'; // Dùng dartz để xử lý Functional Error Handling
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';

abstract class TaskRepository {
  // Trả về Either<Failure, List<TaskEntity>> thay vì ném Exception lung tung
  Future<Either<Failure, List<TaskEntity>>> getTasks();
  Future<Either<Failure, void>> addTask(TaskEntity task);
  Future<Either<Failure, void>> updateTask(TaskEntity task);
  Future<Either<Failure, void>> deleteTask(String id);
  Future<Either<Failure, void>> syncData(); // Hàm đồng bộ khi có mạng
}
