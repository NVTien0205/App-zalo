// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:chat_app/app/app.dart';
import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/chat_room_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatPage extends ConsumerStatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const ChatPage({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  Stream<QuerySnapshot> _chatRoomsStream() {
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .where('participants.${widget.userModel.uid}', isEqualTo: true)
        .snapshots();
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 52,
              color: Color(0xFF9AA4B2),
            ),
            SizedBox(height: 14),
            Text(
              'Chưa có cuộc trò chuyện',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy tìm bạn bè và bắt đầu nhắn tin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(ChatRoomModel chatRoomModel, UserModel targetUser) {
    final hasAvatar = targetUser.profilepicture != null &&
        targetUser.profilepicture!.isNotEmpty;
    final hasLastMessage = chatRoomModel.lastMessage != null &&
        chatRoomModel.lastMessage!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoomPage(
                  chatroom: chatRoomModel,
                  firebaseUser: widget.firebaseUser,
                  userModel: widget.userModel,
                  targetUser: targetUser,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFDCE7FF),
                  backgroundImage: hasAvatar
                      ? NetworkImage(targetUser.profilepicture!)
                      : null,
                  child: hasAvatar
                      ? null
                      : const Icon(Icons.person, color: Color(0xFF4A7DFF)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        targetUser.fullname?.isNotEmpty == true
                            ? targetUser.fullname!
                            : (targetUser.email ?? 'Người dùng'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasLastMessage
                            ? chatRoomModel.lastMessage!
                            : 'Bắt đầu trò chuyện',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: hasLastMessage
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF9AA4B2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatRoomItem(ChatRoomModel chatRoomModel) {
    final participants = chatRoomModel.participants!;
    final participantKeys = participants.keys.toList()
      ..remove(widget.userModel.uid);

    return FutureBuilder(
      future: ref
          .read(databaseServiceProvider)
          .getUserModelById(participantKeys[0]),
      builder: (context, userData) {
        if (userData.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }

        if (userData.data == null) {
          return const SizedBox.shrink();
        }

        final targetUser = userData.data as UserModel;
        return _buildChatTile(chatRoomModel, targetUser);
      },
    );
  }

  Widget _buildChatList(QuerySnapshot chatRoomSnapshot) {
    if (chatRoomSnapshot.docs.isEmpty) {
      return _buildEmpty();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: chatRoomSnapshot.docs.length,
      itemBuilder: (context, index) {
        final chatRoomModel = ChatRoomModel.fromMap(
          chatRoomSnapshot.docs[index].data() as Map<String, dynamic>,
        );

        return _buildChatRoomItem(chatRoomModel);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: StreamBuilder(
          stream: _chatRoomsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.active) {
              return _buildLoading();
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return _buildEmpty();
            }

            return _buildChatList(snapshot.data as QuerySnapshot);
          },
        ),
      ),
    );
  }
}
