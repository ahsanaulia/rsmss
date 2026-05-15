// // ignore_for_file: use_build_context_synchronously

// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart'; 
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class AttendanceView extends StatefulWidget {
//   const AttendanceView({super.key});

//   @override
//   State<AttendanceView> createState() => _AttendanceViewState();
// }

// class _AttendanceViewState extends State<AttendanceView> {
//   CameraController? _cameraController;
//   bool _isInitialising = true;
//   bool _isProcessing = false;
  
//   Position? _currentPosition;
//   String? _currentAddress; 
  
//   List<Map<String, dynamic>> _shifts = []; 
//   String? _selectedShiftId; 
  
//   // Penampung data record yang sedang aktif (belum check out)
//   Map<String, dynamic>? _activeAttendance;
  
//   final supabase = Supabase.instance.client;

//   @override
//   void initState() {
//     super.initState();
//     _startSetup();
//   }

//   Future<void> _startSetup() async {
//     setState(() => _isInitialising = true);
//     try {
//       // 1. Cek status aktif (apakah sudah check in tapi belum check out)
//       await _checkActiveAttendance();
//       // 2. Ambil referensi shift
//       await _fetchShifts();
//       // 3. Urusan lokasi
//       await _determinePosition();
//       // 4. Nyalakan Kamera
//       await _initCamera();
//     } catch (e) {
//       debugPrint("Setup Error: $e");
//     } finally {
//       if (mounted) setState(() => _isInitialising = false);
//     }
//   }

//   // VALIDASI: Cari record yang check_out-nya masih NULL untuk user ini
//   Future<void> _checkActiveAttendance() async {
//     try {
//       final user = supabase.auth.currentUser;
//       if (user == null) return;

//       // Pakai filter universal biar VS Code gak rewel
//       final data = await supabase
//           .from('attendance')
//           .select()
//           .eq('profile_id', user.id)
//           .filter('check_out', 'is', null) 
//           .maybeSingle();

//       if (mounted) {
//         setState(() {
//           _activeAttendance = data;
//           if (data != null) {
//             _selectedShiftId = data['shift_id']; 
//           }
//         });
//       }
//     } catch (e) {
//       debugPrint("Gagal cek status aktif: $e");
//     }
//   }

//   Future<void> _fetchShifts() async {
//     try {
//       final data = await supabase
//           .from('ref_shifts')
//           .select()
//           .order('start_time', ascending: true);
      
//       setState(() {
//         _shifts = List<Map<String, dynamic>>.from(data);
//         if (_shifts.isNotEmpty && _activeAttendance == null) {
//           _selectedShiftId = _shifts[0]['id']; 
//         }
//       });
//     } catch (e) {
//       debugPrint("Error fetching shifts: $e");
//     }
//   }

//   Future<void> _initCamera() async {
//     try {
//       final cameras = await availableCameras();
//       if (cameras.isEmpty) return;
//       final frontCamera = cameras.firstWhere(
//         (c) => c.lensDirection == CameraLensDirection.front,
//         orElse: () => cameras.first,
//       );
//       _cameraController = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: false);
//       await _cameraController!.initialize();
//     } catch (e) {
//       debugPrint("Kamera Error: $e");
//     }
//   }

//   Future<void> _determinePosition() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
//       final position = await Geolocator.getCurrentPosition();
//       try {
//         List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
//         if (placemarks.isNotEmpty) {
//           Placemark p = placemarks[0];
//           _currentAddress = "${p.street}, ${p.subLocality}, ${p.locality}";
//         }
//       } catch (_) {
//         _currentAddress = "Koordinat: ${position.latitude}, ${position.longitude}";
//       }
//       if (mounted) setState(() => _currentPosition = position);
//     } catch (e) {
//       debugPrint("Lokasi Error: $e");
//     }
//   }

//   // --- LOGIKA UTAMA: SUBMIT (INSERT atau UPDATE) ---
//   Future<void> _submitAttendance() async {
//     if (_selectedShiftId == null) return;
//     if (_cameraController == null || !_cameraController!.value.isInitialized) return;

//     setState(() => _isProcessing = true);
//     final user = supabase.auth.currentUser;
//     if (user == null) return;

//     // PAKAI WAKTU HP ANDROID (WIB)
//     final String localTime = DateTime.now().toIso8601String();

//     try {
//       await _cameraController!.takePicture();
//       await _determinePosition();

//       if (_activeAttendance == null) {
//         // --- PROSES CHECK IN (INSERT) ---
//         await supabase.from('attendance').insert({
//           'profile_id': user.id,
//           'shift_id': _selectedShiftId,
//           'check_in': localTime, 
//           'lat': _currentPosition?.latitude,
//           'long': _currentPosition?.longitude,
//           'address_at_check_in': _currentAddress,
//           'status': 'present',
//           'is_available': true,
//           'notes': 'Check In via Android (WIB)',
//         });
//         _showSnack("Check In Berhasil!", Colors.green);
//       } else {
//         // --- PROSES CHECK OUT (UPDATE) ---
//         await supabase.from('attendance').update({
//           'check_out': localTime,
//           'is_available': false,
//         }).eq('id', _activeAttendance!['id']);
//         _showSnack("Check Out Berhasil!", Colors.blue);
//       }

//       // Refresh status setelah sukses
//       await _checkActiveAttendance();

//     } catch (e) {
//       _showSnack("Error: $e", Colors.red);
//     } finally {
//       if (mounted) setState(() => _isProcessing = false);
//     }
//   }

//   void _showSnack(String msg, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
//     );
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isWorking = _activeAttendance != null;

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 30),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(30),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//               child: Container(
//                 padding: const EdgeInsets.all(25),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withValues(alpha: 0.2),
//                   borderRadius: BorderRadius.circular(30),
//                   border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       isWorking ? "STATUS: ON DUTY" : "ABSENSI MANDIRI",
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: isWorking ? Colors.redAccent : const Color(0xFF01579B),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
                    
