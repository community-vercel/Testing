import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:code_structure/core/services/cache_manager.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({required this.videoUrl, Key? key}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  final CacheManager _cacheManager = CacheManager();
  final Dio _dio = Dio();

  bool _isInitialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Check if video is cached
      final extension = _getFileExtension(widget.videoUrl);
      final cachedFile =
          await _cacheManager.getCachedFile(widget.videoUrl, extension);

      if (cachedFile != null) {
        // Use cached video file
        _videoPlayerController = VideoPlayerController.file(cachedFile);
      } else {
        // Download and cache the video
        final downloadedFile =
            await _downloadAndCacheVideo(widget.videoUrl, extension);

        if (downloadedFile != null) {
          _videoPlayerController = VideoPlayerController.file(downloadedFile);
        } else {
          // Fallback to network streaming if download fails
          _videoPlayerController =
              VideoPlayerController.network(widget.videoUrl);
        }
      }

      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Error loading video: $errorMessage',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      );

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing video player: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getFileExtension(String url) {
    // Try to extract extension from URL or default to mp4
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      final fileName = pathSegments.last;
      final extension = path.extension(fileName);
      if (extension.isNotEmpty) {
        return extension.substring(1); // Remove the dot
      }
    }
    return 'mp4'; // Default extension
  }

  Future<File?> _downloadAndCacheVideo(String url, String extension) async {
    try {
      setState(() => _isLoading = true);

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_video.$extension');

      // Download the file
      await _dio.download(url, tempFile.path);

      // Cache the downloaded file
      final cachedFile =
          await _cacheManager.cacheFile(url, tempFile, extension);

      // Delete the temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      return cachedFile;
    } catch (e) {
      print('Error downloading video: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Video', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : _isInitialized
                ? Chewie(controller: _chewieController!)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Failed to load video',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
      ),
    );
  }
}
