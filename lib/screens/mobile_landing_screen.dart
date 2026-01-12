import 'dart:math' as math;
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../router/app_router.dart';
import '../providers/user_data_provider.dart';

class MobileLandingScreen extends ConsumerStatefulWidget {
  const MobileLandingScreen({super.key});

  @override
  ConsumerState<MobileLandingScreen> createState() =>
      _MobileLandingScreenState();
}

class _MobileLandingScreenState extends ConsumerState<MobileLandingScreen> {
  late Timer _timer;
  late DateTime _endTime;
  int _days = 0;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _calculateNextEndTime();
    _updateCountdown();

    // Update countdown every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _calculateNextEndTime() {
    final now = DateTime.now();
    // Target: Next Monday at 23:59:59
    // Monday is weekday 1.
    int daysUntilMonday = (DateTime.monday - now.weekday + 7) % 7;
    // If it's already Monday, we want NEXT Monday unless it's before 11:59 PM?
    // User said "Sunday night 12:01 to Monday 1159".
    // Let's assume the cycle ends every Monday at midnight.
    if (daysUntilMonday == 0 && now.hour >= 23 && now.minute >= 59) {
      daysUntilMonday = 7;
    }

    _endTime = DateTime(
      now.year,
      now.month,
      now.day + daysUntilMonday,
      23,
      59,
      59,
    );
  }

  void _updateCountdown() {
    final now = DateTime.now();
    if (now.isAfter(_endTime)) {
      _calculateNextEndTime();
    }

    final remaining = _endTime.difference(now);

    setState(() {
      _days = remaining.inDays;
      _hours = remaining.inHours % 24;
      _minutes = remaining.inMinutes % 60;
      _seconds = remaining.inSeconds % 60;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userDataAsync = ref.watch(userDataProvider);

    // Helper function to build countdown timer
    Widget buildCountdownTimer() {
      return Column(
        children: [
          Text(
            'Next Prize Drawing In:',
            style: GoogleFonts.baloo2(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          Text(
            '${_days}d ${_hours.toString().padLeft(2, '0')}h ${_minutes.toString().padLeft(2, '0')}m ${_seconds.toString().padLeft(2, '0')}s',
            style: GoogleFonts.baloo2(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
              shadows: const [
                Shadow(
                  color: Colors.black45,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Helper function to build footer
    Widget buildFooter() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Chamber Opoly',
            style: GoogleFonts.baloo2(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          Text(
            'is brought to you by Business name',
            style: GoogleFonts.baloo2(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Helper function to build positioned pentagon
    Positioned buildPositionedPentagon({
      required int index,
      required int count,
      required double centerX,
      required double centerY,
      required double radius,
      required double tileSize,
      required Widget child,
    }) {
      final double angleDeg = -90 + (360 / count) * index;
      final double angleRad = angleDeg * math.pi / 180.0;
      final double x = centerX + radius * math.cos(angleRad) - tileSize / 2;
      final double y = centerY + radius * math.sin(angleRad) - tileSize / 2;
      return Positioned(left: x, top: y, child: child);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: userDataAsync.when(
          data: (userDoc) {
            if (userDoc == null || !userDoc.exists) {
              return Text(
                'Welcome Back',
                style: GoogleFonts.baloo2(
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                ),
              );
            }
            final user = userDoc.data() as Map<String, dynamic>;
            final String username = (user['username'] is String)
                ? user['username']
                : 'Friend';
            return Text(
              'Welcome Back, $username!',
              style: GoogleFonts.baloo2(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            );
          },
          loading: () => Text(
            'Welcome Back',
            style: GoogleFonts.baloo2(
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          error: (_, __) => Text(
            'Welcome Back',
            style: GoogleFonts.baloo2(
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // Prevents back button on home
        toolbarHeight:
            80, // Increased height to center between top and nav boxes
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final minSide = width < height ? width : height;
          // Tile size optimized for mobile touch targets (min 48px tap area)
          final tileSize = (minSide * 0.26).clamp(120.0, 200.0);
          final radius = (minSide * 0.34);
          final centerX = width / 2;
          // Account for bottom navbar by centering in available space
          final navbarHeight = 72 + 32; // navbar height + margins
          final availableHeight = height - navbarHeight;
          final centerY = availableHeight / 2;

          List<_PentagonItem> items = [
            _PentagonItem(
              Icons.star_outline,
              'Stop Hub',
              () => context.go(AppRoutes.stopHub),
            ),
            _PentagonItem(
              Icons.location_on_outlined,
              'Near Me',
              () => context.go(AppRoutes.nearMe),
            ),
            _PentagonItem(
              Icons.emoji_events_outlined,
              'Prizes',
              () => context.go(AppRoutes.prizes),
            ),
            _PentagonItem(
              Icons.help_outline,
              'FAQs',
              () => context.go(AppRoutes.rulesAndPrizes),
            ),
            _PentagonItem(
              Icons.person_outline,
              'My Account',
              () => context.go(AppRoutes.profile),
            ),
          ];

          return Center(
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: [
                  // Nav boxes in center
                  for (int i = 0; i < items.length; i++) ...[
                    buildPositionedPentagon(
                      index: i,
                      count: items.length,
                      centerX: centerX,
                      centerY: centerY,
                      radius: radius,
                      tileSize: tileSize,
                      child: _buildTile(items[i], tileSize),
                    ),
                  ],
                  // Countdown Timer and Footer at Bottom
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildCountdownTimer(),
                          const SizedBox(height: 12),
                          buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTile(_PentagonItem item, double tileSize) {
    return SizedBox(
      width: tileSize,
      height: tileSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24), // Match navbar radius
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Match navbar blur
          child: Container(
            decoration: BoxDecoration(
              // Match navbar gradient
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.4),
                  Colors.white.withOpacity(0.25),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              // Match navbar layered shadows
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(24),
                splashColor: Colors.white.withOpacity(0.3),
                highlightColor: Colors.white.withOpacity(0.15),
                child: Center(child: _buildTileContent(item, tileSize)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTileContent(_PentagonItem item, double tileSize) {
    final words = item.label.split(' ');

    if (words.length > 1) {
      // Multi-word: text above, icon center, text below
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            words[0],
            textAlign: TextAlign.center,
            style: GoogleFonts.baloo2(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 0.5,
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          SizedBox(height: tileSize * 0.04),
          Icon(
            item.icon,
            size: 32,
            color: Colors.white,
            shadows: const [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          SizedBox(height: tileSize * 0.04),
          Text(
            words.sublist(1).join(' '),
            textAlign: TextAlign.center,
            style: GoogleFonts.baloo2(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 0.5,
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Single word: text on top, icon on bottom
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.baloo2(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 0.5,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: tileSize * 0.06),
          Icon(
            item.icon,
            size: 32,
            color: Colors.white,
            shadows: const [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ],
      );
    }
  }
}

class _PentagonItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _PentagonItem(this.icon, this.label, this.onTap);
}
