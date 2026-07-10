import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/progress_repository.dart';
import '../../providers/app_providers.dart';
import '../theme_palettes.dart';

class ThemesScreen extends ConsumerStatefulWidget {
  const ThemesScreen({super.key});

  @override
  ConsumerState<ThemesScreen> createState() => _ThemesScreenState();
}

class _ThemesScreenState extends ConsumerState<ThemesScreen> {
  Set<int> _unlocked = {0};
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(progressRepositoryProvider);
    final unlocked = await repo.getUnlockedThemes();
    final selected = await repo.getSelectedTheme();
    if (mounted) {
      setState(() {
        _unlocked = unlocked;
        _selected = selected;
      });
    }
  }

  Future<void> _select(int id) async {
    if (!_unlocked.contains(id)) return;
    await ref.read(progressRepositoryProvider).setSelectedTheme(id);
    setState(() => _selected = id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Temas de bloques')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kBlockPalettes.length,
        itemBuilder: (context, index) {
          final palette = kBlockPalettes[index];
          final unlocked = _unlocked.contains(index);
          final selected = _selected == index;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              onTap: unlocked ? () => _select(index) : null,
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: palette.colors
                    .map(
                      (c) => Container(
                        width: 16,
                        height: 32,
                        margin: const EdgeInsets.only(right: 2),
                        color: unlocked ? c : Colors.grey,
                      ),
                    )
                    .toList(),
              ),
              title: Text(palette.name),
              subtitle: unlocked
                  ? null
                  : Text(
                      'Desbloquea con puntaje >= ${kThemeUnlockScores[index]}',
                    ),
              trailing: unlocked
                  ? (selected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null)
                  : const Icon(Icons.lock, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
