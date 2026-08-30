import 'package:chat_app/models/articles_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class HiddenPostBanner extends StatelessWidget {
  final VoidCallback onRestore;

  const HiddenPostBanner({super.key, required this.onRestore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 10, left: 10, right: 10),
      child: RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'Bài viết đã bị ẩn. ',
              style: TextStyle(color: Colors.black),
            ),
            TextSpan(
              recognizer: TapGestureRecognizer()..onTap = onRestore,
              text: 'Hiển thị lại bài viết',
              style: const TextStyle(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticlePostCard extends StatelessWidget {
  final Post post;
  final bool isExpanded;
  final double screenWidth;
  final VoidCallback onToggleImageSize;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final ValueChanged<String> onMenuSelected;

  const ArticlePostCard({
    super.key,
    required this.post,
    required this.isExpanded,
    required this.screenWidth,
    required this.onToggleImageSize,
    required this.onLike,
    required this.onComment,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(post.avatarUrl),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.authorName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    formatTimestamp(post.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: onMenuSelected,
              itemBuilder: (context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Chỉnh sửa bài viết'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Xóa bài viết'),
                ),
                const PopupMenuItem<String>(
                  value: 'report',
                  child: Text('Báo cáo bài viết'),
                ),
                PopupMenuItem<String>(
                  value: post.isHide ? 'reHide' : 'hide',
                  child: Text(post.isHide ? 'Hiện bài viết' : 'Ẩn bài viết'),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.only(left: 12, top: 10, bottom: 8),
          alignment: Alignment.centerLeft,
          child: Text(post.content, style: const TextStyle(fontSize: 16)),
        ),
        if (post.imageFileUrl.isNotEmpty)
          GestureDetector(
            onTap: onToggleImageSize,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: screenWidth,
              height: isExpanded ? MediaQuery.of(context).size.height : 350,
              child: Image.network(post.imageFileUrl, fit: BoxFit.cover),
            ),
          ),
        const SizedBox(height: 4),
        Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                post.initialLikes ? Icons.favorite : Icons.favorite_border,
                color: post.initialLikes ? Colors.red : null,
              ),
              onPressed: onLike,
            ),
            Text('${post.likes} Thích'),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(Icons.comment),
              onPressed: onComment,
            ),
            Text('${post.comments.length} Bình luận'),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
