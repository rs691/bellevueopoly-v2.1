# Points Recalculation Script

## Overview

This script recalculates `total_points` for all users based on their scan history in the Firestore database.

## What It Does

1. **Fetches all scans** from the `scans` collection
2. **Groups scans by user** to calculate each user's total points
3. **Updates user records** with accurate `total_points` and `totalVisits`
4. **Handles edge cases** like users with no scans (sets their points to 0)

## When to Run

Run this script when:
- You've added the new `total_points` field and need to populate existing data
- You suspect point totals are out of sync
- After migrating or importing data
- As a maintenance task to ensure data integrity

## Prerequisites

- Flutter environment set up
- Firebase project configured
- Internet connection to access Firestore

## How to Run

### Option 1: Using Dart directly

```bash
dart run scripts/recalculate_points.dart
```

### Option 2: Using Flutter

```bash
flutter run -t scripts/recalculate_points.dart
```

## What to Expect

The script will output progress information:

```
🚀 Starting points recalculation...

✅ Firebase initialized

📊 Fetching all scans...
✅ Found 156 scans

📈 Calculated points for 23 users

💾 Updating user records...

✅ Updated john_doe (abc123): 500 points, 5 visits
✅ Updated jane_smith (def456): 300 points, 3 visits
...

🔍 Checking for users with no scans...
✅ Set new_user (xyz789) to 0 points (no scans)

==================================================
📊 RECALCULATION SUMMARY
==================================================
Total scans processed: 156
Users with scans: 23
Users successfully updated: 23
Users set to 0 points: 2
Errors: 0
==================================================

✨ Points recalculation complete!
```

## Data Changes

The script updates the following fields in the `users` collection:

- `total_points` - Sum of all `points_awarded` from user's scans
- `totalVisits` - Count of scans (check-ins) by the user

## Safety

- ✅ **Read-only on scans**: Only reads from the `scans` collection
- ✅ **Updates only users**: Only modifies the `users` collection
- ✅ **Non-destructive**: Updates existing fields without removing data
- ✅ **Idempotent**: Safe to run multiple times with the same result

## Troubleshooting

### Error: Firebase not initialized

Make sure your `firebase_options.dart` file exists and contains valid credentials.

### Error: Permission denied

Ensure your Firestore security rules allow read/write access for the script. You may need to temporarily adjust rules or run as an authenticated admin.

### No scans found

If the script reports 0 scans, check that:
- You're connected to the correct Firebase project
- The `scans` collection exists and has documents
- Your Firestore rules allow reading the `scans` collection

## Firestore Collections Used

### Read From:
- `scans` - All scan records with `user_id` and `points_awarded`
- `users` - To verify users exist before updating

### Writes To:
- `users` - Updates `total_points` and `totalVisits` fields

## Firestore Index Required

Since the leaderboard now sorts by `total_points`, you may need to create a composite index:

**Collection:** `users`
**Fields:**
- `total_points` - Descending
- (Any other fields used in queries)

Firebase will prompt you to create this index when you first query the leaderboard.

## Related Files

- [lib/models/player.dart](../lib/models/player.dart) - Player model with `totalPoints` field
- [lib/services/firestore_service.dart](../lib/services/firestore_service.dart) - Leaderboard query using `total_points`
- [lib/screens/leaderboard_screen.dart](../lib/screens/leaderboard_screen.dart) - Leaderboard UI showing points
- [lib/screens/qr_scanner_overlay.dart](../lib/screens/qr_scanner_overlay.dart) - Scan creation with enhanced metadata
