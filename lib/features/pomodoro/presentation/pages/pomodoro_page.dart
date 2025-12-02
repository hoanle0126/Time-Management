import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // Cấu hình Notification
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // State Timer
  int _selectedMinutes = 25; // Mặc định 25 phút
  int _remainingSeconds = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;

  // Dùng để tính toán thời gian thực khi chạy nền
  DateTime? _endTime;

  // Animation
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addObserver(this); // Lắng nghe trạng thái App (Nền/Mở)
    _initNotifications();
    _resetController();
  }

  void _resetController() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(minutes: _selectedMinutes),
    );
    _controller.value = 0.0;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controller.dispose();
    _cancelNotification();
    super.dispose();
  }

  // --- 1. XỬ LÝ BACKGROUND (CHẠY NGẦM) ---
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _isRunning) {
      // Khi người dùng thoát App -> Bắn thông báo nhắc nhở
      _showPersistentNotification();
    } else if (state == AppLifecycleState.resumed && _isRunning) {
      // Khi quay lại -> Đồng bộ lại thời gian (để tránh bị lệch giờ)
      _syncTimeFromBackground();
      _cancelNotification(); // Xóa thông báo đi
    }
  }

  void _syncTimeFromBackground() {
    if (_endTime != null) {
      final now = DateTime.now();
      if (now.isAfter(_endTime!)) {
        // Đã hết giờ trong lúc tắt app
        _finishTimer();
      } else {
        // Tính lại số giây còn lại
        setState(() {
          _remainingSeconds = _endTime!.difference(now).inSeconds;
          // Cập nhật lại Animation để không bị nhảy cóc
          final totalSeconds = _selectedMinutes * 60;
          _controller.value = 1.0 - (_remainingSeconds / totalSeconds);
        });
      }
    }
  }

  // --- 2. XỬ LÝ NOTIFICATION ---
  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notificationsPlugin.initialize(settings);

    // Xin quyền
    await Permission.notification.request();
  }

  Future<void> _showPersistentNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro Timer',
      channelDescription: 'Hiển thị thời gian đếm ngược',
      importance:
          Importance.low, // Low để không rung liên tục, chỉ hiện thanh progress
      priority: Priority.low,
      ongoing: true, // Không cho quẹt xóa -> Giả lập "Khóa"
      autoCancel: false,
      showProgress: true,
      maxProgress: 100,
      indeterminate: true, // Thanh chạy liên tục
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      'Đang tập trung...',
      'Đừng lướt App khác! Quay lại làm việc đi.',
      details,
    );
  }

  Future<void> _cancelNotification() async {
    await _notificationsPlugin.cancel(0);
  }

  // --- 3. LOGIC TIMER ---

  void _toggleTimer() {
    if (_isRunning) {
      // Tạm dừng
      _timer?.cancel();
      _controller.stop();
      _endTime = null; // Xóa mốc đích
    } else {
      // Bắt đầu chạy
      // Đặt mốc thời gian đích (Quan trọng cho chạy nền)
      _endTime = DateTime.now().add(Duration(seconds: _remainingSeconds));

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _finishTimer();
          }
        });
      });

      // Tính toán tốc độ chạy animation dựa trên thời gian còn lại
      final totalSeconds = _selectedMinutes * 60;
      final durationRemaining = Duration(seconds: _remainingSeconds);
      _controller.duration = Duration(seconds: totalSeconds);
      _controller.forward(from: 1.0 - (_remainingSeconds / totalSeconds));
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _finishTimer() {
    _timer?.cancel();
    _isRunning = false;
    _remainingSeconds = 0;
    _controller.value = 1.0;
    _cancelNotification();

    // Show Dialog chúc mừng
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text("🎉 Hoàn thành!"),
              content: const Text("Bạn đã tập trung tuyệt vời."),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"))
              ],
            ));
  }

  void _resetTimer() {
    _timer?.cancel();
    _cancelNotification();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _selectedMinutes * 60;
      _endTime = null;
    });
    _resetController(); // Reset animation controller với thời gian mới
  }

  void _updateDuration(double value) {
    setState(() {
      _selectedMinutes = value.toInt();
      _remainingSeconds = _selectedMinutes * 60;
    });
    _resetController();
  }

  String get _timerString {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pomodoro Focus")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. THANH CHỌN THỜI GIAN (TÙY CHỌN)
            if (!_isRunning) ...[
              const Text("Thời gian tập trung:",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              Row(
                children: [
                  const Text("5p"),
                  Expanded(
                    child: Slider(
                      value: _selectedMinutes.toDouble(),
                      min: 5,
                      max: 120,
                      divisions: 23, // (120-5)/5 bước nhảy
                      label: "$_selectedMinutes phút",
                      onChanged: _updateDuration,
                    ),
                  ),
                  const Text("120p"),
                ],
              ),
              Text("$_selectedMinutes phút",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple)),
              const SizedBox(height: 30),
            ],

            // 2. ĐỒNG HỒ
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 280,
                  height: 280,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        value: _controller.value, // Giá trị từ 0.0 đến 1.0
                        strokeWidth: 16,
                        backgroundColor: Colors.grey.shade200,
                        color: _isRunning ? Colors.deepPurple : Colors.orange,
                        strokeCap: StrokeCap.round,
                      );
                    },
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _timerString,
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    if (_isRunning)
                      const Text("Đang chạy ngầm...",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 50),

            // 3. NÚT ĐIỀU KHIỂN
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.large(
                  heroTag: "btn1",
                  onPressed: _toggleTimer,
                  backgroundColor: _isRunning ? Colors.orange : Colors.green,
                  child: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: "btn2",
                  onPressed: _resetTimer,
                  backgroundColor: Colors.grey,
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4. LỜI NHẮC (THAY CHO KHÓA MÀN HÌNH)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200)),
              child: Row(
                children: const [
                  Icon(Icons.lock_clock, color: Colors.red),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Chế độ Focus: Nếu bạn thoát ứng dụng, một thông báo sẽ ghim trên màn hình để nhắc nhở!",
                      style: TextStyle(fontSize: 13, color: Colors.redAccent),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
