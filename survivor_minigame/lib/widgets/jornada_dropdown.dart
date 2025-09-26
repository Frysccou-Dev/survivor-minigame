import 'package:flutter/material.dart';

class JornadaDropdown extends StatelessWidget {
  final List<dynamic> competition;
  final String? startDate;

  const JornadaDropdown({
    super.key,
    required this.competition,
    this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Jornada 1'),
      children: competition.asMap().entries.map((entry) {
        final int index = entry.key;
        final match = entry.value;
        final DateTime? start = _parseDate(startDate);
        final DateTime kickoff = start?.add(Duration(hours: index * 2)) ?? DateTime.now();
        final String formattedDate = _formatKickoff(kickoff);

        return Card(
          child: ListTile(
            leading: Text(match['home']['flag']),
            title: Text('${match['home']['name']} vs ${match['visitor']['name']}'),
            subtitle: Text('Día y Hora: $formattedDate'),
            trailing: Text(match['visitor']['flag']),
          ),
        );
      }).toList(),
    );
  }

  // Funciones auxiliares copiadas de tournament_screens.dart
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

  static String _monthName(int month) {
    const List<String> months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    final int safeIndex = month.clamp(1, months.length).toInt() - 1;
    return months[safeIndex];
  }
}