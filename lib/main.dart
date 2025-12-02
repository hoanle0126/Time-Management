import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

// 1. Import Dependency Injection
import 'injection_container.dart' as di;

// 2. Import Screens & BLoC
import 'features/time_management/presentation/pages/eisenhower_matrix_page.dart';
import 'features/time_management/presentation/bloc/task_bloc.dart';

// 3. Import Models để đăng ký Adapter cho Hive
import 'features/time_management/data/models/task_model.dart';
// Import Entity UserStats (Phần Game hóa/Level)
// Đảm bảo đường dẫn này đúng với nơi bạn tạo file user_stats.dart
import 'features/time_management/domain/entities/user_stats.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // A. Khởi tạo Hive (Database)
  await Hive.initFlutter();

  // B. Đăng ký các Adapter (BẮT BUỘC)
  // Nếu thiếu dòng này sẽ bị lỗi "HiveError: Adapter not found"
  // Lưu ý: Phải chạy lệnh 'flutter packages pub run build_runner build' để sinh file .g.dart trước
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(UserStatsAdapter());

  // C. Khởi tạo Dependency Injection (GetIt)
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // D. Bọc BlocProvider ở tầng cao nhất (Root)
    // Việc này giúp BLoC sống xuyên suốt ứng dụng, Dialog hay màn hình con đều dùng được.
    return BlocProvider(
      create: (_) => di.sl<TaskBloc>()
        ..add(LoadTasks()), // Khởi tạo và Load danh sách ngay lập tức
      child: MaterialApp(
        title: 'Time Management Ultimate',
        debugShowCheckedModeBanner: false, // Tắt chữ Debug ở góc phải
        theme: ThemeData(
          // Thiết lập Theme màu tím DeepPurple hiện đại
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          // Bạn có thể bỏ comment dòng dưới nếu muốn set font toàn app (cần import google_fonts)
          // textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        // Màn hình trang chủ là Ma trận Eisenhower đã nâng cấp giao diện
        home: const EisenhowerMatrixPage(),
      ),
    );
  }
}
