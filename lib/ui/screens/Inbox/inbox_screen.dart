import 'package:code_structure/core/constants/app_assest.dart';
import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:code_structure/core/model/message.dart';
import 'package:code_structure/ui/screens/chat/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:code_structure/core/model/chat.dart';
import 'package:code_structure/core/model/app_user.dart';
import 'package:code_structure/core/services/chat_services.dart';
import 'package:code_structure/core/services/database_services.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:code_structure/core/model/story.dart';
import 'package:code_structure/core/services/story_services.dart';
import 'package:code_structure/ui/screens/stories/create_story_screen.dart';
import 'package:code_structure/ui/screens/stories/story_viewer_screen.dart';
import 'package:code_structure/core/services/cache_manager.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:code_structure/core/models/call.dart';
import 'package:code_structure/core/repositories/call_repository.dart';

class InboxScreen extends StatefulWidget {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  InboxScreen({
    super.key,
  });

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ChatService _chatService = ChatService();
  final DatabaseServices _databaseServices = DatabaseServices();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final StoryService _storyService = StoryService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getLastMessagePreview(String message, MessageType type) {
    switch (type) {
      case MessageType.text:
        return message;
      case MessageType.image:
        return '📷 Image';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.audio:
        return '🎵 Voice message';
      case MessageType.file:
        return '📎 File';
      default:
        return '';
    }
  }

