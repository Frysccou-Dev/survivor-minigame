import 'package:flutter/material.dart';
import '../services/survivor_service.dart';
import '../models/tournament_models.dart';
import '../widgets/dialogs/confirmation_dialog.dart';
import '../widgets/feedback/inline_message.dart';
import '../widgets/tournament/header_section.dart';
import '../widgets/tournament/secondary_nav.dart';
import '../widgets/tournament/match_tile.dart';
import '../widgets/tournament/debug_lives_controls.dart';
import '../widgets/tournament/lives_depleted_banner.dart';

class SurvivorDetailScreen extends StatefulWidget {
  static const routeName = '/survivor-detail';

  final Map<String, dynamic> survivor;

  const SurvivorDetailScreen({super.key, required this.survivor});

  @override
  State<SurvivorDetailScreen> createState() => _SurvivorDetailScreenState();
}

class _SurvivorDetailScreenState extends State<SurvivorDetailScreen> {
  late Map<String, dynamic> _survivor;
  bool _loadingDetail = false;
  bool _joined = false;
  bool _joining = false;
  final Set<String> _pickingMatches = <String>{};
  Map<String, String> _picks = {};
  final Set<String> _expandedStages = <String>{'stage-1'};
  int _activeTab = 0;
  String? _error;
  int _maxLives = 0;
  String? _joinMessage;
  InlineMessageVariant? _joinMessageVariant;

  @override
  void initState() {
    super.initState();
    _survivor = widget.survivor;
    final int? initialLives = widget.survivor['lives'] as int?;
    if (initialLives != null && initialLives > 0) {
      _maxLives = initialLives;
    }
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final String? survivorId = widget.survivor['_id'] as String?;
    if (survivorId == null) {
      return;
    }

    setState(() {
      _loadingDetail = true;
      _error = null;
    });

    try {
      final Map<String, dynamic> detail =
          await SurvivorService.fetchSurvivorDetail(survivorId);
      final Map<String, dynamic> survivorData =
          (detail['survivor'] as Map<String, dynamic>?) ?? widget.survivor;
      final List<dynamic> predictions =
          detail['predictions'] as List<dynamic>? ?? const [];
      final bool joined = detail['joined'] == true;

      setState(() {
        _survivor = survivorData;
        _joined = joined;
        _picks = {
          for (final dynamic item in predictions)
            if (item is Map<String, dynamic> &&
                item['matchId'] != null &&
                item['selectedTeam'] != null)
              item['matchId'].toString(): item['selectedTeam'].toString(),
        };
        final int? detailLives = survivorData['lives'] as int?;
        if (detailLives != null) {
          if (_maxLives == 0) {
            _maxLives = detailLives;
          } else if (detailLives > _maxLives) {
            _maxLives = detailLives;
          }
        }
        if (joined && _joinMessage == null) {
          _joinMessage = 'Ya estás jugando este Survivor.';
          _joinMessageVariant = InlineMessageVariant.info;
        }
        if (!joined && _joinMessageVariant == InlineMessageVariant.info) {
          _joinMessage = null;
          _joinMessageVariant = null;
        }
      });
    } catch (error) {
      final String message = error is ApiException
          ? error.message
          : 'No pudimos cargar el detalle. Intentá nuevamente.';
      setState(() {
        _error = message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingDetail = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TournamentStats stats = _buildStats(_survivor);
    final List<TournamentStage> stages = _buildStages(_survivor);
    final double topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadDetail,
            backgroundColor: const Color(0xFF121212),
            color: const Color(0xFFED9320),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderSection(
                    title: _survivor['name']?.toString() ?? 'Survivor',
                    stats: stats,
                    topPadding: topInset + kToolbarHeight,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_error != null) ...[
                          InlineMessage(
                            message: _error!,
                            variant: InlineMessageVariant.error,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _loadingDetail ? null : _loadDetail,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar carga'),
                          ),
                          const SizedBox(height: 24),
                        ],
                        SecondaryNav(
                          activeIndex: _activeTab,
                          onChanged: (int value) {
                            setState(() {
                              _activeTab = value;
                            });
                          },
                        ),
                        const SizedBox(height: 28),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _buildTabContent(stages),
                        ),
                        const SizedBox(height: 32),
                        _buildJoinSection(),
                        const SizedBox(height: 14),
                        DebugLivesControls(
                          onLoseLife: _simulateLoseLife,
                          onResetLives: _resetLives,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_loadingDetail)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 2,
                color: Color(0xFFED9320),
                backgroundColor: Color(0xFF1C1C1C),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabContent(List<TournamentStage> stages) {
    switch (_activeTab) {
      case 0:
        return _buildMatchesSection(stages);
      case 1:
        return _buildResultsSection();
      case 2:
        return _buildTableSection();
      default:
        return _buildMatchesSection(stages);
    }
  }

  Widget _buildMatchesSection(List<TournamentStage> stages) {
    final int currentLives = _survivor['lives'] is int
        ? _survivor['lives'] as int
        : 0;
    if (_loadingDetail) {
      return Container(
        key: const ValueKey('loading'),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF1F1F1F)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFFED9320)),
        ),
      );
    }

