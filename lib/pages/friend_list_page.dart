// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print

import 'package:chat_app/pages/other_user_info_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/models/user_model.dart';

class FriendListScreen extends StatefulWidget {
  final UserModel userModel;

  const FriendListScreen({super.key, required this.userModel});

  @override
  _FriendListScreenState createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  List<UserModel> friendList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFriendList();
  }

  Future<void> fetchFriendList() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userModel.uid)
              .get();

      if (!mounted) return;

      List<dynamic> friendUids = documentSnapshot.data()?['friendList'] ?? [];
      List<UserModel> friends = [];

      for (String friendUid in friendUids) {
        DocumentSnapshot<Map<String, dynamic>> friendSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(friendUid)
                .get();

        if (friendSnapshot.exists && friendSnapshot.data() != null) {
          UserModel friend = UserModel.fromMap(friendSnapshot.data()!);
          friends.add(friend);
        }
      }

      if (!mounted) return;

      setState(() {
        friendList = friends;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching friend list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách bạn bè'),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : friendList.isNotEmpty
              ? RefreshIndicator(
                  onRefresh: fetchFriendList,
                  child: ListView.builder(
                    itemCount: friendList.length,
                    itemBuilder: (context, index) {
                      UserModel friend = friendList[index];
                      final hasAvatar = friend.profilepicture != null &&
                          friend.profilepicture!.isNotEmpty;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              hasAvatar ? NetworkImage(friend.profilepicture!) : null,
                          child: !hasAvatar ? const Icon(Icons.person) : null,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtherUserScreen(
                                targetUser: friend,
                                userModel: widget.userModel,
                              ),
                            ),
                          );
                        },
                        title: Text(friend.fullname ?? 'Người dùng'),
                      );
                    },
                  ),
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Bạn không có bạn bè.",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Hãy bắt đầu kết bạn nào!",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
    );
  }
}
