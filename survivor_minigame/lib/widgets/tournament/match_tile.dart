import 'package:flutter/material.dart';
import '../../models/tournament_models.dart';
import 'pick_option_button.dart';

class MatchTile extends StatelessWidget {
  final TournamentMatch match;
  final bool joined;
  final String? selectedTeam;
  final bool loading;
  final ValueChanged<String> onPick;

  const MatchTile({
    super.key,
    required this.match,
    required this.joined,
    required this.selectedTeam,
    required this.loading,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final bool canPick = joined && !loading && selectedTeam == null;
    final Widget content = Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF252525)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(match.homeFlag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        match.homeName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    match.kickoff,
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 36,
                    height: 2,
                    decoration: const BoxDecoration(
                      color: Color(0xFFED9320),
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        match.visitorName,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      match.visitorFlag,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: PickOptionButton(
                  label: match.homeName,
                  flag: match.homeFlag,
                  selected: selectedTeam == match.homeName,
                  enabled: canPick,
                  onTap: () => onPick(match.homeName),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PickOptionButton(
                  label: match.visitorName,
                  flag: match.visitorFlag,
                  selected: selectedTeam == match.visitorName,
                  enabled: canPick,
                  onTap: () => onPick(match.visitorName),
                ),
              ),
            ],
          ),
          if (selectedTeam != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Tu pick: $selectedTeam',
                style: const TextStyle(
                  color: Color(0xFFED9320),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );

    if (!loading) {
      return content;
    }

    return Stack(
      children: [
        content,
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFED9320),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
