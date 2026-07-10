import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final brightness = Theme.of(context).brightness;
    final isDark = settings.darkMode ?? (brightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Sonido'),
            value: settings.sound,
            onChanged: notifier.setSound,
          ),
          SwitchListTile(
            title: const Text('Musica'),
            value: settings.music,
            onChanged: notifier.setMusic,
          ),
          SwitchListTile(
            title: const Text('Vibracion'),
            value: settings.vibration,
            onChanged: notifier.setVibration,
          ),
          SwitchListTile(
            title: const Text('Tema oscuro'),
            value: isDark,
            onChanged: notifier.setDarkMode,
          ),
        ],
      ),
    );
  }
}
