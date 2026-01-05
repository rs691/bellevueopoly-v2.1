# Quick Start Guide - Enhanced Scan Tracking & Points System

## What's New? 🎉

Your app now tracks detailed scan information and ranks users by total points!

## Immediate Next Steps

### 1. Run the Recalculation Script ⚡

Since you have existing data, run this script to populate the `total_points` field for all existing users:

```bash
dart run scripts/recalculate_points.dart
```

This will:
- Calculate total points from all existing scans
- Update all user records with accurate point totals
- Set users with no scans to 0 points

### 2. Test a New Scan 📱

1. Launch your app
2. Scan a QR code at a business
3. Check Firebase Console → Firestore → `scans` collection
4. Verify the scan document includes:
   - `scanned_by` (your email)
   - `device_info` (your device model)
   - `device_id` (unique device ID)
   - `platform` (android/ios/windows/etc)
   - `scanned_at` (timestamp)

### 3. Check the Leaderboard 🏆

1. Navigate to the Leaderboard screen
2. Users should be sorted by points (not visits)
3. Each entry shows:
   - Rank (#1, #2, etc.)
   - Username
   - Visit count (smaller, subtitle)
   - **Points** (large, green, prominent)

## What Each Scan Now Records

Every scan creates a document like this:

```json
{
  "user_id": "abc123",
  "scanned_by": "john@example.com",
  "scanned_by_username": "john",
  "business_id": "starbucks_bellevue",
  "scanned_at": "2026-01-05T14:30:00Z",
  "points_awarded": 100,
  "device_info": "Samsung Galaxy S21",
  "device_id": "unique-device-id",
  "platform": "android"
}
```

## Leaderboard Changes

**Before:** Sorted by visit count
```
#1 Alice - 10 visits
#2 Bob - 8 visits
```

**After:** Sorted by total points
```
#1 Alice - 1,500 Points (10 visits)
#2 Bob - 1,200 Points (8 visits)
```

Now if different businesses award different points, the leaderboard reflects total achievement!

## Firebase Console Setup

### Create Index (if prompted)

When you first view the leaderboard, Firebase may prompt you to create an index. Click the link or manually create:

**Collection:** `users`  
**Fields to index:**
- `total_points` (Descending)

## Troubleshooting

### Script fails with "Permission denied"

Update your Firestore rules to allow the script to read/write:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /scans/{scanId} {
      allow read: if request.auth != null;
    }
    match /users/{userId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Leaderboard shows 0 points for everyone

Run the recalculation script:
```bash
dart run scripts/recalculate_points.dart
```

### Device info shows "Unknown Device"

This is normal for:
- Simulators/emulators
- Web platform (browser doesn't expose device info)
- Platforms with restricted permissions

Real devices should show proper model names.

## Viewing Scan Data

### In Firebase Console:

1. Go to Firestore Database
2. Open `scans` collection
3. Click any scan document
4. See all the metadata!

### Useful Queries:

Find all scans by a user:
```javascript
db.collection('scans')
  .where('user_id', '==', 'user123')
  .orderBy('scanned_at', 'desc')
  .get()
```

Find scans from a specific device:
```javascript
db.collection('scans')
  .where('device_id', '==', 'device456')
  .get()
```

## Benefits You Get

1. **Better Analytics** 📊
   - See which devices your users prefer
   - Track scan patterns by time/location
   - Identify potential fraud (same device, multiple accounts)

2. **Fair Competition** 🏆
   - Points reflect actual achievement
   - Encourages visiting high-value businesses
   - More engaging leaderboard

3. **Debugging Help** 🐛
   - "When did I scan this?" → Check `scanned_at`
   - "Did my friend scan?" → Check `scanned_by`
   - "Which phone was used?" → Check `device_info`

4. **Data Integrity** ✅
   - Recalculation script can fix point totals
   - Audit trail for every scan
   - Easy to verify user claims

## Files to Review

📄 **Implementation Summary:** [SCAN_TRACKING_IMPLEMENTATION.md](SCAN_TRACKING_IMPLEMENTATION.md)  
📄 **Script Documentation:** [scripts/README_RECALCULATE.md](scripts/README_RECALCULATE.md)  
📄 **This Guide:** You're reading it! 😊

## Questions?

- **How often should I run the recalculation script?**  
  Only when points seem wrong or after data migration. Normal scans update points automatically.

- **Will old scans work with new code?**  
  Yes! The code handles missing fields gracefully. Old scans just won't have device info.

- **Can users see their own scans?**  
  Not yet - but you could build a "My Scans" screen showing their history!

---

**Need Help?** Check [SCAN_TRACKING_IMPLEMENTATION.md](SCAN_TRACKING_IMPLEMENTATION.md) for full technical details.
