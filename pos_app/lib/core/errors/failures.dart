/// Base failure class for error handling
/// All custom exceptions should extend this class
abstract class Failure {
  final String message;
  
  const Failure(this.message);
  
  @override
  String toString() => message;
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Storage-related failures
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

