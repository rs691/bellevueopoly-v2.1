import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/user_data_provider.dart';
import '../providers/firestore_provider.dart';
import '../widgets/profile_picture_uploader.dart';
import '../widgets/user_image_gallery.dart';
import '../widgets/stat_card.dart';
import '../widgets/logout_confirmation_dialog.dart';
import '../router/app_router.dart';
import '../widgets/glassmorphic_card.dart';
import '../providers/chatbot_settings_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Local state for toggles (simulation for now)
  bool _pushNotifications = true;
  bool _emailUpdates = false;

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userDataProvider);
    final FirebaseAuth auth = FirebaseAuth.instance;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'My Account',
          style: GoogleFonts.baloo2(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () => LogoutConfirmationDialog.show(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: userData.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        data: (userDoc) {
          // If the profile doesn't exist yet (e.g. data latency, permission error, or not created),
          // fallback to display data so the UI renders immediately.
          Map<String, dynamic> user;

          if (userDoc != null && userDoc.exists) {
            user = userDoc.data() as Map<String, dynamic>;
          } else {
            // Fallback/Guest Data
            final currentUser = FirebaseAuth.instance.currentUser;
            user = {
              'username': currentUser?.displayName ?? 'Guest Player',
              'email': currentUser?.email ?? 'No Email',
              'photoURL': currentUser?.photoURL,
              'points': 0,
              'checkIns': 0,
              'isAdmin': false,
            };
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header (Profile Pic, Name, Email)
                _buildProfileHeader(context, user),
                const SizedBox(height: 16),

                // 2. Stats Grid
                _buildStatsGrid(user),
                const SizedBox(height: 16),

                // 3. Account Settings Section
                _buildSectionTitle('ACCOUNT SETTINGS'),
                GlassmorphicCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildListTile(
                        icon: Icons.edit,
                        title: 'Edit Profile',
                        onTap: () => context.push(AppRoutes.editProfile),
                      ),
                      _buildDivider(),
                      _buildListTile(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        onTap: () => context.push(AppRoutes.changePassword),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Notifications Section
                _buildSectionTitle('NOTIFICATIONS'),
                GlassmorphicCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.notifications_outlined,
                        title: 'Push Notifications',
                        value: _pushNotifications,
                        onChanged: (val) =>
                            setState(() => _pushNotifications = val),
                      ),
                      _buildDivider(),
                      _buildSwitchTile(
                        icon: Icons.email_outlined,
                        title: 'Email Updates',
                        value: _emailUpdates,
                        onChanged: (val) => setState(() => _emailUpdates = val),
                      ),
                      _buildDivider(),
                      _buildSwitchTile(
                        icon: Icons.smart_toy_outlined,
                        title: 'Enable Chatbot',
                        value: ref.watch(chatbotSettingsProvider),
                        onChanged: (val) => ref
                            .read(chatbotSettingsProvider.notifier)
                            .toggle(val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 5. History & Activity
                _buildSectionTitle('HISTORY & ACTIVITY'),
                GlassmorphicCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildListTile(
                        icon: Icons.history,
                        title: 'Check-in History',
                        onTap: () => context.push(AppRoutes.checkinHistory),
                      ),
                      _buildDivider(),
                      _buildListTile(
                        icon: Icons.qr_code_2,
                        title: 'QR Scan History',
                        onTap: () {
                          final userId = auth.currentUser?.uid;
                          if (userId != null) {
                            context.push(
                              AppRoutes.qrScanHistory,
                              extra: userId,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 6. My Images
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('MY IMAGES'),
                    TextButton.icon(
                      onPressed: () => context.push(AppRoutes.upload),
                      icon: const Icon(
                        Icons.add_a_photo,
                        size: 16,
                        color: Colors.blueAccent,
                      ),
                      label: const Text(
                        'Upload',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(60, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 8), // Removed extra space
                UserImageGallery(),
                const SizedBox(height: 16),

                // 7. Support & Info
                _buildSectionTitle('SUPPORT & INFO'),
                GlassmorphicCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildListTile(
                        icon: Icons.menu_book_outlined,
                        title: 'How to Play',
                        onTap: () => context.push(AppRoutes.instructions),
                      ),
                      _buildDivider(),
                      _buildListTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        onTap: () {}, // TODO
                      ),
                      _buildDivider(),
                      _buildListTile(
                        icon: Icons.gavel_outlined,
                        title: 'Terms of Service',
                        onTap: () => context.push(AppRoutes.terms),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 8. Danger Zone
                GlassmorphicCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildListTile(
                        icon: Icons.delete_forever_outlined,
                        title: 'Delete Account',
                        color: Colors.redAccent,
                        isDestructive: true,
                        onTap: () => _handleDeleteAccount(context),
                      ),
                    ],
                  ),
                ),

                // Admin Link (Conditional)
                if (user['isAdmin'] == true) ...[
                  const SizedBox(height: 16),
                  GlassmorphicCard(
                    padding: EdgeInsets.zero,
                    child: _buildListTile(
                      icon: Icons.admin_panel_settings,
                      title: 'Admin Console',
                      color: Colors.amber,
                      onTap: () => context.push(AppRoutes.admin),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> user) {
    // Check if we need to show upload prompt (if no photo)
    // Handle inconsistent casing from Firestore (photoURL vs photoUrl)
    final String? photoUrl = (user['photoURL'] ?? user['photoUrl']) as String?;

    return Column(
      children: [
        Center(
          child: SizedBox(
            width: 120,
            height: 120,
            child: ProfilePictureUploader(
              currentPhotoUrl: photoUrl,
              userName: user['username'] ?? 'User',
              onUploadComplete: () {
                // The widget handles update, but we can refresh local provider if needed
                ref.refresh(userDataProvider);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user['username'] ?? 'No Name',
          style: GoogleFonts.baloo2(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user['email'] ?? 'No Email',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> user) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        StatCard(
          label: 'Total Check-ins',
          value: '${user['checkIns'] ?? 0}',
          icon: Icons.location_on,
          color: const Color(0xFF60A5FA),
        ),
        StatCard(
          label: 'Points',
          value: '${user['points'] ?? 0}',
          icon: Icons.stars,
          color: const Color(0xFFFBBF24),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.white,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontSize: 16)),
      trailing: Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blueAccent,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withOpacity(0.1),
      indent: 16,
      endIndent: 16,
    );
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Perform delete logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deletion logic would run here.')),
      );
    }
  }
}
