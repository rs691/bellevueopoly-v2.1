# Available Rewards Nearby Feature

## Overview
This feature provides users with a map-based view of nearby businesses offering rewards, along with a scrollable list showing distances from the user's current location.

## Files Created/Modified

### New Files Created:

1. **`lib/screens/rewards_nearby_screen.dart`**
   - Main screen that displays the map and business list
   - Shows user's location on the map with a blue marker
   - Displays businesses with red markers
   - List below the map shows businesses sorted by distance
   - Includes distance calculation and display

2. **`lib/utils/distance_calculator.dart`**
   - Utility class for calculating distances between coordinates
   - Uses the Haversine formula for accurate distance calculation
   - Supports both kilometers and miles
   - Includes formatting utilities

### Modified Files:

1. **`lib/router/app_router.dart`**
   - Added `rewardsNearby` route constant
   - Imported `RewardsNearbyScreen`
   - Added route configuration in the shell routes

2. **`lib/screens/casual_games_lobby_screen.dart`**
   - Added "Available Rewards Nearby" tile as the first item in the grid
   - Updated `_GameTile` widget to support optional color parameter
   - Linked the tile to the new rewards nearby screen

## Features Implemented

### 1. **Map Display**
- Google Maps integration showing business locations
- User's current location marked with blue pin
- Business locations marked with red pins
- Tap on markers to see business info
- "My Location" button to refresh user's position

### 2. **Location Services**
- Automatic location permission request
- Handles location service disabled scenarios
- Graceful fallback to default location (Bellevue, NE)
- Loading indicator while fetching location
- Error messages for permission/service issues

### 3. **Business List**
- Scrollable list below the map (60% of screen)
- Each card shows:
  - Business image (or placeholder)
  - Business name
  - Category
  - Address
  - Distance from user (in km/m)
- Color-coded distance badges:
  - Green for businesses < 1 km away
  - Blue for businesses farther away
- Sorted by proximity (closest first)
- Tap card to view business details
- Tapping card also animates map to that business location

### 4. **Distance Calculation**
- Real-time distance calculation using Haversine formula
- Accurate Earth-surface distance (not straight line)
- Displays in meters for < 1 km, kilometers for >= 1 km
- Updates when user location changes

## How to Use

### For Users:
1. Navigate to "Casual Game" from the main menu
2. Tap "Available Rewards Nearby" tile
3. Grant location permission when prompted
4. View businesses on map and in list
5. Tap any business to see details
6. Use "My Location" button to refresh your position

### For Developers:

#### Adding More Features:
```dart
// Filter businesses by category
final filteredBusinesses = businesses
    .where((b) => b.category == 'Restaurant')
    .toList();

// Add search functionality
TextFormField(
  onChanged: (query) {
    // Filter businesses by name
  },
)

// Add radius filter
final nearbyBusinesses = businesses.where((b) {
  final distance = DistanceCalculator.calculateDistance(
    userLat, userLng, b.latitude, b.longitude,
  );
  return distance <= 5.0; // Within 5 km
}).toList();
```

#### Using the Distance Calculator:
```dart
import '../utils/distance_calculator.dart';

// Calculate distance
double distance = DistanceCalculator.calculateDistance(
  lat1, lon1, lat2, lon2,
);

// Format for display
String formatted = DistanceCalculator.formatDistance(distance);
// Output: "1.2 km" or "850 m"

// Check if within radius
bool isNearby = DistanceCalculator.isWithinRadius(
  lat1, lon1, lat2, lon2, 
  5.0, // 5 km radius
);

// Convert to miles
double miles = DistanceCalculator.calculateDistanceInMiles(
  lat1, lon1, lat2, lon2,
);
```

#### Using Location Service:
```dart
import '../services/location_service.dart';

// Get current position
final locationService = LocationService();
final position = await locationService.getCurrentPosition();

if (position != null) {
  print('Lat: ${position.latitude}, Lng: ${position.longitude}');
}

// Listen to position updates
locationService.getPositionStream().listen((position) {
  // Update UI with new position
});
```

## Technical Details

