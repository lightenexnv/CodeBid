import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = "AIzaSyAEmpfyIOzXBNcH4Tb0-KCkkS7agJmU8rk";
  static const String _model = "gemini-flash-latest";

  static Future<Map<String, dynamic>> generate(String prompt) async {
    final uri = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey",
    );

    late http.Response response;

    try {
      response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "contents": [
                {
                  "parts": [
                    {"text": prompt}
                  ]
                }
              ],
              "generationConfig": {
                "temperature": 0.2,
                "maxOutputTokens": 1024,
                // Force the model to output pure JSON — no markdown wrapping
                "responseMimeType": "application/json",
              }
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception("Request timed out. Please try again."),
          );
    } catch (e) {
      throw Exception("Network error: $e");
    }

    if (response.statusCode != 200) {
      String message = "API Error (${response.statusCode})";
      try {
        final err = jsonDecode(response.body);
        final detail = err['error']?['message'];
        if (detail != null) message = "Gemini: $detail";
      } catch (_) {}
      throw Exception(message);
    }

    final data = jsonDecode(response.body);

    final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];

    if (text == null) {
      throw Exception("Empty AI response. Please try again.");
    }

    // With responseMimeType=application/json the text should already be clean JSON.
    // _extractJson is kept as a fallback for older models / unexpected responses.
    final jsonString = _extractJson(text);
    if (jsonString == null) {
      throw Exception("AI did not return valid JSON. Response: $text");
    }

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      throw Exception("Failed to parse AI response as JSON.");
    }
  }

  /// Extracts a JSON object from raw text.
  /// Handles: plain JSON, ```json ... ``` fences, and embedded JSON.
  static String? _extractJson(String text) {
    final trimmed = text.trim();

    // 1. Try stripping markdown code fences (```json ... ``` or ``` ... ```)
    final fenceMatch =
        RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(trimmed);
    if (fenceMatch != null) {
      final inside = fenceMatch.group(1)?.trim();
      if (inside != null && inside.startsWith('{')) return inside;
    }

    // 2. If the whole string is already a JSON object
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) return trimmed;

    // 3. Find the first { ... last } as a fallback
    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return trimmed.substring(start, end + 1);
    }

    return null;
  }
}