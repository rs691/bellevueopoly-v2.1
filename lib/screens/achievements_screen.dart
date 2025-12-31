import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AchievementTile(
            title: 'First Win',
            description: 'Win your first game',
            icon: Icons.star,
            unlocked: true,
          ),
          _AchievementTile(
            title: 'High Scorer',
            description: 'Score over 1000 points',
            icon: Icons.trending_up,
            unlocked: false,
          ),
          // Add more achievements
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;

  const _AchievementTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          size: 40,
          color: unlocked ? Colors.amber : Colors.grey,
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: unlocked
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.lock, color: Colors.grey),
      ),
    );
  }
}