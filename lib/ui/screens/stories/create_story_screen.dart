import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:code_structure/core/services/story_services.dart';
import 'package:code_structure/core/model/story.dart';
import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateStoryScreen extends StatefulWidget {
  final String userId;

  const CreateStoryScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final StoryService _storyService = StoryService();
  final TextEditingController _captionController = TextEditingController();
  File? _mediaFile;
  StoryType _storyType = StoryType.image;
  bool _isLoading = false;
  VideoPlayerController? _videoController;

  @override
  void dispose() {
    _captionController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source, StoryType type) async {
    final picker = ImagePicker();
    try {
      final XFile? pickedFile = type == StoryType.video
          ? await picker.pickVideo(source: source)
          : await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _mediaFile = File(pickedFile.path);
          _storyType = type;
        });

        if (type == StoryType.video) {
          _videoController = VideoPlayerController.file(_mediaFile!)
            ..initialize().then((_) {
              setState(() {});
            });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking media: $e')),
      );
    }
  }

  Future<void> _uploadStory() async {
    if (_mediaFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final storageRef = FirebaseStorage.instance.ref().child(
          'stories/${widget.userId}_${DateTime.now().millisecondsSinceEpoch}');

      await storageRef.putFile(_mediaFile!);
      final mediaUrl = await storageRef.getDownloadURL();

      await _storyService.createStory(
        userId: widget.userId,
        mediaUrl: mediaUrl,
        type: _storyType,
        caption: _captionController.text.trim(),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading story: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Story', style: style17B),
        actions: [
          if (_mediaFile != null)
            TextButton(
              onPressed: _isLoading ? null : _uploadStory,
              child: _isLoading
                  ? CircularProgressIndicator(color: lightPinkColor)
                  : Text('Share',
                      style: style17.copyWith(color: lightPinkColor)),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_mediaFile == null) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMediaButton(
                      icon: Icons.camera_alt,
                      label: 'Take Photo',
                      onTap: () =>
                          _pickMedia(ImageSource.camera, StoryType.image),
                    ),
                    SizedBox(height: 20.h),
                    _buildMediaButton(
                      icon: Icons.photo_library,
                      label: 'Choose Photo',
                      onTap: () =>
                          _pickMedia(ImageSource.gallery, StoryType.image),
                    ),
                    SizedBox(height: 20.h),
                    _buildMediaButton(
                      icon: Icons.videocam,
                      label: 'Record Video',
                      onTap: () =>
                          _pickMedia(ImageSource.camera, StoryType.video),
                    ),
                    SizedBox(height: 20.h),
                    _buildMediaButton(
                      icon: Icons.video_library,
                      label: 'Choose Video',
                      onTap: () =>
                          _pickMedia(ImageSource.gallery, StoryType.video),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_storyType == StoryType.video && _videoController != null)
                    _videoController!.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          )
                        : Center(child: CircularProgressIndicator())
                  else
                    Image.file(_mediaFile!, fit: BoxFit.cover),
                  if (_storyType == StoryType.video && _videoController != null)
                    Positioned(
                      bottom: 20.h,
                      right: 20.w,
                      child: FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            _videoController!.value.isPlaying
                                ? _videoController!.pause()
                                : _videoController!.play();
                          });
                        },
                        child: Icon(
                          _videoController!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: TextField(
                controller: _captionController,
                decoration: InputDecoration(
                  hintText: 'Add a caption...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 200.w,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          border: Border.all(color: lightPinkColor),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32.r, color: lightPinkColor),
            SizedBox(height: 8.h),
            Text(label, style: style17.copyWith(color: lightPinkColor)),
          ],
        ),
      ),
    );
  }
}
