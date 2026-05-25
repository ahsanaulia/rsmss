// import 'dart:async';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../exceptions/auth_exceptions.dart';

// /// Service untuk mengelola autentikasi dan profil user.
// /// 
// /// Digunakan sebagai single source of truth untuk:
// /// - Session status (login/logout)
// /// - Data profil user (nama, role)
// /// - Stream yang bisa didengarkan oleh UI (baik Provider/Bloc/setState)
// class AuthService {
//   final SupabaseClient _supabase = Supabase.instance.client;
  
//   // StreamController untuk broadcast ke banyak listener (UI lama & baru)
//   final StreamController<UserSession?> _sessionController = 
//       StreamController<UserSession?>.broadcast();
  
//   // Cache terbaru untuk akses synchronous (getter)
//   UserSession? _cachedSession;
  
//   AuthService() {
//     // Listen ke perubahan auth dari Supabase
//     _supabase.auth.onAuthStateChange.listen((event) {
//       final session = event.session;
//       if (session == null) {
//         _cachedSession = null;
//         _sessionController.add(null);
//       } else {
//         // Session ada -> fetch profil
//         _fetchAndCacheProfile(session.user.id);
//       }
//     });
//   }
  
//   /// Getter untuk akses synchronous (bisa dipanggil kapan saja)
//   UserSession? get currentSession => _cachedSession;
  
//   /// Getter untuk user ID (shortcut)
//   String? get currentUserId => _cachedSession?.userId;
  
//   /// Getter untuk role (shortcut)
//   String? get currentUserRole => _cachedSession?.role;
  
//   /// Stream untuk didengarkan UI (reactive)
//   Stream<UserSession?> get sessionStream => _sessionController.stream;
  
//   /// Fetch profil dari database dan update cache
//   Future<void> _fetchAndCacheProfile(String userId) async {
//     try {
//       final data = await _supabase
//           .from('profiles')
//           .select()
//           .eq('id', userId)
//           .maybeSingle();
      
//       if (data == null) {
//         throw ProfileNotFoundException('Profil tidak ditemukan untuk user: $userId');
//       }
      
//       _cachedSession = UserSession(
//         userId: userId,
//         email: _supabase.auth.currentUser?.email ?? '',
//         fullName: data['full_name'] ?? 'Operator',
//         role: data['role'] ?? 'operation',
//         rawData: data,
//       );
      
//       _sessionController.add(_cachedSession);
//     } catch (e) {
//       // Jika gagal fetch profil, tetap kasih session minimal
//       _cachedSession = UserSession(
//         userId: userId,
//         email: _supabase.auth.currentUser?.email ?? '',
//         fullName: 'User',
//         role: 'operation',
//         rawData: null,
//       );
//       _sessionController.add(_cachedSession);
      
//       rethrow;
//     }
//   }
  
//   /// Cek apakah user sedang login
//   Future<bool> isLoggedIn() async {
//     final session = _supabase.auth.currentSession;
//     return session != null;
//   }
  
//   /// Ambil session saat ini (force refresh dari Supabase)
//   Future<UserSession?> refreshSession() async {
//     final session = _supabase.auth.currentSession;
//     if (session == null) {
//       _cachedSession = null;
//       _sessionController.add(null);
//       return null;
//     }
    
//     await _fetchAndCacheProfile(session.user.id);
//     return _cachedSession;
//   }
  
//   /// Logout user
//   Future<void> logout() async {
//     try {
//       await _supabase.auth.signOut();
//       _cachedSession = null;
//       _sessionController.add(null);
//     } catch (e) {
//       throw AppAuthException('Gagal logout: $e');
//     }
//   }
  
//   /// Dispose resources (panggil saat app ditutup)
//   void dispose() {
//     _sessionController.close();
//   }
// }

// /// Model untuk session user yang sudah lengkap dengan profil
// class UserSession {
//   final String userId;
//   final String email;
//   final String fullName;
//   final String role;
//   final Map<String, dynamic>? rawData;
  
