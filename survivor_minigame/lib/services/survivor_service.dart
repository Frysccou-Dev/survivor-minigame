import 'dart:convert';
import 'package:http/http.dart' as http;

class SurvivorService {
  static const String baseUrl = 'http://localhost:4300/api/survivor';

  // Obtener lista de survivors
  static Future<List<dynamic>> fetchSurvivors() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener survivors: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> fetchSurvivorDetail(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al obtener detalle: ${response.statusCode}');
    }
  }

  // Unirse a un survivor
  static Future<Map<String, dynamic>> joinSurvivor(String id) async {
    final response = await http.post(Uri.parse('$baseUrl/join/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al unirse: ${response.statusCode}');
    }
  }

  // Hacer un pick
  static Future<Map<String, dynamic>> makePick(
    String survivorId,
    String matchId,
    String selectedTeam,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pick'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'survivorId': survivorId,
        'matchId': matchId,
        'selectedTeam': selectedTeam,
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al hacer pick: ${response.statusCode}');
    }
  }
}
