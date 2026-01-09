import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late Offset _startPosition;
  static const double _swipeThreshold = 50.0;
  // Initialize start position to avoid LateInitializationError
  @override
  void initState() {
    super.initState();
    _startPosition = Offset.zero;
  }

  final List<IconData> iconList = [
    Icons.home_rounded,
    Icons.storefront_rounded,
    Icons.emoji_events_rounded,
    Icons.near_me_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateCurrentIndex(context);
    // We only show the nav bar if we are NOT on the home screen (per existing logic)
    // OR the user wants it everywhere. The prompt implies "From the home screen...",
    // but usually the home screen has its own big navigation. 
    // The previous code hid it on home. I will keep it hidden on home for now 
    // unless the user specifically asked to change that behavior.
    // Wait, the prompt says "From the home screen, there are 5 nav boxes...". 
    // That describes the *content* of the home screen.
    // The navbar is usually for navigating *away* or *between* these.
    // I'll stick to: Show navbar only if NOT home screen.
    
    final isHomeScreen = currentIndex == 0 && GoRouterState.of(context).matchedLocation == '/';
    // Fix: Ensure we don't pass null to floatingActionButton if it expects a widget, or check if Scaffold allows null.
    // Scaffold allows null.
    // However, AnimatedBottomNavigationBar expects activeIndex to be valid.
    
    return GestureDetector(
      onHorizontalDragStart: (details) {
        _startPosition = details.globalPosition;
      },
      onHorizontalDragEnd: (details) {
        _handleSwipe(context);
      },
      child: Scaffold(
        extendBody: true, // Allows background to flow behind nav bar
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Global background image for post-login screens
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background3.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            // Dark vignette overlay to darken the edges
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            widget.child,
          ],
        ),
        floatingActionButton: isHomeScreen
            ? null
            : FloatingActionButton(
                onPressed: () => context.push(AppRoutes.game),
                backgroundColor: AppTheme.accentGreen,
                shape: const CircleBorder(),
                child: const Icon(Icons.casino, size: 30, color: Colors.black),
                // params
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: isHomeScreen
            ? null
            : AnimatedBottomNavigationBar(
                icons: iconList,
                activeIndex: currentIndex,
                gapLocation: GapLocation.center,
                notchSmoothness: NotchSmoothness.softEdge,
                leftCornerRadius: 32,
                rightCornerRadius: 32,
                onTap: (index) => _onItemTapped(index, context),
                backgroundColor: Colors.black.withValues(alpha: 0.6), // Glassy look
                activeColor: AppTheme.accentGreen,
                inactiveColor: Colors.white60,
                iconSize: 28,
              ),
      ),
    );
  }

  void _handleSwipe(BuildContext context) {
    // Swipe logic requires knowing the current index conceptually
    // home=0, stops=1, prizes=2, nearMe=3. 
    // Use similar logic but ensure we don't swipe off valid ranges.
    final currentIndex = _calculateCurrentIndex(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final endPosition = Offset(screenWidth / 2, 0);

    // Check if swipe distance exceeds threshold
    final dx = endPosition.dx - _startPosition.dx;

    if (dx.abs() > _swipeThreshold) {
      int newIndex = currentIndex;

      if (dx > 0) {
        // Swiped right - go to previous tab
        newIndex = (currentIndex - 1).clamp(0, 3);
      } else {
        // Swiped left - go to next tab
        newIndex = (currentIndex + 1).clamp(0, 3);
      }

      if (newIndex != currentIndex) {
        _onItemTapped(newIndex, context);
      }
    }
  }

  int _calculateCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    // Tab 0: HOME -> /
    if (location == '/') {
      return 0;
    // Tab 1: STOPS -> /stop-hub
    } else if (location.startsWith('/stop-hub')) {
      return 1;
    // Tab 2: PRIZES -> /prizes
    } else if (location.startsWith('/prizes') ||
        location.startsWith('/rules-and-prizes')) {
      return 2;
    // Tab 3: NEAR ME -> /near-me
    } else if (location.startsWith('/near-me')) {
      return 3;
    }
    return 0; // Default to home if unknown
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.stopHub);
        break;
      case 2:
        context.go(AppRoutes.prizes);
        break;
      case 3:
        context.go(AppRoutes.nearMe);
        break;
    }
  }
}
