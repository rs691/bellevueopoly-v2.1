import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;
import 'package:geolocator/geolocator.dart';
import '../widgets/async_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/business_model.dart';
import '../providers/business_provider.dart';
import '../services/location_service.dart';
import '../utils/distance_calculator.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/search_bar.dart' as custom_search;

class StopHubScreen extends ConsumerStatefulWidget {
  const StopHubScreen({super.key});

  @override
  ConsumerState<StopHubScreen> createState() => _StopHubScreenState();
}

class _StopHubScreenState extends ConsumerState<StopHubScreen> {
  Position? _userPosition;
  Set<gmf.Marker> _markers = {};
  gmf.GoogleMapController? _mapController;
  bool _isLoadingLocation = true;
  String? _locationError;
  String _searchQuery = '';

  // Default to Bellevue, NE
  final gmf.LatLng _defaultLocation = const gmf.LatLng(41.15, -95.92);

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentPosition();
      if (mounted && position != null) {
        setState(() {
          _userPosition = position;
          _isLoadingLocation = false;
        });
        _updateMapCamera();
      } else if (mounted) {
        setState(() {
          _locationError = 'Unable to get location';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = e.toString();
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _updateMapCamera() {
    if (_mapController != null && _userPosition != null) {
      _mapController!.animateCamera(
        gmf.CameraUpdate.newLatLngZoom(
          gmf.LatLng(_userPosition!.latitude, _userPosition!.longitude),
          14.0,
        ),
      );
    }
  }

  void _updateMarkers(List<Business> businesses) {
    final markers = <gmf.Marker>{};

    if (_userPosition != null) {
      markers.add(
        gmf.Marker(
          markerId: const gmf.MarkerId('user_location'),
          position: gmf.LatLng(
            _userPosition!.latitude,
            _userPosition!.longitude,
          ),
          icon: gmf.BitmapDescriptor.defaultMarkerWithHue(
            gmf.BitmapDescriptor.hueAzure,
          ),
          infoWindow: const gmf.InfoWindow(title: 'Your Location'),
        ),
      );
    }

    for (final business in businesses) {
      if (business.latitude != 0.0 && business.longitude != 0.0) {
        markers.add(
          gmf.Marker(
            markerId: gmf.MarkerId(business.id),
            position: gmf.LatLng(business.latitude, business.longitude),
            icon: gmf.BitmapDescriptor.defaultMarkerWithHue(
              gmf.BitmapDescriptor.hueRed,
            ),
            infoWindow: gmf.InfoWindow(
              title: business.name,
              onTap: () => context.push('/business/${business.id}'),
            ),
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  Future<void> _refreshBusinesses() async {
    // Refresh the business list provider and user location
    await Future.wait([_getUserLocation()]);
    // Invalidate the provider to refetch data
    ref.invalidate(businessListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final businessListAsync = ref.watch(businessListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Rewards Nearby'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getUserLocation,
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: Column(
        children: [
          // Map on top with rounded card styling
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    gmf.GoogleMap(
                      initialCameraPosition: gmf.CameraPosition(
                        target: _userPosition != null
                            ? gmf.LatLng(
                                _userPosition!.latitude,
                                _userPosition!.longitude,
                              )
                            : _defaultLocation,
                        zoom: 13.0,
                      ),
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                    ),
                    if (_isLoadingLocation)
                      Container(
                        color: Colors.black26,
                        child: const Center(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 8),
                                  Text('Getting your location...'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_locationError != null && !_isLoadingLocation)
                      Positioned(
                        top: 8,
                        left: 8,
                        right: 8,
                        child: Card(
                          color: Colors.orange.shade100,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.orange),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Location unavailable. Showing default area.',
                                    style: const TextStyle(fontSize: 12),
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
            ),
          ),

          // Animated business list below map
          Expanded(
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: custom_search.SearchBar(
                    hintText: 'Search businesses...',
                    onChanged: (query) => setState(() => _searchQuery = query),
                    onClear: () => setState(() => _searchQuery = ''),
                  ),
                ),

                // Business list
                Expanded(
                  child: businessListAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text('Error loading businesses: $err'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.refresh(businessListProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                    data: (businesses) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _updateMarkers(businesses);
                      });

                      final items = businesses
                          .where((b) {
                            // Search filter
                            if (_searchQuery.isNotEmpty &&
                                !b.name.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                )) {
                              return false;
                            }
                            return b.latitude != 0.0 && b.longitude != 0.0;
                          })
                          .map((business) {
                            double? distance;
                            if (_userPosition != null) {
                              distance = DistanceCalculator.calculateDistance(
                                _userPosition!.latitude,
                                _userPosition!.longitude,
                                business.latitude,
                                business.longitude,
                              );
                            }
                            return _BusinessWithDistance(business, distance);
                          })
                          .toList();

                      if (_userPosition != null) {
                        items.sort((a, b) {
                          if (a.distance == null) return 1;
                          if (b.distance == null) return -1;
                          return a.distance!.compareTo(b.distance!);
                        });
                      }

                      if (items.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 64,
                                color: AppColors.lightGrey,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              const Text('No businesses match your search'),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _refreshBusinesses,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _BusinessDistanceCard(
                              business: item.business,
                              distance: item.distance,
                              userPosition: _userPosition,
                              onTap: () {
                                if (_mapController != null) {
                                  _mapController!.animateCamera(
                                    gmf.CameraUpdate.newLatLngZoom(
                                      gmf.LatLng(
                                        item.business.latitude,
                                        item.business.longitude,
                                      ),
                                      15.0,
                                    ),
                                  );
                                }
                                context.push('/business/${item.business.id}');
                              },
                              context: context,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

class _BusinessWithDistance {
  final Business business;
  final double? distance;

  _BusinessWithDistance(this.business, this.distance);
}

class _BusinessDistanceCard extends StatelessWidget {
  final Business business;
  final double? distance;
  final Position? userPosition;
  final VoidCallback onTap;
  final BuildContext context;

  const _BusinessDistanceCard({
    required this.business,
    required this.distance,
    required this.userPosition,
    required this.onTap,
    required this.context,
  });

  String _formatDistance(double? distanceInKm) {
    if (distanceInKm == null) return 'Distance unknown';
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)} m away';
    }
    return '${distanceInKm.toStringAsFixed(1)} km away';
  }

  Future<void> _openDirections() async {
    if (userPosition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Location not available')));
      return;
    }

    final url =
        'https://www.google.com/maps/dir/?api=1'
        '&origin=${userPosition!.latitude},${userPosition!.longitude}'
        '&destination=${business.latitude},${business.longitude}';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open directions')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening directions: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.purple.shade800, Colors.purple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Business Image/Icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AsyncImage(
                    imageUrl: business.heroImageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholderAsset: 'assets/images/restaurant_placeholder.png',
                  ),
                ),
                const SizedBox(width: 16),

                // Business Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        business.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        business.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),
                ),

                // Distance and direction
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.navigation,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDistance(distance),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _openDirections,
                      child: const Icon(
                        Icons.directions,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[700],
      child: Icon(Icons.store, size: 30, color: Colors.grey[400]),
    );
  }
}
