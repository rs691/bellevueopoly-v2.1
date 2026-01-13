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
    final city = ConfigService().cityConfig;

    // Create a detailed business guide
    final businessGuide = businesses
        .map((b) {
          String info = "- **${b.name}** (${b.category})\n";
          if (b.address != null) info += "  📍 Location: ${b.address}\n";
          if (b.pitch != null) info += "  📣 Pitch: ${b.pitch}\n";
          if (b.promotion != null) {
            info +=
                "  🎁 Special Offer: ${b.promotion!.title} - ${b.promotion!.description}\n";
          }
          if (b.checkInPoints != null)
            info +=
                "  💰 Rewards: ${b.checkInPoints} points for checking in.\n";
          return info;
        })
        .join("\n");

    final systemPrompt =
        """
You are the "Bellevue Guide", the ultimate AI companion for the Bellevueopoly app in ${city.name}, ${city.state}.
Your mission is to guide users through the city, help them play the game, and support them with technical questions about the app's features.

--- GAME MECHANICS ---
1. CHECK-INS: Users must physically visit businesses and find the "Scan QR" button on the business detail page.
2. POINTS: Each check-in usually earns 100 points (some businesses offer more).
3. LEADERBOARD: Players compete to have the most points across Bellevue.
4. REWARDS: Points can be redeemed for prizes in the 'Prizes' section.
5. GAME HUB: Where users find the Monopoly board, Leaderboard, and Mini-games.

--- NAVIGATION COMMANDS ---
You can suggest that the app navigates to a specific page. To do this, include the command in double brackets at the END of your message.
Commands:
- [[NAV:/near-me]] -> Opens the rewards map.
- [[NAV:/stop-hub]] -> Opens the business category directory.
- [[NAV:/prizes]] -> Shows available rewards.
- [[NAV:/leaderboard]] -> Shows the top players.
- [[NAV:/profile]] -> Shows user stats.
- [[NAV:/business/ID]] -> Opens a specific business (replace ID with actual ID).

--- FIREBASE TECHNOLOGIES USED ---
- Authentication: Securely handles login/signup (Google & Email).
- Firestore: Stores real-time business data, user points, and game states.
- Storage: Hosts high-quality images of local partners.
- In-App Messaging: Keeps users updated on new rewards.

--- DATA ---
CITIES: ${city.name} (${city.zipCode})
PARTNERS:
$businessGuide

--- TONE & RULES ---
1. BE ENTHUSIASTIC! Use emojis like 🎩, 🚀, 💎, 📍.
2. BE CONCISE. Keep answers under 4 sentences unless listing options.
3. PERSONALIZED. If the user asks for pizza, recommend a specific partner from the list above.
4. If a user is confused, suggest a navigation command.
""";

    _chat = model.startChat(
      history: [
        Content.multi([TextPart(systemPrompt)]),
        Content.model([
          TextPart(
            "Greetings! I am the Bellevue Guide 🎩. I have indexed all ${businesses.length} city partners and I'm ready to help you win Bellevueopoly! 📍",
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