//                     // --- CAMERA PREVIEW ---
//                     Container(
//                       width: 160, height: 160,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(color: isWorking ? Colors.redAccent : Colors.white, width: 4),
//                       ),
//                       child: ClipOval(
//                         child: _isInitialising
//                             ? const Center(child: CircularProgressIndicator())
//                             : AspectRatio(
//                                 aspectRatio: 1,
//                                 child: CameraPreview(_cameraController!),
//                               ),
//                       ),
//                     ),
                    
//                     const SizedBox(height: 20),

//                     // --- DROPDOWN SHIFT (Locked if Working) ---
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withValues(alpha: isWorking ? 0.1 : 0.4),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           value: _selectedShiftId,
//                           isExpanded: true,
//                           disabledHint: Text(
//                              _shifts.isEmpty ? "Loading..." : 
//                              _shifts.firstWhere((s) => s['id'] == _selectedShiftId, 
//                              orElse: () => {'shift_name': 'Shift Aktif'})['shift_name'],
//                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
//                           ),
//                           items: isWorking ? null : _shifts.map((shift) {
//                             return DropdownMenuItem<String>(
//                               value: shift['id'],
//                               child: Text(
//                                 "${shift['shift_name']} (${shift['start_time']} - ${shift['end_time']})",
//                                 style: GoogleFonts.poppins(fontSize: 12),
//                               ),
//                             );
//                           }).toList(),
//                           onChanged: isWorking ? null : (val) => setState(() => _selectedShiftId = val),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 15),

//                     // --- INFO LOKASI ---
//                     Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
//                             const SizedBox(width: 5),
//                             Flexible(
//                               child: Text(
//                                 _currentAddress ?? "Mencari lokasi...",
//                                 textAlign: TextAlign.center,
//                                 style: GoogleFonts.poppins(fontSize: 10, color: Colors.black87),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 25),

