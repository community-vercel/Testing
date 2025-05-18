import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class NotificationService {
  static const String _fcmEndpoint =
      'https://fcm.googleapis.com/v1/projects/buzz-me-a3d75/messages:send';

  Future<String> _getAccessToken() async {
    try {
      final accountCredentials = ServiceAccountCredentials.fromJson(
        {
          "type": "service_account",
          "project_id": "buzz-me-a3d75",
          "private_key_id": "8e255172c8c9462370654eaf225a2e459c414ce7",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQD3SmZl7/dnAxPq\nFzX/XAP73AdwicLJ5tl2aMecIDWZ8j33ALW1r4RkCTi6lMLKuK144aGrIrIwBYxj\nWcjzevx5arUtjrduLwnsrgcZTuM76dXD3Sy0ICG6DDKDQlS4fN0xV+qmJFLqLv1f\nLhLt3eUYey8t41NXj1vOv38C0I07EITx050Sty2+vQMgLWzV6hFqFi4bA8CCdiY2\nGUr2mIF3bYeC0z/NtCLvgloUFmqrjsHrzIPUAxZ6937x9LA2r8rWlgLnZD6DTnwG\nQm9h+hEG+QGV2ac0VGmG0+u1I1TPnje6huii6jPA6UTrmgd5Lrpt/wGfjSWPKx3E\ntQr+kszZAgMBAAECggEASTp37jHMUm3f5M8wx0ipSVjTvyicTQuWU/EdQwdquAa7\nALzuEjpCexkb+mx47m0XuZcfN71ThNLvyq/YyPkfcJj/w9jiSreVOcgjBASPV7ub\n+J8zULe/JQfdoW7wBZ28JpOBQee5we1eTGQpaNTvtXss8mrB0Ej8h9G/O8ckO1vI\n6SbvOZSWErGz9E9MbbEB7okoPRGkblYZSboL9jHURPgpP/UQggdZkbAUoY872qTr\nl0jiXueC5VHSGI3AJdiAn8AnlXuam0CK1jTkNaCFcAphkSBx5lwt3ZzdfyGnXAeF\n5WeENgePf1UCmrhsat1XqtKsPRb0VT8qhIRglAcVXQKBgQD/3SwDWlsvZEOZwtXW\njBRU2L1AxqpNWOCkU0Ubm04TwUwW6QwoFH8oTDbLTVI5qgGkfg25FUG9J9WZMAI0\nBCoDBC60pzWR0ywOZzXe3DCADC8/5yYd1y9RcfKDZKACAOreuy2K0QMSKPnVUxtB\nUKjart4nRq2oGj6BpsRuqMNTYwKBgQD3bA+iQt5aThPbmXojV1Y8eZAHgsihlQ7p\nANjwGh2+fxrUBUSZmhqrB2uboRuGPEfzaYtTJOHoQLHpoX/EFME9atfO6/D94Zll\n0MG9Ma8ySVE1SF1OT05umtb/jPqk0h5eP5xbJeuLFZLwzmTMhprrhiojfrqdhY06\nXJy9hMnZkwKBgQDoHX9WM1xRrAXfse9ISaAQMOfPoerRbHWu3ZPuLYAxT8R1bEoI\n+j85EZsL6ENV6LLAxVIxu+T9cuvFotX81mI+hkbQwHhKqGZpUpx+Zwbgwy0CLfJY\nU+SrYFH/fQPjjW2FTg1Mx7yfduje7BvnrwLgEI+c1fOoctaNy/qb4SIBvQKBgQD3\nG9fpaPuGGaC/nGNd1KZuM8LjnX0f1C1WDOCdvJekYHG8+53uAvlLg1e30YoZ4S7D\nLtBVs+pj+ek2u3NNtKTi4Ei1gvPnvF9mTr6QZITjplIS8zktMwvUb5T3GihiYPCv\nlLxmVFMRT/S3yIrnsjAbtp1zYeij1nScq05oAa1PPQKBgQCBF3r2Iqflaw24OHCi\ngf3Ov6myDDHd/8Izj3rQIJCiMP/gd10vATEHdFMfZafsV1LwESHZ9whA5723lEL6\nycfLgjjpi7OaP2xSWr95KK82Po9A0WwGc1EhOayzOyukMaYnR4dMJfkMPWGaWWwb\ndVPTiq/GedR3FoGFqVTJV/DBOQ==\n-----END PRIVATE KEY-----\n",
          "client_email":
              "firebase-adminsdk-fbsvc@buzz-me-a3d75.iam.gserviceaccount.com",
          "client_id": "101059376418645324849",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40buzz-me-a3d75.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        },
      );
      var scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
log('accesstoken ' + accountCredentials.email);
      AuthClient client =
          await clientViaServiceAccount(accountCredentials, scopes);

      log('accesstoken ' + client.toString());

      return client.credentials.accessToken.data;
    } catch (e) {
      throw Exception('Failed to get access token: $e');
    }
  }

  // Send call notification
  Future<bool> sendCallNotification({
    required String recipientToken,
    required String callerName,
    required String callerId,
    required String callType,
    required String callId,
  }) async {
    try {
      final token = await _getAccessToken();

      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': {
            'token': recipientToken,
            'data': {
              'type': 'call',
              'callType': callType,
              'callerName': callerName,
              'callerId': callerId,
              'callId': callId,
              'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            },
            'android': {
              'priority': 'high',
              'notification': {
                'channelId': 'Incoming Calls',
                'defaultSound': true,
                'defaultVibrateTimings': true,
              },
            },
            'apns': {
              'headers': {
                'apns-priority': '10',
                'apns-push-type': 'background',
              },
              'payload': {
                'aps': {
                  'content-available': 1,
                  'sound': 'default',
                  'category': 'call',
                  'priority': 10,
                },
              },
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }
      print('FCM Error: ${response.body}');
      return false;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  // Send call ended notification
  Future<bool> sendCallEndedNotification({
    required String recipientToken,
    required String callId,
  }) async {
    try {
      final token = await _getAccessToken();

      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': {
            'token': recipientToken,
            'data': {
              'type': 'call_ended',
              'callId': callId,
              'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }
      print('FCM Error: ${response.body}');
      return false;
    } catch (e) {
      print('Error sending call ended notification: $e');
      return false;
    }
  }

  // Send call rejected notification
  Future<bool> sendCallRejectedNotification({
    required String recipientToken,
    required String callId,
  }) async {
    try {
      final token = await _getAccessToken();

      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': {
            'token': recipientToken,
            'data': {
              'type': 'call_rejected',
              'callId': callId,
              'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }
      print('FCM Error: ${response.body}');
      return false;
    } catch (e) {
      print('Error sending call rejected notification: $e');
      return false;
    }
  }
}
