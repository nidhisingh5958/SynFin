import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatApiService {
  // Replace with your actual API base URL
  static const String baseUrl = 'https://your-api-url.com';

  /// Send a chat message to the backend
  ///
  /// Parameters:
  /// - customerId: The customer's unique ID
  /// - message: The user's message
  /// - applicationId: Optional application ID for existing conversations
  /// - dataUpdate: Optional data to update in the backend
  Future<ChatResponse> sendMessage({
    required String customerId,
    required String message,
    String? applicationId,
    Map<String, dynamic>? dataUpdate,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/chat');

      final requestBody = {
        'customer_id': customerId,
        'message': message,
        if (applicationId != null) 'application_id': applicationId,
        if (dataUpdate != null) 'data_update': dataUpdate,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatResponse.fromJson(data);
      } else if (response.statusCode == 422) {
        final error = jsonDecode(response.body);
        throw ApiException('Validation error: ${error['detail']}');
      } else {
        throw ApiException('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }
}

class ChatResponse {
  final String? applicationId;
  final String? agentName;
  final String? message;
  final String? status;
  final String? actionRequired;

  ChatResponse({
    this.applicationId,
    this.agentName,
    this.message,
    this.status,
    this.actionRequired,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      applicationId: json['application_id'],
      agentName: json['agent_name'],
      message: json['message'],
      status: json['status'],
      actionRequired: json['action_required'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'application_id': applicationId,
      'agent_name': agentName,
      'message': message,
      'status': status,
      'action_required': actionRequired,
    };
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
