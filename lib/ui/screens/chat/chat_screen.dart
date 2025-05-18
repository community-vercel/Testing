// ignore_for_file: unreachable_switch_default, unused_local_variable, unused_field, avoid_print, use_build_context_synchronously, deprecated_member_use

import 'package:code_structure/core/constants/app_assest.dart';
import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:code_structure/core/model/app_user.dart';
import 'package:code_structure/core/services/call_service.dart';
import 'package:code_structure/core/services/database_services.dart';
import 'package:code_structure/core/services/stripe_service.dart';
import 'package:code_structure/ui/screens/call/audio_call_screen.dart';
import 'package:code_structure/ui/screens/call/video_call_screen.dart';
import 'package:code_structure/ui/widgets/video_thumbnail_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:code_structure/core/model/message.dart';
import 'package:code_structure/core/services/chat_services.dart';
import 'package:code_structure/core/services/storage_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:code_structure/core/providers/call_provider.dart';
import 'package:code_structure/ui/widgets/audio_message_player.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:code_structure/ui/screens/video_player_screen.dart';
import 'package:code_structure/core/providers/call_minutes_provider.dart';
import 'package:code_structure/ui/screens/checkout/cart_screen.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String? otherUserId;
  final String? otherUserfcm;
  final bool isGroup;
  final String title;
  final String? imageUrl;

  const ChatScreen({
    required this.chatId,
    required this.currentUserId,
    this.otherUserId,
    this.otherUserfcm,
    required this.isGroup,
    required this.title,
    this.imageUrl,
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final DatabaseServices _databaseService = DatabaseServices();
  final StorageService _storageService = StorageService();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordingPath;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  final ImagePicker _imagePicker = ImagePicker();
  // Map to track messages that are currently being sent
  final Map<String, bool> _sendingMessages = {};
  final bool _isShowingParticipants = false;
 final DatabaseServices _databaseServices = DatabaseServices();

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  Future<void> _markMessagesAsRead() async {
    try {
      await _chatService.markMessagesAsRead(
          widget.chatId, widget.currentUserId);
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }
  Future<bool> hasStripeAccount(String userId) async {
  final stripeId = await _databaseService.getSellerStripeId(userId);
  return stripeId != null && stripeId.isNotEmpty;
}

  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration += Duration(seconds: 1);
      });
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _audioRecorder.dispose();
    _stopRecordingTimer();
    super.dispose();
  }

  Future<void> _sendMessage(String content, MessageType type,
      {String? filePath}) async {
    _messageController.clear();
    if (content.isEmpty && type == MessageType.text) return;

    String messageId = const Uuid().v4();
    try {
      // Get current user's information
      final currentUser = await _databaseService.getUser(widget.currentUserId);
      if (currentUser == null) {
        throw Exception('Current user not found');
      }

      final message = Message(
        id: messageId,
        senderId: widget.currentUserId,
        senderName: currentUser.userName ?? 'Unknown User',
        content: content,
        type: type,
        timestamp: DateTime.now(),
        filePath: filePath,
      );

      // Set the message as "sending"
      setState(() {
        _sendingMessages[messageId] = true;
      });

      await _chatService.sendMessage(message, widget.chatId);
      // Message sent successfully
    } catch (e) {
      // Handle error
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    } finally {
      // Remove message from sending state
      setState(() {
        _sendingMessages.remove(messageId);
      });
    }
  }

  Future<void> _handleCameraSelection() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      // Create a temporary message ID
      final messageId = const Uuid().v4();

      // Create a placeholder message with "sending" state
      setState(() {
        _sendingMessages[messageId] = true;
      });

      try {
        final String url = await _storageService.uploadChatFile(
            File(image.path), widget.chatId);
        await _sendMessage(url, MessageType.image);
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      } finally {
        // Remove temporary message
        setState(() {
          _sendingMessages.remove(messageId);
        });
      }
    }
  }

  Future<void> _handleGallerySelection() async {
    final XFile? video =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (video != null) {
      // Create a temporary message ID
      final messageId = const Uuid().v4();

      // Create a placeholder message with "sending" state
      setState(() {
        _sendingMessages[messageId] = true;
      });

      try {
        final String url = await _storageService.uploadChatFile(
            File(video.path), widget.chatId);
        await _sendMessage(url, MessageType.video);
      } catch (e) {
        print('Error uploading video: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload video: $e')),
        );
      } finally {
        // Remove temporary message
        setState(() {
          _sendingMessages.remove(messageId);
        });
      }
    }
  }

  // Future<void> _handleFileSelection() async {
  //   final FilePickerResult? result = await FilePicker.platform.pickFiles();
  //   if (result != null) {
  //     // Create a temporary message ID
  //     final messageId = const Uuid().v4();
  //     final fileName = result.files.single.name;

  //     // Create a placeholder message with "sending" state
  //     setState(() {
  //       _sendingMessages[messageId] = true;
  //     });

  //     try {
  //       final File file = File(result.files.single.path!);
  //       final String url =
  //           await _storageService.uploadChatFile(file, widget.chatId);
  //       await _sendMessage(url, MessageType.file, filePath: fileName);
  //     } catch (e) {
  //       print('Error uploading file: $e');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to upload file: $e')),
  //       );
  //     } finally {
  //       // Remove temporary message
  //       setState(() {
  //         _sendingMessages.remove(messageId);
  //       });
  //     }
  //   }
  // }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        _recordingPath = '${directory.path}/audio_message.m4a';
        await _audioRecorder.start(RecordConfig(), path: _recordingPath ?? '');
        setState(() {
          _isRecording = true;
          _recordingDuration = Duration.zero;
        });
        _startRecordingTimer();
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      _stopRecordingTimer();
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);

      if (path != null && _recordingDuration.inSeconds >= 1) {
        // Create a temporary message ID
        final messageId = const Uuid().v4();

        // Create a placeholder message with "sending" state
        setState(() {
          _sendingMessages[messageId] = true;
        });

        try {
          final String url =
              await _storageService.uploadAudio(File(path), widget.chatId);
          await _sendMessage(url, MessageType.audio);
        } catch (e) {
          print('Error uploading audio: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload audio: $e')),
          );
        } finally {
          // Remove temporary message
          setState(() {
            _sendingMessages.remove(messageId);
          });
        }
      } else if (_recordingDuration.inSeconds < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recording too short. Please hold longer.')),
        );
      }
      _recordingDuration = Duration.zero;
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Color(0xFFF8F8F8).withAlpha(200),
        leadingWidth: 40.w,
        title: widget.isGroup ? _buildGroupHeader() : _buildUserHeader(),
        actions: [
          if (widget.isGroup)
            IconButton(
              onPressed: _showGroupOptions,
              icon: Icon(Icons.group, color: lightOrangeColor),
            ),
          if (!widget.isGroup)
            IconButton(
              onPressed: () {
                _checkAndStartCall(context, 'audio');
              },
              icon: Icon(Icons.call, color: lightOrangeColor),
            ),
          if (!widget.isGroup)
            IconButton(
              onPressed: () {
                _checkAndStartCall(context, 'video');
              },
              icon: Icon(Icons.videocam, color: lightOrangeColor),
            ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
        shape: const Border(
          bottom: BorderSide(color: Colors.black26),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final bool isMe = message.senderId == widget.currentUserId;
                    return _buildMessageItem(message, isMe);
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 10.h,
            ),
            decoration: BoxDecoration(
              color: Color(0xFFFAFAFA),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: const Offset(0, -1),
                  blurRadius: 7.r,
                  spreadRadius: 0,
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: Colors.black26,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _isRecording
                      ? Container(
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 12.w,
                                height: 12.h,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Recording ${_recordingDuration.inSeconds}s',
                                style: style14.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 12.w),
                              Icon(
                                Icons.emoji_emotions_outlined,
                                color: Colors.grey,
                                size: 24.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  onChanged: (value) {
                                    setState(
                                        () {}); // Trigger rebuild to update button
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Type a Message...',
                                    hintStyle: style14.copyWith(
                                      color: Colors.grey,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 10.h),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _showAttachmentOptions(context);
                                },
                                icon: Icon(
                                  Icons.attach_file,
                                  color: Colors.grey,
                                  size: 24.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onLongPressStart: (_) => _startRecording(),
                  onLongPressEnd: (_) => _stopRecording(),
                  // onTapCancel: () => _stopRecording(),
                  onTap: (_messageController.text.isNotEmpty)
                      ? () {
                          _sendMessage(
                              _messageController.text, MessageType.text);
                        }
                      : null,
                  child: Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.red : Color(0xFFE56B6F),
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    child: Icon(
                      _messageController.text.isNotEmpty
                          ? Icons.send
                          : _isRecording
                              ? Icons.mic
                              : Icons.mic_none,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Message message, bool isMe) {
    final bool isSending = _sendingMessages.containsKey(message.id);
    final bool isGroupChat = widget.isGroup;
    final bool isUnread = !message.readBy.contains(widget.currentUserId);

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 5.h,
        horizontal: 16.w,
      ),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
            decoration: BoxDecoration(
              gradient: isMe
                  ? LinearGradient(
                      colors: [lightOrangeColor, lightPinkColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isMe ? null : const Color(0xFFDADADA),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (isGroupChat && !isMe)
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Text(
                      message.senderName,
                      style: style14.copyWith(
                        color: lightOrangeColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                _buildMessageContent(message),
              ],
            ),
          ),
          // Show loading indicator for sending messages
          if (isSending && isMe)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(2.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 15.w,
                  height: 15.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(Message message) {
    final bool isSending = _sendingMessages.containsKey(message.id);

    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: style16.copyWith(
            color: message.senderId == widget.currentUserId
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.w400,
          ),
        );
      case MessageType.image:
        return Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: isSending
                  ? null
                  : () => _showFullScreenImage(message.content),
              child: Image.network(
                message.content,
                height: 200.h,
                width: 200.w,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 200.h,
                        width: 200.w,
                        color: Colors.grey[300],
                      ),
                      CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ],
                  );
                },
              ),
            ),
            if (isSending)
              Container(
                height: 200.h,
                width: 200.w,
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Uploading...',
                        style: style14.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      case MessageType.video:
        return Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: isSending
                  ? null
                  : () => _showVideoPlayer(context, message.content),
              child: VideoThumbnailWidget(
                videoUrl: message.content,
                width: 200.w,
                height: 150.h,
                isCurrentUser: message.senderId == widget.currentUserId,
              ),
            ),
            if (isSending)
              Container(
                height: 150.h,
                width: 200.w,
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Uploading...',
                        style: style14.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      case MessageType.audio:
        return isSending
            ? Container(
                width: 200.w,
                padding: EdgeInsets.all(12.r),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          message.senderId == widget.currentUserId
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Uploading audio...',
                      style: style14.copyWith(
                        color: message.senderId == widget.currentUserId
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              )
            : AudioMessagePlayer(
                audioUrl: message.content,
                isCurrentUser: message.senderId == widget.currentUserId,
              );
      case MessageType.file:
        final fileName = message.filePath ?? 'Document';
        return GestureDetector(
          onTap:
              isSending ? null : () => _downloadFile(message.content, fileName),
          child: Container(
            width: 200.w,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.insert_drive_file,
                  size: 24.sp,
                  color: message.senderId == widget.currentUserId
                      ? Colors.white
                      : Colors.black,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        fileName,
                        style: style14.copyWith(
                          color: message.senderId == widget.currentUserId
                              ? Colors.white
                              : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        isSending ? 'Uploading...' : 'Tap to download',
                        style: style14.copyWith(
                          color: message.senderId == widget.currentUserId
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSending)
                  SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        message.senderId == widget.currentUserId
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Content',
              style: style17.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                    context, Icons.camera, 'Camera', Colors.purple, () {
                  _handleCameraSelection();
                }),
                _buildAttachmentOption(
                    context, Icons.photo, 'Gallery', Colors.blue, () {
                  _handleGallerySelection();
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
      BuildContext context, IconData icon, String label, Color color, onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: style14.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: EdgeInsets.all(20.w),
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showVideoPlayer(BuildContext context, String videoUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
      ),
    );
  }

  Future<void> _downloadFile(String url, String fileName) async {
    try {
      // Show download progress
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Downloading $fileName...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Create dio instance
      final dio = Dio();

      // Get the download directory
      final directory = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      // Download the file
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // Update progress if needed
            print('${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      // Show success message
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Downloaded $fileName to ${directory.path}'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () async {
              final result = await OpenFile.open(filePath);
              if (result.type != ResultType.done) {
                scaffold.showSnackBar(
                  SnackBar(
                      content: Text('Could not open file: ${result.message}')),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      print('Error downloading file: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download file: $e')),
      );
    }
  }

  Future<void> _checkAndStartCall(BuildContext context, String callType
  ) async {
    final callMinutesProvider =
        Provider.of<CallMinutesProvider>(context, listen: false);
    final otherUserId = widget.otherUserId;

    // Check if user has enough minutes (minimum 1 minute required)
    final hasEnoughMinutes =
        await callMinutesProvider.hasEnoughMinutes(callType, 1);
 final hasStripe = await callMinutesProvider.hasStripeAccount(widget.otherUserId.toString());
  
  if (!hasStripe) {
    // Receiver doesn't have Stripe connected - show dialog
     
    // Send notification to receiver to setup Stripe
  
 
    await _showReceiverStripeRequiredDialog(context);
    return;
  }
    if (hasEnoughMinutes) {
      // User has enough minutes, proceed with the call
      final callProvider = context.read<CallProvider>();
      await callProvider.startCall(
        callerId: widget.currentUserId,
        callerName: widget.title,
        receiverId: widget.otherUserId!,
        receiverName: widget.title,
        receiverFcmToken: widget.otherUserfcm ?? '',
        callType: callType,
      );

      // Get the current call from the provider
      final call = callProvider.currentCall;
      if (call != null) {
        // Navigate to the appropriate call screen based on call type
        if (callType == 'video') {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoCallScreen(
                call: call,
                onCallEnd: (duration) async {
                  // Record the actual minutes used when call ends
                  final minutesUsed = (duration.inSeconds / 60).ceil();
                  await callMinutesProvider.recordUsedMinutes(
                    callType,
                    minutesUsed,
                  );
                  context.read<CallService>().endCall(call.callId);
                },
              ),
            ),
          );
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AudioCallScreen(
                call: call,
                onCallEnd: (duration) async {
                  // Record the actual minutes used when call ends
                  final minutesUsed = (duration.inSeconds / 60).ceil();
                  await callMinutesProvider.recordUsedMinutes(
                    callType,
                    minutesUsed,
                  );
                  context.read<CallService>().endCall(call.callId);
                },
              ),
            ),
          );
        }
      }
    } else {
      // User doesn't have enough minutes, show purchase dialog
      _showPurchaseDialog(context, callType);
    }
  }
  Future<void> _showReceiverStripeRequiredDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: ListTile(
  contentPadding: EdgeInsets.zero,
  leading: Icon(Icons.warning_amber_rounded, color: Colors.amber[800]),
  title: Text(
    'Payment Setup Required',
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  ),
),
      content: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(
              text: 'The reciever ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: 'needs to set up a Stripe payment account before you can call them.\n\n'
                  'To receive calls, users must connect to Stripe from their profile.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
 

  // Show dialog to inform user they need to purchase more minutes
  void _showPurchaseDialog(BuildContext context, String callType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Insufficient Minutes'),
        content: Text(
            'You don\'t have enough ${callType.toLowerCase()} call minutes. Would you like to purchase more?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Navigate to cart/purchase screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(),
                ),
              );
            },
            child: Text('Buy Minutes'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return widget.otherUserId != null
        ? StreamBuilder<AppUser?>(
            stream: _databaseService.userStream(widget.otherUserId!),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return const SizedBox.shrink();
              }

              final otherUser = userSnapshot.data!;
              return Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundImage: otherUser.images![0] != null
                        ? NetworkImage(otherUser.images![0]!)
                        : AssetImage(AppAssets().pic) as ImageProvider,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: style17.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          (otherUser.isOnline ?? false)
                              ? 'Online'
                              : timeago.format(otherUser.lastOnline!),
                          style: style14.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            })
        : Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: widget.imageUrl != null
                    ? NetworkImage(widget.imageUrl!)
                    : AssetImage(AppAssets().pic) as ImageProvider,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: style17.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
  }

  Widget _buildGroupHeader() {
    return StreamBuilder<List<AppUser>>(
      stream: _chatService.getGroupParticipants(widget.chatId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final participants = snapshot.data!;
        return Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundImage: widget.imageUrl != null
                  ? NetworkImage(widget.imageUrl!)
                  : AssetImage(AppAssets().pic) as ImageProvider,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: style17.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${participants.length} participants',
                    style: style14.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showGroupOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StreamBuilder<List<AppUser>>(
        stream: _chatService.getGroupParticipants(widget.chatId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final participants = snapshot.data!;
          return Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Group Participants',
                  style: style17.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: ListView.builder(
                    itemCount: participants.length,
                    itemBuilder: (context, index) {
                      final user = participants[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.images?[0] != null
                              ? NetworkImage(user.images![0]!)
                              : AssetImage(AppAssets().pic) as ImageProvider,
                        ),
                        title: Text(user.userName ?? 'Unknown'),
                        trailing: user.uid != widget.currentUserId
                            ? IconButton(
                                icon: Icon(Icons.remove_circle_outline),
                                onPressed: () async {
                                  try {
                                    await _chatService.removeGroupParticipant(
                                      widget.chatId,
                                      user.uid!,
                                    );
                                    Navigator.pop(context);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Error removing participant: $e')),
                                    );
                                  }
                                },
                              )
                            : null,
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showAddParticipantsDialog(context),
                  child: Text('Add Participants'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddParticipantsDialog(BuildContext context) {
    List<String> selectedUsers = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Participants'),
          content: Container(
            width: double.maxFinite,
            height: 300.h,
            child: StreamBuilder<List<AppUser>?>(
              stream: _databaseService.allUsersStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!
                    .where((element) => element.uid != widget.currentUserId)
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
                            : AssetImage(AppAssets().pic) as ImageProvider,
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedUsers.isEmpty) {
                  return;
                }

                try {
                  await _chatService.addGroupParticipants(
                    widget.chatId,
                    selectedUsers,
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding participants: $e')),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.pink, Colors.orange],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, 10, 10));

    var path = Path();
    path.moveTo(10, 0);
    path.lineTo(0, 10);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