//                     // --- TOMBOL DINAMIS ---
//                     SizedBox(
//                       width: double.infinity, height: 50,
//                       child: ElevatedButton(
//                         onPressed: (_isProcessing || _isInitialising) ? null : _submitAttendance,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: isWorking ? Colors.redAccent : const Color(0xFF01579B),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         child: _isProcessing
//                             ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                             : Text(
//                                 isWorking ? "CHECK OUT SEKARANG" : "CHECK IN SEKARANG", 
//                                 style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: use_build_context_synchronously
import 'package:uuid/uuid.dart';  // ← Tambahkan di atas
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/tracking_service.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  CameraController? _cameraController;
  bool _isInitialising = true;
  bool _isProcessing = false;
  
  Position? _currentPosition;
  String? _currentAddress; 
  
  List<Map<String, dynamic>> _shifts = []; 
  String? _selectedShiftId; 
  
  // Penampung data record yang sedang aktif (belum check out)
  Map<String, dynamic>? _activeAttendance;
  String? _currentSessionId;
  
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _startSetup();
  }

  Future<void> _startSetup() async {
    setState(() => _isInitialising = true);
    try {
      await _checkActiveAttendance();
      await _fetchShifts();
      await _determinePosition();
      await _initCamera();
    } catch (e) {
      debugPrint("Setup Error: $e");
    } finally {
      if (mounted) setState(() => _isInitialising = false);
    }
  }

  Future<void> _checkActiveAttendance() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final data = await supabase
          .from('attendance')
          .select()
          .eq('profile_id', user.id)
          .filter('check_out', 'is', null) 
          .maybeSingle();

      if (mounted) {
        setState(() {
          _activeAttendance = data;
          if (data != null) {
            _selectedShiftId = data['shift_id'];
            _currentSessionId = data['session_id'];
            
            // Jika sudah ON DUTY dan tracking belum aktif, mulai tracking
            if (_currentSessionId != null) {
              final tracking = getIt<TrackingService>();
              if (!tracking.isTracking) {
                tracking.startTracking(
                  profileId: user.id,
                  sessionId: _currentSessionId!,
                  immediate: true,
                );
              }
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Gagal cek status aktif: $e");
    }
  }

  Future<void> _fetchShifts() async {
    try {
      final data = await supabase
          .from('ref_shifts')
          .select()
          .order('start_time', ascending: true);
      
      setState(() {
        _shifts = List<Map<String, dynamic>>.from(data);
        if (_shifts.isNotEmpty && _activeAttendance == null) {
          _selectedShiftId = _shifts[0]['id']; 
        }
      });
    } catch (e) {
      debugPrint("Error fetching shifts: $e");
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: false);
      await _cameraController!.initialize();
    } catch (e) {
      debugPrint("Kamera Error: $e");
    }
  }

  Future<void> _determinePosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      final position = await Geolocator.getCurrentPosition();
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark p = placemarks[0];
          _currentAddress = "${p.street}, ${p.subLocality}, ${p.locality}";
        }
      } catch (_) {
        _currentAddress = "Koordinat: ${position.latitude}, ${position.longitude}";
      }
      if (mounted) setState(() => _currentPosition = position);
    } catch (e) {
      debugPrint("Lokasi Error: $e");
    }
  }

  Future<void> _submitAttendance() async {
    if (_selectedShiftId == null) return;
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    setState(() => _isProcessing = true);
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final String localTime = DateTime.now().toIso8601String();
    final tracking = getIt<TrackingService>();

    try {
      await _cameraController!.takePicture();
      await _determinePosition();

      if (_activeAttendance == null) {
        // --- CHECK IN ---
        // final sessionId = '${user.id}_${DateTime.now().millisecondsSinceEpoch}';
        final sessionId = const Uuid().v4(); 
        await supabase.from('attendance').insert({
          'profile_id': user.id,
          'shift_id': _selectedShiftId,
          'check_in': localTime, 
          'lat': _currentPosition?.latitude,
          'long': _currentPosition?.longitude,
          'address_at_check_in': _currentAddress,
          'status': 'present',
          'is_available': true,
          'is_tracking_active': true,
          'session_id': sessionId,
          'notes': 'Check In via Android',
        });
        
        // START TRACKING
        tracking.startTracking(
          profileId: user.id,
          sessionId: sessionId,
          immediate: true,
        );
        
        _showSnack("Check In Berhasil! Tracking dimulai.", Colors.green);
      } else {
        // --- CHECK OUT ---
        await supabase.from('attendance').update({
          'check_out': localTime,
          'is_available': false,
          'is_tracking_active': false,
        }).eq('id', _activeAttendance!['id']);
        
        // STOP TRACKING
        tracking.stopTracking();
        
        _showSnack("Check Out Berhasil! Tracking dihentikan.", Colors.blue);
      }

      await _checkActiveAttendance();

    } catch (e) {
      _showSnack("Error: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    // Stop tracking saat widget di dispose
    final tracking = getIt<TrackingService>();
    if (tracking.isTracking) {
      tracking.stopTracking();
    }
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isWorking = _activeAttendance != null;
    final tracking = getIt<TrackingService>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status dengan indikator tracking
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isWorking && tracking.isTracking)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          isWorking ? "STATUS: ON DUTY" : "ABSENSI MANDIRI",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isWorking ? Colors.redAccent : const Color(0xFF01579B),
                          ),
                        ),
                      ],
                    ),
                    if (isWorking && tracking.isTracking)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "📍 Tracking lokasi aktif (setiap 10 menit)",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    
                    // Camera Preview
                    Container(
                      width: 160, height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: isWorking ? Colors.redAccent : Colors.white, width: 4),
                      ),
                      child: ClipOval(
                        child: _isInitialising
                            ? const Center(child: CircularProgressIndicator())
                            : AspectRatio(
                                aspectRatio: 1,
                                child: CameraPreview(_cameraController!),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    // Dropdown Shift (disabled when working)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: isWorking ? 0.1 : 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedShiftId,
                          isExpanded: true,
                          disabledHint: Text(
                             _shifts.isEmpty ? "Loading..." : 
                             _shifts.firstWhere((s) => s['id'] == _selectedShiftId, 
                             orElse: () => {'shift_name': 'Shift Aktif'})['shift_name'],
                             style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                          ),
                          items: isWorking ? null : _shifts.map((shift) {
                            return DropdownMenuItem<String>(
                              value: shift['id'],
                              child: Text(
                                "${shift['shift_name']} (${shift['start_time']} - ${shift['end_time']})",
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                            );
                          }).toList(),
                          onChanged: isWorking ? null : (val) => setState(() => _selectedShiftId = val),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Location Info
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                _currentAddress ?? "Mencari lokasi...",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(fontSize: 10, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Submit Button
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        onPressed: (_isProcessing || _isInitialising) ? null : _submitAttendance,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isWorking ? Colors.redAccent : const Color(0xFF01579B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isProcessing
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                isWorking ? "CHECK OUT SEKARANG" : "CHECK IN SEKARANG", 
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}