import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../models/article_model.dart';
import 'comments_dialog_widget.dart';

class ArticleCardWidget extends StatefulWidget {
  final ArticleModel article;
  final Function(ArticleModel) onLikeToggle;
  final Function(String postId, String text) onAddComment;
  final Function(String postId, String newContent) onEditPost;
  final Function(String postId) onDeletePost;
  final Function(String postId, bool currentHide) onToggleHidePost;

  const ArticleCardWidget({
    super.key,
    required this.article,
    required this.onLikeToggle,
    required this.onAddComment,
    required this.onEditPost,
    required this.onDeletePost,
    required this.onToggleHidePost,
  });

  @override
  State<ArticleCardWidget> createState() => _ArticleCardWidgetState();
}

class _ArticleCardWidgetState extends State<ArticleCardWidget> {
  bool _isImageExpanded = false;

  String _formatTimestamp(int timestamp) {
    if (timestamp == 0) return '';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  }

  void _showEditDialog() {
    final controller = TextEditingController(text: widget.article.content);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chỉnh sửa bài viết'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nhập nội dung bài viết...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  widget.onEditPost(widget.article.postId, controller.text.trim());
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc muốn xóa bài viết này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                widget.onDeletePost(widget.article.postId);
                Navigator.of(context).pop();
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _showCommentsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CommentsDialogWidget(
          article: widget.article,
          onAddComment: (text) {
            widget.onAddComment(widget.article.postId, text);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final screenWidth = MediaQuery.of(context).size.width;

    if (article.isHide) {
      return Container(
        padding: const EdgeInsets.only(bottom: 20, top: 10, left: 10, right: 10),
        child: RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: "Bài viết đã bị ẩn. ",
                style: TextStyle(color: Colors.black),
              ),
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    widget.onToggleHidePost(article.postId, article.isHide);
                  },
                text: "Hiển thị lại bài viết",
                style: const TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: article.avatarUrl.isNotEmpty
                    ? NetworkImage(article.avatarUrl)
                    : null,
                child: article.avatarUrl.isEmpty ? const Icon(Icons.person, size: 16) : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.authorName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    _formatTimestamp(article.timestamp),
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditDialog();
                    break;
                  case 'delete':
                    _showDeleteDialog();
                    break;
                  case 'hide':
                    widget.onToggleHidePost(article.postId, article.isHide);
                    break;
                  case 'report':
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bạn đã báo cáo bài viết thành công')),
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa bài viết')),
                const PopupMenuItem(value: 'delete', child: Text('Xóa bài viết')),
                const PopupMenuItem(value: 'report', child: Text('Báo cáo bài viết')),
                const PopupMenuItem(value: 'hide', child: Text('Ẩn bài viết')),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.only(left: 12, top: 10, bottom: 8, right: 12),
          child: Text(
            article.content,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        if (article.imageFileUrl.isNotEmpty)
          GestureDetector(
            onTap: () {
              setState(() {
                _isImageExpanded = !_isImageExpanded;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: screenWidth,
              height: _isImageExpanded ? MediaQuery.of(context).size.height * 0.7 : 350,
              child: Image.network(
                article.imageFileUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.broken_image, size: 50));
                },
              ),
            ),
          ),
        const SizedBox(height: 4),
        Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                article.initialLikes ? Icons.favorite : Icons.favorite_border,
                color: article.initialLikes ? Colors.red : null,
              ),
              onPressed: () => widget.onLikeToggle(article),
            ),
            Text('${article.likes} Thích'),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(Icons.comment),
              onPressed: _showCommentsDialog,
            ),
            Text('${article.comments.length} Bình luận'),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
