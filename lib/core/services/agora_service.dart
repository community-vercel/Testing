import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgoraService {
  static const String appId = "7564ffdc7bb94a719019cbc9980d3427";
  // Replace with your Firebase Functions URL
  static const String serverUrl =
      "https://generatetoken-lczraojsja-uc.a.run.app";

  Future<String> generateToken(String channelName) async {
    log('Generating Agora token for channel: $channelName');
    try {
      // Validate channel name
      if (channelName.isEmpty) {
        throw Exception('Channel name cannot be empty');
      }

      // Validate channel name length (64 bytes)
      if (channelName.length > 64) {
        throw Exception('Channel name must be less than 64 bytes');
      }

      // Validate channel name characters
      final validCharacters = RegExp(
        r'^[a-zA-Z0-9!#\$%&\(\)\+\-\:;<=>?@\[\]\^_\{\}\|~,]+$',
      );
      if (!validCharacters.hasMatch(channelName)) {
        throw Exception('Channel name contains invalid characters');
      }

      log('Channel name validation passed: $channelName');

      // Get the current user's Firebase ID token
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        log('User not authenticated');
        throw Exception('User not authenticated');
      }

      log('Getting Firebase ID token');
      final idToken = await user.getIdToken();
      log('Got Firebase ID token');

      log('Making request to token server: $serverUrl');
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'channelName': channelName, 'uid': 0}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['rtcToken'];
        log('Token generated successfully: ${data.toString()}');

        // if (!token.startsWith('006')) {
        //   log('Invalid token format. Token should start with "006"');
        //   throw Exception('Invalid token format');
        // }

        return token;
      }
      log(
        'Failed to generate token. Status code: ${response.statusCode}, Response: ${response.body}',
      );
      throw Exception('Failed to generate token: ${response.body}');
    } catch (e) {
      log('Error generating token: $e');
      // For development/testing, return a temporary token
      // In production, always use a token server
      return "0063c7b549ae83a4ac98b285578e3648f80IAAmpq1iHwWlfW1TmQ3V2F1qHsaI4tRNM8ITmHYCWHl/f9Cv6zUAAAAAIgC8nCog/s/kZwQAAQCOjONnAgCOjONnAwCOjONnBACOjONn";
    }
  }

  Future<void> initializeEngine() async {
    final engine = createAgoraRtcEngine();
    await engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );
  }
}
