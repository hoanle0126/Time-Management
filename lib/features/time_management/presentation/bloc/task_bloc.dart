import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;

  TaskBloc({required this.repository}) : super(TaskInitial()) {
    on<LoadTasks>((event, emit) async {
      emit(TaskLoading());
      final result = await repository.getTasks();
      result.fold(
        (failure) => emit(const TaskError("Lỗi tải dữ liệu")),
        (tasks) => emit(TaskLoaded(tasks)),
      );
    });

    on<AddTaskEvent>((event, emit) async {
      final result = await repository.addTask(event.task);
      result.fold(
        (failure) => emit(const TaskError("Lỗi thêm task")),
        (success) => add(LoadTasks()), // Reload lại sau khi thêm
      );
    });

    // --- THÊM LOGIC DELETE ---
    on<DeleteTaskEvent>((event, emit) async {
      final result = await repository.deleteTask(event.id);
      result.fold(
        (failure) => emit(const TaskError("Lỗi xóa task")),
        (success) => add(LoadTasks()), // Reload lại sau khi xóa
      );
    });

    // --- THÊM LOGIC UPDATE ---
    on<UpdateTaskEvent>((event, emit) async {
      final result = await repository.updateTask(event.task);
      result.fold(
        (failure) => emit(const TaskError("Lỗi sửa task")),
        (success) => add(LoadTasks()), // Reload lại sau khi sửa
      );
    });
  }
}
