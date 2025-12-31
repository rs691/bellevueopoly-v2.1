import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CasualGamesLobbyScreen extends StatelessWidget {
  const CasualGamesLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arcade Games'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _GameTile(
            title: 'Mini Game 1',
            icon: Icons.games,
            onTap: () => context.push('/casual-games/game1'),
          ),
          _GameTile(
            title: 'Achievements',
            icon: Icons.emoji_events,
            onTap: () => context.push('/casual-games/achievements'),
          ),
          _GameTile(
            title: 'Settings',
            icon: Icons.settings,
            onTap: () => context.push('/casual-games/settings'),
          ),
          // Add more game tiles as needed
        ],
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _GameTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}