import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static final String _apiKey = kIsWeb
      ? 'AIzaSyANTCt5fCB1HOLe6Met1RWkAOckwsiNHIk'
      : dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static Future<String> generatePlan(String userPrompt) async {
    const systemPrompt = """
    You are an expert AI planner that creates structured, datewise plans with rich detail in each day’s entry. Output only the plan.

    For each day, follow this format exactly:
    YYYY-MM-DD | Title | Detailed Description

    Guidelines:
    1. If the user specifies a date range, use that range.
    2. If not, start from tomorrow and generate a logical progression.
    3. The 'Title' should be a 2–5 word summary of the day's focus.
    4. The 'Detailed Description' should be 2–4 sentences long, including:
      - Specific activities or steps
      - Locations or equipment needed (if any)
      - Time-of-day suggestions, if relevant
      - Instructions, tips, or contextual notes

    Example output (no intro, no bullets, no summary):
    2025-05-08 | Chest & Triceps | Begin with a 5-minute warm-up jog. Focus on bench press (4 sets), incline dumbbell press (3 sets), and tricep dips (3 sets to failure). Stretch post-workout and hydrate properly.

    Do not include anything except the plan lines.
    """;

    final body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": "$systemPrompt - $userPrompt"}
          ]
        }
      ]
    };

    final response = await http.post(
      Uri.parse('$_baseUrl?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] ??
          'No response';
    } else {
      throw Exception("Failed to generate plan: ${response.body}");
    }
  }
}
