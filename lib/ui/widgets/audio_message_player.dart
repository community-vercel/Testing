import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:code_structure/core/services/cache_manager.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class AudioMessagePlayer extends StatefulWidget {
  final String audioUrl;
  final bool isCurrentUser;

  const AudioMessagePlayer({
    required this.audioUrl,
    required this.isCurrentUser,
    Key? key,
  }) : super(key: key);

  @override
  State<AudioMessagePlayer> createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<AudioMessagePlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final CacheManager _cacheManager = CacheManager();
  final Dio _dio = Dio();

  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  File? _cachedAudioFile;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      setState(() => _isLoading = true);

      // Try to get the cached audio file
      final extension = _getFileExtension(widget.audioUrl);
      _cachedAudioFile =
          await _cacheManager.getCachedFile(widget.audioUrl, extension);

      // If not cached, download and cache it
      if (_cachedAudioFile == null) {
        _cachedAudioFile =
            await _downloadAndCacheAudio(widget.audioUrl, extension);
      }

      // Set the audio source using the local file
      if (_cachedAudioFile != null) {
        await _audioPlayer.setFilePath(_cachedAudioFile!.path);
      } else {
        // Fallback to URL if caching fails
        await _audioPlayer.setUrl(widget.audioUrl);
      }

      // Get the duration
      _duration = _audioPlayer.duration ?? Duration.zero;

      // Listen for position changes
      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() => _position = position);
        }
      });

      // Listen for player state changes
      _audioPlayer.playerStateStream.listen((playerState) {
        if (mounted) {
          setState(() {
            _isPlaying = playerState.playing;
            if (playerState.processingState == ProcessingState.completed) {
              _audioPlayer.seek(Duration.zero);
              _audioPlayer.pause();
            }
          });
        }
      });

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error initializing audio player: $e');
      setState(() => _isLoading = false);
    }
  }

  String _getFileExtension(String url) {
    // Try to extract extension from URL or default to mp3
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      final fileName = pathSegments.last;
      final extension = path.extension(fileName);
      if (extension.isNotEmpty) {
        return extension.substring(1); // Remove the dot
      }
    }
    return 'mp3'; // Default extension
  }

  Future<File?> _downloadAndCacheAudio(String url, String extension) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_audio.$extension');

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
      print('Error downloading audio: $e');
      return null;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isCurrentUser ? Colors.white : Colors.black;

    return Container(
      width: 200.w,
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: _isLoading
          ? Center(
              child: SizedBox(
                width: 24.w,
                height: 24.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: textColor,
                    size: 26.sp,
                  ),
                  onTap: () {
                    if (_isPlaying) {
                      _audioPlayer.pause();
                    } else {
                      _audioPlayer.play();
                    }
                  },
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 2.h,
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 6.r),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 12.r),
                          thumbColor: textColor,
                          activeTrackColor: textColor,
                          inactiveTrackColor: textColor.withOpacity(0.3),
                        ),
                        child: Slider(
                          min: 0,
                          max: _duration.inMilliseconds.toDouble(),
                          value: _position.inMilliseconds.toDouble().clamp(
                                0,
                                _duration.inMilliseconds.toDouble(),
                              ),
                          onChanged: (value) {
                            final newPosition =
                                Duration(milliseconds: value.toInt());
                            _audioPlayer.seek(newPosition);
                          },
                          // padding: EdgeInsets.symmetric(
                          //     vertical: 6.h, horizontal: 5.w),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: style14.copyWith(
                              color: textColor,
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: style14.copyWith(
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