### Dependencies Used:
- `google_maps_flutter` - Map display
- `geolocator` - Location services
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `cloud_firestore` - Business data (via existing provider)

### Map Configuration:
- Initial zoom: 13.0
- Camera updates when user location found
- Default location: Bellevue, NE (41.15, -95.92)
- Map occupies top 40% of screen
- List occupies bottom 60% of screen

### Business Data:
- Pulled from Firestore via `businessListProvider`
- Uses existing `Business` model with lat/lng fields
- Filters out businesses with 0.0 coordinates
- Real-time updates when business data changes

### Performance Considerations:
- Efficient marker updates using setState
- Distance calculations only performed when data loads
- Cached business images
- Lazy loading for list items

## Navigation Flow

```
Main Menu
  └─> Casual Game (MobileLandingScreen)
       └─> Arcade Games (CasualGamesLobbyScreen)
            └─> Available Rewards Nearby (RewardsNearbyScreen)
                 └─> Business Detail (BusinessDetailScreen)
```

## Route Configuration

```dart
// In app_router.dart
static const String rewardsNearby = '/rewards-nearby';

// Route definition
GoRoute(
  path: AppRoutes.rewardsNearby,
  builder: (context, state) => const RewardsNearbyScreen(),
),
```

## Permissions Required

### Android (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby businesses with rewards.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to show nearby businesses with rewards.</string>
```

## Future Enhancements

1. **Filtering Options**
   - Filter by category (restaurants, shops, etc.)
   - Filter by distance radius
   - Search by business name

2. **Map Enhancements**
   - Custom marker icons for different categories
   - Cluster markers when zoomed out
   - Route directions to selected business

3. **List Enhancements**
   - Pull-to-refresh
   - Infinite scroll for large datasets
   - Favorite/bookmark businesses

4. **User Experience**
   - Toggle between list/grid view
   - Toggle between km/miles
   - Save preferred radius setting
   - Background location tracking for notifications

5. **Rewards Integration**
   - Show active promotions on cards
   - Filter by available rewards
   - Show points/rewards earned at each location

## Troubleshooting

### Location not working:
1. Check device location services are enabled
2. Check app has location permission
3. On iOS, check Info.plist has required keys
4. On Android, check AndroidManifest.xml permissions

### Businesses not showing:
1. Check Firestore connection
2. Verify businesses have valid lat/lng coordinates
3. Check businessListProvider is working
4. Look for errors in debug console

### Map not loading:
1. Check Google Maps API key is configured
2. Verify API key has Maps SDK enabled
3. Check network connectivity
4. Look for API errors in console

## Testing

### Test Cases:
1. ✅ Screen loads with map and list
2. ✅ User location is requested and displayed
3. ✅ Businesses appear as markers on map
4. ✅ List shows businesses with distances
5. ✅ Tapping business card navigates to detail screen
6. ✅ Tapping marker shows business info
7. ✅ My Location button refreshes position
8. ✅ Graceful handling of location permission denial
9. ✅ Graceful handling of location service disabled
10. ✅ List sorted by proximity when location available

### Manual Testing:
```bash
# Run the app
flutter run

# Test location permissions
# 1. Deny permission - should show default location
# 2. Grant permission - should show user location
# 3. Disable location services - should show error message

# Test business interactions
# 1. Tap business card - should navigate to detail
# 2. Tap map marker - should show info window
# 3. Scroll list - should remain smooth

# Test refresh
# 1. Tap my location button - should re-center map
```

## Code Quality

- ✅ Null safety enabled
- ✅ Proper error handling
- ✅ Loading states implemented
- ✅ Clean widget separation
- ✅ Reusable components
- ✅ Documentation comments
- ✅ Consistent naming conventions
- ✅ Follows Flutter best practices

## Summary

The "Available Rewards Nearby" feature successfully integrates:
- Real-time location services
- Google Maps display with custom markers
- Distance calculation and sorting
- Business data from Firestore
- Smooth navigation and UX
- Proper error handling and edge cases

The implementation is production-ready and can be extended with additional features as needed.
