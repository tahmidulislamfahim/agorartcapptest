import 'dart:convert';
import 'package:agorartcapptest/core/api_endpoint/api_endpoint.dart';
import 'package:agorartcapptest/core/services/network_service/network_service.dart';
import 'package:agorartcapptest/features/call/models/call_model.dart';

class CallService {
  final NetworkService _networkService = NetworkService();

  Future<CallModel> initiateCall(int receiverId, String callType) async {
    final response = await _networkService.post(
      ApiEndpoint.initiateCall,
      body: {
        'receiver_id': receiverId,
        'call_type': callType,
      },
    );

    if (response.statusCode == 200) {
      return CallModel.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to initiate call');
    }
  }

  Future<CallModel> updateCallStatus(int callId, String status) async {
    final response = await _networkService.post(
      ApiEndpoint.updateCallStatus,
      body: {
        'call_id': callId,
        'status': status,
      },
    );

    if (response.statusCode == 200) {
      return CallModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update call status');
    }
  }

  Future<List<CallModel>> getCallHistory() async {
    final response = await _networkService.get(ApiEndpoint.getCallHistory);
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((item) => CallModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch call history');
    }
  }
}
