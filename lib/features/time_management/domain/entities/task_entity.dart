// lib/features/time_management/domain/entities/task_entity.dart
import 'package:equatable/equatable.dart';

enum EisenhowerQuadrant { doFirst, schedule, delegate, eliminate }

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final EisenhowerQuadrant quadrant; // Cho ma trận Eisenhower

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.quadrant,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    dueDate,
    isCompleted,
    quadrant,
  ];
}
