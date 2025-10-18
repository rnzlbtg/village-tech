/// Base class for API result handling
/// Provides success/failure states with optional error codes
class ApiResult<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? code;

  const ApiResult._({
    required this.success,
    this.data,
    this.error,
    this.code,
  });

  /// Create a successful result
  factory ApiResult.success(T data) {
    return ApiResult._(
      success: true,
      data: data,
    );
  }

  /// Create a failure result
  factory ApiResult.failure(String error, {String? code}) {
    return ApiResult._(
      success: false,
      error: error,
      code: code,
    );
  }

  /// Check if result is successful
  bool get isSuccess => success;

  /// Check if result is a failure
  bool get isFailure => !success;

  /// Get data or throw if failure
  T get dataOrThrow {
    if (isFailure) {
      throw Exception(error ?? 'Unknown error');
    }
    return data as T;
  }

  /// Map success data to another type
  ApiResult<U> map<U>(U Function(T data) mapper) {
    if (isFailure) {
      return ApiResult.failure(error!, code: code);
    }
    return ApiResult.success(mapper(data as T));
  }

  /// Handle success and failure cases
  R when<R>({
    required R Function(T data) success,
    required R Function(String error, String? code) failure,
  }) {
    if (isSuccess) {
      return success(data as T);
    } else {
      return failure(error!, code);
    }
  }
}

/// Common error codes
class ApiErrorCodes {
  static const String unauthorized = 'UNAUTHORIZED';
  static const String validationError = 'VALIDATION_ERROR';
  static const String allocationExceeded = 'ALLOCATION_EXCEEDED';
  static const String notFound = 'NOT_FOUND';
  static const String alreadyExists = 'ALREADY_EXISTS';
  static const String networkError = 'NETWORK_ERROR';
  static const String serverError = 'SERVER_ERROR';
}
