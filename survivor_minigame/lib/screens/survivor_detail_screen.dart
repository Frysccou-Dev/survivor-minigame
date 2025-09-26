import 'package:flutter/material.dart';
import '../services/survivor_service.dart';
import '../widgets/survivor_stats.dart';
import '../widgets/jornada_dropdown.dart';

class SurvivorDetailScreen extends StatefulWidget {
  final Map<String, dynamic> survivor;

  const SurvivorDetailScreen({super.key, required this.survivor});

  @override
  State<SurvivorDetailScreen> createState() => _SurvivorDetailScreenState();
}

class _SurvivorDetailScreenState extends State<SurvivorDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isJoined = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.survivor['name'])),
      body: Column(
        children: [
          SurvivorStats(survivor: widget.survivor), // Stats mocks
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Por jugar'),
              Tab(text: 'Resultados'),
              Tab(text: 'Tabla'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                JornadaDropdown(competition: widget.survivor['competition']), // Lista de partidos
                const Center(child: Text('Resultados mock - Próximamente')), // Mock
                const Center(child: Text('Tabla de mejores jugadores mock - Próximamente')), // Mock
              ],
            ),
          ),
          if (!isJoined)
            ElevatedButton(
              onPressed: () async {
                try {
                  await SurvivorService.joinSurvivor(widget.survivor['_id']);
                  setState(() => isJoined = true);
                  // Feedback o navegación
                } catch (e) {
                  // Manejar error
                }
              },
              child: const Text('Unirse al Torneo'),
            ),
        ],
      ),
    );
  }
}