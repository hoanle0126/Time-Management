import 'package:equatable/equatable.dart';

enum EisenhowerQuadrant { doFirst, schedule, delegate, eliminate }

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final EisenhowerQuadrant quadrant;

  // --- CÁC TRƯỜNG MỚI CHO SMART SCHEDULING ---
  final DateTime? startTime; // Giờ bắt đầu được xếp lịch
  final DateTime? endTime; // Giờ kết thúc
  final int durationMinutes; // Thời lượng dự kiến (AI sẽ đoán cái này)

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.quadrant,
    this.startTime,
    this.endTime,
    this.durationMinutes = 30, // Mặc định 30 phút
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        dueDate,
        isCompleted,
        quadrant,
        startTime,
        endTime,
        durationMinutes
      ];
}
