import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glassmorphic_card.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = const [
      (
        'How do I earn points?',
        'Check in at participating locations, scan QR codes after purchases, and complete weekly challenges to stack bonus points.',
      ),
      (
        'What if a QR code will not scan?',
        'Try increasing screen brightness, clean the camera lens, and move 6-8 inches from the code. If it still fails, enter the receipt code manually from the cashier.',
      ),
      (
        'When are prizes released?',
        'Prizes refresh every Monday at 9 AM. Limited-quantity items appear first-come, first-served and restock mid-week when available.',
      ),
      (
        'Can I transfer points?',
        'Points are tied to your account and cannot be transferred, but family members can each earn points on their own devices.',
      ),
      (
        'How do I report an issue?',
        'Open Settings > Help & Support and tap “Report a Problem,” or email support@bellevueopoly.com with screenshots and your device model.',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'FAQ',
          style: GoogleFonts.luckiestGuy(
            fontSize: 32, 
            color: Colors.white,
            letterSpacing: 2.0, // Consistent with Prizes
            shadows: [
              const Shadow(
                color: Colors.black45,
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          ...faqs.map((faq) => _buildFAQCard(faq.$1, faq.$2)),
          const SizedBox(height: 24),
          _buildContactCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
              ),
              child: const Icon(Icons.help_outline, size: 28, color: Colors.amber),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Freq. Asked Questions',
                style: GoogleFonts.luckiestGuy(
                  fontSize: 22, 
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Quick answers for the most common app questions. Tap any question to expand the details.',
          style: GoogleFonts.baloo2(
            fontSize: 16, 
            color: Colors.white70,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildFAQCard(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassmorphicCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: ThemeData(dividerColor: Colors.transparent), // Remove expansion tile border line
          child: ExpansionTile(
            collapsedIconColor: Colors.amber,
            iconColor: Colors.amber,
            title: Text(
              question,
              style: GoogleFonts.baloo2(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  answer,
                  style: GoogleFonts.baloo2(
                    fontSize: 16, 
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.support_agent, color: Colors.amber, size: 36),
          const SizedBox(height: 12),
          Text(
            'Still need help?',
            style: GoogleFonts.luckiestGuy(fontSize: 20, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Reach us at support@bellevueopoly.com and we will respond within one business day.',
            style: GoogleFonts.baloo2(
              fontSize: 16, 
              color: Colors.white70,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
