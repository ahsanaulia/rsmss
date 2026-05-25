import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';
import '../services/tracking_service.dart';

final getIt = GetIt.instance;

/// Setup semua dependency injection untuk aplikasi.
Future<void> setupServiceLocator() async {
  // Register AuthService sebagai singleton
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  
  // ✅ PERBAIKAN: Register TrackingService sebagai lazy singleton
  getIt.registerLazySingleton<TrackingService>(() => TrackingService());
}

// Shortcut getter untuk memudahkan akses
AuthService get authService => getIt<AuthService>();