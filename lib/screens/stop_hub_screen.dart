import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../router/app_router.dart';
import '../models/business_model.dart';
import '../providers/business_provider.dart';
import '../widgets/async_image.dart';
import '../widgets/pentagon_button.dart';

class StopHubScreen extends ConsumerStatefulWidget {
  const StopHubScreen({super.key});

  @override
  ConsumerState<StopHubScreen> createState() => _StopHubScreenState();
}

class _StopHubScreenState extends ConsumerState<StopHubScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch the provider for business list
    final businessListAsync = ref.watch(businessListProvider);

    // Helper function to build positioned pentagon (n-gon)
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

    List<_PentagonItem> items = [
      _PentagonItem(
        Icons.business,
        'Boulevard Partners',
        () => context.go(AppRoutes.boulevardPartners),
      ),
      _PentagonItem(
        Icons.flag,
        'Patriotic Partners',
        () => context.go(AppRoutes.patrioticPartners),
      ),
      _PentagonItem(
        Icons.shopping_bag,
        'Merch Partners',
        () => context.go(AppRoutes.merchPartners),
      ),
      _PentagonItem(
        Icons.volunteer_activism,
        'Giving Partners',
        () => context.go(AppRoutes.givingPartners),
      ),
      _PentagonItem(
        Icons.card_giftcard,
        'Community Chest',
        () => context.go(AppRoutes.communityChest),
      ),
      _PentagonItem(
        Icons.casino,
        'Wild Cards',
        () => context.go(AppRoutes.wildCards),
      ),
      _PentagonItem(
        Icons.celebration,
        'Fun House',
        () => context.go(AppRoutes.funHouse),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Stop Hub',
          style: GoogleFonts.baloo2(fontSize: 38, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
      ),
      body: CustomScrollView(
        slivers: [
          // Pentagon Navigation Section
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.55, // Take up top portion
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;
                  final minSide = width < height ? width : height;
                  
                  // UPDATED: Match MobileLandingScreen size (0.26)
                  final tileSize = (minSide * 0.26).clamp(100.0, 200.0);
                  
                  // Adjusted radius to fit within the fixed height container
                  final radius = (minSide * 0.34); 
                  final centerX = width / 2;
                  final centerY = height / 2;

                  return Center(
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: Stack(
                        children: [
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
                                label: items[i].label,
                                onTap: items[i].onTap,
                                size: tileSize,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Business List Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Explore Businesses',
                style: GoogleFonts.baloo2(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Business List
          businessListAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
            ),
            data: (businesses) {
              if (businesses.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('No businesses found', style: TextStyle(color: Colors.white))),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final business = businesses[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: _BusinessCard(
                        business: business,
                        onTap: () => context.push('/business/${business.id}'),
                      ),
                    );
                  },
                  childCount: businesses.length,
                ),
              );
            },
          ),
          
          // Bottom padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
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

class _BusinessCard extends StatelessWidget {
  final Business business;
  final VoidCallback onTap;

  const _BusinessCard({
    required this.business,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3d2b5e), // Lighter purple
              Color(0xFF2a1d4a), // Darker purple
            ],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Row(
              children: [
                // Business Icon/Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AsyncImage(
                    imageUrl: business.heroImageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholderAsset: 'assets/icons/heart_outline.png',
                  ),
                ),
                const SizedBox(width: 16),

                // Business Name and Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        business.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        business.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Chevron Icon
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.white54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
