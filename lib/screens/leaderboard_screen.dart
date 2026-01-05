import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../providers/firestore_provider.dart';
import '../models/player.dart';

final leaderboardProvider = StreamProvider<List<Player>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getTopPlayersStream();
});

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
      ),
      body: leaderboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (players) {
          if (players.isEmpty) {
            return const Center(child: Text('No players found yet!'));
          }
          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              final rank = index + 1;
              
              // Highlight top 3
              Color? rankColor;
              if (rank == 1) rankColor = Colors.amber; // Gold
              else if (rank == 2) rankColor = Colors.grey[400]; // Silver
              else if (rank == 3) rankColor = Colors.brown[300]; // Bronze

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: rankColor ?? Colors.blueAccent,
                    child: Text(
                      '#$rank',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${player.totalVisits} visits'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${player.totalPoints}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text('Points', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
