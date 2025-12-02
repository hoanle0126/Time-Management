# 🚀 Time Management Ultimate - Eisenhower & Pomodoro RPG

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Arch-green?style=for-the-badge)
![State Management](https://img.shields.io/badge/State-BLoC-purple?style=for-the-badge)
![Database](https://img.shields.io/badge/Database-Hive%20(NoSQL)-orange?style=for-the-badge)
![AI](https://img.shields.io/badge/AI-Gemini%201.5%20Flash-blue?style=for-the-badge)

> **"Không chỉ là quản lý thời gian, đây là một trò chơi năng suất."**

Ứng dụng quản lý thời gian đa nền tảng (Cross-platform) được xây dựng bằng **Flutter**, áp dụng triệt để **Clean Architecture**. Tích hợp **Google Gemini AI** để tự động phân loại công việc và hệ thống **Gamification (Game hóa)** giúp biến việc quản lý task khô khan trở nên thú vị như chơi game nhập vai (RPG).

---

## ✨ Tính năng nổi bật (Key Features)

### 1. 🧠 Ma trận Eisenhower thông minh (Smart Eisenhower Matrix)
* Phân loại công việc vào 4 nhóm dựa trên độ khẩn cấp và quan trọng:
  * 🔴 **Làm ngay (Do First):** Khẩn cấp & Quan trọng.
  * 🔵 **Sắp xếp (Schedule):** Quan trọng & Không khẩn cấp.
  * 🟢 **Giao việc (Delegate):** Khẩn cấp & Không quan trọng.
  * ⚪ **Loại bỏ (Eliminate):** Không khẩn cấp & Không quan trọng.

### 2. 🤖 Trợ lý AI (Powered by Google Gemini)
* Tích hợp model **Gemini 1.5 Flash** (Tốc độ phản hồi cực nhanh).
* **AI Smart Classification:** Người dùng chỉ cần nhập tên việc (ví dụ: *"Vợ đẻ"*), AI sẽ tự động phân tích ngữ cảnh và xếp vào ô "Làm ngay".
* Giải quyết vấn đề "lười suy nghĩ" của người dùng.

### 3. 🎮 Game hóa năng suất (RPG Gamification)
* **Hệ thống XP & Level:** Hoàn thành mỗi công việc nhận được XP (Kinh nghiệm).
* **Level Up:** Hiệu ứng pháo giấy (Confetti) và thông báo chúc mừng khi lên cấp.
* **Retention Hook:** Tạo động lực để người dùng quay lại ứng dụng mỗi ngày.

### 4. 🍅 Đồng hồ Pomodoro & Focus Police
* Kỹ thuật Pomodoro đếm ngược 25 phút.
* **Background Persistence:** Sử dụng thuật toán Timestamp Math để đảm bảo thời gian chạy chính xác ngay cả khi tắt ứng dụng.
* **Cơ chế Focus:** Cảnh báo (Notification) ghim trên thanh trạng thái nếu người dùng thoát ứng dụng để làm việc riêng.

### 5. 📊 Thống kê trực quan (Smart Analytics)
* Biểu đồ tròn (Interactive Pie Chart) thể hiện tỷ lệ phân bổ thời gian.
* Tương tác chạm (Touch interaction) để xem chi tiết từng phần trăm.

### 6. 📱 Giao diện thích ứng (Adaptive UI)
* **Mobile:** Giao diện dọc (Column layout).
* **Tablet/Desktop:** Tự động chuyển sang giao diện lưới (Grid layout 2 cột).
* Thiết kế hiện đại với Gradient, Card UI và Google Fonts (Poppins).

### 7. ⚡ Offline-first & Hiệu năng cao
* Sử dụng **Hive (NoSQL)**: Lưu trữ dữ liệu cục bộ, tốc độ nhanh gấp nhiều lần SQLite.
* Dữ liệu luôn sẵn sàng ngay cả khi mất kết nối Internet.

---

## 🛠️ Công nghệ & Kiến trúc (Tech Stack)

Dự án được xây dựng dựa trên tiêu chuẩn **Clean Architecture** chia tách rõ ràng 3 tầng:

### Cấu trúc thư mục:
```text
lib/
├── core/                   # Các thành phần cốt lõi (Network, Errors, Utils)
├── features/               # Chia theo tính năng (Feature-first)
│   ├── time_management/    # Feature chính
│   │   ├── data/           # Data Sources, Models, Repositories Impl (Hive)
│   │   ├── domain/         # Entities, UseCases, Repositories Interface
│   │   └── presentation/   # BLoC, Pages, Widgets (UI)
└── injection_container.dart # Dependency Injection (Service Locator)