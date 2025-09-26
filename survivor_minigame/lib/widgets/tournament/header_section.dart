import 'package:flutter/material.dart';
import '../../models/tournament_models.dart';
import 'stats_bar.dart';

class HeaderSection extends StatelessWidget {
  final String title;
  final TournamentStats stats;
  final double topPadding;

  const HeaderSection({
    super.key,
    required this.title,
    required this.stats,
    required this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    final double resolvedTop = topPadding + 16;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('lib/public/header.jpg', fit: BoxFit.cover),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.45),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(20, resolvedTop, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 20),
                StatsBar(stats: stats),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
