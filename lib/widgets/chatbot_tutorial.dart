import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gemini_provider.dart';
import '../providers/chatbot_settings_provider.dart';

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

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatHistory.add(MessageBubble(text: text, isUser: true));
      _isThinking = true;
      _textController.clear();
    });

    try {
      final geminiService = ref.read(geminiServiceProvider);
      final responseText = await geminiService.getResponse(text);

      if (mounted) {
        setState(() {
          _chatHistory.add(MessageBubble(text: responseText, isUser: false));
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
    // Chatbot is always available but never auto-opens
    // User must manually tap the chatbot icon to open it
    setState(() {
      _isVisible = true;
      _isMinimized = true; // Start minimized
    });
    _animationController.forward();
  }

  Future<void> _markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_chatbot_v3', true);
  }

  // Removed local _handleSend, replaced above

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
    // GeminiService handles its own initialization now
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

    final isChatbotEnabled = ref.watch(chatbotSettingsProvider);
    if (!isChatbotEnabled) return const SizedBox.shrink();

    return Positioned(
      bottom: 120, // Slightly higher to clear bottom navigation
      right: 20,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _isMinimized ? _buildMinimized() : _buildMaximized(),
      ),
    );
  }

  Widget _buildMinimized() {
    return GestureDetector(
      onTap: _expand,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.4),
                  Colors.white.withValues(alpha: 0.25),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/chatbot_icon.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
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
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: 320, // Fixed width to be less intrusive
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.4),
                    Colors.white.withValues(alpha: 0.25),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
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
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Ask me anything...',
                              hintStyle: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
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
                            size: 20,
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
    // Check for navigation commands [[NAV:/route]]
    final navMatch = RegExp(r'\[\[NAV:(.+?)\]\]').firstMatch(bubble.text);
    final cleanText = bubble.text
        .replaceAll(RegExp(r'\[\[NAV:.+?\]\]'), '')
        .trim();
    final navRoute = navMatch?.group(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Align(
        alignment: bubble.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: bubble.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: bubble.isUser
                          ? [
                              AppTheme.accentPurple.withValues(alpha: 0.4),
                              AppTheme.accentPurple.withValues(alpha: 0.2),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.4),
                              Colors.white.withValues(alpha: 0.25),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: bubble.isUser
                          ? AppTheme.accentPurple.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    cleanText,
                    style: GoogleFonts.baloo2(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ),
            if (navRoute != null && !bubble.isUser)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton.icon(
                  onPressed: () => context.go(navRoute),
                  icon: const Icon(Icons.explore, size: 16),
                  label: Text(
                    _getNavLabel(navRoute),
                    style: GoogleFonts.baloo2(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getNavLabel(String route) {
    if (route.contains('/near-me')) return 'View Map';
    if (route.contains('/stop-hub')) return 'Explore City';
    if (route.contains('/prizes')) return 'View Prizes';
    if (route.contains('/leaderboard')) return 'See Rankings';
    if (route.contains('/profile')) return 'My Profile';
    if (route.contains('/business/')) return 'View Business';
    return 'Go There';
  }
}

class MessageBubble {
  final String text;
  final bool isUser;
  MessageBubble({required this.text, required this.isUser});
}
