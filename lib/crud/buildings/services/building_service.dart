import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class BuildingService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'buildings';

  // ==================== CRUD UTAMA ====================

  Future<List<Map<String, dynamic>>> getAllBuildings() async {
    debugPrint('🔍 [Service] getAllBuildings - Start');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            hospital_profile:hospital_id (
              id,
              name
            ),
            ref_building_functions:function_id (
              id,
              function_name
            )
          ''')
          .order('building_name', ascending: true);

      debugPrint('✅ [Service] getAllBuildings - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getAllBuildings - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data gedung: $e');
    }
  }

  Future<Map<String, dynamic>?> getBuildingById(String id) async {
    debugPrint('🔍 [Service] getBuildingById - ID: $id');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            hospital_profile:hospital_id (
              id,
              name
            ),
            ref_building_functions:function_id (
              id,
              function_name
            )
          ''')
          .eq('id', id)
          .maybeSingle();

      debugPrint('✅ [Service] getBuildingById - Success: ${response != null}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getBuildingById - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil detail gedung: $e');
    }
  }

  Future<Map<String, dynamic>> insertBuilding(Map<String, dynamic> data) async {
    debugPrint('📝 [Service] insertBuilding - Data: $data');
    
    try {
      data.removeWhere((key, value) => value == null);
      
      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      debugPrint('✅ [Service] insertBuilding - Success: ${response['id']}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] insertBuilding - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menambah gedung: $e');
    }
  }

  Future<Map<String, dynamic>> updateBuilding(String id, Map<String, dynamic> data) async {
    debugPrint('✏️ [Service] updateBuilding - ID: $id, Data: $data');
    
    try {
      data.removeWhere((key, value) => value == null);
      data.remove('id');
      data.remove('created_at');
      data.remove('created_by');
      
      final response = await _supabase
          .from(_tableName)
          .update(data)
          .eq('id', id)
          .select()
          .single();

      debugPrint('✅ [Service] updateBuilding - Success');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] updateBuilding - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengupdate gedung: $e');
    }
  }

  Future<void> deleteBuilding(String id) async {
    debugPrint('🗑️ [Service] deleteBuilding - ID: $id');
    
    try {
      // Cek apakah gedung memiliki lantai
      final floors = await _supabase
          .from('floors')
          .select('id')
          .eq('building_id', id);
      
      if (floors.isNotEmpty) {
        throw Exception('Tidak dapat menghapus gedung yang masih memiliki lantai (${floors.length} lantai). Hapus lantai terlebih dahulu.');
      }
      
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      debugPrint('✅ [Service] deleteBuilding - Success');
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] deleteBuilding - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menghapus gedung: $e');
    }
  }

  // ==================== DATA UNTUK DROPDOWN ====================

  Future<List<Map<String, dynamic>>> getHospitals() async {
    debugPrint('🔍 [Service] getHospitals - Start');
    
    try {
      final response = await _supabase
          .from('hospital_profile')
          .select('id, name')
          .order('name', ascending: true);

      debugPrint('✅ [Service] getHospitals - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getHospitals - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getBuildingFunctions() async {
    debugPrint('🔍 [Service] getBuildingFunctions - Start');
    
    try {
      final response = await _supabase
          .from('ref_building_functions')
          .select('id, function_name')
          .order('function_name', ascending: true);

      debugPrint('✅ [Service] getBuildingFunctions - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getBuildingFunctions - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getApps() async {
    debugPrint('🔍 [Service] getApps - Start');
    
    try {
      final response = await _supabase
          .from('apps_config')
          .select('id, client_name')
          .order('client_name', ascending: true);

      debugPrint('✅ [Service] getApps - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getApps - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return [];
    }
  }

  // ==================== GPS / LOCATION ====================

  Future<Map<String, dynamic>?> getCurrentLocation() async {
    debugPrint('📍 [Service] getCurrentLocation - Start');
    
    try {
      // Request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak permanen, silakan aktifkan di pengaturan');
      }
      
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      // Reverse geocoding to get address
      List<Placemark> placemarks = [];
      String address = '';
      try {
        placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks[0];
          address = [
            p.street,
            p.subLocality,
            p.locality,
            p.administrativeArea,
            p.postalCode,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
        }
      } catch (e) {
        debugPrint('Geocoding error: $e');
      }
      
      debugPrint('✅ [Service] getCurrentLocation - Success: ${position.latitude}, ${position.longitude}');
      
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
      };
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getCurrentLocation - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return null;
    }
  }
}