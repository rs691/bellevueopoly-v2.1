import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/stat_card.dart';
import '../router/app_router.dart';
import '../theme/app_spacing.dart';
import '../providers/user_data_provider.dart';

class MobileLandingScreen extends ConsumerWidget {
  const MobileLandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(userDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Back'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Prevents back button on home
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final minSide = width < height ? width : height;
          // Tile size scales but stays small enough to fit - increased size
          final tileSize = (minSide * 0.22).clamp(110.0, 180.0);
          final radius = (minSide * 0.32);
          final centerX = width / 2;
          final centerY = height / 2;

          List<_PentagonItem> items = [
            _PentagonItem(
              Icons.star,
              'Stop Hub',
              () => context.go(AppRoutes.stopHub),
            ),
            _PentagonItem(
              Icons.location_on,
              'Near Me',
              () => context.go(AppRoutes.nearMe),
            ),
            _PentagonItem(
              Icons.emoji_events,
              'Prizes',
              () => context.go(AppRoutes.prizes),
            ),
            _PentagonItem(
              Icons.help,
              'FAQs',
              () => context.go(AppRoutes.rulesAndPrizes),
            ),
            _PentagonItem(
              Icons.person,
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
                  for (int i = 0; i < items.length; i++) ...[
                    _positionedPentagon(
                      index: i,
                      count: items.length,
                      centerX: centerX,
                      centerY: centerY,
                      radius: radius,
                      tileSize: tileSize,
                      child: _buildTile(items[i], tileSize),
                    ),
                  ],
                  // Optional quick stats row near bottom (kept minimal)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 16,
                    child: userDataAsync.when(
                      data: (userDoc) {
                        if (userDoc == null || !userDoc.exists) {
                          return const SizedBox.shrink();
                        }
                        final user = userDoc.data() as Map<String, dynamic>;
                        return _buildQuickStats(context, user);
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
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

  Widget _buildQuickStats(BuildContext context, Map<String, dynamic> user) {
    final int points = (user['points'] as num?)?.toInt() ?? 0;
    final int visits = (user['visits'] as num?)?.toInt() ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: MiniStat(
              label: 'Points',
              value: points.toString(),
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: MiniStat(
              label: 'Visits',
              value: visits.toString(),
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(_PentagonItem item, double tileSize) {
    return SizedBox(
      width: tileSize,
      height: tileSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Glassmorphism background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
            // Frosted glass effect
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            // Interactive overlay
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(20),
                splashColor: Colors.white.withOpacity(0.3),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: tileSize * 0.40,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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

Positioned _positionedPentagon({
  required int index,
  required int count,
  required double centerX,
  required double centerY,
  required double radius,
  required double tileSize,
  required Widget child,
}) {
  // Distribute evenly around a circle, start at top (-90 degrees)
  final double angleDeg = -90 + (360 / count) * index;
  final double angleRad = angleDeg * math.pi / 180.0;
  final double x = centerX + radius * math.cos(angleRad) - tileSize / 2;
  final double y = centerY + radius * math.sin(angleRad) - tileSize / 2;
  return Positioned(left: x, top: y, child: child);
}
