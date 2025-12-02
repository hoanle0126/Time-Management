import 'package:hive/hive.dart';
import '../../domain/entities/task_entity.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends TaskEntity {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String title;
  @override
  @HiveField(2)
  final String description;
  @override
  @HiveField(3)
  final DateTime dueDate;
  @override
  @HiveField(4)
  final bool isCompleted;
  @HiveField(5)
  final int quadrantIndex;

  // --- THÊM FIELD MỚI CHO HIVE ---
  @override
  @HiveField(6)
  final DateTime? startTime;
  @override
  @HiveField(7)
  final DateTime? endTime;
  @override
  @HiveField(8)
  final int durationMinutes;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
    required this.quadrantIndex,
    this.startTime,
    this.endTime,
    this.durationMinutes = 30,
  }) : super(
          id: id,
          title: title,
          description: description,
          dueDate: dueDate,
          isCompleted: isCompleted,
          quadrant: EisenhowerQuadrant.values[quadrantIndex],
          startTime: startTime,
          endTime: endTime,
          durationMinutes: durationMinutes,
        );

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      isCompleted: entity.isCompleted,
      quadrantIndex: entity.quadrant.index,
      startTime: entity.startTime,
      endTime: entity.endTime,
      durationMinutes: entity.durationMinutes,
    );
  }
}
