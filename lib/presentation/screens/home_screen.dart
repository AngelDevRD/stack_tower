import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/app_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _bestScore = 0;
  int _dailyTarget = 0;
  bool _dailyCompleted = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = ref.read(statsRepositoryProvider);
    final daily = ref.read(dailyChallengeRepositoryProvider);
    final best = await stats.getBestScore();
    final target = await daily.getTodayTarget();
    final completed = await daily.isTodayCompleted();
    if (mounted) {
      setState(() {
        _bestScore = best;
        _dailyTarget = target;
        _dailyCompleted = completed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                'Stack Tower',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mejor puntaje: $_bestScore',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () async {
                  await context.push('/game');
                  _load();
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: const Text(
                  'Modo infinito',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _dailyCompleted
                    ? null
                    : () async {
                        await context.push('/game', extra: _dailyTarget);
                        _load();
                      },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: Text(
                  _dailyCompleted
                      ? 'Reto diario completado (altura $_dailyTarget)'
                      : 'Reto diario: altura $_dailyTarget',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavIcon(
                    icon: Icons.palette,
                    label: 'Temas',
                    onTap: () => context.push('/themes'),
                  ),
                  _NavIcon(
                    icon: Icons.emoji_events,
                    label: 'Logros',
                    onTap: () => context.push('/achievements'),
                  ),
                  _NavIcon(
                    icon: Icons.bar_chart,
                    label: 'Stats',
                    onTap: () => context.push('/stats'),
                  ),
                  _NavIcon(
                    icon: Icons.settings,
                    label: 'Ajustes',
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
