import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  Future<String> getCacheDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${directory.path}/media_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  String generateCacheKey(String url) {
    // Create a hash of the URL to use as the filename
    final bytes = utf8.encode(url);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  Future<File?> getCachedFile(String url, String extension) async {
    final cacheDir = await getCacheDirectory();
    final cacheKey = generateCacheKey(url);
    final file = File('$cacheDir/$cacheKey.$extension');

    if (await file.exists()) {
      return file;
    }
    return null;
  }

  Future<File> cacheFile(String url, File sourceFile, String extension) async {
    final cacheDir = await getCacheDirectory();
    final cacheKey = generateCacheKey(url);
    final targetFile = File('$cacheDir/$cacheKey.$extension');

    if (!await targetFile.exists()) {
      await sourceFile.copy(targetFile.path);
    }

    return targetFile;
  }

  Future<void> clearCache() async {
    final cacheDir = await getCacheDirectory();
    final directory = Directory(cacheDir);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
      await directory.create();
    }
  }
}
