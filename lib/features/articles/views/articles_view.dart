import 'package:chat_app/core/widgets/app_snack_bar.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../articles_view_model.dart';
import '../models/articles_state.dart';
import 'widgets/article_card_widget.dart';
import 'widgets/create_post_widget.dart';

class ArticlesView extends ConsumerStatefulWidget {
  final UserModel userModel;

  const ArticlesView({
    super.key,
    required this.userModel,
  });

  @override
  ConsumerState<ArticlesView> createState() => _ArticlesViewState();
}

class _ArticlesViewState extends ConsumerState<ArticlesView> {
  late final TextEditingController _postController;

  @override
  void initState() {
    super.initState();
    _postController = TextEditingController();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    debugPrint(
      '[Interaction] Articles -> user tapped submit post | text="${_postController.text.trim()}"',
    );

    final viewModel = ref.read(articlesViewModelProvider.notifier);
    final success = await viewModel.createPost(
      content: _postController.text,
      authorName: widget.userModel.fullname ?? 'Người đăng bài',
      avatarUrl: widget.userModel.profilepicture ?? '',
    );

    if (success) {
      debugPrint('[UI] Articles -> clear post input after submit success');
      _postController.clear();
      if (!mounted) return;
      debugPrint('[UI] Articles -> show success snackbar for create post');
      showAppSnackBar(context, 'Đăng bài thành công');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(articlesViewModelProvider);
    final viewModel = ref.read(articlesViewModelProvider.notifier);

    ref.listen<ArticlesState>(articlesViewModelProvider, (previous, next) {
      final error = next.errorMessage;
      if (error != null && error != previous?.errorMessage) {
        debugPrint('[UI] Articles -> show error snackbar: $error');
        showAppSnackBar(context, error);
      }
    });

    if (state.isLoading) {
      debugPrint('[UI] Articles -> render loading state');
    } else if (state.posts.isEmpty) {
      debugPrint('[UI] Articles -> render empty posts state');
    } else {
      debugPrint(
        '[UI] Articles -> render posts list count: ${state.posts.length}',
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            viewModel.init();
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                CreatePostWidget(
                  userModel: widget.userModel,
                  postController: _postController,
                  state: state,
                  onPostTextChanged: (value) {
                    debugPrint(
                      '[Interaction] Articles -> user typing post text | length: ${value.trim().length}',
                    );
                  },
                  onPickImage: () => viewModel.pickImage(),
                  onSubmitPost: _submitPost,
                ),
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.posts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'Chưa có bài viết nào. Hãy là người đầu tiên đăng bài!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.posts.length,
                    separatorBuilder: (context, index) => const Divider(
                      color: Color.fromARGB(255, 236, 236, 236),
                      thickness: 10.0,
                      height: 0,
                    ),
                    itemBuilder: (context, index) {
                      final article = state.posts[index];
                      return ArticleCardWidget(
                        article: article,
                        onLikeToggle: (art) {
                          debugPrint(
                            '[Interaction] Articles -> user tapped like button',
                          );
                          viewModel.toggleLike(art);
                        },
                        onAddComment: (postId, text) {
                          debugPrint(
                            '[Interaction] Articles -> user typing comment text | length: ${text.trim().length}',
                          );
                          debugPrint(
                            '[Interaction] Articles -> submit comment for postId: $postId',
                          );
                          viewModel.addComment(
                            postId: postId,
                            text: text,
                            authorName:
                                widget.userModel.fullname ?? 'Người đăng bài',
                          );
                        },
                        onEditPost: (postId, newContent) =>
                            viewModel.updatePostContent(postId, newContent),
                        onDeletePost: (postId) => viewModel.deletePost(postId),
                        onToggleHidePost: (postId, currentHide) =>
                            viewModel.toggleHidePost(postId, currentHide),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
