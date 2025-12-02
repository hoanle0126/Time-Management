import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

// Import Bloc & Models
import '../bloc/task_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../widgets/eisenhower_extensions.dart';
import '../../data/models/task_model.dart';
import '../../../../core/services/gemini_service.dart';

// Import trang con
import '../../../pomodoro/presentation/pages/pomodoro_page.dart';
import 'statistics_page.dart';
import 'calendar_page.dart'; // Import trang lịch trình

// --- USER STATS MODEL (Giữ nguyên để chạy tính năng Game) ---
@HiveType(typeId: 1)
class UserStats extends HiveObject {
  @HiveField(0)
  int level;
  @HiveField(1)
  int currentXp;
  @HiveField(2)
  int xpToNextLevel;

  UserStats({this.level = 1, this.currentXp = 0, this.xpToNextLevel = 100});

  bool addXp(int amount) {
    currentXp += amount;
    if (currentXp >= xpToNextLevel) {
      level++;
      currentXp -= xpToNextLevel;
      xpToNextLevel = (xpToNextLevel * 1.5).toInt();
      return true;
    }
    return false;
  }
}

class EisenhowerMatrixPage extends StatefulWidget {
  const EisenhowerMatrixPage({super.key});

  @override
  State<EisenhowerMatrixPage> createState() => _EisenhowerMatrixPageState();
}

