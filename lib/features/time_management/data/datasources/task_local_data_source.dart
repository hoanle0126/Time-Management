import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getLastTasks();
  Future<void> cacheTask(TaskModel task);
  Future<void> markAsUnsynced(String taskId);
}

// (Tạm thời chúng ta chưa implement chi tiết, chỉ cần class abstract để hết lỗi)
