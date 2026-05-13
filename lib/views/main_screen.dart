// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'login_screen.dart';
// import 'operation/operation_dashboard.dart';
// import 'monitor/monitor_dashboard.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   final SupabaseClient supabase = Supabase.instance.client;
  
//   bool _isLoading = true;
//   String _userName = "";
//   String _userRole = "";

//   @override
//   void initState() {
//     super.initState();
//     // Gunakan postFrameCallback agar fungsi dijalankan SETELAH build pertama selesai
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initSession();
//     });
//   }

//   Future<void> _initSession() async {
//     final session = supabase.auth.currentSession;
    
//     if (session == null) {
//       _redirectToLogin();
//       return;
//     }

//     try {
//       final userId = supabase.auth.currentUser!.id;
//       // Gunakan try-catch lokal khusus untuk query
//       final data = await supabase
//           .from('profiles') 
//           .select()
//           .eq('id', userId)
//           .maybeSingle(); // Pakai maybeSingle agar tidak throw error jika data kosong

//       if (data == null) {
//         throw Exception("Profil tidak ditemukan");
//       }

//       if (mounted) {
//         setState(() {
//           _userName = data['full_name'] ?? "Operator";
//           _userRole = data['role'] ?? "operation";
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint("Error fetching profile: $e");
      
//       _handleLogout();
//     }
//   }

//   void _redirectToLogin() {
//     if (!mounted) return;
    
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => const LoginScreen()),
//       (route) => false,
//     );
//   }

//   Future<void> _handleLogout() async {
//     try {
//       await supabase.auth.signOut();
//     } finally {
//       _redirectToLogin();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Scaffold transisi agar tidak layar hitam
//     if (_isLoading) {
//       return const Scaffold(
//         backgroundColor: Colors.white,
//         body: Center(
//           child: CircularProgressIndicator(color: Color(0xFF01579B)),
//         ),
//       );
//     }

//     // Role-Based Routing
//     if (_userRole == 'operation') {
//       return OperationDashboard(
//         userName: _userName,
//         onLogout: _handleLogout,
//       );
//     }

//     // 2. ROLE: MONITOR
//     if (_userRole == 'monitor') {
//       return MonitorDashboard(
//         userName: _userName,
//         onLogout: _handleLogout,
//       );
//     }

//     // Default Fallback
//     return Scaffold(
//       body: Center(
//         child: Text("Role $_userRole tidak dikenal."),
//       ),
//     );
//   }
// }

// lib/views/main_screen.dart (perubahan)

import 'package:flutter/material.dart';
import 'package:rsmss/core/di/service_locator.dart';
import 'package:rsmss/core/services/auth_service.dart';
import 'login_screen.dart';
import 'operation/operation_dashboard.dart';
import 'monitor/monitor_dashboard.dart';

// ⚠️ Bagian INI jangan diubah - tetap seperti asli
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// ⚠️ Bagian INI yang diubah - ganti dengan versi baru
class _MainScreenState extends State<MainScreen> {
  late final AuthService _authService;
  
  bool _isLoading = true;
  String _userName = "";
  String _userRole = "";
  
  Stream<UserSession?>? _authStream;
  
  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSession();
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authStream = _authService.sessionStream;
    _authStream?.listen((session) {
      if (!mounted) return;
      
      if (session == null) {
        _redirectToLogin();
      } else {
        setState(() {
          _userName = session.fullName;
          _userRole = session.role;
          _isLoading = false;
        });
      }
    });
  }
  
  Future<void> _initSession() async {
    final session = await _authService.refreshSession();
    
    if (!mounted) return;
    
    if (session == null) {
      _redirectToLogin();
    } else {
      setState(() {
        _userName = session.fullName;
        _userRole = session.role;
        _isLoading = false;
      });
    }
  }
  
  void _redirectToLogin() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
  
  Future<void> _handleLogout() async {
    await _authService.logout();
  }
  
  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF01579B)),
        ),
      );
    }
    
    if (_userRole == 'operation') {
      return OperationDashboard(
        userName: _userName,
        onLogout: _handleLogout,
      );
    }
    
    if (_userRole == 'monitor') {
      return MonitorDashboard(
        userName: _userName,
        onLogout: _handleLogout,
      );
    }
    
    return Scaffold(
      body: Center(
        child: Text("Role $_userRole tidak dikenal."),
      ),
    );
  }
}