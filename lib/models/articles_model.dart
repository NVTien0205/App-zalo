// ignore_for_file: unused_import, unnecessary_this

import 'dart:io';

class Post {
  late String postId;
  late String avatarUrl;
  late String authorName;
  late String content;
  late String imageFileUrl;
  late int likes;
  late bool initialLikes;
  late List<Comment> comments;
  late int timestamp;
  late bool isHide;

  Post({
    required this.isHide,
    required this.postId,
    required this.avatarUrl,
    required this.authorName,
    required this.content,
    required this.imageFileUrl,
    this.likes = 0,
    this.initialLikes = false,
    this.comments = const [],
    required this.timestamp,
  });
}

class Comment {
  late String authorName;
  late String text;

  Comment({
    required this.authorName,
    required this.text,
  });
}

String formatTimestamp(int timestamp) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  // Định dạng thời gian ở đây (ví dụ: "dd/MM/yyyy HH:mm")
  String formattedTime =
      "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  return formattedTime;
}
