import 'app_error.dart';

/// Result wrapper thay cho try/catch rải rác khắp UI layer.
/// Dùng sealed class (Dart 3+) để bắt buộc xử lý đủ 2 nhánh khi pattern-match.
sealed class Result<T> {
  const Result();

  /// Gộp 2 nhánh Success/Failure thành 1 giá trị chung kiểu R.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppError error) onFailure,
  }) {
    final self = this;
    if (self is Success<T>) {
      return onSuccess(self.value);
    } else if (self is Failure<T>) {
      return onFailure(self.error);
    }
    throw StateError("Unreachable: Result has no other subtype");
  }

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);
}
