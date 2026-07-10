import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int _gamesPlayed = 0;
  int _bestHeight = 0;
  int _totalPerfects = 0;
  Duration _totalPlayTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(statsRepositoryProvider);
    final games = await repo.getGamesPlayed();
    final height = await repo.getBestHeight();
    final perfects = await repo.getTotalPerfects();
    final playTime = await repo.getTotalPlayTime();
    if (mounted) {
      setState(() {
        _gamesPlayed = games;
        _bestHeight = height;
        _totalPerfects = perfects;
        _totalPlayTime = playTime;
      });
    }
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadisticas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatTile(label: 'Partidas jugadas', value: '$_gamesPlayed'),
          _StatTile(label: 'Mejor altura', value: '$_bestHeight'),
          _StatTile(label: 'Colocaciones perfectas', value: '$_totalPerfects'),
          _StatTile(
            label: 'Tiempo total jugado',
            value: _formatDuration(_totalPlayTime),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
