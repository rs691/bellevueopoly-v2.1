import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/navigation_box.dart';
import '../router/app_router.dart';

class MobileLandingScreen extends StatelessWidget {
  const MobileLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Back'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Prevents back button on home
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            // 1. Stop Hub (Business Categories)
            NavigationBox(
              icon: Icons.star,
              label: 'Stop Hub',
              onTap: () => context.go(AppRoutes.stopHub),
            ),
            // 2. Near Me (Map with nearby rewards)
            NavigationBox(
              icon: Icons.location_on,
              label: 'Near Me',
              onTap: () => context.go(AppRoutes.nearMe),
            ),

            // 3. Prizes
            NavigationBox(
              icon: Icons.emoji_events,
              label: 'Prizes',
              onTap: () => context.go(AppRoutes.prizes),
            ),

            // 4. FAQs (in Rules & Prizes screen)
            NavigationBox(
              icon: Icons.help,
              label: 'FAQs',
              onTap: () => context.go(AppRoutes.rulesAndPrizes),
            ),

            // 5. My Account / Profile
            NavigationBox(
              icon: Icons.person,
              label: 'My Account',
              onTap: () => context.go(AppRoutes.profile),
            ),
          ],
        ),
      ),
    );
  }
}
