import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotSettingsNotifier extends Notifier<bool> {
  static const _key = 'chatbot_enabled';

  @override
  bool build() {
    // We can't use async in build, so we'll initialize from a default and load asynchronously
    _loadState();
    return true; // Default to enabled
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? true;
  }

  Future<void> toggle(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}

final chatbotSettingsProvider = NotifierProvider<ChatbotSettingsNotifier, bool>(
  () {
    return ChatbotSettingsNotifier();
  },
);
