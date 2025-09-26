import 'package:flutter/material.dart';
import '../services/survivor_service.dart';
import 'tournament_screens.dart';

class SurvivorListScreen extends StatefulWidget {
  static const routeName = '/';

  const SurvivorListScreen({super.key});

  @override
  State<SurvivorListScreen> createState() => _SurvivorListScreenState();
}

class _SurvivorListScreenState extends State<SurvivorListScreen> {
  bool _isLoading = false;
  String? _error;
  List<dynamic> _survivors = [];

  @override
  void initState() {
    super.initState();
    _fetchSurvivors();
  }

  Future<void> _fetchSurvivors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await SurvivorService.fetchSurvivors();
      setState(() {
        _survivors = data;
      });
    } catch (error) {
      setState(() {
        _error = 'No pudimos cargar los torneos. Intenta de nuevo.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Penka Survivor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchSurvivors,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSurvivors,
        backgroundColor: const Color(0xFF121212),
        color: const Color(0xFFED9320),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _survivors.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF272727)),
            ),
            child: Text(_error!, style: const TextStyle(color: Colors.white70)),
          ),
        ],
      );
    }

    if (_survivors.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(
            child: Text(
              'No encontramos torneos disponibles.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _survivors.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final survivor = _survivors[index] as Map<String, dynamic>;
        return _SurvivorCard(
          survivor: survivor,
          onTap: () {
            Navigator.pushNamed(
              context,
              SurvivorDetailScreen.routeName,
              arguments: survivor,
            );
          },
        );
      },
    );
  }
}

class _SurvivorCard extends StatelessWidget {
  final Map<String, dynamic> survivor;
  final VoidCallback onTap;

  const _SurvivorCard({required this.survivor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final DateTime? startDate = _parseDate(survivor['startDate']);
    final String formattedDate = startDate != null
        ? '${_twoDigits(startDate.day)} ${_monthName(startDate.month)} ${startDate.year}'
        : 'Fecha a definir';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1C1C1C), Color(0xFF121212)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF1F1F1F)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFED9320).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${survivor['lives']} vidas',
                    style: const TextStyle(
                      color: Color(0xFFED9320),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white70,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              survivor['name'] ?? 'Torneo',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.white60,
                ),
                const SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 12, color: Colors.white60),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  static String _monthName(int month) {
    const months = [
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
    if (month < 1 || month > 12) {
      return '';
    }
    return months[month - 1];
  }
}
