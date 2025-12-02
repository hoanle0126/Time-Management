import '../../features/time_management/domain/entities/task_entity.dart';

class SchedulerService {
  /// Thuật toán tham lam (Greedy Algorithm) xếp lịch đơn giản
  /// Input: Danh sách Task chưa có giờ
  /// Output: Danh sách Task đã được gán giờ (startTime, endTime)
  List<TaskEntity> autoSchedule(List<TaskEntity> tasks) {
    // 1. Sắp xếp ưu tiên: Làm ngay (DoFirst) -> Sắp xếp (Schedule) -> ...
    tasks.sort((a, b) => a.quadrant.index.compareTo(b.quadrant.index));

    // 2. Bắt đầu xếp từ 8:00 sáng mai (hoặc thời gian rảnh tiếp theo)
    // Để đơn giản cho demo, ta xếp vào ngày hiện tại bắt đầu từ bây giờ
    DateTime currentSlot = DateTime.now();
    if (currentSlot.hour < 8) {
      currentSlot =
          DateTime(currentSlot.year, currentSlot.month, currentSlot.day, 8, 0);
    }

    List<TaskEntity> scheduledTasks = [];

    for (var task in tasks) {
      // Bỏ qua task đã hoàn thành hoặc đã có lịch
      if (task.isCompleted || task.startTime != null) {
        scheduledTasks.add(task);
        continue;
      }

      // Gán giờ
      final startTime = currentSlot;
      final endTime = startTime.add(Duration(minutes: task.durationMinutes));

      // Tạo bản sao task mới với thời gian đã gán
      final scheduledTask = TaskEntity(
        id: task.id,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        isCompleted: task.isCompleted,
        quadrant: task.quadrant,
        startTime: startTime,
        endTime: endTime,
        durationMinutes: task.durationMinutes,
      );

      scheduledTasks.add(scheduledTask);

      // Cập nhật slot tiếp theo (Nghỉ 5 phút giữa các task)
      currentSlot = endTime.add(const Duration(minutes: 5));
    }

    return scheduledTasks;
  }
}
