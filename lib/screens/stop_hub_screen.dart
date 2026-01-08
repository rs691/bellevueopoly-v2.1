import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;

import '../models/business_model.dart';
import '../providers/config_provider.dart';
import '../providers/business_provider.dart';
import '../router/app_router.dart';

class StopHubScreen extends ConsumerStatefulWidget {
  const StopHubScreen({super.key});

  @override
  ConsumerState<StopHubScreen> createState() => _StopHubScreenState();
}

class _StopHubScreenState extends ConsumerState<StopHubScreen> {
  Set<gmf.Marker> _markers = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cityConfigAsync = ref.watch(cityConfigProvider);

    // Mirror home screen marker handling
    ref.listen<AsyncValue<List<Business>>>(businessesProvider, (previous, next) {
      next.whenData((businesses) {
        setState(() {
          _markers = businesses
              .where((b) => b.latitude != 0.0 && b.longitude != 0.0)
              .map((business) => gmf.Marker(
                    markerId: gmf.MarkerId(business.id),
                    position: gmf.LatLng(business.latitude, business.longitude),
                    infoWindow: gmf.InfoWindow(
                      title: business.name,
                      onTap: () => context.push('/business/${business.id}'),
                    ),
                    onTap: () => context.push('/business/${business.id}'),
                  ))
              .toSet();
        });
      });
    });

    const double defaultLat = 41.15;
    const double defaultLng = -95.92;
    const double defaultZoom = 13.0;

    final categories = <_CategoryBoxData>[
      _CategoryBoxData('Boulevard Partners', Icons.business, AppRoutes.boulevardPartners),
      _CategoryBoxData('Patriotic Partners', Icons.flag, AppRoutes.patrioticPartners),
      _CategoryBoxData('Merch Partners', Icons.shopping_bag, AppRoutes.merchPartners),
      _CategoryBoxData('Giving Partners', Icons.volunteer_activism, AppRoutes.givingPartners),
      _CategoryBoxData('Community Chest', Icons.card_giftcard, AppRoutes.communityChest),
      _CategoryBoxData('Wild Cards', Icons.casino, AppRoutes.wildCards),
      _CategoryBoxData('Fun House', Icons.celebration, AppRoutes.funHouse),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('STOP HUB'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: cityConfigAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading city: $err')),
        data: (cityConfig) {
          final initialPosition = gmf.LatLng(defaultLat, defaultLng);

          return Stack(
            children: [
              gmf.GoogleMap(
                initialCameraPosition: gmf.CameraPosition(
                  target: initialPosition,
                  zoom: defaultZoom,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                padding: const EdgeInsets.only(bottom: 150),
              ),
              Positioned(
                bottom: 96,
                left: 0,
                right: 0,
                child: _buildCategoryList(categories),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryList(List<_CategoryBoxData> categories) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final item = categories[index];
          return _CategoryCard(data: item);
        },
      ),
    );
  }
}

class _CategoryBoxData {
  final String title;
  final IconData icon;
  final String route;

  const _CategoryBoxData(this.title, this.icon, this.route);
}

class _CategoryCard extends StatelessWidget {
  final _CategoryBoxData data;

  const _CategoryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go(data.route),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(data.icon, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to explore',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
