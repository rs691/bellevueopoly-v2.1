import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';

import 'secrets.dart'; // This file is gitignored

// Fallback to environment variable if secrets.dart is empty or missing
const String _envGeminiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: geminiApiKey,
);

final geminiApiKeyProvider = Provider<String>((ref) => _envGeminiKey);

final geminiServiceProvider = Provider<GeminiService>((ref) {
  final apiKey = ref.watch(geminiApiKeyProvider);

  if (apiKey.isEmpty) {
    debugPrint('----------------------------------------------------');
    debugPrint('WARNING: GEMINI_API_KEY is not defined!');
    debugPrint('Ensure you are running with:');
    debugPrint('--dart-define=GEMINI_API_KEY=your_key');
    debugPrint('----------------------------------------------------');
  }

  return GeminiService(apiKey);
});
