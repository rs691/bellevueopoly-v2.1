import 'package:flutter/material.dart';
import '../widgets/glassmorphic_card.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassmorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Updated: January 2026',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '1. Acceptance of Terms',
                    content:
                        'By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement. '
                        'If you do not agree to abide by the above, please do not use this service.',
                  ),
                  _buildSection(
                    title: '2. Use License',
                    content:
                        'Permission is granted to temporarily use the application for personal, non-commercial use only. '
                        'This is the grant of a license, not a transfer of title.',
                  ),
                  _buildSection(
                    title: '3. Game Rules & Check-ins',
                    content:
                        'Participation in the game requires adherence to all game rules. '
                        'Check-ins must be legitimate and performed at the physical location of participating businesses. '
                        'Fraudulent check-ins or any attempt to manipulate the system will result in immediate disqualification.',
                  ),
                  _buildSection(
                    title: '4. Prizes & Rewards',
                    content:
                        'Prize eligibility is determined by check-in completion and adherence to game rules. '
                        'Prizes are awarded at the discretion of the game organizers. '
                        'Prize values are approximate and subject to change without notice.',
                  ),
                  _buildSection(
                    title: '5. Privacy',
                    content:
                        'Your use of the application is also governed by our Privacy Policy. '
                        'We collect location data and check-in information as part of game functionality.',
                  ),
                  _buildSection(
                    title: '6. Account Termination',
                    content:
                        'We reserve the right to terminate or suspend your account at any time for violations of these terms, '
                        'fraudulent activity, or any other reason deemed necessary by the game organizers.',
                  ),
                  _buildSection(
                    title: '7. Modifications',
                    content:
                        'We reserve the right to modify these terms at any time. '
                        'Continued use of the application after changes constitutes acceptance of the updated terms.',
                  ),
                  _buildSection(
                    title: '8. Disclaimer',
                    content:
                        'The application is provided "as is" without warranty of any kind. '
                        'We do not guarantee uninterrupted or error-free service.',
                  ),
                  _buildSection(
                    title: '9. Limitation of Liability',
                    content:
                        'In no event shall the game organizers be liable for any damages arising from the use or inability to use the application.',
                  ),
                  _buildSection(
                    title: '10. Contact Information',
                    content:
                        'For questions about these Terms & Conditions, please contact us at support@bellevueopoly.com',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('I UNDERSTAND'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.baloo2(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
