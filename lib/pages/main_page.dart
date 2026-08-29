// ignore_for_file: file_names, library_private_types_in_public_api, prefer_const_constructors, use_key_in_widget_constructors, use_build_context_synchronously

import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/articles_page.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/friend_list_page.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/notification_page.dart';
import 'package:chat_app/pages/search_page.dart';
import 'package:chat_app/pages/user_information_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MainPage({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _pages = [
      ChatPage(
        userModel: widget.userModel,
        firebaseUser: widget.firebaseUser,
      ),
      FriendListScreen(userModel: widget.userModel),
      History(userModel: widget.userModel),
      FriendRequestScreen(currentUser: widget.userModel),
      ProfilePage(userModel: widget.userModel),
    ];
  }

  Future<void> _openSearch() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SearchPage(
        userModel: widget.userModel,
        firebaseUser: widget.firebaseUser,
      );
    }));
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) {
        return HomePage();
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.blueAccent.shade700,
      toolbarHeight: 56,
      titleSpacing: 12,
      title: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: _openSearch,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: const [
              Icon(Icons.search_rounded, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Text(
                'Tìm kiếm',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_scanner_rounded, size: 24),
          color: Colors.white,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.add_rounded, size: 28),
          color: Colors.white,
          onPressed: () {},
        ),
        IconButton(
          onPressed: _signOut,
          icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 24),
        ),
      ],
    );
  }

  BottomNavigationBar _buildBottomNav(int notificationCount) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blueAccent.shade700,
      unselectedItemColor: const Color(0xFF8B95A7),
      selectedFontSize: 12,
      unselectedFontSize: 12,
      elevation: 8,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          activeIcon: Icon(Icons.chat_bubble_rounded),
          label: 'Tin nhắn',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.people_outline_rounded),
          activeIcon: Icon(Icons.people_rounded),
          label: 'Danh bạ',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.photo_library_outlined),
          activeIcon: Icon(Icons.photo_library_rounded),
          label: 'Bài viết',
        ),
        BottomNavigationBarItem(
          icon: _buildNotificationIcon(notificationCount, false),
          activeIcon: _buildNotificationIcon(notificationCount, true),
          label: 'Thông báo',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Cá nhân',
        ),
      ],
    );
  }

  Widget _buildNotificationIcon(int count, bool isActive) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(isActive
            ? Icons.notifications_rounded
            : Icons.notifications_none_rounded),
        if (count > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Text(
                count > 9 ? '9+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('friend_requests')
          .where('receiverId', isEqualTo: widget.userModel.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final notificationCount = snapshot.data?.docs.length ?? 0;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FA),
          appBar: _buildAppBar(),
          body: PageView(
            controller: _pageController,
            children: _pages,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          bottomNavigationBar: _buildBottomNav(notificationCount),
        );
      },
    );
  }
}

class ContactsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Contacts Page'),
    );
  }
}

class MomentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Moments Page'),
    );
  }
}
