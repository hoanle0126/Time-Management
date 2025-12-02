import 'package:google_generative_ai/google_generative_ai.dart';
import '../../features/time_management/domain/entities/task_entity.dart';

class GeminiService {
  // THAY MÃ API CỦA BẠN VÀO ĐÂY
  static const String _apiKey = 'AIzaSyAUij-IKyJa37zaXo4hfxwvH_ovcj-L1kU';

  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro-latest',
      apiKey: _apiKey,
    );
  }

  /// Hàm gửi text lên AI và nhận về Quadrant (0, 1, 2, 3)
  Future<EisenhowerQuadrant?> analyzeTaskPriority(
      String title, String description) async {
    if (_apiKey.startsWith('HÃY_DÁN')) {
      throw Exception("Chưa nhập API Key!");
    }

    // Kỹ thuật Prompt Engineering: Dạy AI cách trả lời
    final prompt = '''
      Bạn là một trợ lý quản lý thời gian chuyên về Ma trận Eisenhower.
      
      Hãy phân tích công việc sau:
      - Tiêu đề: "$title"
      - Mô tả: "$description"
      
      Dựa trên độ khẩn cấp và quan trọng, hãy xếp nó vào 1 trong 4 loại sau:
      0: Làm ngay (Quan trọng & Khẩn cấp)
      1: Sắp xếp (Quan trọng & Không khẩn cấp)
      2: Giao việc (Không quan trọng & Khẩn cấp)
      3: Loại bỏ (Không quan trọng & Không khẩn cấp)
      
      Yêu cầu: CHỈ TRẢ VỀ ĐÚNG 1 CON SỐ DUY NHẤT (0, 1, 2 hoặc 3). Không giải thích gì thêm.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final textResult = response.text?.trim() ?? "";

      // Parse kết quả từ AI (Ví dụ AI trả về "0" -> lấy số 0)
      final index = int.tryParse(textResult);

      if (index != null && index >= 0 && index <= 3) {
        return EisenhowerQuadrant.values[index];
      }
      return null; // AI không hiểu
    } catch (e) {
      print("Lỗi AI: $e");
      return null;
    }
  }
}
