# Scan Tracking & Leaderboard Points System - Implementation Summary

## Overview

Enhanced the scan tracking system to capture detailed information about each scan (device, user, timestamp) and updated the leaderboard to rank users by total points earned rather than just visit counts.

## Changes Made

### 1. Enhanced Scan Tracking

**File:** [lib/screens/qr_scanner_overlay.dart](lib/screens/qr_scanner_overlay.dart)

#### Added Fields to Scan Documents:

Each scan in the `scans` collection now includes:

| Field | Type | Description |
|-------|------|-------------|
| `user_id` | String | Firebase user ID (existing) |
| `scanned_by` | String | User's email or display name |
| `scanned_by_username` | String | Shortened username for display |
| `business_id` | String | ID of the scanned business (existing) |
| `scanned_at` | Timestamp | Server timestamp of scan |
| `timestamp` | Timestamp | (Kept for backward compatibility) |
| `points_awarded` | int | Points earned from this scan (existing) |
| `device_info` | String | Device model (e.g., "Samsung Galaxy S21") |
| `device_id` | String | Unique device identifier |
| `platform` | String | Operating system (android, ios, windows, etc.) |

#### New Dependency:

Added `device_info_plus: ^11.1.1` to [pubspec.yaml](pubspec.yaml) for device detection.

#### Example Scan Document:

```json
{
  "user_id": "abc123xyz",
  "scanned_by": "john.doe@example.com",
  "scanned_by_username": "john.doe",
  "business_id": "starbucks_bellevue",
  "scanned_at": "2026-01-05T14:30:00Z",
  "timestamp": "2026-01-05T14:30:00Z",
  "points_awarded": 100,
  "device_info": "Samsung Galaxy S21",
  "device_id": "abc123device456",
  "platform": "android"
}
```

### 2. Points-Based Leaderboard

#### Updated Files:

1. **[lib/models/player.dart](lib/models/player.dart)**
   - Added `totalPoints` field to track cumulative points
   - Updated `fromJson`, `toJson`, `copyWith`, and `props` methods

2. **[lib/services/firestore_service.dart](lib/services/firestore_service.dart)**
   - Changed `getTopPlayersStream()` to sort by `total_points` (descending)
   - Updated `addUser()` to initialize `total_points: 0` for new users
   - Updated error handling to include `totalPoints`

3. **[lib/screens/leaderboard_screen.dart](lib/screens/leaderboard_screen.dart)**
   - Updated UI to display points prominently
   - Shows both points (primary) and visits (secondary)
   - Points displayed in green with larger font

#### Leaderboard Display:

```
#1 🥇 john_doe
   5 visits
   → 500 Points

#2 🥈 jane_smith  
   3 visits
   → 300 Points
```

### 3. Points Recalculation Script

**File:** [scripts/recalculate_points.dart](scripts/recalculate_points.dart)

A maintenance script to recalculate total points for all users based on their scan history.

#### Features:
- ✅ Reads all scans from Firestore
- ✅ Groups by user and sums points
- ✅ Updates `total_points` and `totalVisits` for each user
- ✅ Handles users with no scans (sets to 0)
- ✅ Provides detailed progress output
- ✅ Generates summary report

#### Usage:

```bash
# Run the recalculation script
dart run scripts/recalculate_points.dart

# Or with Flutter
flutter run -t scripts/recalculate_points.dart
```

See [scripts/README_RECALCULATE.md](scripts/README_RECALCULATE.md) for full documentation.

## Database Schema Changes

### Users Collection

**New/Updated Fields:**

```javascript
{
  "username": "john_doe",
  "email": "john.doe@example.com",
  "createdAt": Timestamp,
  "totalVisits": 5,           // Count of scans (existing, recalculated)
  "total_points": 500,        // NEW: Sum of points from all scans
  "propertiesOwned": [],
  "trophies": []
}
```

### Scans Collection

**Enhanced Structure:**

```javascript
{
  "user_id": "abc123xyz",              // Existing
  "business_id": "starbucks_bellevue", // Existing
  "timestamp": Timestamp,              // Existing
  "points_awarded": 100,               // Existing
  "scanned_by": "john.doe@example.com",        // NEW
  "scanned_by_username": "john.doe",           // NEW
  "scanned_at": Timestamp,                     // NEW
  "device_info": "Samsung Galaxy S21",         // NEW
  "device_id": "abc123device456",              // NEW
  "platform": "android"                        // NEW
}
```

## Firestore Index Required

For optimal leaderboard performance, create this index:

**Collection:** `users`

| Field | Order |
|-------|-------|
| `total_points` | Descending |

Firebase Console will prompt you to create this when first querying.

## Migration Steps

### For Existing Data:

1. **Install new dependency:**
   ```bash
   flutter pub get
   ```

2. **Run recalculation script:**
   ```bash
   dart run scripts/recalculate_points.dart
   ```

3. **Verify in Firebase Console:**
   - Check that users have `total_points` field
   - Verify leaderboard sorts correctly
   - Confirm new scans include device info

### For New Users:

No action needed - new users automatically get `total_points: 0` on registration.

## Testing Checklist

- [ ] Install packages: `flutter pub get`
- [ ] Run app and create a test scan
- [ ] Verify scan document includes all new fields
- [ ] Check device_info contains correct device model
- [ ] Run recalculation script
- [ ] Open leaderboard and confirm sorting by points
- [ ] Verify points display correctly
- [ ] Create another scan and check points increment

## Benefits

### 1. **Better Scan Tracking**
   - Know exactly who scanned, when, and from what device
   - Useful for analytics and fraud detection
   - Helps troubleshoot user issues

### 2. **Fair Leaderboard**
   - Ranks by points, not just visits
   - Reflects actual achievement (some businesses award more points)
   - More engaging for competitive users

### 3. **Data Integrity**
   - Script can recalculate points if they get out of sync
   - Backup mechanism for point totals
   - Easy to audit and verify

## Future Enhancements

Consider these additional features:

1. **Scan History Screen**
   - Show users their scan history with timestamps and devices
   - Display which device was used for each scan

2. **Admin Dashboard**
   - View scans in real-time
   - Filter by user, device, date range
   - Export scan data for analytics

3. **Fraud Detection**
   - Alert if same device scans multiple businesses too quickly
   - Flag suspicious patterns

4. **Device Management**
   - Let users see all devices they've scanned from
   - Option to revoke/remove old devices

## Files Modified

- ✏️ [pubspec.yaml](pubspec.yaml) - Added device_info_plus
- ✏️ [lib/screens/qr_scanner_overlay.dart](lib/screens/qr_scanner_overlay.dart) - Enhanced scan tracking
- ✏️ [lib/models/player.dart](lib/models/player.dart) - Added totalPoints field
- ✏️ [lib/services/firestore_service.dart](lib/services/firestore_service.dart) - Updated queries
- ✏️ [lib/screens/leaderboard_screen.dart](lib/screens/leaderboard_screen.dart) - Updated UI

## Files Created

- ✨ [scripts/recalculate_points.dart](scripts/recalculate_points.dart) - Recalculation script
- ✨ [scripts/README_RECALCULATE.md](scripts/README_RECALCULATE.md) - Script documentation

---

**Implementation Date:** January 5, 2026  
**Status:** ✅ Complete and Ready to Deploy
