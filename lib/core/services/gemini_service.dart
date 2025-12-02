import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../features/time_management/domain/entities/task_entity.dart';

class AISuggestion {
  final EisenhowerQuadrant quadrant;
  final String description;
  final int durationMinutes;

  AISuggestion(this.quadrant, this.description, this.durationMinutes);
}

class GeminiService {
  static const String _apiKey =
      'AIzaSyAUij-IKyJa37zaXo4hfxwvH_ovcj-L1kU'; // Dán Key của bạn vào
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(model: 'gemini-pro-latest', apiKey: _apiKey);
  }

  Future<AISuggestion?> analyzeAndSuggest(String title) async {
    try {
      print("🧠 AI đang suy nghĩ...");
      final prompt = '''
        Bạn là trợ lý quản lý thời gian. Hãy phân tích công việc: "$title".
        
        Nhiệm vụ:
        1. Xác định mức độ ưu tiên (Eisenhower Matrix 0-3).
        2. Viết mô tả ngắn gọn các bước thực hiện (Actionable steps) bằng tiếng Việt.
        3. Ước lượng thời gian hoàn thành (phút).
        
        Output JSON duy nhất:
        {
          "index": (0=Do First, 1=Schedule, 2=Delegate, 3=Eliminate),
          "description": "(nội dung mô tả)",
          "duration": (số phút, ví dụ: 30)
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
      );
    } catch (e) {
      print("❌ Lỗi AI: $e");
      return null;
    }
  }
}
