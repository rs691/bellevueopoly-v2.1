import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';

// IMPORTANT: The user should provide their API key.
// For now, we define a provider that can be overridden or initialized with a key.
final geminiApiKeyProvider = Provider<String>(
  (ref) => "AIzaSyBBaFFqbZ3t8E5RYOgnEHUmngvSJ9cqDek",
);

final geminiServiceProvider = Provider<GeminiService>((ref) {
  final apiKey = ref.watch(geminiApiKeyProvider);
  return GeminiService(apiKey);
});
