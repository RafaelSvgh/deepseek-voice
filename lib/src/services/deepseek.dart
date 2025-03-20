import 'dart:convert';
import 'package:http/http.dart' as http;

class DeepSeekService {
  final String apiKey =
      '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';
  final String baseUrl = 'https://openrouter.ai/api/v1';

  Future<String> getChatResponse(String prompt) async {
    final url = Uri.parse('$baseUrl/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      "model": "deepseek/deepseek-r1:free",
      "messages": [
        {
          "role": "system",
          "content":
              "Responde siempre en español y usa solo texto plano, sin negritas, listas o símbolos especiales."
        },
        {
          "role": "user",
          "content":
              "${prompt}Responde siempre en español y usa solo texto plano, sin negritas, listas o símbolos especiales."
        }
      ]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        return data["choices"][0]["message"]["content"];
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        return "Error: $errorBody";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
