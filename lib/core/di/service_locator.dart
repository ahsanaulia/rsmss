import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';

final getIt = GetIt.instance;

/// Setup semua dependency injection untuk aplikasi.
/// Panggil method ini sekali di main() sebelum runApp.
Future<void> setupServiceLocator() async {
  // Register AuthService sebagai singleton
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  
  // Nanti tambahkan service lain di sini:
  // getIt.registerLazySingleton<StorageService>(() => StorageService());
  // getIt.registerLazySingleton<PrintService>(() => PrintService());
}

// Shortcut getter untuk memudahkan akses
AuthService get authService => getIt<AuthService>();