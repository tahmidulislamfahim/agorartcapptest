import 'dart:convert';
import 'package:agorartcapptest/core/api_endpoint/api_endpoint.dart';
import 'package:agorartcapptest/core/services/network_service/network_service.dart';
import 'package:agorartcapptest/features/auth/models/user_model.dart';

class UserListService {
  final NetworkService _networkService = NetworkService();

  Future<List<UserModel>> getUsers() async {
    final response = await _networkService.get(ApiEndpoint.getUsers);
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((item) => UserModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch user list');
    }
  }
}
