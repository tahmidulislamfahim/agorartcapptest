import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agorartcapptest/core/services/local_service/shared_preferences_helper.dart';

class NetworkService {
  final http.Client _client = http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final token = await SharedPreferencesHelper.getAccessToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'accept': '*/*',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> get(String url) async {
    final headers = await _getHeaders();
    return await _client.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> post(String url, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final String? bodyJson = body != null ? jsonEncode(body) : null;
    return await _client.post(Uri.parse(url), headers: headers, body: bodyJson);
  }

  Future<http.Response> put(String url, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final String? bodyJson = body != null ? jsonEncode(body) : null;
    return await _client.put(Uri.parse(url), headers: headers, body: bodyJson);
  }
}
