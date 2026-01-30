import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart';

class SmartSearchService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  late final GenerativeModel _model;

  SmartSearchService() {
    if (_apiKey.isNotEmpty && _apiKey != 'YOUR_GEMINI_API_KEY_HERE') {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );
    }
  }

  bool get isAvailable =>
      _apiKey.isNotEmpty && _apiKey != 'YOUR_GEMINI_API_KEY_HERE';

  Future<List<String>> analyzeQuery(String query) async {
    if (!isAvailable) return [query];

    try {
      final prompt = '''
사용자의 검색 의도를 분석하여 영화 검색에 도움이 될만한 키워드 3개를 추출해줘.
사용자 입력: "$query"

출력 형식: 키워드1, 키워드2, 키워드3 (단어만 출력)
예: "슬픈 영화 보여줘" -> 슬픔, 감동, 드라마
예: "신나는 액션" -> 액션, 범죄, 모험
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text != null) {
        return response.text!
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (e) {
      print('AI Search Error: $e');
    }

    return [query];
  }

  // 텍스트 임베딩이나 더 복잡한 매칭은 추후 고도화 가능
  // 현재는 의도 분석 후 키워드 기반 필터링 수행
}
