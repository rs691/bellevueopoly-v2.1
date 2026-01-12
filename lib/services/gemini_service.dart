import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import '../services/config_service.dart';

class GeminiService {
  final GenerativeModel model;
  ChatSession? _chat;

  GeminiService(String apiKey)
    : model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          maxOutputTokens: 200,
          temperature: 0.7,
        ),
      );

  Future<void> initChat() async {
    final businesses = ConfigService().businesses;
    final businessInfo = businesses
        .map((b) => "- ${b.name} (${b.category}) in ${b.address ?? 'Bellevue'}")
        .join("\n");

    final systemPrompt =
        """
You are the "Bellevue Guide", a friendly chatbot for the Bellevueopoly app. 
Your goal is to help users understand the game and find local businesses in Bellevue, Nebraska.

GAME RULES:
1. Users visit local businesses.
2. They scan a QR code at the business to "Check In".
3. Each check-in earns 100 points.
4. Points are used to climb the leaderboard and unlock prizes.
5. Prizes are listed in the "Prizes" tab.

LOCATIONS:
Here are some of the businesses in the game:
$businessInfo

TONE:
Be friendly, enthusiastic, and concise. Use emojis occasionally (🎩, 💰, 📍). Keep responses under 3 sentences.
""";

    _chat = model.startChat(
      history: [
        Content.multi([TextPart(systemPrompt)]),
        Content.model([
          TextPart(
            "Understood! I am the Bellevue Guide, ready to help players navigate Bellevueopoly! 🎩📍",
          ),
        ]),
      ],
    );
  }

  Future<String> getResponse(String message) async {
    try {
      if (_chat == null) await initChat();
      final response = await _chat!.sendMessage(
        Content.multi([TextPart(message)]),
      );
      return response.text ??
          "I'm not sure how to answer that. Try asking about the rules or a specific business!";
    } catch (e) {
      debugPrint("Gemini Error: $e");
      return "Oops! I lost connection to the Bellevue cloud. ☁️ Try again in a moment!";
    }
  }
}
