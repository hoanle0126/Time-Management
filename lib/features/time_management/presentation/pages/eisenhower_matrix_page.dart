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
import '../widgets/task_card.dart';
import '../../data/models/task_model.dart';
import '../../../../core/services/gemini_service.dart';

// Import trang con
import '../../../pomodoro/presentation/pages/pomodoro_page.dart';
import 'statistics_page.dart';

// --- USER STATS MODEL (Tích hợp nhanh để chạy luôn) ---
// Trong dự án thực tế, bạn nên tách file ra nhé.
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

// Nhớ đăng ký Adapter cho UserStats trong main.dart nếu tách file.
// Nếu lười, ta dùng Box<dynamic> tạm thời.

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
    // Mở Box riêng cho User Stats
    _userBox = await Hive.openBox('user_stats');
    // Đọc dữ liệu, nếu chưa có thì tạo mới
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
      // Lưu lại vào Hive
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
      backgroundColor: const Color(0xFFF5F7FA), // Màu nền hiện đại
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. HEADER HIỆN ĐẠI (SliverAppBar)
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
                            // Avatar + Level Badge
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
                        // Thanh XP
                        Row(
                          children: [
                            Expanded(
                              child: LinearPercentIndicator(
                                lineHeight: 8.0,
                                percent:
                                    _stats.currentXp / _stats.xpToNextLevel,
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

              // 2. BODY MA TRẬN
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
              const SliverToBoxAdapter(
                  child: SizedBox(height: 80)), // Padding bottom
            ],
          ),

          // Hiệu ứng pháo giấy
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

  // --- LOGIC LAYOUT ---
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
                      subtitle: Text(task.description,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      leading: Checkbox(
                        value: task.isCompleted,
                        activeColor: quadrant.headerColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) {
                          // LOGIC HOÀN THÀNH TASK VÀ NHẬN XP
                          // 1. Cập nhật UI Task
                          // 2. Cộng XP
                          if (val == true && !task.isCompleted) {
                            _addXp(50); // Cộng 50 XP khi xong việc
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("+50 XP! Keep going!"),
                                    backgroundColor: Colors.amber,
                                    duration: Duration(milliseconds: 500)));
                          }
                          // Tạm thời gọi update UI (Đúng ra phải gọi BLoC update status)
                          // Bạn cần thêm logic UpdateStatus trong BLoC sau nhé.
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

  // --- LOGIC DIALOG (Giữ nguyên như cũ, chỉ chỉnh lại Font) ---
  void _showAddTaskDialog(BuildContext context, {TaskEntity? taskToEdit}) {
    final isEditing = taskToEdit != null;
    final titleController =
        TextEditingController(text: isEditing ? taskToEdit.title : '');
    final descController =
        TextEditingController(text: isEditing ? taskToEdit.description : '');
    bool isAnalyzing = false;
    EisenhowerQuadrant selectedQuadrant =
        isEditing ? taskToEdit.quadrant : EisenhowerQuadrant.doFirst;
    final geminiService = GeminiService();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            Future<void> askAI() async {
              if (titleController.text.isEmpty) return;
              setState(() => isAnalyzing = true);
              try {
                final suggestion = await geminiService.analyzeTaskPriority(
                    titleController.text, descController.text);
                if (suggestion != null)
                  setState(() => selectedQuadrant = suggestion);
              } catch (e) {
                // Ignore error
              } finally {
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
                    Row(children: [
                      Expanded(
                          child: InputDecorator(
                              decoration: const InputDecoration(
                                  labelText: "Ưu tiên",
                                  border: OutlineInputBorder()),
                              child: DropdownButtonHideUnderline(
                                  child: DropdownButton<EisenhowerQuadrant>(
                                      value: selectedQuadrant,
                                      isExpanded: true,
                                      items: EisenhowerQuadrant.values
                                          .map((q) => DropdownMenuItem(
                                              value: q,
                                              child: Text(q.title,
                                                  style: TextStyle(
                                                      color: q.headerColor))))
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null)
                                          setState(
                                              () => selectedQuadrant = val);
                                      })))),
                      IconButton.filledTonal(
                          onPressed: isAnalyzing ? null : askAI,
                          icon: isAnalyzing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.auto_awesome),
                          tooltip: "AI Gợi ý")
                    ]),
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
                      final task = TaskEntity(
                          id: isEditing
                              ? taskToEdit.id
                              : DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                          title: titleController.text,
                          description: descController.text,
                          dueDate: DateTime.now(),
                          quadrant: selectedQuadrant,
                          isCompleted:
                              isEditing ? taskToEdit.isCompleted : false);
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
