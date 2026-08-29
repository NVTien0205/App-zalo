// ignore_for_file: file_names

import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FriendRequestScreen extends StatelessWidget {
  final UserModel currentUser;

  const FriendRequestScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('Thông báo'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('friend_requests')
            .where('receiverId', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Không có thông báo nào'),
            );
          }

          final requests = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final request = requests[index];

              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(request['senderId'])
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const _NotificationLoadingCard();
                  }

                  final userData = userSnapshot.data?.data();
                  if (userData == null) {
                    return const SizedBox.shrink();
                  }

                  final sender = UserModel.fromMap(userData);

                  return _FriendRequestCard(
                    sender: sender,
                    onAccept: () => _acceptRequest(
                      context: context,
                      requestId: request.id,
                      senderId: request['senderId'] as String,
                    ),
                    onReject: () => _rejectRequest(
                      context: context,
                      requestId: request.id,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _acceptRequest({
    required BuildContext context,
    required String requestId,
    required String senderId,
  }) async {
    await FirebaseFirestore.instance
        .collection('friend_requests')
        .doc(requestId)
        .update({'status': 'accepted'});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({
      'friendList': FieldValue.arrayUnion([senderId]),
    });

    await FirebaseFirestore.instance.collection('users').doc(senderId).update({
      'friendList': FieldValue.arrayUnion([currentUser.uid]),
    });

    await FirebaseFirestore.instance
        .collection('friend_requests')
        .doc(requestId)
        .delete();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã chấp nhận lời mời kết bạn')),
    );
  }

  Future<void> _rejectRequest({
    required BuildContext context,
    required String requestId,
  }) async {
    await FirebaseFirestore.instance
        .collection('friend_requests')
        .doc(requestId)
        .delete();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã từ chối lời mời kết bạn')),
    );
  }
}

class _FriendRequestCard extends StatelessWidget {
  final UserModel sender;
  final Future<void> Function() onAccept;
  final Future<void> Function() onReject;

  const _FriendRequestCard({
    required this.sender,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(profileUrl: sender.profilepicture, fullname: sender.fullname),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sender.fullname?.isNotEmpty == true
                      ? sender.fullname!
                      : 'Người dùng',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Đã gửi cho bạn một lời mời kết bạn',
                  style: TextStyle(
                    color: Colors.black54,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Đang chờ phản hồi',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Color(0xFFD0D7E2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Từ chối'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Chấp nhận'),
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

class _Avatar extends StatelessWidget {
  final String? profileUrl;
  final String? fullname;

  const _Avatar({
    required this.profileUrl,
    required this.fullname,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = profileUrl != null && profileUrl!.trim().isNotEmpty;
    final firstLetter = (fullname != null && fullname!.trim().isNotEmpty)
        ? fullname!.trim()[0].toUpperCase()
        : '?';

    return CircleAvatar(
      radius: 26,
      backgroundColor: const Color(0xFFE5E7EB),
      backgroundImage: hasImage ? NetworkImage(profileUrl!) : null,
      child: hasImage
          ? null
          : Text(
              firstLetter,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

class _NotificationLoadingCard extends StatelessWidget {
  const _NotificationLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          CircleAvatar(radius: 26, backgroundColor: Color(0xFFE5E7EB)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 14,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Color(0xFFE5E7EB)),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  height: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Color(0xFFF1F5F9)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
