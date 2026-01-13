import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/qr_scan.dart';
import '../widgets/glassmorphic_card.dart';
import 'package:google_fonts/google_fonts.dart';

final qrScansProvider = StreamProvider.autoDispose.family<List<QrScan>, String>((
  ref,
  playerId,
) {
  return FirebaseFirestore.instance
      .collection('scans')
      .where('user_id', isEqualTo: playerId)
      .snapshots()
      .map((snapshot) {
        final scans = snapshot.docs
            .map((doc) => QrScan.fromFirestore(doc))
            .toList();
        // Sort manually because combined queries without composite indexes might fail on some Firebase setups
        // and we want maximum robustness.
        scans.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
        return scans;
      });
});

class QrScanHistoryScreen extends ConsumerStatefulWidget {
  final String playerId;

  const QrScanHistoryScreen({super.key, required this.playerId});

  @override
  ConsumerState<QrScanHistoryScreen> createState() =>
      _QrScanHistoryScreenState();
}

class _QrScanHistoryScreenState extends ConsumerState<QrScanHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final qrScansAsync = ref.watch(qrScansProvider(widget.playerId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'QR Scan History',
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: qrScansAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, stack) => Center(
          child: Text(
            'Error loading history: $err',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        data: (scans) {
          if (scans.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No QR scans yet',
                      style: GoogleFonts.baloo2(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Scan QR codes at participating businesses to start earning points and climbing the leaderboard!',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: scans.length,
            itemBuilder: (context, index) {
              final scan = scans[index];
              final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

              return GlassmorphicCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    scan.businessName,
                    style: GoogleFonts.baloo2(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(scan.scannedAt),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                      if (scan.notes != null && scan.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            scan.notes!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+${scan.pointsEarned}',
                        style: GoogleFonts.baloo2(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      ),
                      const Text(
                        'PTS',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
