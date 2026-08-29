// ignore_for_file: file_names, use_build_context_synchronously

import 'package:chat_app/core/utils/validators.dart';
import 'package:chat_app/core/widgets/app_snack_bar.dart';
import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/models/chat_room_uuid_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/chat_room_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();

  Future<UserModel?>? searchFuture;
  bool hasSearched = false;
  String currentKeyword = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    debugPrint(
        'SearchPage debug -> preparing chatroom for target uid: ${targetUser.uid}');

    final chatRoomId = ChatRoomUtil.generateChatRoomId(
      widget.userModel.uid!,
      targetUser.uid!,
    );

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatRoomId)
          .get();

      debugPrint(
          'SearchPage debug -> chatroom doc checked: $chatRoomId | exists: ${snapshot.exists}');

      if (snapshot.exists) {
        final docData = snapshot.data();
        if (docData == null) {
          debugPrint('SearchPage debug -> chatroom exists but data is null');
          return null;
        }

        final existingChatroom = ChatRoomModel.fromMap(docData);
        debugPrint('SearchPage debug -> chatroom already exists');
        return existingChatroom;
      }

      final newChatroom = ChatRoomModel(
        chatroomid: chatRoomId,
        lastMessage: '',
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );

      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());

      debugPrint(
          'SearchPage debug -> new chatroom created: ${newChatroom.chatroomid}');
      return newChatroom;
    } on FirebaseException catch (ex) {
      debugPrint('SearchPage debug -> chatroom firestore error: ${ex.message}');
      if (mounted) {
        showAppSnackBar(context, ex.message ?? 'Không thể tạo phòng chat.');
      }
      return null;
    } catch (e) {
      debugPrint('SearchPage debug -> unexpected chatroom error: $e');
      if (mounted) {
        showAppSnackBar(context, 'Không thể tạo phòng chat.');
      }
      return null;
    }
  }

  void performSearch() {
    final keyword = searchController.text.trim();
    debugPrint('SearchPage debug -> interaction: press search button');
    debugPrint('SearchPage debug -> raw keyword: ${searchController.text}');
    debugPrint('SearchPage debug -> trimmed keyword: $keyword');

    final emailError = Validators.validateEmail(keyword);
    if (emailError != null) {
      debugPrint('SearchPage debug -> validation blocked search: $emailError');
      showAppSnackBar(context, emailError);
      return;
    }

    if (keyword == widget.userModel.email) {
      debugPrint('SearchPage debug -> blocked self search');
      showAppSnackBar(context, 'Bạn đang tìm chính tài khoản của mình.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      hasSearched = true;
      currentKeyword = keyword;
      searchFuture = searchUserByEmail(keyword);
    });
  }

  Future<UserModel?> searchUserByEmail(String email) async {
    debugPrint('SearchPage debug -> async start search by email: $email');

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      debugPrint(
          'SearchPage debug -> firestore query completed, doc count: ${querySnapshot.docs.length}');

      if (querySnapshot.docs.isEmpty) {
        debugPrint('SearchPage debug -> no user found for email: $email');
        return null;
      }

      final doc = querySnapshot.docs.first;
      final userMap = doc.data();
      debugPrint('SearchPage debug -> user doc found: ${doc.id}');

      final searchedUser = UserModel.fromMap(userMap);
      debugPrint(
          'SearchPage debug -> mapped user uid: ${searchedUser.uid}, email: ${searchedUser.email}');

      if (searchedUser.uid == widget.userModel.uid) {
        debugPrint('SearchPage debug -> result is current user, ignore');
        return null;
      }

      return searchedUser;
    } on FirebaseException catch (ex) {
      debugPrint('SearchPage debug -> firestore search error: ${ex.message}');
      rethrow;
    } catch (e) {
      debugPrint('SearchPage debug -> unexpected search error: $e');
      rethrow;
    }
  }

  Future<void> openChatWithUser(UserModel searchedUser) async {
    debugPrint(
        'SearchPage debug -> interaction: tap search result uid: ${searchedUser.uid}');

    final chatroomModel = await getChatroomModel(searchedUser);
    if (chatroomModel == null) {
      debugPrint(
          'SearchPage debug -> stop navigation because chatroom is null');
      return;
    }

    debugPrint(
        'SearchPage debug -> navigation to ChatRoomPage with roomId: ${chatroomModel.chatroomid}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ChatRoomPage(
            targetUser: searchedUser,
            userModel: widget.userModel,
            firebaseUser: widget.firebaseUser,
            chatroom: chatroomModel,
          );
        },
      ),
    );
  }

  Widget _buildEmptyHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.manage_search_rounded, size: 36, color: Color(0xFF4A7DFF)),
          SizedBox(height: 12),
          Text(
            'Tìm bạn bè bằng email',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Nhập email rồi bấm tìm kiếm để bắt đầu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(strokeWidth: 2.6),
          ),
          SizedBox(height: 14),
          Text(
            'Đang tìm tài khoản...',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 34, color: const Color(0xFF4A7DFF)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(UserModel searchedUser) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        onTap: () async {
          await openChatWithUser(searchedUser);
        },
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: searchedUser.profilepicture != null &&
                  searchedUser.profilepicture!.isNotEmpty
              ? NetworkImage(searchedUser.profilepicture!)
              : null,
          backgroundColor: const Color(0xFFD9E5FF),
          child: searchedUser.profilepicture == null ||
                  searchedUser.profilepicture!.isEmpty
              ? const Icon(Icons.person, color: Color(0xFF4A7DFF))
              : null,
        ),
        title: Text(
          searchedUser.fullname?.isNotEmpty == true
              ? searchedUser.fullname!
              : 'Chưa cập nhật tên',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            searchedUser.email ?? '',
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
        trailing: Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF4FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Color(0xFF4A7DFF),
          ),
        ),
      ),
    );
  }

  Widget buildResultSection() {
    if (!hasSearched || searchFuture == null) {
      return _buildEmptyHint();
    }

    return FutureBuilder<UserModel?>(
      future: searchFuture,
      builder: (context, snapshot) {
        debugPrint(
          'SearchPage debug -> UI state: ${snapshot.connectionState} | hasData: ${snapshot.hasData} | hasError: ${snapshot.hasError}',
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          final errorText = snapshot.error.toString();
          debugPrint('SearchPage debug -> UI render error state: $errorText');
          return _buildMessageCard(
            icon: Icons.error_outline_rounded,
            title: 'Không thể tìm kiếm lúc này',
            subtitle: 'Hãy kiểm tra mạng hoặc thử lại sau ít phút.',
          );
        }

        final searchedUser = snapshot.data;
        if (searchedUser == null) {
          debugPrint(
              'SearchPage debug -> UI render empty state for keyword: $currentKeyword');
          return _buildMessageCard(
            icon: Icons.person_search_outlined,
            title: 'Chưa tìm thấy tài khoản',
            subtitle: 'Không có kết quả phù hợp với email $currentKeyword',
          );
        }

        debugPrint(
            'SearchPage debug -> UI render result uid: ${searchedUser.uid}');
        return _buildUserTile(searchedUser);
      },
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) {
          performSearch();
        },
        decoration: const InputDecoration(
          hintText: 'Nhập email cần tìm',
          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF4A7DFF)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide(color: Color(0xFF4A7DFF), width: 1.3),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: performSearch,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A7DFF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.search_rounded),
        label: const Text(
          'Tìm kiếm',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: const Color(0xFF111827),
        title: const Text(
          'Tìm kiếm qua email',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            const Text(
              'Thêm bạn mới',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tìm tài khoản bằng email để xem thông tin và bắt đầu cuộc trò chuyện.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            _buildSearchField(),
            const SizedBox(height: 14),
            _buildSearchButton(),
            const SizedBox(height: 24),
            buildResultSection(),
          ],
        ),
      ),
    );
  }
}
