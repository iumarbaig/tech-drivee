import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  static const String _projectId = 'techdrive-1495f';

  static Future<String> _getAccessToken() async {
    final jsonString = await rootBundle
        .loadString('assets/keys/techdrive-1495f-8fe6cc5bfa3b.json');
    final credentials =
    ServiceAccountCredentials.fromJson(jsonDecode(jsonString));

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(credentials, scopes);
    final token = client.credentials.accessToken.data;
    client.close();
    return token;
  }

  static Future<void> sendNotification({
    required String recipientUid,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(recipientUid)
          .get();

      if (!userDoc.exists) return;
      final token = userDoc.data()?['fcmToken'];
      if (token == null) return;

      final accessToken = await _getAccessToken();

      final response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': data?.map((k, v) => MapEntry(k, v.toString())) ?? {},
          }
        }),
      );

      print("FCM Response: ${response.statusCode} - ${response.body}");
    } catch (e) {
      print("Notification error: $e");
    }
  }
}