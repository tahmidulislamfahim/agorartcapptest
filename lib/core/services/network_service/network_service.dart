import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  void _logRequest(String method, String url, {dynamic body}) {
    debugPrint('--------------------------------------------------');
    debugPrint('🌐 HTTP $method API: $url');
    if (body != null) {
      debugPrint('📦 Request Body: $body');
    }
  }

  void _logResponse(String method, String url, http.Response response) {
    debugPrint('📥 Response Status Code [$method $url]: ${response.statusCode}');
    debugPrint('📄 Response Body: ${response.body}');
    debugPrint('--------------------------------------------------');
  }

  Future<http.Response> get(String url) async {
    final headers = await _getHeaders();
    _logRequest('GET', url);
    final response = await _client.get(Uri.parse(url), headers: headers);
    _logResponse('GET', url, response);
    return response;
  }

  Future<http.Response> post(String url, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final String? bodyJson = body != null ? jsonEncode(body) : null;
    _logRequest('POST', url, body: bodyJson);
    final response = await _client.post(Uri.parse(url), headers: headers, body: bodyJson);
    _logResponse('POST', url, response);
    return response;
  }

  Future<http.Response> put(String url, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final String? bodyJson = body != null ? jsonEncode(body) : null;
    _logRequest('PUT', url, body: bodyJson);
    final response = await _client.put(Uri.parse(url), headers: headers, body: bodyJson);
    _logResponse('PUT', url, response);
    return response;
  }
}
