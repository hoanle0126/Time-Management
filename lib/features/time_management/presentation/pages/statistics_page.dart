import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../widgets/eisenhower_extensions.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int touchedIndex = -1; // Biến để xử lý hiệu ứng khi chạm vào biểu đồ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thống kê năng suất"),
        centerTitle: true,
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is! TaskLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = state.tasks;
          if (tasks.isEmpty) {
            return const Center(child: Text("Chưa có dữ liệu để thống kê"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Phân bổ công việc",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // --- BIỂU ĐỒ TRÒN ---
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2, // Khoảng cách giữa các miếng
                      centerSpaceRadius: 40, // Độ rỗng ở giữa (Tạo hình Donut)
                      sections: _showingSections(tasks),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- CHÚ THÍCH (LEGEND) ---
                _buildLegend(),
              ],
            ),
          );
        },
      ),
    );
  }

  // Hàm tính toán dữ liệu cho biểu đồ
  List<PieChartSectionData> _showingSections(List<TaskEntity> tasks) {
    final total = tasks.length;

    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      // Hiệu ứng phóng to khi chạm
      final fontSize = isTouched ? 20.0 : 14.0;
      final radius = isTouched ? 110.0 : 100.0;
      final widgetSize = isTouched ? 55.0 : 40.0;

      // Lấy Quadrant tương ứng index
      final quadrant = EisenhowerQuadrant.values[i];
      // Đếm số task trong quadrant này
      final count = tasks.where((t) => t.quadrant == quadrant).length;
      final percentage = (count / total) * 100;

      return PieChartSectionData(
        color: quadrant.headerColor,
        value: count.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
        badgeWidget: _Badge(
          quadrant.title.split('(').first.trim(), // Lấy tên ngắn gọn
          size: widgetSize,
          borderColor: quadrant.headerColor,
        ),
        badgePositionPercentageOffset: .98,
      );
    });
  }

  Widget _buildLegend() {
    return Column(
      children: EisenhowerQuadrant.values.map((q) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: q.headerColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                q.title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Widget hiển thị nhãn dán bên ngoài biểu đồ
class _Badge extends StatelessWidget {
  final String text;
  final double size;
  final Color borderColor;

  const _Badge(
    this.text, {
    required this.size,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Animation mượt mà
      width: size * 2, // Mở rộng chiều ngang để chứa chữ
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: size * 0.3,
            fontWeight: FontWeight.bold,
            color: borderColor),
      ),
    );
  }
}
