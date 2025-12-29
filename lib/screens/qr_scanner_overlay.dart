import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/analytics_service.dart';

class QRScannerOverlay extends StatefulWidget {
  final String? businessId;
  final String? correctSecret;
  final int? pointsToAward;

  const QRScannerOverlay({
    super.key,
    this.businessId,
    this.correctSecret,
    this.pointsToAward,
  });

  @override
  State<QRScannerOverlay> createState() => _QRScannerOverlayState();
}

class _QRScannerOverlayState extends State<QRScannerOverlay> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  Future<void> _handleScan(String scannedValue) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    controller.stop(); // Pause scanner immediately

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
        if (mounted) setState(() => _isProcessing = false);
        return;
    }

    try {
      final db = FirebaseFirestore.instance;
      String targetBusinessId;
      int points = widget.pointsToAward ?? 100;

      // Mode A: Direct Verification (Business ID provided)
      if (widget.businessId != null && widget.correctSecret != null) {
        if (scannedValue != widget.correctSecret) {
          throw 'Invalid QR Code for this business.';
        }
        targetBusinessId = widget.businessId!;
      } 
      // Mode B: Generic Verification (Lookup by Secret)
      else {
        final querySnapshot = await db
            .collection('businesses')
            .where('secretCode', isEqualTo: scannedValue)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          throw 'Invalid QR Code. No matching business found.';
        }

        final businessDoc = querySnapshot.docs.first;
        targetBusinessId = businessDoc.id;
        points = businessDoc.data()['checkInPoints'] ?? 100;
      }

      final scanRef = db.collection('scans').doc('${user.uid}_$targetBusinessId');

      // 2. Atomic Transaction: Check for duplicates & award points
      await db.runTransaction((transaction) async {
        final scanDoc = await transaction.get(scanRef);
        if (scanDoc.exists) throw 'You have already checked in here!';

        // Create the scan record
        transaction.set(scanRef, {
          'user_id': user.uid,
          'business_id': targetBusinessId,
          'timestamp': FieldValue.serverTimestamp(),
          'points_awarded': points,
        });

        // Update user's total points
        transaction.update(db.collection('users').doc(user.uid), {
          'total_points': FieldValue.increment(points),
        });
      });



      // Log Analytics Event for In-App Messaging Trigger
      final String businessName = widget.businessId != null 
          ? 'Business (${widget.businessId})' 
          : 'Business ($targetBusinessId)'; 
          
      // Ideally we would fetch the name properly if we did a lookup, 
      // but for now ID is sufficient or we can pass name if we had it.
      // If we did a lookup (Mode B), we have 'businessDoc'. Let's verify if we need to fetch name.
      
      // FIX: In Mode B we have businessDoc. In Mode A we don't fetch the doc, just check secret.
      // To be clean, let's just log the ID for now or fetch name if critical.
      // User just wants the trigger.
      
      await AnalyticsService().logCheckIn(
        businessId: targetBusinessId,
        businessName: businessName,
        points: points,
      );

      if (mounted) _showSuccessUI(points);
    } catch (e) {
      if (mounted) _showErrorUI(e.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessUI(int points) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.9),
        title: const Icon(Icons.stars, color: AppTheme.accentGreen, size: 64),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CHECK-IN SUCCESSFUL!', 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),
            Text(
              '+$points POINTS', 
              style: const TextStyle(color: AppTheme.accentGreen, fontSize: 24, fontWeight: FontWeight.bold)
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
               Navigator.of(context).pop(); // Close Dialog
               Navigator.of(context).pop(); // Close Sheet
            }, 
            child: const Text('BACK TO BOARD', style: TextStyle(color: Colors.white))
          )
        ],
      ),
    );
  }

  void _showErrorUI(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
    ));
    // Resume scanner after a short delay so user can try again
    Future.delayed(const Duration(seconds: 2), () {
        if (mounted) controller.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppTheme.navBarBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text('ALIGN QR CODE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          Expanded(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    if (capture.barcodes.isEmpty) return;
                    final barcode = capture.barcodes.first;
                    if (barcode.rawValue != null) _handleScan(barcode.rawValue!);
                  },
                ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}