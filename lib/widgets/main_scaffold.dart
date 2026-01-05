import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bottom_nav_bar.dart';
import '../router/app_router.dart';


class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _calculateCurrentIndex(context),
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }

  int _calculateCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/') {
      return 0;
    } else if (location.startsWith('/map')) {
      return 1;
    } else if (location.startsWith('/businesses')) {
      return 2;
    } else if (location.startsWith('/profile')) {
      return 3;
    } else if (location.startsWith(AppRoutes.game) ||
        location.startsWith(AppRoutes.casualGame)) {
      return 4;
    }
    return 0;
  }


// inside MainScaffold's NavigationBar onDestinationSelected:
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home); // Welcome Back
        break;
      case 1:
        context.go(AppRoutes.map); // Map
        break;
      case 2:
        context.go(AppRoutes.businesses); // List
        break;
      case 3:
        context.go(AppRoutes.profile); // Profile
        break;
      case 4:
        context.go(AppRoutes.game); // Game
        break;
    }
  }


}
