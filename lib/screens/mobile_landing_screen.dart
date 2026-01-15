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
import '../widgets/pentagon_button.dart';

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
  String? _randomBusinessName;

  @override
  void initState() {
    super.initState();
    _calculateNextEndTime();
    _updateCountdown();
    _fetchRandomBusinessName();

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

  Future<void> _fetchRandomBusinessName() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('businesses')
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final random = math.Random();
        final randomIndex = random.nextInt(querySnapshot.docs.length);
        final businessData = querySnapshot.docs[randomIndex].data();
        setState(() {
          _randomBusinessName = businessData['name'] as String?;
        });
      }
    } catch (e) {
      debugPrint('Error fetching random business name: $e');
    }
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${_days}d ${_hours.toString().padLeft(2, '0')}h ${_minutes.toString().padLeft(2, '0')}m ${_seconds.toString().padLeft(2, '0')}s',
              style: GoogleFonts.baloo2(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
                shadows: const [
                  Shadow(
                    color: Colors.black45,
                    offset: Offset(0, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'ChamberOpoly',
              style: GoogleFonts.baloo2(
                fontSize: 22,
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
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _randomBusinessName != null
                  ? 'is brought to you by $_randomBusinessName'
                  : 'is brought to you by Chamber of Commerce',
              textAlign: TextAlign.center,
              style: GoogleFonts.baloo2(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
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
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                ),
              );
            }
            final user = userDoc.data() as Map<String, dynamic>;
            final String username = (user['username'] is String)
                ? user['username']
                : 'Friend';
            return FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Welcome Back, $username!',
                style: GoogleFonts.baloo2(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
          loading: () => FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Welcome Back',
              style: GoogleFonts.baloo2(
                fontSize: 52,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          error: (_, __) => FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Welcome Back',
              style: GoogleFonts.baloo2(
                fontSize: 52,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // Prevents back button on home
        toolbarHeight: 80,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final minSide = width < height ? width : height;

          // Responsive tile sizing - reverted to previous
          final tileSize = (minSide * 0.28).clamp(100.0, 160.0);
          // Radius adjustment - reverted to previous
          final radius = (minSide * 0.34).clamp(120.0, 200.0);
          final centerX = width / 2;

          // Calculate available vertical space more accurately
          final appBarHeight = 80.0;
          final bottomContentHeight = 160.0; // Compacted footer space
          final availableHeight = height - appBarHeight - bottomContentHeight;

          // Reverted center Y position
          final centerY = appBarHeight + (availableHeight / 2);

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
                      child: PentagonButton(
                        icon: items[i].icon,
                        label: items[i].label, // Fixed property name
                        onTap: items[i].onTap,
                        size: tileSize,
                      ),
                    ),
                  ],
                  // Countdown Timer and Footer at Bottom
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildCountdownTimer(),
                          const SizedBox(height: 16),
                          buildFooter(),
                          const SizedBox(height: 8),
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
}

class _PentagonItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _PentagonItem(this.icon, this.label, this.onTap);
}
