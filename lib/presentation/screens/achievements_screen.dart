import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/progress_repository.dart';
import '../../providers/app_providers.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  Set<String> _unlocked = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final unlocked = await ref
        .read(progressRepositoryProvider)
        .getUnlockedAchievements();
    if (mounted) setState(() => _unlocked = unlocked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logros')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kAchievementIds.length,
        itemBuilder: (context, index) {
          final id = kAchievementIds[index];
          final unlocked = _unlocked.contains(id);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                unlocked ? Icons.emoji_events : Icons.emoji_events_outlined,
                color: unlocked ? Colors.amber : Colors.grey,
              ),
              title: Text(kAchievementLabels[id] ?? id),
              trailing: unlocked
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
