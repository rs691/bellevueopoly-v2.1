import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../services/config_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gemini_provider.dart';

class ChatbotTutorial extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;

  const ChatbotTutorial({super.key, this.onComplete});

  @override
  ConsumerState<ChatbotTutorial> createState() => _ChatbotTutorialState();
}

class _ChatbotTutorialState extends ConsumerState<ChatbotTutorial>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  bool _isVisible = false;
  bool _isMinimized = false;
  bool _isThinking = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _textController = TextEditingController();
  final List<MessageBubble> _chatHistory = [];
  ChatSession? _chat;

  Future<void> initChat() async {
    final geminiService = ref.read(geminiServiceProvider);
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

    _chat = geminiService.model.startChat(
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

  final List<String> _tutorialMessages = [
    "Hi there! I'm your Bellevueopoly Guide. 🎩 Welcome to the ultimate neighborhood adventure!",
    "It's simple: Visit local businesses, find their QR codes, and scan them to 'Check In'.",
    "Each check-in earns you points! 💰 You can use them to climb the leaderboard and unlock exclusive prizes.",
    "I'll be hanging around if you need me. Just tap my face to revisit the rules or ask me anything! Ready to explore?",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _checkVisibility();
  }

  Future<void> _checkVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('has_seen_chatbot_v3') ?? false;

    if (!hasSeen) {
      setState(() {
        _isVisible = true;
        _chatHistory.add(
          MessageBubble(text: _tutorialMessages[0], isUser: false),
        );
      });
      _animationController.forward();
    } else {
      setState(() {
        _isVisible = true;
        _isMinimized = true;
      });
      _animationController.forward();
    }
  }

  Future<void> _markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_chatbot_v3', true);
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatHistory.add(MessageBubble(text: text, isUser: true));
      _isThinking = true;
      _textController.clear();
    });

    if (_chat == null) {
      await initChat();
    }

    try {
      final response = await _chat!.sendMessage(
        Content.multi([TextPart(text)]),
      );
      if (mounted) {
        setState(() {
          _chatHistory.add(
            MessageBubble(text: response.text ?? "No response.", isUser: false),
          );
          _isThinking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _chatHistory.add(
            MessageBubble(text: "Error: ${e.toString()}", isUser: false),
          );
          _isThinking = false;
        });
      }
    }
  }

  void _nextStep() {
    if (_currentStep < _tutorialMessages.length - 1) {
      setState(() {
        _currentStep++;
        _chatHistory.add(
          MessageBubble(text: _tutorialMessages[_currentStep], isUser: false),
        );
      });
    } else {
      _minimize();
    }
  }

  void _minimize() {
    _markAsSeen();
    setState(() => _isMinimized = true);
  }

  void _expand() {
    setState(() {
      _isMinimized = false;
      // If expanding after tutorial, keep history but show input
      if (_currentStep < _tutorialMessages.length - 1) {
        _currentStep = 0;
        _chatHistory.clear();
        _chatHistory.add(
          MessageBubble(text: _tutorialMessages[0], isUser: false),
        );
      }
    });
    // Initialize chat if it hasn't been initialized yet (e.g., first time expanding after tutorial)
    if (_chat == null) {
      initChat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Positioned(
      bottom: 110,
      right: 20,
      left: _isMinimized ? null : 20,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _isMinimized ? _buildMinimized() : _buildMaximized(),
      ),
    );
  }

  Widget _buildMinimized() {
    return GestureDetector(
      onTap: _expand,
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.accentPurple, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset('assets/chatbot_icon.png', fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildMaximized() {
    final isTutorial =
        _currentStep < _tutorialMessages.length - 1 &&
        _chatHistory.length <= _tutorialMessages.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Chat Bubble
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: const AssetImage(
                          'assets/chatbot_icon.png',
                        ),
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Bellevue Guide',
                        style: GoogleFonts.baloo2(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: _minimize,
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _chatHistory.length + (_isThinking ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _chatHistory.length && _isThinking) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: SizedBox(
                              width: 20,
                              height: 2,
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.transparent,
                                color: AppTheme.accentPurple,
                              ),
                            ),
                          );
                        }
                        return _buildMessage(_chatHistory[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isTutorial)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _minimize,
                          child: Text(
                            'Skip',
                            style: GoogleFonts.baloo2(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _currentStep == _tutorialMessages.length - 2
                                ? 'Let\'s Go!'
                                : 'Next',
                            style: GoogleFonts.baloo2(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Ask me anything...',
                              hintStyle: const TextStyle(color: Colors.white54),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white12,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            onSubmitted: (_) => _handleSend(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: AppTheme.accentPurple,
                          ),
                          onPressed: _handleSend,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessage(MessageBubble bubble) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: bubble.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bubble.isUser
                ? AppTheme.accentPurple.withOpacity(0.5)
                : Colors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            bubble.text,
            style: GoogleFonts.baloo2(color: Colors.white, fontSize: 15),
          ),
        ),
      ),
    );
  }
}

class MessageBubble {
  final String text;
  final bool isUser;
  MessageBubble({required this.text, required this.isUser});
}
