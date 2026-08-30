import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'article_repository.dart';
import 'models/article_model.dart';
import 'models/articles_state.dart';

final articleRepositoryProvider = Provider<IArticleRepository>((ref) {
  return ArticleRepository();
});

final articlesViewModelProvider =
    NotifierProvider<ArticlesViewModel, ArticlesState>(ArticlesViewModel.new);

class ArticlesViewModel extends Notifier<ArticlesState> {
  late final IArticleRepository _repository;
  StreamSubscription<List<ArticleModel>>? _postsSubscription;

  @override
  ArticlesState build() {
    _repository = ref.watch(articleRepositoryProvider);
    ref.onDispose(() {
      _postsSubscription?.cancel();
    });

    Future.microtask(_startPostsSubscription);

    return const ArticlesState(isLoading: true);
  }

  void init() {
    _startPostsSubscription();
  }

  void _startPostsSubscription() {
    debugPrint('ArticlesViewModel debug -> start posts subscription');
    debugPrint(
      '[State] Articles -> set isLoading=true before subscribe stream',
    );

    state = state.copyWith(isLoading: true, errorMessage: null);
    _postsSubscription?.cancel();

    _postsSubscription = _repository.watchPosts().listen(
      (posts) {
        debugPrint(
          'ArticlesViewModel debug -> posts updated, count: ${posts.length}',
        );
        debugPrint(
          '[State] Articles -> set posts=${posts.length}, isLoading=false, errorMessage=null',
        );
        state = state.copyWith(
          posts: posts,
          isLoading: false,
          errorMessage: null,
        );
      },
      onError: (error) {
        debugPrint('ArticlesViewModel debug -> stream error: $error');
        debugPrint('[State] Articles -> set isLoading=false with stream error');
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Lỗi khi tải bài viết: $error',
        );
      },
    );
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      state = state.copyWith(
        selectedImageFile: pickedFile,
        selectedImageBytes: bytes,
      );
    }
  }

  void clearSelectedImage() {
    state = state.copyWith(clearSelectedImage: true);
  }

  Future<bool> createPost({
    required String content,
    required String authorName,
    required String avatarUrl,
  }) async {
    final trimmedContent = content.trim();
    final hasText = trimmedContent.isNotEmpty;
    final hasSelectedImage = state.selectedImageFile != null;
    final canCreatePost = hasText || hasSelectedImage;

    debugPrint(
      '[BusinessRule] Articles -> create post requires text or image',
    );
    debugPrint(
      '[PureLogic] Articles -> createPost compute | hasText: $hasText | hasSelectedImage: $hasSelectedImage | canCreatePost: $canCreatePost | trimmedLength: ${trimmedContent.length}',
    );
    debugPrint(
      '[Control] Articles -> start create post validation | trimmedLength: ${trimmedContent.length} | hasSelectedImage: $hasSelectedImage',
    );

    if (!canCreatePost) {
      debugPrint(
        '[Control] Articles -> block submit because content is empty and no image selected',
      );
      debugPrint(
        '[SideEffect] Articles -> set errorMessage for invalid create post input',
      );
      debugPrint('[State] Articles -> set errorMessage for empty create post');
      state = state.copyWith(
        errorMessage: 'Vui lòng nhập nội dung hoặc chọn ảnh!',
      );
      return false;
    }

    debugPrint('[Control] Articles -> passed create post validation');
    debugPrint(
        '[SideEffect] Articles -> set isSubmitting=true and clear old error');
    debugPrint('[State] Articles -> set isSubmitting=true before createPost');

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    debugPrint('[Async] Articles -> await repository.createPost start');
    final result = await _repository.createPost(
      content: content,
      authorName: authorName,
      avatarUrl: avatarUrl,
      imageFile: state.selectedImageFile,
      imageBytes: state.selectedImageBytes,
    );

    return result.fold(
      onSuccess: (postId) {
        debugPrint(
          '[Async] Articles -> repository.createPost success | postId: $postId',
        );
        debugPrint(
          '[SideEffect] Articles -> set isSubmitting=false and clear selected image after create success',
        );
        debugPrint(
          '[State] Articles -> set isSubmitting=false and clear selected image after create success',
        );
        state = state.copyWith(
          isSubmitting: false,
          clearSelectedImage: true,
        );
        return true;
      },
      onFailure: (error) {
        debugPrint(
          '[Async] Articles -> repository.createPost failed | error: ${error.message}',
        );
        debugPrint(
          '[SideEffect] Articles -> set isSubmitting=false and push errorMessage to state',
        );
        debugPrint(
          '[State] Articles -> set isSubmitting=false with errorMessage: ${error.message}',
        );
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: error.message,
        );
        return false;
      },
    );
  }

  Future<void> toggleLike(ArticleModel article) async {
    final newIsLiked = !article.initialLikes;
    debugPrint(
      '[Interaction] Articles -> user tapped like | postId: ${article.postId}',
    );
    final newLikes = newIsLiked ? article.likes + 1 : article.likes - 1;
    debugPrint(
      '[PureLogic] Articles -> toggleLike compute | oldIsLiked: ${article.initialLikes} | newIsLiked: $newIsLiked | newLikes: $newLikes',
    );
    final updatedPosts = state.posts.map((p) {
      if (p.postId == article.postId) {
        return p.copyWith(initialLikes: newIsLiked, likes: newLikes);
      }
      return p;
    }).toList();

    state = state.copyWith(posts: updatedPosts);
    debugPrint(
      '[State] Articles -> optimistic update like | postId: ${article.postId} | likes: $newLikes',
    );

    final result = await _repository.toggleLike(
      postId: article.postId,
      isLiked: newIsLiked,
      likesCount: newLikes,
    );

    result.fold(
      onSuccess: (_) {},
      onFailure: (error) {
        debugPrint(
          'ArticlesViewModel debug -> toggle like failed: ${error.message}',
        );
        init();
      },
    );
  }

  Future<bool> addComment({
    required String postId,
    required String text,
    required String authorName,
  }) async {
    if (text.trim().isEmpty) return false;

    final comment = CommentModel(authorName: authorName, text: text.trim());
    final article = state.posts.firstWhere((p) => p.postId == postId);

    final result = await _repository.addComment(
      postId: postId,
      comment: comment,
      currentComments: article.comments,
    );

    return result.fold(
      onSuccess: (_) => true,
      onFailure: (error) {
        state = state.copyWith(errorMessage: error.message);
        return false;
      },
    );
  }

  Future<bool> updatePostContent(String postId, String newContent) async {
    final result = await _repository.updatePostContent(
      postId: postId,
      newContent: newContent,
    );

    return result.fold(
      onSuccess: (_) => true,
      onFailure: (error) {
        state = state.copyWith(errorMessage: error.message);
        return false;
      },
    );
  }

  Future<void> toggleHidePost(String postId, bool currentHideState) async {
    await _repository.toggleHidePost(
      postId: postId,
      isHide: !currentHideState,
    );
  }

  Future<void> deletePost(String postId) async {
    await _repository.deletePost(postId);
  }
}
