/// Core exception untuk auth-related errors milik aplikasi.
/// Nama diubah menjadi AppAuthException untuk menghindari bentrok dengan 
/// AuthException milik Supabase (package:gotrue).
class AppAuthException implements Exception {
  final String message;
  final StackTrace? stackTrace;
  
  AppAuthException(this.message, [this.stackTrace]);
  
  @override
  String toString() => 'AppAuthException: $message';
}

class ProfileNotFoundException extends AppAuthException {
  ProfileNotFoundException(super.message, [super.stackTrace]);
}

class SessionExpiredException extends AppAuthException {
  SessionExpiredException(super.message, [super.stackTrace]);
}