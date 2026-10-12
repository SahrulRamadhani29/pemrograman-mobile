import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/mahasiswa.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.66.5:8000/api/mahasiswa',
  );
  final http.Client _client;
  static const headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
  Future<List<Mahasiswa>> getAll({String search = ''}) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: search.trim().isEmpty ? null : {'search': search.trim()},
    );
    final response = await _client.get(uri, headers: headers);
    _check(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['data'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Mahasiswa.fromJson)
        .toList();
  }

  Future<Mahasiswa> getById(int id) async {
    final r = await _client.get(Uri.parse('$baseUrl/$id'), headers: headers);
    _check(r);
    return Mahasiswa.fromJson((jsonDecode(r.body) as Map)['data']);
  }

  Future<Mahasiswa> create(Mahasiswa m) async {
    final r = await _client.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(m.toJson()),
    );
    _check(r, expected: 201);
    return Mahasiswa.fromJson((jsonDecode(r.body) as Map)['data']);
  }

  Future<Mahasiswa> update(Mahasiswa m) async {
    final r = await _client.put(
      Uri.parse('$baseUrl/${m.id}'),
      headers: headers,
      body: jsonEncode(m.toJson()),
    );
    _check(r);
    return Mahasiswa.fromJson((jsonDecode(r.body) as Map)['data']);
  }

  Future<void> delete(int id) async {
    final r = await _client.delete(Uri.parse('$baseUrl/$id'), headers: headers);
    _check(r);
  }

  void _check(http.Response response, {int expected = 200}) {
    if (response.statusCode == expected) return;
    Map<String, dynamic>? body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = null;
    }
    if (body != null) {
      final errors = body['errors'] as Map<String, dynamic>?;
      final detail = errors?.values
          .expand((v) => v is List ? v : [v])
          .join('\n');
      throw Exception(
        detail ??
            body['message'] ??
            'Permintaan gagal (${response.statusCode}).',
      );
    }
    throw Exception(
      'Permintaan gagal (${response.statusCode}). Periksa server Laravel.',
    );
  }
}
