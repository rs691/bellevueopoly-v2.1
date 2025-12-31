import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_provider.dart';

class GameSettingsScreen extends ConsumerWidget {
  const GameSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioManager = ref.watch(audioManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Music'),
            subtitle: const Text('Background music'),
            value: audioManager.musicEnabled,
            onChanged: (value) => audioManager.toggleMusic(value),
          ),
          SwitchListTile(
            title: const Text('Sound Effects'),
            subtitle: const Text('Game sound effects'),
            value: audioManager.sfxEnabled,
            onChanged: (value) => audioManager.toggleSfx(value),
          ),
          const Divider(),
          // Add more settings as needed
        ],
      ),
    );
  }
}