// lib/screens/play_session_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/config_provider.dart';
import '../theme/app_theme.dart';
import 'qr_scanner_overlay.dart';

class PlaySessionScreen extends ConsumerWidget {
  final String? businessId;

  const PlaySessionScreen({super.key, this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (businessId == null) {
      return Scaffold(
        backgroundColor: AppTheme.primaryPurple,
        body: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Icon(
                  Icons.qr_code_scanner, 
                  size: 100, 
                  color: AppTheme.accentGreen
                ),
                const SizedBox(height: 40),
                Text(
                  'MONOPOLY GO',
                  style: AppTheme.theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Scan a business QR code to check in, earn points, and unlock properties!',
                  style: AppTheme.theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      foregroundColor: AppTheme.primaryPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    onPressed: () {
                       _openScanner(context, null, null, null);
                    },
                    child: const Text(
                      'START SCANNING',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      );
    }

    final businessAsync = ref.watch(businessByIdProvider(businessId!));

    return Scaffold(
      appBar: AppBar(title: const Text('PROPERTY CARD')),
      body: businessAsync.when(
        data: (business) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Business "Hero" Header
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(business?.heroImageUrl ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(business?.name ?? '', style: AppTheme.theme.textTheme.headlineSmall),
              const Spacer(),
              // The "VISIT" Action
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('CHECK IN TO WIN'),
                onPressed: () {
                   _openScanner(
                     context, 
                     business!.id, 
                     business.secretCode ?? 'SECRET', 
                     business.checkInPoints ?? 100
                   );
                },
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _openScanner(BuildContext context, String? businessId, String? secret, int? points) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QRScannerOverlay(
        businessId: businessId,
        correctSecret: secret,
        pointsToAward: points,
      ),
    );
  }
}