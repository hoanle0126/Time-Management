import 'package:hive/hive.dart';
import '../../domain/entities/task_entity.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends TaskEntity {
  // Biến này chỉ có ở Model để phục vụ lưu trữ (lưu index của Enum)
  @HiveField(5)
  final int quadrantIndex;

  // BỎ TỪ KHÓA 'const' Ở ĐÂY để sửa lỗi Invalid constant
  TaskModel({
    required String id,
    required String title,
    required String description,
    required DateTime dueDate,
    required bool isCompleted,
    required this.quadrantIndex,
  }) : super(
          // Truyền dữ liệu lên cha (Entity)
          id: id,
          title: title,
          description: description,
          dueDate: dueDate,
          isCompleted: isCompleted,
          // Logic này không chạy được trong const constructor, nên ta đã bỏ const
          quadrant: EisenhowerQuadrant.values[quadrantIndex],
        );

  // --- MAPPER CHO HIVE (SỬA LỖI OVERRIDE FIELDS) ---
  // Thay vì khai báo lại biến, ta override Getter để Hive nhận diện

  @override
  @HiveField(0)
  String get id => super.id;

  @override
  @HiveField(1)
  String get title => super.title;

  @override
  @HiveField(2)
  String get description => super.description;

  @override
  @HiveField(3)
  DateTime get dueDate => super.dueDate;

  @override
  @HiveField(4)
  bool get isCompleted => super.isCompleted;

  // --- FACTORY CONSTRUCTOR ---

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      isCompleted: entity.isCompleted,
      quadrantIndex: entity.quadrant.index,
    );
  }
}
