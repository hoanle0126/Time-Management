import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<void> addTask(TaskModel task);
  // Thêm các hàm khác sau này
}
