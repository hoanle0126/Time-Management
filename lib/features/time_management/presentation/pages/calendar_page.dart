import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../bloc/task_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../../../../core/services/scheduler_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final SchedulerService _scheduler = SchedulerService();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _runAutoSchedule(BuildContext context, List<TaskEntity> currentTasks) {
    // Gọi thuật toán sắp xếp
    _scheduler.autoSchedule(currentTasks);

    // Thông báo (Demo)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("⚡ Đã tối ưu hóa lịch trình! (Demo Mode)")),
    );
  }

  List<TaskEntity> _getTasksForDay(DateTime day, List<TaskEntity> allTasks) {
    return allTasks.where((task) {
      // Dùng hàm isSameDay của thư viện table_calendar
      if (task.startTime != null) {
        return isSameDay(task.startTime, day);
      }
      return isSameDay(task.dueDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch trình thông minh"),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            tooltip: "Tự động xếp lịch",
            onPressed: () {
              final state = context.read<TaskBloc>().state;
              if (state is TaskLoaded) {
                _runAutoSchedule(context, state.tasks);
              }
            },
          )
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is! TaskLoaded)
            return const Center(child: CircularProgressIndicator());

          final tasks = _getTasksForDay(_selectedDay!, state.tasks);

          // Sắp xếp task theo giờ bắt đầu
          tasks.sort((a, b) {
            if (a.startTime == null) return 1;
            if (b.startTime == null) return -1;
            return a.startTime!.compareTo(b.startTime!);
          });

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                      color: Colors.orange, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(
                      color: Colors.deepPurple, shape: BoxShape.circle),
                ),
              ),
              const Divider(),
              Expanded(
                child: tasks.isEmpty
                    ? const Center(child: Text("Không có công việc nào"))
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          return _buildTimeSlotCard(tasks[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeSlotCard(TaskEntity task) {
    final hasTime = task.startTime != null;
    final timeStr = hasTime
        ? "${DateFormat('HH:mm').format(task.startTime!)} - ${DateFormat('HH:mm').format(task.endTime!)}"
        : "Chưa xếp lịch";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // SỬA LỖI: Dùng withValues thay cho withOpacity (Flutter mới)
          side: BorderSide(
              color: task.quadrant.index == 0
                  ? Colors.red.withValues(alpha: 0.5)
                  : Colors.transparent)),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time,
                size: 16, color: hasTime ? Colors.deepPurple : Colors.grey),
            Text(hasTime ? "${task.durationMinutes}p" : "--",
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        title: Text(task.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(task.description,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text(timeStr,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: hasTime ? Colors.black : Colors.grey)),
      ),
    );
  }
}
