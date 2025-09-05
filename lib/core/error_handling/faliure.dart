class Failure {
  final String message;
  final String? code;

  Failure({required this.message, this.code});

  @override
  String toString() => 'Failure(code: $code, message: $message)';
}

class FirebaseErrorMapper {
  static Failure fromCode(String code) {
    switch (code) {
      // 🔐 Authentication errors
      case "ERROR_EMAIL_ALREADY_IN_USE":
      case "account-exists-with-different-credential":
      case "email-already-in-use":
        return Failure(
          code: code,
          message: "Email already used. Go to login page.",
        );

      case "ERROR_WRONG_PASSWORD":
      case "wrong-password":
      case "invalid-credential":
        return Failure(
          code: code,
          message: "Wrong email/password combination.",
        );

      case "ERROR_USER_NOT_FOUND":
      case "user-not-found":
        return Failure(code: code, message: "No user found with this email.");

      case "ERROR_USER_DISABLED":
      case "user-disabled":
        return Failure(code: code, message: "User disabled.");

      case "ERROR_TOO_MANY_REQUESTS":
      case "operation-not-allowed":
        return Failure(
          code: code,
          message: "Too many requests. Try again later.",
        );

      case "ERROR_OPERATION_NOT_ALLOWED":
      case "ERROR_INVALID_EMAIL":
      case "invalid-email":
        return Failure(code: code, message: "Email address is invalid.");

      // 📦 Firestore or General Firebase errors
      case "permission-denied":
        return Failure(
          code: code,
          message: "You do not have permission to access this data.",
        );

      case "unavailable":
        return Failure(
          code: code,
          message: "Service is unavailable. Try again later.",
        );

      case "not-found":
        return Failure(code: code, message: "Document not found.");

      case "deadline-exceeded":
        return Failure(
          code: code,
          message: "The request timed out. Try again.",
        );

      case "resource-exhausted":
        return Failure(
          code: code,
          message: "Too many reads/writes. Slow down.",
        );

      default:
        return Failure(code: code, message: "Unexpected error occurred.");
    }
  }
}
