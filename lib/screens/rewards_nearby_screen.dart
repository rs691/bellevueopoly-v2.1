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

/// Screen that displays nearby businesses with rewards on a map
/// with a scrollable list below showing distances from user's location
class RewardsNearbyScreen extends ConsumerStatefulWidget {
  const RewardsNearbyScreen({super.key});

  @override
  ConsumerState<RewardsNearbyScreen> createState() =>
      _RewardsNearbyScreenState();
}

class _RewardsNearbyScreenState extends ConsumerState<RewardsNearbyScreen> {
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Available Rewards Nearby'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
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
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3d2b5e), // Lighter purple for center effect
              Color(0xFF2a1d4a), // Darker purple
            ],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              children: [
                // Business Icon/Image - smaller
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: AsyncImage(
                    imageUrl: business.heroImageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    placeholderAsset: 'assets/images/restaurant_placeholder.png',
                  ),
                ),
                const SizedBox(width: 12),

                // Business Name and Offer Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        business.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white, // White text
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'offer details',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70, // White text with opacity
                        ),
                      ),
                    ],
                  ),
                ),

                // Distance in miles/minutes
                Text(
                  _formatDistance(distance),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white, // White text
                  ),
                ),
                const SizedBox(width: 12),

                // Get Directions Icon
                GestureDetector(
                  onTap: _openDirections,
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white, // White icon
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
