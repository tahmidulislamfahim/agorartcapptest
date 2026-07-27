import 'dart:convert';
import 'package:agorartcapptest/core/api_endpoint/api_endpoint.dart';

import 'package:agorartcapptest/core/services/network_service/network_service.dart';
import 'package:agorartcapptest/features/auth/models/user_model.dart';

class AuthService {
  final NetworkService _networkService = NetworkService();

  Future<UserModel> register(String username, String email, String password) async {
    final response = await _networkService.post(
      ApiEndpoint.register,
      body: {
        'username': username,
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return UserModel.fromJson(json);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Registration failed');
    }
  }

  Future<Map<String, dynamic>> login(String usernameOrEmail, String password) async {
    final response = await _networkService.post(
      ApiEndpoint.login,
      body: {
        'username_or_email': usernameOrEmail,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Login failed');
    }
  }

  Future<UserModel> getMe() async {
    final response = await _networkService.get(ApiEndpoint.getMe);
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }
}
