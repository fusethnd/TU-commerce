import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
class NotificationService {
  final String serverKey =
      'AAAAJyGO45I:APA91bEAm0BD51p3onfptJ_oz7s90U4f-nLF0JnKdVOC1FwUPyYiX64-jRuDWc8iF6F3WTQH92-BZoteiBcXPyoDfxNXSQ1qws5-jZd0DkK0IDpejkzA6G4mDAAhJEVteGUxqaD_3jKY'; // Obtain from Firebase Console

  Future<void> sendNotification(String recipientToken, String message) async {
    print('Sending notification...');
    try {
      final Map<String, dynamic> notification = {
        'to': recipientToken,
        'data': {
          'title': 'New Message',
          'body': message,
        }
      };

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(notification),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print(
            'Failed to send notification. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> requestNotificationPermissions() async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notification permissions granted.');
    } else {
      print(
          'User declined or has not yet granted notification permissions.');
    }
  }
}