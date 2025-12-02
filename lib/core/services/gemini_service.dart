import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../features/time_management/domain/entities/task_entity.dart';

class AISuggestion {
  final EisenhowerQuadrant quadrant;
  final String description;
  final int durationMinutes;
  final String? timeContext; // Giờ cụ thể AI tìm thấy (dạng HH:mm)

  AISuggestion(
      this.quadrant, this.description, this.durationMinutes, this.timeContext);
}

class GeminiService {
  static const String _apiKey = 'AIzaSyAUij-IKyJa37zaXo4hfxwvH_ovcj-L1kU';
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(model: 'gemini-pro-latest', apiKey: _apiKey);
  }

  Future<AISuggestion?> analyzeAndSuggest(String title) async {
    try {
      // Lấy giờ hiện tại để AI biết ngữ cảnh
      final now = DateTime.now();

      final prompt = '''
        Bạn là trợ lý ảo thông minh. Hãy phân tích câu: "$title".
        Thời gian hiện tại là: ${now.hour}:${now.minute}.
        
        Nhiệm vụ:
        1. Phân loại Eisenhower (0-3).
        2. Viết mô tả ngắn gọn.
        3. Ước lượng thời gian làm (duration).
        4. QUAN TRỌNG: Nếu người dùng nhắc đến giờ cụ thể (ví dụ: "lúc 9h", "chiều nay 5h", "at 10pm"), hãy trích xuất giờ đó dưới dạng "HH:mm" (24h). Nếu không có, để null.
        
        Output JSON:
        {
          "index": (int 0-3),
          "description": "(string)",
          "duration": (int phút),
          "time": "(string HH:mm hoặc null)"
        }
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      String textResult = response.text?.trim() ?? "";
      textResult =
          textResult.replaceAll('```json', '').replaceAll('```', '').trim();

      final json = jsonDecode(textResult);

      return AISuggestion(
        EisenhowerQuadrant.values[json['index']],
        json['description'],
        json['duration'],
        json['time'], // Lấy thêm trường thời gian
      );
    } catch (e) {
      print("❌ Lỗi AI: $e");
      return null;
    }
  }
}
