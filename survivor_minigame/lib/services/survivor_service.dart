import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => message;
}

class SurvivorService {
  static const String baseUrl = 'http://localhost:4300/api/survivor';

  static Future<List<dynamic>> fetchSurvivors() async {
    final http.Response response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final dynamic body = _decodeBody(response.body);
      if (body is List) {
        return body;
      }
      throw ApiException('Formato de respuesta inválido');
    }
    throw _buildError(response, 'No pudimos obtener los survivors.');
  }

  static Future<Map<String, dynamic>> fetchSurvivorDetail(String id) async {
    final http.Response response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      final dynamic body = _decodeBody(response.body);
      if (body is Map<String, dynamic>) {
        return body;
      }
      throw ApiException('Formato de respuesta inválido');
    }
    throw _buildError(response, 'No pudimos cargar el detalle.');
  }

  static Future<Map<String, dynamic>> joinSurvivor(String id) async {
    final http.Response response = await http.post(
      Uri.parse('$baseUrl/join/$id'),
    );
    if (response.statusCode == 200) {
      final dynamic body = _decodeBody(response.body);
      if (body is Map<String, dynamic>) {
        return body;
      }
      throw ApiException('Formato de respuesta inválido');
    }
    throw _buildError(response, 'No pudimos completar el ingreso.');
  }

  static Future<Map<String, dynamic>> makePick(
    String survivorId,
    String matchId,
    String selectedTeam,
  ) async {
    final http.Response response = await http.post(
      Uri.parse('$baseUrl/pick'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'survivorId': survivorId,
        'matchId': matchId,
        'selectedTeam': selectedTeam,
      }),
    );
    if (response.statusCode == 200) {
      final dynamic body = _decodeBody(response.body);
      if (body is Map<String, dynamic>) {
        return body;
      }
      throw ApiException('Formato de respuesta inválido');
    }
    throw _buildError(response, 'No pudimos registrar el pick.');
  }

  static dynamic _decodeBody(String body) {
    if (body.isEmpty) {
      return null;
    }
    try {
      return json.decode(body);
    } catch (_) {
      return null;
    }
  }

  static ApiException _buildError(http.Response response, String fallback) {
    final dynamic body = _decodeBody(response.body);
    String message = fallback;
    if (body is Map<String, dynamic>) {
      final dynamic detail = body['message'] ?? body['error'];
      if (detail is String && detail.trim().isNotEmpty) {
        message = detail.trim();
      }
    }
    return ApiException(message, code: response.statusCode);
  }
}
