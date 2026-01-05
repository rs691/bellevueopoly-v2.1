import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// Script to recalculate total_points for all users based on their scans
/// 
/// This script:
/// 1. Fetches all scans from the 'scans' collection
/// 2. Groups scans by user_id
/// 3. Calculates total points per user
/// 4. Updates each user's total_points field
/// 
/// Usage: dart run scripts/recalculate_points.dart

Future<void> main() async {
  print('🚀 Starting points recalculation...\n');

  try {
    // Initialize Firebase using the app's configuration
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.web,
    );
    print('✅ Firebase initialized\n');
  } catch (e) {
    print('⚠️  Firebase already initialized or error: $e\n');
  }

  final db = FirebaseFirestore.instance;

  try {
    // Step 1: Fetch all scans
    print('📊 Fetching all scans...');
    final scansSnapshot = await db.collection('scans').get();
    print('✅ Found ${scansSnapshot.docs.length} scans\n');

    if (scansSnapshot.docs.isEmpty) {
      print('ℹ️  No scans found. Nothing to recalculate.');
      exit(0);
    }

    // Step 2: Group scans by user_id and calculate total points
    Map<String, int> userPoints = {};
    Map<String, int> userVisits = {};

    for (var scanDoc in scansSnapshot.docs) {
      final data = scanDoc.data();
      final userId = data['user_id'] as String?;
      final pointsAwarded = data['points_awarded'];

      if (userId == null) {
        print('⚠️  Scan ${scanDoc.id} has no user_id, skipping...');
        continue;
      }

      // Parse points safely
      int points = 100; // default
      if (pointsAwarded is int) {
        points = pointsAwarded;
      } else if (pointsAwarded is String) {
        points = int.tryParse(pointsAwarded) ?? 100;
      }

      // Accumulate points
      userPoints[userId] = (userPoints[userId] ?? 0) + points;
      userVisits[userId] = (userVisits[userId] ?? 0) + 1;
    }

    print('📈 Calculated points for ${userPoints.length} users\n');

    // Step 3: Update each user's total_points
    print('💾 Updating user records...\n');
    
    int successCount = 0;
    int errorCount = 0;

    for (var entry in userPoints.entries) {
      final userId = entry.key;
      final points = entry.value;
      final visits = userVisits[userId] ?? 0;

      try {
        // Check if user exists
        final userDoc = await db.collection('users').doc(userId).get();
        
        if (!userDoc.exists) {
          print('⚠️  User $userId does not exist, skipping...');
          errorCount++;
          continue;
        }

        // Update user's total_points and totalVisits
        await db.collection('users').doc(userId).update({
          'total_points': points,
          'totalVisits': visits,
        });

        final username = userDoc.data()?['username'] ?? 'Unknown';
        print('✅ Updated $username ($userId): $points points, $visits visits');
        successCount++;
      } catch (e) {
        print('❌ Error updating user $userId: $e');
        errorCount++;
      }
    }

    // Step 4: Handle users with no scans (set their points to 0)
    print('\n🔍 Checking for users with no scans...');
    final usersSnapshot = await db.collection('users').get();
    int zeroPointsCount = 0;

    for (var userDoc in usersSnapshot.docs) {
      final userId = userDoc.id;
      
      if (!userPoints.containsKey(userId)) {
        try {
          await db.collection('users').doc(userId).update({
            'total_points': 0,
            'totalVisits': 0,
          });
          final username = userDoc.data()['username'] ?? 'Unknown';
          print('✅ Set $username ($userId) to 0 points (no scans)');
          zeroPointsCount++;
        } catch (e) {
          print('❌ Error updating user $userId: $e');
          errorCount++;
        }
      }
    }

    // Summary
    print('\n' + '=' * 50);
    print('📊 RECALCULATION SUMMARY');
    print('=' * 50);
    print('Total scans processed: ${scansSnapshot.docs.length}');
    print('Users with scans: ${userPoints.length}');
    print('Users successfully updated: $successCount');
    print('Users set to 0 points: $zeroPointsCount');
    print('Errors: $errorCount');
    print('=' * 50);
    print('\n✨ Points recalculation complete!');

  } catch (e, stack) {
    print('❌ Fatal error during recalculation: $e');
    print('Stack trace: $stack');
    exit(1);
  }

  exit(0);
}
