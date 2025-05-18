import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import 'package:code_structure/core/model/story.dart';
import 'package:code_structure/core/model/app_user.dart';
import 'package:code_structure/core/services/story_services.dart';
import 'package:code_structure/core/services/database_services.dart';
import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:code_structure/core/services/cache_manager.dart';
import 'dart:io';

class StoryViewerScreen extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;
  final String currentUserId;

  const StoryViewerScreen({
    Key? key,
    required this.stories,
    required this.initialIndex,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  final StoryController controller = StoryController();
  final StoryService _storyService = StoryService();
  final DatabaseServices _databaseServices = DatabaseServices();
  final CacheManager _cacheManager = CacheManager();
  bool _isCommenting = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    _commentController.dispose();
    super.dispose();
  }

  List<StoryItem> _buildStoryItems() {
    return widget.stories.map((story) {
      if (story.type == StoryType.video) {
        return StoryItem.pageVideo(
          story.mediaUrl,
          controller: controller,
          duration: Duration(seconds: 5),
        );
      } else {
        return StoryItem.pageImage(
          url: story.mediaUrl,
          controller: controller,
          duration: Duration(seconds: 5),
        );
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          StoryView(
            storyItems: _buildStoryItems(),
            controller: controller,
            onComplete: () {
              Navigator.pop(context);
            },
            // onStoryShow: (storyItem, index) {
            //   // Mark story as viewed
            //   final index = _buildStoryItems().indexOf(storyItem);
            //   if (index >= 0 && index < widget.stories.length) {
            //     final story = widget.stories[index];
            //     if (!story.viewedBy.contains(widget.currentUserId)) {
            //       _storyService.viewStory(story.id, widget.currentUserId);
            //     }
            //   }
            // },
            onVerticalSwipeComplete: (direction) {
              if (direction == Direction.down) {
                Navigator.pop(context);
              }
            },
          ),
          _buildHeader(),
          // if (_isCommenting) _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final story = widget.stories.first;
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 0,
      right: 0,
      child: FutureBuilder<AppUser?>(
        future: _databaseServices.getUser(story.userId),
        builder: (context, snapshot) {
          final user = snapshot.data;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: user?.images?[0] != null
                      ? NetworkImage(user!.images![0]!)
                      : null,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.userName ?? 'Unknown',
                        style: style17.copyWith(color: Colors.white),
                      ),
                      Text(
                        timeago.format(story.createdAt),
                        style: style14.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget _buildCommentInput() {
  //   return Positioned(
  //     bottom: 0,
  //     left: 0,
  //     right: 0,
  //     child: Container(
  //       color: Colors.black.withOpacity(0.7),
  //       padding: EdgeInsets.fromLTRB(
  //           16.w, 16.h, 16.w, MediaQuery.of(context).padding.bottom + 16.h),
  //       child: Row(
  //         children: [
  //           Expanded(
  //             child: TextField(
  //               controller: _commentController,
  //               style: style17.copyWith(color: Colors.white),
  //               decoration: InputDecoration(
  //                 hintText: 'Add a comment...',
  //                 hintStyle: style17.copyWith(color: Colors.white70),
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(24.r),
  //                   borderSide: BorderSide(color: Colors.white30),
  //                 ),
  //                 enabledBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(24.r),
  //                   borderSide: BorderSide(color: Colors.white30),
  //                 ),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(24.r),
  //                   borderSide: BorderSide(color: lightPinkColor),
  //                 ),
  //               ),
  //             ),
  //           ),
  //           SizedBox(width: 8.w),
  //           IconButton(
  //             icon: Icon(Icons.send, color: lightPinkColor),
  //             onPressed: () async {
  //               if (_commentController.text.isNotEmpty) {
  //                 final story = widget.stories[controller.currentIndex];
  //                 await _storyService.addComment(story.id);
  //                 _commentController.clear();
  //                 setState(() {
  //                   _isCommenting = false;
  //                 });
  //               }
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