class _EisenhowerMatrixPageState extends State<EisenhowerMatrixPage> {
  late ConfettiController _confettiController;
  late Box _userBox;
  UserStats _stats = UserStats();

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _initUserData();
  }

  Future<void> _initUserData() async {
    _userBox = await Hive.openBox('user_stats');
    final level = _userBox.get('level', defaultValue: 1);
    final xp = _userBox.get('xp', defaultValue: 0);
    final maxXp = _userBox.get('maxXp', defaultValue: 100);

    setState(() {
      _stats = UserStats(level: level, currentXp: xp, xpToNextLevel: maxXp);
    });
  }

  void _addXp(int amount) {
    setState(() {
      bool levelUp = _stats.addXp(amount);
      _userBox.put('level', _stats.level);
      _userBox.put('xp', _stats.currentXp);
      _userBox.put('maxXp', _stats.xpToNextLevel);

      if (levelUp) {
        _confettiController.play();
        _showLevelUpDialog();
      }
    });
  }

  void _showLevelUpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.deepPurple.shade50,
        title: Column(
          children: [
            const Icon(Icons.stars_rounded, color: Colors.orange, size: 60),
            Text("LÊN CẤP ${_stats.level}!",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          ],
        ),
        content: const Text("Bạn quá xuất sắc! Hãy giữ vững phong độ nhé."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tuyệt vời"))
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // --- 1. HEADER (DASHBOARD) ---
              SliverAppBar(
                expandedHeight: 180.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.deepPurple,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Xin chào,",
                                    style: GoogleFonts.poppins(
                                        color: Colors.white70, fontSize: 16)),
                                Text("Master Productivity",
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                children: [
                                  const Icon(Icons.shield,
                                      color: Colors.amber, size: 24),
                                  Text("LV.${_stats.level}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: LinearPercentIndicator(
                                lineHeight: 8.0,
                                percent:
                                    (_stats.currentXp / _stats.xpToNextLevel)
                                        .clamp(0.0, 1.0),
                                backgroundColor: Colors.white24,
                                progressColor: Colors.amber,
                                barRadius: const Radius.circular(10),
                                animation: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                                "${_stats.currentXp}/${_stats.xpToNextLevel} XP",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  // Nút Lịch Trình (Smart Schedule)
                  IconButton(
                    icon: const Icon(Icons.calendar_month_outlined,
                        color: Colors.white),
                    tooltip: 'Lịch trình',
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CalendarPage())),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bar_chart_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StatisticsPage())),
                  ),
                  IconButton(
                    icon: const Icon(Icons.timer_outlined, color: Colors.white),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PomodoroPage())),
                  ),
                ],
              ),

              // --- 2. BODY MATRIX ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: BlocBuilder<TaskBloc, TaskState>(
                    builder: (context, state) {
                      if (state is TaskLoading)
                        return const Center(child: CircularProgressIndicator());
                      if (state is TaskLoaded) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final isTablet = constraints.maxWidth > 600;
                            return isTablet
                                ? _buildTabletLayout(state.tasks)
                                : _buildMobileLayout(state.tasks);
                          },
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        label: const Text("Thêm việc"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
  }

  // --- LOGIC GIAO DIỆN (Layout) ---
  Widget _buildMobileLayout(List<TaskEntity> tasks) {
    return Column(
        children: EisenhowerQuadrant.values
            .map((q) => _buildQuadrantSection(q, tasks))
            .toList());
  }

  Widget _buildTabletLayout(List<TaskEntity> tasks) {
    return Column(
      children: [
        Row(children: [
          Expanded(
              child: _buildQuadrantSection(EisenhowerQuadrant.doFirst, tasks)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildQuadrantSection(EisenhowerQuadrant.schedule, tasks))
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _buildQuadrantSection(EisenhowerQuadrant.delegate, tasks)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildQuadrantSection(EisenhowerQuadrant.eliminate, tasks))
        ]),
      ],
    );
  }

  Widget _buildQuadrantSection(
      EisenhowerQuadrant quadrant, List<TaskEntity> allTasks) {
    final tasks = allTasks.where((t) => t.quadrant == quadrant).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: quadrant.headerColor.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, color: quadrant.headerColor, size: 14),
                const SizedBox(width: 8),
                Text(quadrant.title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text("${tasks.length}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: quadrant.headerColor)),
                )
              ],
            ),
          ),
          tasks.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text("Trống trải quá...",
                      style: GoogleFonts.poppins(color: Colors.grey)))
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.title,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null)),
                      subtitle: Text(
                        "${task.description}\n⏱ ${task.durationMinutes} phút", // Hiển thị thời gian dự kiến
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      isThreeLine: true,
                      leading: Checkbox(
                        value: task.isCompleted,
                        activeColor: quadrant.headerColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) {
                          if (val == true && !task.isCompleted) {
                            _addXp(50);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("+50 XP! Keep going!"),
                                    backgroundColor: Colors.amber,
                                    duration: Duration(milliseconds: 500)));
                          }
                          // Gửi event update task (đánh dấu hoàn thành) vào BLoC tại đây nếu cần
                        },
                      ),
                      onTap: () =>
                          _showAddTaskDialog(context, taskToEdit: task),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // --- LOGIC DIALOG: AI + MANUAL SCHEDULING (CHỌN TAY) ---
  void _showAddTaskDialog(BuildContext context, {TaskEntity? taskToEdit}) {
    final isEditing = taskToEdit != null;

    // Controller cho Text
    final titleController =
        TextEditingController(text: isEditing ? taskToEdit.title : '');
    final descController =
        TextEditingController(text: isEditing ? taskToEdit.description : '');

    // State cho Phân loại & Thời gian
    EisenhowerQuadrant selectedQuadrant =
        isEditing ? taskToEdit.quadrant : EisenhowerQuadrant.doFirst;
    int durationMinutes =
        isEditing ? taskToEdit.durationMinutes : 30; // Mặc định 30p

    // --- BIẾN MỚI CHO VIỆC CHỌN LỊCH THỦ CÔNG ---
    DateTime selectedDate = isEditing && taskToEdit.startTime != null
        ? taskToEdit.startTime!
        : DateTime.now();

    TimeOfDay? selectedStartTime = isEditing && taskToEdit.startTime != null
        ? TimeOfDay.fromDateTime(taskToEdit.startTime!)
        : null; // Mặc định null (Chưa xếp giờ)

    TimeOfDay? selectedEndTime = isEditing && taskToEdit.endTime != null
        ? TimeOfDay.fromDateTime(taskToEdit.endTime!)
        : null;

    bool isAnalyzing = false;
    final geminiService = GeminiService();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            // Hàm chọn Ngày
            Future<void> pickDate() async {
              final picked = await showDatePicker(
                context: ctx,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => selectedDate = picked);
              }
            }

            // Hàm chọn Giờ (Start/End)
            Future<void> pickTime({required bool isStart}) async {
              final initial = isStart
                  ? (selectedStartTime ?? TimeOfDay.now())
                  : (selectedEndTime ?? TimeOfDay.now());

              final picked =
                  await showTimePicker(context: ctx, initialTime: initial);

              if (picked != null) {
                setState(() {
                  if (isStart) {
                    selectedStartTime = picked;
                    // Tự động set EndTime = StartTime + Duration (nếu EndTime chưa có)
                    if (selectedEndTime == null) {
                      final startDt =
                          DateTime(2024, 1, 1, picked.hour, picked.minute);
                      final endDt =
                          startDt.add(Duration(minutes: durationMinutes));
                      selectedEndTime = TimeOfDay.fromDateTime(endDt);
                    }
                  } else {
                    selectedEndTime = picked;
                    // Tính lại Duration nếu người dùng chọn EndTime thủ công
                    if (selectedStartTime != null) {
                      final startDt = DateTime(2024, 1, 1,
                          selectedStartTime!.hour, selectedStartTime!.minute);
                      final endDt =
                          DateTime(2024, 1, 1, picked.hour, picked.minute);
                      final diff = endDt.difference(startDt).inMinutes;
                      if (diff > 0) durationMinutes = diff;
                    }
                  }
                });
              }
            }

            // Hàm AI (Giữ nguyên logic cũ)
            Future<void> askAI() async {
              if (titleController.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text("Nhập tiêu đề trước đã!")));
                return;
              }
              setState(() => isAnalyzing = true);
              try {
                final suggestion =
                    await geminiService.analyzeAndSuggest(titleController.text);
                if (suggestion != null) {
                  setState(() {
                    selectedQuadrant = suggestion.quadrant;
                    descController.text = suggestion.description;
                    durationMinutes = suggestion.durationMinutes;
                    // Nếu AI gợi ý xong, ta có thể reset giờ để người dùng tự xếp hoặc Auto-schedule sau
                  });
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(
                            "✨ AI: ${suggestion.durationMinutes}p - ${suggestion.description}"),
                        backgroundColor: Colors.deepPurple));
                  }
                }
              } catch (e) {/*...*/} finally {
                setState(() => isAnalyzing = false);
              }
            }

            return AlertDialog(
              title: Text(isEditing ? "Sửa nhiệm vụ" : "Nhiệm vụ mới",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. NHẬP LIỆU CƠ BẢN
                    TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                            labelText: "Tên nhiệm vụ",
                            border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(
                        controller: descController,
                        decoration: const InputDecoration(
                            labelText: "Chi tiết",
                            border: OutlineInputBorder()),
                        maxLines: 2),
                    const SizedBox(height: 12),

                    // 2. AI & PHÂN LOẠI
                    Row(children: [
                      Expanded(
                          child: InputDecorator(
                              decoration: const InputDecoration(
                                  labelText: "Ưu tiên",
                                  border: OutlineInputBorder(),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10)),
                              child: DropdownButtonHideUnderline(
                                  child: DropdownButton<EisenhowerQuadrant>(
                                      value: selectedQuadrant,
                                      isExpanded: true,
                                      items: EisenhowerQuadrant.values
                                          .map((q) => DropdownMenuItem(
                                              value: q,
                                              child: Text(q.title,
                                                  style: TextStyle(
                                                      color: q.headerColor,
                                                      fontSize: 13))))
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null)
                                          setState(
                                              () => selectedQuadrant = val);
                                      })))),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                          onPressed: isAnalyzing ? null : askAI,
                          icon: isAnalyzing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.auto_awesome,
                                  color: Colors.deepPurple),
                          tooltip: "AI Phân tích")
                    ]),

                    const Divider(height: 30),

                    // 3. CHỌN LỊCH TRÌNH THỦ CÔNG (PHẦN MỚI)
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Lịch trình (Tùy chọn):",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey))),
                    const SizedBox(height: 8),

                    // Chọn Ngày
                    InkWell(
                      onTap: pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 18, color: Colors.deepPurple),
                            const SizedBox(width: 8),
                            Text(
                                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Chọn Giờ Bắt đầu & Kết thúc
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => pickTime(isStart: true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 18, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text(
                                      selectedStartTime?.format(context) ??
                                          "Bắt đầu",
                                      style: TextStyle(
                                          color: selectedStartTime == null
                                              ? Colors.grey
                                              : Colors.black)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => pickTime(isStart: false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_filled,
                                      size: 18, color: Colors.redAccent),
                                  const SizedBox(width: 8),
                                  Text(
                                      selectedEndTime?.format(context) ??
                                          "Kết thúc",
                                      style: TextStyle(
                                          color: selectedEndTime == null
                                              ? Colors.grey
                                              : Colors.black)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (selectedStartTime == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text("Nếu không chọn giờ, AI sẽ tự sắp xếp sau.",
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.shade800,
                                fontStyle: FontStyle.italic)),
                      )
                  ],
                ),
              ),
              actions: [
                if (isEditing)
                  TextButton(
                      onPressed: () {
                        context
                            .read<TaskBloc>()
                            .add(DeleteTaskEvent(taskToEdit.id));
                        Navigator.pop(ctx);
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text("Xóa")),
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Hủy")),
                ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isEmpty) return;

                      // Xử lý ghép Ngày + Giờ thành DateTime hoàn chỉnh
                      DateTime? finalStartTime;
                      DateTime? finalEndTime;

                      if (selectedStartTime != null) {
                        finalStartTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedStartTime!.hour,
                            selectedStartTime!.minute);

                        if (selectedEndTime != null) {
                          finalEndTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedEndTime!.hour,
                              selectedEndTime!.minute);
                          // Tính lại duration chính xác theo giờ người dùng chọn
                          durationMinutes =
                              finalEndTime.difference(finalStartTime).inMinutes;
                        } else {
                          // Nếu chỉ chọn giờ bắt đầu, tự cộng duration dự kiến
                          finalEndTime = finalStartTime
                              .add(Duration(minutes: durationMinutes));
                        }
                      }

                      final task = TaskEntity(
                        id: isEditing
                            ? taskToEdit.id
                            : DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        description: descController.text,
                        dueDate: selectedDate, // Lưu ngày vào dueDate
                        quadrant: selectedQuadrant,
                        isCompleted: isEditing ? taskToEdit.isCompleted : false,
                        durationMinutes: durationMinutes,
                        startTime:
                            finalStartTime, // Lưu giờ bắt đầu (có thể null)
                        endTime: finalEndTime, // Lưu giờ kết thúc (có thể null)
                      );

                      isEditing
                          ? context.read<TaskBloc>().add(UpdateTaskEvent(task))
                          : context.read<TaskBloc>().add(AddTaskEvent(task));
                      Navigator.pop(ctx);
                    },
                    child: const Text("Lưu lại")),
              ],
            );
          },
        );
      },
    );
  }
}