    if (stages.isEmpty) {
      return Container(
        key: const ValueKey('empty'),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF1F1F1F)),
        ),
        child: const Center(
          child: Text(
            'Sin partidos programados por ahora.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Column(
      key: const ValueKey('matches'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentLives <= 0) const LivesDepletedBanner(),
        if (!_joined)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF272727)),
            ),
            child: Row(
              children: const [
                Icon(Icons.lock_outline, color: Color(0xFFED9320), size: 18),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Unite al torneo para habilitar tus picks.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ...stages.map((stage) => _buildStageCard(stage, currentLives)).toList(),
      ],
    );
  }

  Widget _buildStageCard(TournamentStage stage, int currentLives) {
    final bool isExpanded = _expandedStages.contains(stage.id);
    final bool isLocked = stage.locked;
    final Color counterColor = isLocked
        ? Colors.white38
        : const Color(0xFFED9320);

    return Container(
      key: ValueKey<String>(stage.id),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1F1F1F)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: isLocked ? null : () => _toggleStage(stage.id),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isLocked ? Colors.white38 : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stage.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isLocked ? Colors.white30 : Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.sports_soccer, color: counterColor, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        stage.matchCount.toString(),
                        style: TextStyle(
                          color: isLocked ? Colors.white38 : Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    isLocked
                        ? Icons.lock_outline
                        : (isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down),
                    color: isLocked ? Colors.white38 : Colors.white70,
                  ),
                ],
              ),
            ),
          ),
          if (isLocked)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Disponible próximamente',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            )
          else
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  const Divider(height: 1, color: Color(0xFF1F1F1F)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                    child: _buildStageMatches(stage, currentLives),
                  ),
                ],
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
            ),
        ],
      ),
    );
  }

  Widget _buildStageMatches(TournamentStage stage, int currentLives) {
    if (stage.matches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF1F1F1F)),
        ),
        child: const Center(
          child: Text(
            'Sin partidos programados por ahora.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1F1F1F)),
      ),
      child: Column(
        children: stage.matches
            .map(
              (TournamentMatch match) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: MatchTile(
                  match: match,
                  joined: _joined && currentLives > 0,
                  selectedTeam: _picks[match.id],
                  loading: _pickingMatches.contains(match.id),
                  onPick: (String team) => _handlePick(match, team),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Container(
      key: const ValueKey('results'),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1F1F1F)),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Icon(Icons.hourglass_empty, color: Color(0xFFED9320), size: 32),
          SizedBox(height: 12),
          Text(
            'Cuando haya resultados los vas a ver acá mismo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSection() {
    const List<Map<String, String>> standings = [
      {'pos': '1', 'name': 'La Renga', 'streak': 'WWWWW', 'points': '39'},
      {'pos': '2', 'name': 'MatyFC', 'streak': 'WWWLW', 'points': '36'},
      {'pos': '3', 'name': 'Charly 10', 'streak': 'WLWWW', 'points': '34'},
      {'pos': '4', 'name': 'Gonza Key', 'streak': 'LWWWW', 'points': '32'},
      {'pos': '5', 'name': 'LuchoDR', 'streak': 'WWLLW', 'points': '30'},
    ];

    return Container(
      key: const ValueKey('table'),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1F1F1F)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: const [
                Expanded(
                  flex: 1,
                  child: Text(
                    '#',
                    style: TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Jugador',
                    style: TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Racha',
                    style: TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Pts',
                    style: TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0, color: Color(0xFF1F1F1F)),
          ...standings.map(
            (Map<String, String> row) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      row['pos']!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      row['name']!,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1C),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF272727)),
                      ),
                      child: Text(
                        row['streak']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFED9320),
                          fontSize: 12,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      row['points']!,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinSection() {
    final String? survivorId = _survivor['_id'] as String?;
    if (survivorId == null) {
      return const SizedBox.shrink();
    }

    final List<Widget> columnChildren = [];
    if (_joinMessage != null && _joinMessageVariant != null) {
      columnChildren.add(
        InlineMessage(message: _joinMessage!, variant: _joinMessageVariant!),
      );
      columnChildren.add(const SizedBox(height: 12));
    }

    columnChildren.add(
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: _joined
                ? const Color(0xFF1C1C1C)
                : const Color(0xFFED9320),
            foregroundColor: _joined ? Colors.white70 : Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _joined || _joining
              ? null
              : () => _joinSurvivor(survivorId),
          icon: _joining
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : Icon(
                  _joined ? Icons.verified_user_outlined : Icons.sports_soccer,
                ),
          label: Text(
            _joined ? 'Ya estás jugando este Survivor' : 'Unirme al torneo',
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: columnChildren,
    );
  }

  Future<void> _joinSurvivor(String survivorId) async {
    final bool confirmed = await showConfirmationDialog(
      context: context,
      title: '¿Unirte al Survivor?',
      message:
          'Vas a quedar registrado con 3 vidas iniciales y se habilitan tus picks. ¿Querés continuar?',
      confirmLabel: 'Sí, unirme',
      cancelLabel: 'No todavía',
    );

    if (!confirmed) {
      return;
    }

    setState(() {
      _joining = true;
      _joinMessage = null;
      _joinMessageVariant = null;
    });

    try {
      await SurvivorService.joinSurvivor(survivorId);
      if (!mounted) {
        return;
      }
      setState(() {
        _joined = true;
        _joinMessage = 'Te uniste al Survivor. ¡Éxitos en tus picks!';
        _joinMessageVariant = InlineMessageVariant.success;
      });
      _showSnack('Te uniste al Survivor. ¡Éxitos en tus picks!');
      await _loadDetail();
    } catch (error) {
      if (!mounted) {
        return;
      }
      final String message = error is ApiException
          ? error.message
          : 'No pudimos unirte. Probá de nuevo en un rato.';
      setState(() {
        _joinMessage = message;
        _joinMessageVariant = InlineMessageVariant.error;
      });
      _showSnack(message);
    } finally {
      if (mounted) {
        setState(() {
          _joining = false;
        });
      }
    }
  }

  Future<void> _handlePick(TournamentMatch match, String teamName) async {
    if (!_joined) {
      _showSnack('Primero tenés que unirte al Survivor.');
      return;
    }

    final String? survivorId = _survivor['_id'] as String?;
    if (survivorId == null) {
      return;
    }

    if (_picks.containsKey(match.id)) {
      _showSnack('Ya elegiste tu pick para este partido.');
      return;
    }

    final bool confirmed = await _confirmPick(teamName, match);
    if (!confirmed) {
      return;
    }

    setState(() {
      _pickingMatches.add(match.id);
    });

    try {
      await SurvivorService.makePick(survivorId, match.id, teamName);
      if (!mounted) return;
      setState(() {
        _picks = Map<String, String>.from(_picks)..[match.id] = teamName;
      });
      _showSnack('Pick guardado: $teamName');
    } catch (error) {
      if (!mounted) return;
      final String message = error is ApiException
          ? error.message
          : 'No pudimos guardar el pick. Intentá de nuevo.';
      _showSnack(message);
    } finally {
      if (mounted) {
        setState(() {
          _pickingMatches.remove(match.id);
        });
      }
    }
  }

  Future<bool> _confirmPick(String teamName, TournamentMatch match) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1C),
          title: const Text('Confirmar pick'),
          content: Text(
            '¿Seguro que querés elegir $teamName para el partido ${match.homeName} vs ${match.visitorName}? Recordá que no lo vas a poder cambiar.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _simulateLoseLife() {
    final int currentLives = _survivor['lives'] is int
        ? _survivor['lives'] as int
        : 0;
    if (currentLives <= 0) {
      _showSnack('No te quedan vidas disponibles.');
      return;
    }

    final int updatedLives = currentLives - 1;
    _updateLives(updatedLives);

    if (updatedLives <= 0) {
      _showSnack(
        'Has perdido todas tus vidas. ¡Suerte en tus próximos torneos!',
      );
    } else {
      _showSnack('Perdiste una vida. Te quedan $updatedLives.');
    }
  }

  void _resetLives() {
    const int restoredLives = 3;
    _updateLives(restoredLives);
    _showSnack('Vidas restablecidas a $restoredLives.');
  }

  void _toggleStage(String stageId) {
    setState(() {
      if (_expandedStages.contains(stageId)) {
        _expandedStages.remove(stageId);
      } else {
        _expandedStages.add(stageId);
      }
    });
  }

  void _updateLives(int value) {
    setState(() {
      final int sanitizedValue = value < 0 ? 0 : value;
      _survivor = Map<String, dynamic>.from(_survivor)
        ..['lives'] = sanitizedValue;
      if (sanitizedValue > _maxLives) {
        _maxLives = sanitizedValue;
      }
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  TournamentStats _buildStats(Map<String, dynamic> survivor) {
    final int lives = survivor['lives'] is int ? survivor['lives'] as int : 0;
    final int hash = survivor['name']?.hashCode ?? 0;
    final int displayMaxLives = _maxLives > 0
        ? _maxLives
        : (lives > 0 ? lives : 0);
    final String livesLabel = displayMaxLives > 0
        ? '${lives.clamp(0, displayMaxLives)}/$displayMaxLives VIDAS'
        : 'VIDAS';
    final String position = _formatPosition(hash);
    final int potValue = (hash.abs() % 5000) + 2500;
    final String pot = '\$${_formatThousands(potValue)}';
    final String survivors = ((hash % 50) + 25).toString();

    return TournamentStats(
      lives: livesLabel,
      position: position,
      pot: pot,
      survivors: survivors,
    );
  }

  List<TournamentStage> _buildStages(Map<String, dynamic> survivor) {
    final List<TournamentMatch> stageOneMatches = _buildMatches(survivor);
    final DateTime baseDate =
        _parseDate(survivor['startDate']) ?? DateTime.now();

    final List<TournamentStage> stages = <TournamentStage>[
      TournamentStage(
        id: 'stage-1',
        title: 'Jornada 1',
        subtitle: _formatStageDate(baseDate),
        matches: stageOneMatches,
        matchCount: stageOneMatches.length,
        locked: false,
      ),
    ];

    for (int index = 2; index <= 5; index++) {
      final DateTime mockDate = baseDate.add(Duration(days: (index - 1) * 7));
      stages.add(
        TournamentStage(
          id: 'stage-$index',
          title: 'Jornada $index',
          subtitle: _formatStageDate(mockDate),
          matches: const <TournamentMatch>[],
          matchCount: 3,
          locked: true,
        ),
      );
    }

    return stages;
  }

  List<TournamentMatch> _buildMatches(Map<String, dynamic> survivor) {
    final List<dynamic> competition =
        survivor['competition'] as List<dynamic>? ?? [];
    final DateTime start = _parseDate(survivor['startDate']) ?? DateTime.now();

    return competition.asMap().entries.map((entry) {
      final int index = entry.key;
      final Map<String, dynamic> match =
          (entry.value as Map<String, dynamic>?) ?? {};
      final Map<String, dynamic> home =
          (match['home'] as Map<String, dynamic>?) ?? {};
      final Map<String, dynamic> visitor =
          (match['visitor'] as Map<String, dynamic>?) ?? {};
      final DateTime kickoff = start.add(Duration(hours: index * 2));

      return TournamentMatch(
        id: match['matchId']?.toString() ?? 'match_$index',
        homeName: home['name']?.toString() ?? 'Local',
        homeFlag: home['flag']?.toString() ?? '⚽',
        visitorName: visitor['name']?.toString() ?? 'Visitante',
        visitorFlag: visitor['flag']?.toString() ?? '⚽',
        kickoff: _formatKickoff(kickoff),
      );
    }).toList();
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }

  static String _formatKickoff(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = _monthName(date.month);
    final String hour = date.hour.toString().padLeft(2, '0');
    final String minutes = date.minute.toString().padLeft(2, '0');
    return '$day $month $hour:$minutes';
  }

  static String _formatStageDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = _monthName(date.month);
    return '$day $month ${date.year}';
  }

  static String _monthName(int month) {
    const List<String> months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    final int safeIndex = month.clamp(1, months.length).toInt() - 1;
    return months[safeIndex];
  }

  static String _formatPosition(int hash) {
    final int top = (hash % 25) + 1;
    final int total = (hash.abs() % 4000) + 1200;
    return '${top.toString().padLeft(2, '0')}/${_formatThousands(total)}';
  }

  static String _formatThousands(int number) {
    final String value = number.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      final int index = value.length - 1 - i;
      buffer.write(value[index]);
      if ((i + 1) % 3 == 0 && index != 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join();
  }
}
