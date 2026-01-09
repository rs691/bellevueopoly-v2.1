import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glassmorphic_card.dart';

class PrizesScreen extends ConsumerStatefulWidget {
  const PrizesScreen({super.key});

  @override
  ConsumerState<PrizesScreen> createState() => _PrizesScreenState();
}

class _PrizesScreenState extends ConsumerState<PrizesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Ensures global background shows through
      appBar: AppBar(
        title: Text(
          'PRIZES',
          style: GoogleFonts.luckiestGuy(
            fontSize: 32,
            color: Colors.white,
            letterSpacing: 2.0,
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('prizes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.amber.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Access Error',
                      style: GoogleFonts.luckiestGuy(fontSize: 24, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}', // Show actual error for debugging
                      style: GoogleFonts.baloo2(fontSize: 14, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No prizes available yet.',
                    style: GoogleFonts.baloo2(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back soon!',
                    style: GoogleFonts.baloo2(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final description = data['description'] as String? ?? '';
              // Try to find a suitable title from common field names, or use a default
              final title = data['title'] as String? ?? 
                           data['name'] as String? ?? 
                           data['tier'] as String? ?? 
                           'Prize Reward';
              
              return _buildPrizeCard(title, description);
            },
          );
        },
      ),
    );
  }

  Widget _buildPrizeCard(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                color: Colors.amber.shade300,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: GoogleFonts.luckiestGuy(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.baloo2(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
