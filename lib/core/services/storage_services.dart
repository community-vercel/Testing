import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final uuid = const Uuid();

  Future<String> uploadChatFile(File file, String chatId) async {
    try {
      final String fileName = '${uuid.v4()}${path.extension(file.path)}';
      final Reference ref = _storage.ref().child('chats/$chatId/$fileName');
      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      throw Exception('Failed to upload file');
    }
  }

  Future<String> uploadProfileImage(File file, String userId) async {
    try {
      final String fileName = '${uuid.v4()}${path.extension(file.path)}';
      final Reference ref = _storage.ref().child('profiles/$userId/$fileName');
      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      throw Exception('Failed to upload file');
    }
  }

  Future<String> uploadAudio(File audioFile, String chatId) async {
    try {
      final String fileName = '${uuid.v4()}.m4a';
      final Reference ref =
          _storage.ref().child('chats/$chatId/audio/$fileName');
      final UploadTask uploadTask = ref.putFile(audioFile);
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading audio: $e');
      throw Exception('Failed to upload audio');
    }
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
      throw Exception('Failed to delete file');
    }
  }
}
