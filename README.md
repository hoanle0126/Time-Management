# 🚀 Time Management Ultimate - AI-Powered Productivity RPG

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Arch-green?style=for-the-badge)
![State Management](https://img.shields.io/badge/State-BLoC-purple?style=for-the-badge)
![Database](https://img.shields.io/badge/Database-Hive%20(NoSQL)-orange?style=for-the-badge)
![AI](https://img.shields.io/badge/AI-Gemini%201.5%20Flash-blue?style=for-the-badge)

> **"Not just a To-Do List. It's your Personal Productivity Assistant."**

Ứng dụng quản lý thời gian đa nền tảng (Cross-platform) được xây dựng bằng **Flutter**, áp dụng triệt để **Clean Architecture**. Tích hợp **Google Gemini AI** để tự động phân loại công việc và hệ thống **Gamification (Game hóa)** giúp biến việc quản lý task khô khan trở nên thú vị như chơi game nhập vai (RPG).

---

## ✨ Tính năng nổi bật (Key Features)

### 1. 🤖 Trợ lý AI Thông minh (Powered by Gemini 1.5)
Ứng dụng hiểu ngôn ngữ tự nhiên (**Natural Language Processing**) để tự động hóa việc nhập liệu.
* **Hiểu ngữ cảnh:** Nhập *"Đi đá bóng lúc 17h30 chiều nay"*.
* **Tự động trích xuất:** AI sẽ tự điền:
    * **Tiêu đề:** Đi đá bóng.
    * **Thời gian:** 17:30 (Bắt đầu) & 19:00 (Kết thúc - tự suy luận thời lượng).
    * **Phân loại:** Sắp xếp (Màu xanh).
    * **Mô tả:** *"Chuẩn bị giày, quần áo, nước uống..."* (Tự viết nội dung).

### 2. 🧠 Ma trận Eisenhower (Smart Eisenhower Matrix)
* Phân loại công việc vào 4 nhóm dựa trên độ khẩn cấp và quan trọng:
  * 🔴 **Làm ngay (Do First):** Khẩn cấp & Quan trọng.
  * 🔵 **Sắp xếp (Schedule):** Quan trọng & Không khẩn cấp.
  * 🟢 **Giao việc (Delegate):** Khẩn cấp & Không quan trọng.
  * ⚪ **Loại bỏ (Eliminate):** Không khẩn cấp & Không quan trọng.

### 3. 📅 Lịch trình thông minh (Smart Calendar)
* **Visual Timeline:** Hiển thị công việc trực quan trên giao diện Lịch.
* **Auto-Schedule:** Thuật toán tự động sắp xếp các công việc chưa có giờ vào các khoảng trống trong ngày.
* **Time Management:** Quản lý xung đột thời gian hiệu quả.

### 4. 🎮 Game hóa năng suất (RPG Gamification)
* **Hệ thống XP & Level:** Hoàn thành mỗi công việc nhận được XP (Kinh nghiệm).
* **Level Up:** Hiệu ứng pháo giấy (Confetti) và thông báo chúc mừng khi lên cấp.
* **Retention Hook:** Tạo động lực để người dùng quay lại ứng dụng mỗi ngày.

### 5. 🍅 Đồng hồ Pomodoro & Focus Police
* Kỹ thuật Pomodoro đếm ngược 25 phút.
* **Background Persistence:** Sử dụng thuật toán Timestamp Math để đảm bảo thời gian chạy chính xác ngay cả khi tắt ứng dụng (Background Service).
* **Cơ chế Focus:** Cảnh báo (Notification) ghim trên thanh trạng thái nếu người dùng thoát ứng dụng để làm việc riêng.

### 6. 📊 Thống kê & Giao diện thích ứng (Analytics & Adaptive UI)
* **Smart Analytics:** Biểu đồ tròn (Interactive Pie Chart) thể hiện tỷ lệ phân bổ thời gian.
* **Adaptive UI:**
    * **Mobile:** Giao diện dọc (Column layout).
    * **Tablet/Desktop:** Tự động chuyển sang giao diện lưới (Grid layout 2 cột).

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
│   │   ├── domain/         # Entities, Repositories Interface, UseCases
│   │   └── presentation/   # BLoC, Pages, Widgets (UI)
└── injection_container.dart # Dependency Injection (Service Locator)