import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

Future<void> main() async {
  // Conditionally load .env only if not web
  if (!kIsWeb) {
    await dotenv.load(fileName: ".env");
  } else {
    dotenv.testLoad(fileInput: '''
GEMINI_API_KEY=AIzaSyANTCt5fCB1HOLe6Met1RWkAOckwsiNHIk
''');
  }

  runApp(const PlannerAIApp());
}
