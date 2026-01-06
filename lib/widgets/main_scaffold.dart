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
    // Tab 0: HOME -> /
    if (location == '/') {
      return 0;
    // Tab 1: STOPS -> /stop-hub
    } else if (location.startsWith('/stop-hub')) {
      return 1;
    // Tab 2: QR Scanner (modal, no route)
    // Tab 3: PRIZES -> /prizes
    } else if (location.startsWith('/prizes')) {
      return 3;
    // Tab 4: NEAR ME -> /near-me
    } else if (location.startsWith('/near-me')) {
      return 4;
    }
    return 0;
  }


// inside MainScaffold's NavigationBar onDestinationSelected:
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home); // HOME -> Welcome Back
        break;
      case 1:
        context.go(AppRoutes.stopHub); // STOPS -> Stop Hub
        break;
      case 2:
        // QR Scanner - TODO: Open modal/overlay for QR scanning
        // For now, do nothing (or show a snackbar)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR Scanner coming soon!')),
        );
        break;
      case 3:
        context.go(AppRoutes.prizes); // PRIZES
        break;
      case 4:
        context.go(AppRoutes.nearMe); // NEAR ME -> Map with nearby rewards
        break;
    }
  }


}