//   UserSession({
//     required this.userId,
//     required this.email,
//     required this.fullName,
//     required this.role,
//     this.rawData,
//   });
  
//   @override
//   String toString() => 'UserSession(userId: $userId, role: $role, name: $fullName)';
// }

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../exceptions/auth_exceptions.dart';

/// Service untuk mengelola autentikasi dan profil user.
/// 
/// Digunakan sebagai single source of truth untuk:
/// - Session status (login/logout)
/// - Data profil user (nama, role, approval status)
/// - Stream yang bisa didengarkan oleh UI (baik Provider/Bloc/setState)
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // StreamController untuk broadcast ke banyak listener (UI lama & baru)
  final StreamController<UserSession?> _sessionController = 
      StreamController<UserSession?>.broadcast();
  
  // Cache terbaru untuk akses synchronous (getter)
  UserSession? _cachedSession;
  
  // Subscription untuk cleanup (fix memory leak)
  StreamSubscription<AuthState>? _authStateSubscription;
  
  AuthService() {
    // Listen ke perubahan auth dari Supabase
    _authStateSubscription = _supabase.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session == null) {
        _cachedSession = null;
        _sessionController.add(null);
      } else {
        // Session ada -> fetch profil
        _fetchAndCacheProfile(session.user.id);
      }
    });
  }
  
  /// Getter untuk akses synchronous (bisa dipanggil kapan saja)
  UserSession? get currentSession => _cachedSession;
  
  /// Getter untuk user ID (shortcut)
  String? get currentUserId => _cachedSession?.userId;
  
  /// Getter untuk role (shortcut)
  String? get currentUserRole => _cachedSession?.role;
  
  /// Getter untuk status approval (shortcut)
  bool get isApproved => _cachedSession?.isApproved ?? false;
  
  /// Stream untuk didengarkan UI (reactive)
  Stream<UserSession?> get sessionStream => _sessionController.stream;
  
  /// Fetch profil dari database dan update cache
  Future<void> _fetchAndCacheProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (data == null) {
        throw ProfileNotFoundException('Profil tidak ditemukan untuk user: $userId');
      }
      
      _cachedSession = UserSession(
        userId: userId,
        email: _supabase.auth.currentUser?.email ?? '',
        fullName: data['full_name'] ?? 'Operator',
        role: data['role'] ?? 'operation',
        isApproved: data['is_approved'] ?? false,
        rawData: data,
      );
      
      _sessionController.add(_cachedSession);
    } catch (e) {
      // Jika gagal fetch profil, tetap kasih session minimal (tidak approved)
      _cachedSession = UserSession(
        userId: userId,
        email: _supabase.auth.currentUser?.email ?? '',
        fullName: 'User',
        role: 'operation',
        isApproved: false,
        rawData: null,
      );
      _sessionController.add(_cachedSession);
      
      rethrow;
    }
  }
  
  /// Cek apakah user sedang login
  Future<bool> isLoggedIn() async {
    final session = _supabase.auth.currentSession;
    return session != null;
  }
  
  /// Ambil session saat ini (force refresh dari Supabase)
  Future<UserSession?> refreshSession() async {
    final session = _supabase.auth.currentSession;
    if (session == null) {
      _cachedSession = null;
      _sessionController.add(null);
      return null;
    }
    
    await _fetchAndCacheProfile(session.user.id);
    return _cachedSession;
  }
  
  /// Logout user
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      _cachedSession = null;
      _sessionController.add(null);
    } catch (e) {
      throw AppAuthException('Gagal logout: $e');
    }
  }
  
  /// Dispose resources (panggil saat app ditutup)
  void dispose() {
    _authStateSubscription?.cancel();
    _sessionController.close();
  }
}

/// Model untuk session user yang sudah lengkap dengan profil
class UserSession {
  final String userId;
  final String email;
  final String fullName;
  final String role;
  final bool isApproved;
  final Map<String, dynamic>? rawData;
  
  UserSession({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isApproved,
    this.rawData,
  });
  
  @override
  String toString() => 'UserSession(userId: $userId, role: $role, name: $fullName, approved: $isApproved)';
}