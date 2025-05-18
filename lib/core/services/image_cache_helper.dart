import 'dart:io';
import 'package:code_structure/core/services/cache_manager.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageCacheHelper {
  static final CacheManager _cacheManager = CacheManager();
  static final Dio _dio = Dio();

  /// Get file extension from a URL
  static String getFileExtension(String url) {
    // Try to extract extension from URL
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      final fileName = pathSegments.last;
      final extension = path.extension(fileName);
      if (extension.isNotEmpty) {
        return extension.substring(1); // Remove the dot
      }
    }

    // Default to jpg if no extension found
    return 'jpg';
  }

  /// Check if a file with this URL is already cached
  static Future<File?> getCachedImage(String url) async {
    try {
      final fileExtension = getFileExtension(url);
      return await _cacheManager.getCachedFile(url, fileExtension);
    } catch (e) {
      print('Error checking cached image: $e');
      return null;
    }
  }

  /// Download and cache an image from a URL
  static Future<File?> downloadAndCacheImage(String url) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileExtension = getFileExtension(url);
      final tempFile = File('${tempDir.path}/temp_img.$fileExtension');

      // Download the file
      await _dio.download(
        url,
        tempFile.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // Can update progress if needed (e.g., via callback)
          }
        },
      );

      // Cache the downloaded file
      final cachedFile =
          await _cacheManager.cacheFile(url, tempFile, fileExtension);

      // Delete the temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      return cachedFile;
    } catch (e) {
      print('Error downloading and caching image: $e');
      return null;
    }
  }

  /// Get a cached image or download it if not available
  static Future<File?> getOrDownloadImage(String url) async {
    // First check if it's already cached
    final cachedFile = await getCachedImage(url);
    if (cachedFile != null) {
      return cachedFile;
    }

    // If not cached, download and cache it
    return await downloadAndCacheImage(url);
  }

  /// Cache a local file with a URL as key (useful for newly selected images)
  static Future<File?> cacheLocalFile(String url, File localFile) async {
    try {
      final fileExtension = path.extension(localFile.path);
      final extension = fileExtension.isNotEmpty
          ? fileExtension.substring(1) // Remove the dot
          : 'jpg';

      return await _cacheManager.cacheFile(url, localFile, extension);
    } catch (e) {
      print('Error caching local file: $e');
      return null;
    }
  }

  /// Clear all cached images
  static Future<void> clearCache() async {
    try {
      await _cacheManager.clearCache();
    } catch (e) {
      print('Error clearing image cache: $e');
    }
  }

  /// Remove a specific URL from the cache
  static Future<bool> removeFromCache(String url) async {
    try {
      final fileExtension = getFileExtension(url);
      final cacheDir = await _cacheManager.getCacheDirectory();
      final cacheKey = _cacheManager.generateCacheKey(url);
      final file = File('$cacheDir/$cacheKey.$fileExtension');

      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing file from cache: $e');
      return false;
    }
  }
}