  Widget _buildSearchBar(String hintText) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: TextFormField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: style17.copyWith(
            color: Color(0xFF9B9B9B),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 26.r,
          ),
          fillColor: Color(0xFFE6E6E6),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        _buildSearchBar('Search chats...'),
        Divider(color: Color(0xFFDAD9E2)),
        _buildOnlineUsers(),
        Expanded(
          child: StreamBuilder<List<Chat>>(
            stream: _chatService.getUserChats(widget.currentUserId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final chats = snapshot.data!
                  .where((chat) => !chat.isGroup)
                  .where((chat) =>
                      chat.lastMessage.toLowerCase().contains(_searchQuery))
                  .toList();

              if (chats.isEmpty) {
                return const Center(child: Text('No chats found'));
              }

              return ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final otherUserId = chat.participants
                      .firstWhere((id) => id != widget.currentUserId);

                  return StreamBuilder<AppUser?>(
                    stream: _databaseServices.userStream(otherUserId),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      final otherUser = userSnapshot.data!;
                      return _buildChatListTile(chat, otherUser);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineUsers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '   ONLINE USERS',
          style: style17B.copyWith(
            color: lightGreyColor,
          ),
        ),
        15.verticalSpace,
        SizedBox(
          height: 100.h,
          child: StreamBuilder<List<AppUser>?>(
            stream: _databaseServices.allUsersStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = snapshot.data!
                  .where((user) => user.uid != widget.currentUserId)
                  .where((user) => user.isOnline ?? false)
                  .where((user) =>
                      user.userName!.toLowerCase().contains(_searchQuery))
                  .toList();

              if (users.isEmpty) {
                return const Center(child: Text('No online users'));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _buildOnlineUserItem(user);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineUserItem(AppUser user) {
    return GestureDetector(
      onTap: () async {
        final chatId = await _chatService.createOrGetChat(
          [widget.currentUserId, user.uid!],
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
              currentUserId: widget.currentUserId,
              otherUserId: user.uid!,
              otherUserfcm: user.fcmToken,
              isGroup: false,
              title: user.userName ?? '',
              imageUrl: user.images![0],
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(right: 16.w),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundImage: user.images![0] != null
                      ? NetworkImage(user.images![0]!)
                      : AssetImage(AppAssets().pic) as ImageProvider,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 15.w,
                    height: 15.h,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              user.userName ?? '',
              style: style14.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatListTile(Chat chat, AppUser otherUser) {
    final lastMessageTime = timeago.format(chat.lastMessageTime);
    final unreadCount = chat.getUnreadCountForUser(widget.currentUserId);

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chat.id,
              currentUserId: widget.currentUserId,
              otherUserId: otherUser.uid!,
              otherUserfcm: otherUser.fcmToken,
              isGroup: false,
              title: otherUser.userName ?? '',
              imageUrl: otherUser.images![0],
            ),
          ),
        );
      },
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundImage: otherUser.images![0] != null
                ? NetworkImage(otherUser.images![0]!)
                : AssetImage(AppAssets().pic) as ImageProvider,
          ),
          if (otherUser.isOnline ?? false)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 15.w,
                height: 15.h,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        otherUser.userName ?? '',
        style: style17.copyWith(
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A4A4A),
        ),
      ),
      subtitle: Text(
        _getLastMessagePreview(chat.lastMessage, chat.lastMessageType),
        style: style14.copyWith(color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            lastMessageTime,
            style: style14.copyWith(color: Colors.grey),
          ),
          if (unreadCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [lightOrangeColor, lightPinkColor],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                unreadCount.toString(),
                style: style14.copyWith(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGroupsTab() {
    return Stack(
      children: [
        Column(
          children: [
            _buildSearchBar('Search groups...'),
            Divider(color: Color(0xFFDAD9E2)),
            Expanded(
              child: StreamBuilder<List<Chat>>(
                stream: _chatService.getUserChats(widget.currentUserId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final groups = snapshot.data!
                      .where((chat) => chat.isGroup)
                      .where((chat) =>
                          chat.groupName
                              ?.toLowerCase()
                              .contains(_searchQuery) ??
                          false)
                      .toList();

                  if (groups.isEmpty) {
                    return const Center(child: Text('No groups found'));
                  }

                  return ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return _buildGroupListTile(group);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 16.h,
          right: 16.w,
          child: FloatingActionButton(
            onPressed: () => _showCreateGroupDialog(context),
            backgroundColor: lightPinkColor,
            child: Icon(Icons.group_add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupListTile(Chat group) {
    final lastMessageTime = timeago.format(group.lastMessageTime);
    final unreadCount = group.getUnreadCountForUser(widget.currentUserId);

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: group.id,
              currentUserId: widget.currentUserId,
              isGroup: true,
              title: group.groupName!,
              imageUrl: group.groupImage,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        radius: 30.r,
        backgroundImage: group.groupImage != null
            ? NetworkImage(group.groupImage!)
            : AssetImage(AppAssets().pic) as ImageProvider,
      ),
      title: Text(
        group.groupName!,
        style: style17.copyWith(
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A4A4A),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${group.participants.length} members',
            style: style14.copyWith(color: Colors.grey),
          ),
          Text(
            _getLastMessagePreview(group.lastMessage, group.lastMessageType),
            style: style14.copyWith(color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            lastMessageTime,
            style: style14.copyWith(color: Colors.grey),
          ),
          if (unreadCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [lightOrangeColor, lightPinkColor],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                unreadCount.toString(),
                style: style14.copyWith(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final TextEditingController groupNameController = TextEditingController();
    List<String> selectedUsers = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Create Group'),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: groupNameController,
                  decoration: InputDecoration(
                    hintText: 'Group Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  height: 300.h,
                  child: StreamBuilder<List<AppUser>?>(
                    stream: _databaseServices.allUsersStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final users = snapshot.data!
                          .where((user) => user.uid != widget.currentUserId)
                          .toList();
                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final isSelected = selectedUsers.contains(user.uid);

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.images?[0] != null
                                  ? NetworkImage(user.images![0]!)
                                  : AssetImage(AppAssets().pic)
                                      as ImageProvider,
                            ),
                            title: Text(user.userName ?? 'Unknown'),
                            trailing: Checkbox(
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedUsers.add(user.uid!);
                                  } else {
                                    selectedUsers.remove(user.uid!);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (groupNameController.text.isEmpty || selectedUsers.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                // Add current user to participants
                selectedUsers.add(widget.currentUserId);

                try {
                  final chatId = await _chatService.createOrGetChat(
                    selectedUsers,
                    isGroup: true,
                    groupName: groupNameController.text,
                  );

                  Navigator.pop(context);

                  // Navigate to the group chat
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: chatId,
                        currentUserId: widget.currentUserId,
                        isGroup: true,
                        title: groupNameController.text,
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating group: $e')),
                  );
                }
              },
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        title: Text(
          'Inbox',
          style: style25B.copyWith(
            fontSize: 34.sp,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: lightPinkColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: lightPinkColor,
          indicatorWeight: 3,
          labelStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Chat'),
            Tab(text: 'Groups'),
            Tab(text: 'Stories'),
            Tab(text: 'Calls'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(),
          _buildGroupsTab(),
          _buildStoriesTab(),
          _buildCallsTab(),
        ],
      ),
    );
  }

  Widget _buildStoriesTab() {
    return StreamBuilder<List<Story>>(
      stream: _storyService.getStories(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Group stories by user
        final Map<String, List<Story>> storiesByUser = {};
        for (var story in snapshot.data!) {
          if (!storiesByUser.containsKey(story.userId)) {
            storiesByUser[story.userId] = [];
          }
          storiesByUser[story.userId]!.add(story);
        }

        // Sort stories by user by most recent story
        final sortedUserIds = storiesByUser.keys.toList()
          ..sort((a, b) {
            final aLatestStory = storiesByUser[a]!.reduce((curr, next) =>
                curr.createdAt.isAfter(next.createdAt) ? curr : next);
            final bLatestStory = storiesByUser[b]!.reduce((curr, next) =>
                curr.createdAt.isAfter(next.createdAt) ? curr : next);
            return bLatestStory.createdAt.compareTo(aLatestStory.createdAt);
          });

        final myStories = storiesByUser[widget.currentUserId] ?? [];
        final otherStories = sortedUserIds
            .where((userId) => userId != widget.currentUserId)
            .map((userId) => storiesByUser[userId]!.reduce((curr, next) =>
                curr.createdAt.isAfter(next.createdAt) ? curr : next))
            .toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add Story Button
              Padding(
                padding: EdgeInsets.all(16.w),
                child: InkWell(
                  onTap: () => _addNewStory(),
                  child: Container(
                    width: double.infinity,
                    height: 180.h,
                    decoration: BoxDecoration(
                      color: Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: 48.r,
                          color: lightPinkColor,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Add New Story',
                          style: style17.copyWith(
                            color: lightPinkColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // My Stories Section
              if (myStories.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'MY STORIES',
                    style: style17B.copyWith(color: lightGreyColor),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  height: 200.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      final latestStory = myStories.reduce((curr, next) =>
                          curr.createdAt.isAfter(next.createdAt) ? curr : next);
                      return _buildStoryCard(latestStory, myStories,
                          isMyStory: true);
                    },
                  ),
                ),
              ],

              // Recent Stories Section
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'RECENT STORIES',
                  style: style17B.copyWith(color: lightGreyColor),
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: otherStories.length,
                  itemBuilder: (context, index) {
                    final story = otherStories[index];
                    return _buildStoryCard(story, storiesByUser[story.userId]!);
                  },
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoryCard(Story story, List<Story> userStories,
      {bool isMyStory = false}) {
    return CachedStoryCard(
      story: story,
      isMyStory: isMyStory,
      userId: widget.currentUserId,
      onTap: () => _viewStory(story, userStories),
      databaseServices: _databaseServices,
    );
  }

  void _addNewStory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateStoryScreen(userId: widget.currentUserId),
      ),
    );
  }

  void _viewStory(Story story, List<Story> userStories) async {
    print(story.toJson());
    print(userStories.indexOf(story));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryViewerScreen(
          stories: userStories,
          initialIndex: userStories.indexOf(story),
          currentUserId: widget.currentUserId,
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String subtitle, String trailing,
      {Widget? leading, Widget? subtitleWidget}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 5.h),
      leading: leading,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitleWidget ??
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xFFC1C0C9),
            ),
          ),
      trailing: Text(
        trailing,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          color: Color(0xFFC1C0C9),
        ),
      ),
    );
  }

  Widget _buildCallsTab() {
    final CallRepository _callRepository = CallRepository();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar('Search calls...'),
          Divider(
            color: Color(0xFFDAD9E2),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'RECENT CALLS',
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC1C0C9)),
            ),
          ),
          10.verticalSpace,
          StreamBuilder<List<Call>>(
            stream: _callRepository.getCallHistory(widget.currentUserId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                    child: Text('Error loading calls: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final calls = snapshot.data!;
              if (calls.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 32.h),
                    child: Text(
                      'No call history',
                      style: style17.copyWith(color: Colors.grey),
                    ),
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: calls.length,
                  itemBuilder: (context, index) {
                    final call = calls[index];
                    final isIncoming = call.receiverId == widget.currentUserId;
                    final otherUserId =
                        isIncoming ? call.callerId : call.receiverName;
                    final otherUserName =
                        isIncoming ? call.callerName : call.receiverName;
                    final isMissed = call.status == 'rejected' ||
                        (call.status == 'ended' &&
                            _callRepository.getCallDuration(call).inSeconds <
                                5);

                    return StreamBuilder<AppUser?>(
                      stream: _databaseServices.userStream(otherUserId),
                      builder: (context, userSnapshot) {
                        final user = userSnapshot.data;

                        return _buildListTile(
                          otherUserName,
                          '${isIncoming ? 'Incoming' : 'Outgoing'} ${call.callType} call ${isMissed ? '(Missed)' : ''}',
                          timeago.format(call.createdAt),
                          leading: CircleAvatar(
                            radius: 30.r,
                            backgroundImage: user?.images?[0] != null
                                ? NetworkImage(user!.images![0]!)
                                : AssetImage(AppAssets().pic) as ImageProvider,
                          ),
                          subtitleWidget: Row(
                            children: [
                              Icon(
                                isIncoming
                                    ? Icons.call_received
                                    : Icons.call_made,
                                size: 16.r,
                                color: isMissed ? Colors.red : Colors.green,
                              ),
                              5.horizontalSpace,
                              Icon(
                                call.callType == 'video'
                                    ? Icons.videocam
                                    : Icons.phone,
                                size: 16.r,
                                color: Color(0xFFC1C0C9),
                              ),
                              5.horizontalSpace,
                              Text(
                                '${isIncoming ? 'Incoming' : 'Outgoing'} ${isMissed ? '(Missed)' : ''}',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFC1C0C9),
                                ),
                              ),
                              if (call.status == 'ended' && !isMissed) ...[
                                5.horizontalSpace,
                                Text(
                                  '(${_formatDuration(_callRepository.getCallDuration(call))})',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFFC1C0C9),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }
}

class CachedStoryCard extends StatefulWidget {
  final Story story;
  final bool isMyStory;
  final String userId;
  final VoidCallback onTap;
  final DatabaseServices databaseServices;

  const CachedStoryCard({
    Key? key,
    required this.story,
    required this.isMyStory,
    required this.userId,
    required this.onTap,
    required this.databaseServices,
  }) : super(key: key);

  @override
  State<CachedStoryCard> createState() => _CachedStoryCardState();
}

class _CachedStoryCardState extends State<CachedStoryCard> {
  final CacheManager _cacheManager = CacheManager();
  bool _isLoading = true;
  String? _cachedMediaPath;
  String? _thumbnailPath;
  bool _hasError = false;
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _loadUserAndMedia();
  }

  Future<void> _loadUserAndMedia() async {
    try {
      // Load user info
      _user = await widget.databaseServices.getUser(widget.story.userId);

      // Check if the media is cached
      final fileExtension = _getFileExtension(widget.story.mediaUrl);
      final cachedFile = await _cacheManager.getCachedFile(
          widget.story.mediaUrl, fileExtension);

      if (cachedFile != null) {
        // Use cached file
        setState(() {
          _cachedMediaPath = cachedFile.path;
          _isLoading = false;
        });
      } else {
        // For videos, we need to get a thumbnail
        if (widget.story.type == StoryType.video) {
          await _generateThumbnail();
        }

        // Start downloading the file
        _downloadAndCacheMedia();
      }
    } catch (e) {
      print('Error loading media: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  String _getFileExtension(String url) {
    // Try to extract extension from URL or default to jpg for images and mp4 for videos
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      final fileName = pathSegments.last;
      final extension = path.extension(fileName);
      if (extension.isNotEmpty) {
        return extension.substring(1); // Remove the dot
      }
    }

    // Default extensions based on story type
    return widget.story.type == StoryType.video ? 'mp4' : 'jpg';
  }

  Future<void> _generateThumbnail() async {
    try {
      // Check if we already have a cached thumbnail
      final thumbnailFile = await _cacheManager.getCachedFile(
          "${widget.story.mediaUrl}_thumbnail", "jpg");

      if (thumbnailFile != null) {
        // Use the cached thumbnail
        setState(() {
          _thumbnailPath = thumbnailFile.path;
          _isLoading = false;
        });
        return;
      }

      // Generate thumbnail from URL
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: widget.story.mediaUrl,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 300,
        quality: 75,
      );

      if (thumbnailPath != null) {
        // Cache the thumbnail
        final thumbnailFile = File(thumbnailPath.path);
        final cachedThumbnail = await _cacheManager.cacheFile(
            "${widget.story.mediaUrl}_thumbnail", thumbnailFile, "jpg");

        setState(() {
          _thumbnailPath = cachedThumbnail.path;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error generating thumbnail: $e');
      // Continue with loading, even if thumbnail generation fails
    }
  }

  Future<void> _downloadAndCacheMedia() async {
    try {
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final fileExtension = _getFileExtension(widget.story.mediaUrl);
      final tempFile = File('${tempDir.path}/temp_story.$fileExtension');

      // Download the file
      await dio.download(
        widget.story.mediaUrl,
        tempFile.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // Can update progress if needed
          }
        },
      );

      // Cache the downloaded file
      final cachedFile = await _cacheManager.cacheFile(
          widget.story.mediaUrl, tempFile, fileExtension);

      // Delete the temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      // Update UI with cached file
      setState(() {
        _cachedMediaPath = cachedFile.path;
        _isLoading = false;
      });
    } catch (e) {
      print('Error downloading media: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.only(right: widget.isMyStory ? 12.w : 0),
        width: widget.isMyStory ? 140.w : double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.grey[300],
        ),
        child: Stack(
          children: [
            // Media content (image/video thumbnail)
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(lightPinkColor),
                ),
              )
            else if (_hasError)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 40.r),
                    SizedBox(height: 8.h),
                    Text(
                      'Error loading media',
                      style: style14.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: _buildMediaContent(),
                ),
              ),

            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Video indicator if applicable
            if (widget.story.type == StoryType.video && !_isLoading)
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.videocam, color: Colors.white, size: 14.r),
                      SizedBox(width: 4.w),
                      Text(
                        'Video',
                        style: style14.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

            // User info and stats
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16.r,
                          backgroundImage: _user?.images?[0] != null
                              ? NetworkImage(_user!.images![0]!)
                              : AssetImage(AppAssets().pic) as ImageProvider,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            _user?.userName ?? 'Loading...',
                            style: style14.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye_outlined,
                          size: 14.r,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${widget.story.viewedBy.length}',
                          style: style14.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    if (_cachedMediaPath != null) {
      if (widget.story.type == StoryType.video) {
        // For videos, use the thumbnail path if available
        if (_thumbnailPath != null) {
          return Image.file(
            File(_thumbnailPath!),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading thumbnail: $error');
              return Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(Icons.videocam, size: 40.r, color: Colors.grey),
                ),
              );
            },
          );
        } else {
          // Fallback for videos without thumbnail
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: Icon(Icons.videocam, size: 40.r, color: Colors.grey),
            ),
          );
        }
      } else {
        // For images
        return Image.file(
          File(_cachedMediaPath!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error');
            return Container(
              color: Colors.grey[300],
              child: Center(
                child: Icon(Icons.broken_image, size: 40.r, color: Colors.grey),
              ),
            );
          },
        );
      }
    } else if (_thumbnailPath != null) {
      return Image.file(
        File(_thumbnailPath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading thumbnail: $error');
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: Icon(Icons.videocam, size: 40.r, color: Colors.grey),
            ),
          );
        },
      );
    } else {
      // Fallback to network image if both cached paths are null
      return Image.network(
        widget.story.mediaUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              valueColor: AlwaysStoppedAnimation<Color>(lightPinkColor),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading network image: $error');
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: Icon(Icons.broken_image, size: 40.r, color: Colors.grey),
            ),
          );
        },
      );
    }
  }
}
