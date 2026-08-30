// ignore_for_file: file_names, avoid_print

import 'dart:typed_data';

import 'package:chat_app/models/articles_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/articles/article_dialogs.dart';
import 'package:chat_app/pages/articles/article_service.dart';
import 'package:chat_app/pages/articles/widgets/article_composer_section.dart';
import 'package:chat_app/pages/articles/widgets/article_post_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class History extends StatefulWidget {
  final UserModel userModel;

  const History({super.key, required this.userModel});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final ArticleService _articleService = ArticleService();

  bool isSearchActivated = false;
  String searchText = '';
  List<Post> posts = [];
  late TextEditingController postController;
  XFile? selectedImageFile;
  Uint8List? selectedImageBytes;
  bool _isExpanded = false;

  void _logDataFlow(String message) {
    debugPrint('Articles data -> $message');
  }

  void _toggleImageSize() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  void initState() {
    super.initState();
    postController = TextEditingController();
    _getPosts();
  }

  @override
  void dispose() {
    postController.dispose();
    super.dispose();
  }

  Future<void> deletePost(int index) async {
    try {
      final post = posts[index];
      _logDataFlow(
        'delete start | index: $index | postId: ${post.postId} | localCountBefore: ${posts.length}',
      );

      final deleted = await _articleService.deletePostById(post.postId);

      _logDataFlow(
        'delete fetch document | postId: ${post.postId} | exists: $deleted',
      );

      if (!deleted) {
        debugPrint('Tài liệu không tồn tại');
        return;
      }

      if (!mounted) return;

      setState(() {
        posts.removeAt(index);
      });

      _logDataFlow(
        'delete success | removed postId: ${post.postId} | localCountAfter: ${posts.length}',
      );
    } catch (e) {
      debugPrint('Lỗi khi xóa bài viết: $e');
    }
  }

  Future<void> editPost(int index) async {
    await showEditPostDialog(
      context: context,
      initialContent: posts[index].content,
      onChanged: (value) {
        posts[index].content = value;
      },
      onSave: (value) async {
        try {
          final post = posts[index];
          final updated = await _articleService.updatePostContent(
            postId: post.postId,
            content: value,
          );

          if (!updated) {
            debugPrint('Tài liệu không tồn tại.');
            return;
          }

          if (!mounted) return;
          setState(() {
            posts[index].content = value;
          });
        } catch (e) {
          debugPrint('Lỗi khi cập nhật bài viết: $e');
        }
      },
    );
  }

  Future<void> _submitForm() async {
    final postText = postController.text.trim();
    String? imageUrl;

    if (postText.isEmpty && selectedImageFile == null) {
      return;
    }

    _logDataFlow(
      'submit start | textLength: ${postText.length} | hasSelectedImage: ${selectedImageFile != null}',
    );

    if (selectedImageFile != null) {
      _logDataFlow(
          'upload image start | source: ArticleService.uploadPostImage');
      imageUrl = await _articleService.uploadPostImage(
        selectedImageFile: selectedImageFile!,
        selectedImageBytes: selectedImageBytes,
      );
      _logDataFlow('upload image success | imageUrl: $imageUrl');
    }

    _logDataFlow(
      'create local Post object | author: ${widget.userModel.fullname} | imageAttached: ${imageUrl != null && imageUrl.isNotEmpty}',
    );

    _logDataFlow('write Firestore start | collection: posts');
    final newPost = await _articleService.createPost(
      userModel: widget.userModel,
      postText: postText,
      imageUrl: imageUrl,
    );
    _logDataFlow('write Firestore success | new postId: ${newPost.postId}');

    if (!mounted) return;

    setState(() {
      posts.insert(0, newPost);
      postController.clear();
      selectedImageFile = null;
      selectedImageBytes = null;
    });

    _logDataFlow(
      'local state updated after submit | localCount: ${posts.length} | controllerCleared: ${postController.text.isEmpty}',
    );
  }

  Future<void> _getPosts() async {
    _logDataFlow('fetch posts start | source: ArticleService.fetchPosts');
    final fetchedPosts = await _articleService.fetchPosts();

    _logDataFlow(
      'fetch posts success | rawDocCount: ${fetchedPosts.length}',
    );

    for (final post in fetchedPosts) {
      _logDataFlow(
        'map document -> Post | postId: ${post.postId} | hasImage: ${post.imageFileUrl.isNotEmpty} | likes: ${post.likes}',
      );
    }

    _logDataFlow('mapping finished | fetchedPosts: ${fetchedPosts.length}');

    if (!mounted) return;

    setState(() {
      posts = fetchedPosts;
    });

    _logDataFlow(
      'local state replaced from Firestore | localCount: ${posts.length}',
    );
  }

  Future<void> getImage() async {
    _logDataFlow('pick image start | source: gallery');
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      _logDataFlow('pick image cancelled by user');
      return;
    }

    final bytes = await pickedFile.readAsBytes();
    _logDataFlow(
      'pick image success | fileName: ${pickedFile.name} | byteLength: ${bytes.length}',
    );

    if (!mounted) return;

    setState(() {
      selectedImageFile = pickedFile;
      selectedImageBytes = bytes;
    });
  }

  void addComment(int index, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      final comment = Comment(
        authorName: widget.userModel.fullname ?? '',
        text: trimmed,
      );
      posts[index].comments.add(comment);
    });
  }

  Future<void> showComments(int index) async {
    await showCommentsDialog(
      context: context,
      commentTiles: posts[index]
          .comments
          .map(
            (comment) => ListTile(
              title: Text(comment.authorName),
              subtitle: Text(comment.text),
            ),
          )
          .toList(),
      onSubmitted: (text) {
        addComment(index, text);
      },
    );
  }

  Future<void> updateLikesInFirestore(String id, bool isLike, int likes) async {
    try {
      await _articleService.updateLikes(
        postId: id,
        isLike: isLike,
        likes: likes,
      );
    } catch (e) {
      print('Lỗi khi cập nhật lượt thích: $e');
    }
  }

  Future<void> hidePost(String id) async {
    try {
      await _articleService.setPostHidden(postId: id, hide: true);
    } catch (e) {
      print('Lỗi khi ẩn bài viết: $e');
    }
  }

  Future<void> reHidePost(String id) async {
    try {
      await _articleService.setPostHidden(postId: id, hide: false);
    } catch (e) {
      print('Lỗi khi hiện lại bài viết: $e');
    }
  }

  Future<void> _togglePostVisibility(int index) async {
    final post = posts[index];
    if (post.isHide) {
      await reHidePost(post.postId);
    } else {
      await hidePost(post.postId);
    }
    await _getPosts();
  }

  Future<void> _togglePostLike(int index) async {
    final post = posts[index];
    final isLike = !post.initialLikes;
    final likes = isLike ? post.likes + 1 : post.likes - 1;

    setState(() {
      post.initialLikes = isLike;
      post.likes = likes;
    });

    await updateLikesInFirestore(post.postId, isLike, likes);
  }

  Future<void> _handlePostMenuAction(int index, String value) async {
    if (value == 'edit') {
      await editPost(index);
      return;
    }

    if (value == 'delete') {
      final shouldDelete = await showDeletePostDialog(context);
      if (shouldDelete) {
        await deletePost(index);
      }
      return;
    }

    if (value == 'hide' || value == 'reHide') {
      await _togglePostVisibility(index);
      return;
    }

    if (value == 'report') {
      await showReportDialog(context);
    }
  }

  Future<void> showSearchBar() async {
    await showSearchDialog(
      context: context,
      onChanged: (value) {
        setState(() {
          searchText = value;
        });
      },
      onClose: () {
        setState(() {
          isSearchActivated = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ArticleComposerSection(
              userModel: widget.userModel,
              postController: postController,
              onPickImage: getImage,
              onSubmit: _submitForm,
              onCreateAlbum: () {},
            ),
            const SizedBox(height: 8),
            Container(
              height: 10,
              color: const Color.fromARGB(255, 236, 236, 236),
            ),
            if (selectedImageFile != null)
              SizedBox(
                width: screenWidth,
                child: selectedImageBytes != null
                    ? Image.memory(selectedImageBytes!, fit: BoxFit.cover)
                    : const SizedBox.shrink(),
              ),
            SizedBox(
              height: 800,
              child: ListView.separated(
                separatorBuilder: (context, index) => const Divider(
                  color: Color.fromARGB(255, 236, 236, 236),
                  thickness: 10,
                  height: 0,
                ),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];

                  if (post.isHide) {
                    return HiddenPostBanner(
                      onRestore: () {
                        _togglePostVisibility(index);
                      },
                    );
                  }

                  return ArticlePostCard(
                    post: post,
                    isExpanded: _isExpanded,
                    screenWidth: screenWidth,
                    onToggleImageSize: _toggleImageSize,
                    onLike: () {
                      _togglePostLike(index);
                    },
                    onComment: () {
                      showComments(index);
                    },
                    onMenuSelected: (value) {
                      _handlePostMenuAction(index, value);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
