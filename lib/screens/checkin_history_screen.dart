import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glassmorphic_card.dart';
import '../theme/app_theme.dart';
import '../router/app_router.dart';

class CheckinHistoryScreen extends StatelessWidget {
  const CheckinHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Text(
            'Please sign in to view your check-ins.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final userDocStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();

    final scansStream = FirebaseFirestore.instance
        .collection('scans')
        .where('user_id', isEqualTo: user.uid)
        .orderBy('scanned_at', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Check-in History',
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
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userDocStream,
        builder: (context, userSnap) {
          final userData = userSnap.data?.data() as Map<String, dynamic>?;
          final name =
              userData?['username'] ?? userData?['displayName'] ?? 'Explorer';
          final email = userData?['email'] ?? user.email ?? '';
          final lastLogin = user.metadata.lastSignInTime;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _UserInfoCard(
                  name: name,
                  email: email,
                  lastLogin: lastLogin,
                  totalPoints: userData?['total_points'] ?? 0,
                  totalVisits: userData?['totalVisits'] ?? 0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'RECENT ACTIVITY',
                  style: GoogleFonts.baloo2(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: scansStream,
                  builder: (context, scanSnap) {
                    if (scanSnap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    if (scanSnap.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${scanSnap.error}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      );
                    }
                    final docs = scanSnap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No check-ins yet.',
                              style: TextStyle(color: Colors.white60),
                            ),
                          ],
                        ),
                      );
                    }
                    return FutureBuilder<Map<String, _BizMeta>>(
                      future: _resolveBusinessMeta(docs),
                      builder: (context, metaSnap) {
                        final metaMap = metaSnap.data ?? const {};

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final businessId = data['business_id'] ?? '';
                            final meta = metaMap[businessId];
                            final businessName =
                                data['businessName'] ??
                                data['business_name'] ??
                                meta?.name ??
                                'Business';
                            final addressLine = meta?.address ?? '';
                            final imageUrl = meta?.imageUrl;
                            final points =
                                data['points_awarded'] ??
                                data['points_earned'] ??
                                100;
                            final ts =
                                (data['scanned_at'] ?? data['timestamp'])
                                    as Timestamp?;
                            final dateStr = ts != null
                                ? DateFormat(
                                    'MMM dd, yyyy • hh:mm a',
                                  ).format(ts.toDate())
                                : 'Recently';

                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 1.0, end: 0.0),
                              duration: Duration(
                                milliseconds: 300 + (index * 50).clamp(0, 300),
                              ),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * value),
                                  child: Opacity(
                                    opacity: 1 - value,
                                    child: child,
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: GlassmorphicCard(
                                  padding: EdgeInsets.zero,
                                  child: ListTile(
                                    onTap: () => context.push(
                                      '${AppRoutes.stopHub}/business/$businessId',
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    leading: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        image: imageUrl != null
                                            ? DecorationImage(
                                                image: NetworkImage(imageUrl),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: imageUrl == null
                                          ? const Icon(
                                              Icons.storefront,
                                              color: Colors.white70,
                                            )
                                          : null,
                                    ),
                                    title: Text(
                                      businessName,
                                      style: GoogleFonts.baloo2(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          dateStr,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.6,
                                            ),
                                            fontSize: 13,
                                          ),
                                        ),
                                        if (addressLine.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 2.0,
                                            ),
                                            child: Text(
                                              addressLine,
                                              style: const TextStyle(
                                                color: Colors.white38,
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '+$points',
                                          style: GoogleFonts.baloo2(
                                            color: Colors.greenAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const Text(
                                          'PTS',
                                          style: TextStyle(
                                            color: Colors.white38,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<Map<String, _BizMeta>> _resolveBusinessMeta(
    List<QueryDocumentSnapshot> docs,
  ) async {
    final ids = <String>{};
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final bid = data['business_id'] as String?;
      if (bid != null && bid.isNotEmpty) ids.add(bid);
    }
    if (ids.isEmpty) return {};

    final result = <String, _BizMeta>{};
    final chunks = ids.toList();

    for (var i = 0; i < chunks.length; i += 10) {
      final slice = chunks.sublist(
        i,
        i + 10 > chunks.length ? chunks.length : i + 10,
      );
      final snap = await FirebaseFirestore.instance
          .collection('businesses')
          .where(FieldPath.documentId, whereIn: slice)
          .get();
      for (final doc in snap.docs) {
        final data = doc.data();
        final name = (data['name'] ?? data['title'] ?? doc.id).toString();
        final imageUrl = data['heroImageUrl'] as String?;
        final street = data['street'] as String?;
        final city = data['city'] as String?;
        final state = data['state'] as String?;
        final zip = data['zip'] as String?;
        final category = data['category'] as String?;
        final address = _formatAddress(street, city, state, zip);
        result[doc.id] = _BizMeta(
          name: name,
          address: address,
          imageUrl: imageUrl,
          category: category,
        );
      }
    }
    return result;
  }

  String _formatAddress(
    String? street,
    String? city,
    String? state,
    String? zip,
  ) {
    final parts = [
      if (street != null && street.isNotEmpty) street,
      [
        if (city != null && city.isNotEmpty) city,
        if (state != null && state.isNotEmpty) state,
      ].join(', '),
      if (zip != null && zip.isNotEmpty) zip,
    ];
    return parts.where((e) => e.isNotEmpty).join(' · ');
  }
}

class _UserInfoCard extends StatelessWidget {
  final String name;
  final String email;
  final DateTime? lastLogin;
  final int totalPoints;
  final int totalVisits;

  const _UserInfoCard({
    required this.name,
    required this.email,
    required this.lastLogin,
    required this.totalPoints,
    required this.totalVisits,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.baloo2(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Points',
                  '$totalPoints',
                  Icons.stars_rounded,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white12),
              Expanded(
                child: _buildStatItem('Visits', '$totalVisits', Icons.place),
              ),
            ],
          ),
          if (lastLogin != null) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.white.withValues(alpha: 0.1)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  'Last seen: ${DateFormat('MMM dd, yyyy').format(lastLogin!)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.accentPurple, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.baloo2(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.6),
            letterSpacing: 1.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _BizMeta {
  final String name;
  final String address;
  final String? imageUrl;
  final String? category;
  const _BizMeta({
    required this.name,
    required this.address,
    this.imageUrl,
    this.category,
  });
}
