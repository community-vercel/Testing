import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:code_structure/core/services/cache_manager.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;
  final double width;
  final double height;
  final bool isCurrentUser;

  const VideoThumbnailWidget({
    required this.videoUrl,
    required this.width,
    required this.height,
    required this.isCurrentUser,
    Key? key,
  }) : super(key: key);

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  final CacheManager _cacheManager = CacheManager();
  String? _thumbnailPath;
  File? _cachedVideoFile;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadVideoAndGenerateThumbnail();
  }

  Future<void> _loadVideoAndGenerateThumbnail() async {
    try {
      // First check if we have a cached video
      final extension = _getFileExtension(widget.videoUrl);
      _cachedVideoFile =
          await _cacheManager.getCachedFile(widget.videoUrl, extension);

      // If we already have a cached video, generate thumbnail from it
      if (_cachedVideoFile != null) {
        await _generateThumbnailFromFile(_cachedVideoFile!.path);
      } else {
        // Check if we already have a cached thumbnail
        final thumbnailFile = await _cacheManager.getCachedFile(
            "${widget.videoUrl}_thumbnail", "jpg");

        if (thumbnailFile != null) {
          // Use the cached thumbnail
          setState(() {
            _thumbnailPath = thumbnailFile.path;
            _isLoading = false;
          });
        } else {
          // Generate and cache the thumbnail from URL
          await _generateThumbnailFromUrl();
        }

        // Start downloading and caching the video for future use
        _downloadAndCacheVideo(widget.videoUrl, extension);
      }
    } catch (e) {
      print('Error loading video or generating thumbnail: $e');
      setState(() {
        _hasError = true;
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

  Future<void> _generateThumbnailFromFile(String filePath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: filePath,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: (widget.width * 2).toInt(),
        quality: 75,
      );

      if (thumbnailPath != null) {
        // Cache the thumbnail
        final thumbnailFile = File(thumbnailPath.path);
        final cachedThumbnail = await _cacheManager.cacheFile(
            "${widget.videoUrl}_thumbnail", thumbnailFile, "jpg");

        setState(() {
          _thumbnailPath = cachedThumbnail.path;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error generating thumbnail from file: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _generateThumbnailFromUrl() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: widget.videoUrl,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: (widget.width * 2).toInt(),
        quality: 75,
      );

      if (thumbnailPath != null) {
        // Cache the thumbnail
        final thumbnailFile = File(thumbnailPath.path);
        final cachedThumbnail = await _cacheManager.cacheFile(
            "${widget.videoUrl}_thumbnail", thumbnailFile, "jpg");

        setState(() {
          _thumbnailPath = cachedThumbnail.path;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error generating thumbnail from URL: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadAndCacheVideo(String url, String extension) async {
    try {
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_video.$extension');

      // Download the file
      await dio.download(url, tempFile.path);

      // Cache the downloaded file
      _cachedVideoFile =
          await _cacheManager.cacheFile(url, tempFile, extension);

      // Delete the temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      print('Error downloading video: $e');
      // We don't need to update the state here as this is just for caching
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: widget.isCurrentUser ? Colors.white : Colors.black54,
              ),
            )
          else if (_hasError || _thumbnailPath == null)
            Container(
              color: Colors.grey[800],
              child: Icon(
                Icons.videocam,
                size: 40.sp,
                color: Colors.white,
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.file(
                File(_thumbnailPath!),
                width: widget.width,
                height: widget.height,
                fit: BoxFit.cover,
              ),
            ),

          // Play button overlay
          if (!_isLoading)
            Icon(
              Icons.play_circle_fill,
              size: 40.sp,
              color: Colors.white,
            ),

          // Duration indicator
          Positioned(
            bottom: 8.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                'Video',
                style: style14.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
