import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'article_model.dart';

class ArticlesState {
  final List<ArticleModel> posts;
  final bool isLoading;
  final bool isSubmitting;
  final XFile? selectedImageFile;
  final Uint8List? selectedImageBytes;
  final String? errorMessage;

  const ArticlesState({
    this.posts = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.selectedImageFile,
    this.selectedImageBytes,
    this.errorMessage,
  });

  ArticlesState copyWith({
    List<ArticleModel>? posts,
    bool? isLoading,
    bool? isSubmitting,
    XFile? selectedImageFile,
    Uint8List? selectedImageBytes,
    String? errorMessage,
    bool clearSelectedImage = false,
  }) {
    return ArticlesState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      selectedImageFile:
          clearSelectedImage ? null : (selectedImageFile ?? this.selectedImageFile),
      selectedImageBytes:
          clearSelectedImage ? null : (selectedImageBytes ?? this.selectedImageBytes),
      errorMessage: errorMessage,
    );
  }
}
