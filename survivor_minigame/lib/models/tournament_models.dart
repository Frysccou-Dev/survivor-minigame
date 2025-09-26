class TournamentStats {
  final String lives;
  final String position;
  final String pot;
  final String survivors;

  const TournamentStats({
    required this.lives,
    required this.position,
    required this.pot,
    required this.survivors,
  });
}

class TournamentMatch {
  final String id;
  final String homeName;
  final String homeFlag;
  final String visitorName;
  final String visitorFlag;
  final String kickoff;

  const TournamentMatch({
    required this.id,
    required this.homeName,
    required this.homeFlag,
    required this.visitorName,
    required this.visitorFlag,
    required this.kickoff,
  });
}

class TournamentStage {
  final String id;
  final String title;
  final String subtitle;
  final List<TournamentMatch> matches;
  final int matchCount;
  final bool locked;

  const TournamentStage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.matches,
    required this.matchCount,
    required this.locked,
  });
}
