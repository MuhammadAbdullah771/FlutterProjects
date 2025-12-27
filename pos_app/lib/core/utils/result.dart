/// Result class for handling success/failure states
/// This is a common pattern in functional programming
/// It helps avoid throwing exceptions and makes error handling explicit
sealed class Result<T> {
  const Result();
}

/// Success result containing the data
final class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
}

/// Failure result containing the error
final class Failure<T> extends Result<T> {
  final String message;
  
  const Failure(this.message);
}

/// Extension methods for Result
extension ResultExtensions<T> on Result<T> {
  /// Returns true if the result is a success
  bool get isSuccess => this is Success<T>;
  
  /// Returns true if the result is a failure
  bool get isFailure => this is Failure<T>;
  
  /// Gets the data if success, null otherwise
  T? get dataOrNull => switch (this) {
    Success(data: final data) => data,
    Failure() => null,
  };
  
  /// Gets the error message if failure, null otherwise
  String? get errorOrNull => switch (this) {
    Success() => null,
    Failure(message: final message) => message,
  };
}

