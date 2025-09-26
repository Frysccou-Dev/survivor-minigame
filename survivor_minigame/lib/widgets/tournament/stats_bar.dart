import 'package:flutter/material.dart';
import '../../models/tournament_models.dart';
import 'stat_tile.dart';

class StatsBar extends StatelessWidget {
  final TournamentStats stats;

  const StatsBar({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    const Color cardColor = Color(0xFF181818);
    return Row(
      children: [
        Expanded(
          child: StatTile(
            icon: Icons.favorite_border,
            value: stats.lives,
            label: 'Vidas',
            color: cardColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatTile(
            icon: Icons.emoji_events_outlined,
            value: stats.position,
            label: 'Posición',
            color: cardColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatTile(
            icon: Icons.savings_outlined,
            value: stats.pot,
            label: 'Pozo acumulado',
            color: cardColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatTile(
            icon: Icons.shield_moon_outlined,
            value: stats.survivors,
            label: 'Sobrevivientes',
            color: cardColor,
          ),
        ),
      ],
    );
  }
}
