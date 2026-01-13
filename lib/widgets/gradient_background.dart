import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2d1b4e),
            Color(0xFF1a0d33),
            Color.fromARGB(0, 126, 58, 214),
          ],
        ),
      ),
      child: child,
    );
  }
}
