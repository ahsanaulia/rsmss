// ============================================================
// SERVICE: Asset Assignment Service
// ============================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/asset_request_model.dart';
import '../models/asset_assignment_pending.dart';

final _supabase = Supabase.instance.client;

class AssetAssignmentService {
  
  // ==========================================================
  // UNTUK PEGAWAI
  // ==========================================================

  /// Fetch daftar aset yang tersedia dari view v_asset_available
  Future<List<Map<String, dynamic>>> fetchAvailableAssets() async {
    try {
      final response = await _supabase
          .from('v_asset_available')
          .select()
          .order('asset_name', ascending: true);
      return response;
    } catch (e) {
      throw Exception('Gagal memuat daftar aset: $e');
    }
  }

  /// Fetch daftar ruangan dari tabel rooms
  Future<List<Map<String, dynamic>>> fetchRooms() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('id, room_name')
          .order('room_name', ascending: true);
      return response;
    } catch (e) {
      throw Exception('Gagal memuat daftar ruangan: $e');
    }
  }

  /// Submit permintaan aset oleh pegawai (INSERT ke asset_assignments)
  Future<void> submitRequest(AssetRequest request) async {
    try {
      final jsonData = request.toJson();
      final response = await _supabase
          .from('asset_assignments')
          .insert(jsonData)
          .select();
      if (response.isEmpty) {
        throw Exception('Gagal menyimpan permintaan');
      }
    } catch (e) {
      throw Exception('Gagal mengirim permintaan: $e');
    }
  }

  /// Fetch riwayat permintaan milik pegawai
  Future<List<AssetAssignmentPending>> fetchMyRequests(String profileId) async {
    try {
      final response = await _supabase
          .from('v_my_asset_requests')
          .select()
          .eq('profile_id', profileId)
          .order('requested_at', ascending: false);
      
      return response.map((json) => AssetAssignmentPending.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal memuat riwayat permintaan: $e');
    }
  }

  /// Batalkan permintaan aset (hapus record dengan status pending)
  Future<void> cancelRequest(String requestId) async {
    try {
      await _supabase
          .from('asset_assignments')
          .delete()
          .eq('id', requestId)
          .eq('assignment_status', 'pending');
    } catch (e) {
      throw Exception('Gagal membatalkan permintaan: $e');
    }
  }

  /// Fetch aset aktif (sedang dipakai) milik pegawai tertentu
  Future<List<Map<String, dynamic>>> fetchMyActiveAssets(String profileId) async {
    try {
      // Step 1: Ambil semua assignment aktif milik pegawai
      final assignments = await _supabase
          .from('asset_assignments')
          .select('id, asset_id, assigned_at, handover_location_id, notes')
          .eq('profile_id', profileId)
          .eq('assignment_status', 'active')
          .order('assigned_at', ascending: false);
      
      if (assignments.isEmpty) return [];
      
      // Step 2: Kumpulkan semua asset_id yang unik
      final assetIds = assignments.map((a) => a['asset_id'] as String).toSet().toList();
      
      // Step 3: Ambil data aset (asset_name, foto_url) untuk semua asset_id
      final assets = await _supabase
          .from('assets')
          .select('id, asset_name, foto_url')
          .inFilter('id', assetIds);
      
      // Step 4: Buat map untuk akses cepat data aset
      final assetMap = {
        for (var asset in assets) asset['id'] as String: asset
      };
      
      // Step 5: Kumpulkan semua handover_location_id yang tidak null
      final handoverIds = assignments
          .map((a) => a['handover_location_id'] as String?)
          .where((id) => id != null)
          .toSet()
          .toList();
      
      // Step 6: Ambil data rooms untuk handover location
      Map<String, String> roomMap = {};
      if (handoverIds.isNotEmpty) {
        final rooms = await _supabase
            .from('rooms')
            .select('id, room_name')
            .inFilter('id', handoverIds);
        
        roomMap = {
          for (var room in rooms) room['id'] as String: room['room_name'] as String
        };
      }
      
      // Step 7: Gabungkan semua data
      return assignments.map((assignment) {
        final assetData = assetMap[assignment['asset_id']];
        return {
          'id': assignment['id'],
          'asset_id': assignment['asset_id'],
          'asset_name': assetData?['asset_name'] ?? 'Unknown Asset',
          'foto_url': assetData?['foto_url'],
          'assigned_at': assignment['assigned_at'],
          'handover_location_id': assignment['handover_location_id'],
          'handover_location_name': roomMap[assignment['handover_location_id']],
          'notes': assignment['notes'],
        };
      }).toList();
    } catch (e) {
      print('Error fetchMyActiveAssets: $e');
      throw Exception('Gagal memuat aset yang sedang dipakai: $e');
    }
  }

  /// Kembalikan aset (update assignment_status = 'released')
  Future<void> returnAsset({
    required String assignmentId,
    required String? returnLocationId,
    required String? notes,
  }) async {
    try {
      final jsonData = {
        'assignment_status': 'released',
        'released_at': DateTime.now().toIso8601String(),
        if (returnLocationId != null) 'return_location_id': returnLocationId,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      await _supabase
          .from('asset_assignments')
          .update(jsonData)
          .eq('id', assignmentId);
    } catch (e) {
      throw Exception('Gagal mengembalikan aset: $e');
    }
  }

  // ==========================================================
  // UNTUK ADMIN
  // ==========================================================

  /// Fetch daftar permintaan pending dari view v_pending_assignments
  Future<List<AssetAssignmentPending>> fetchPendingRequests() async {
    try {
      final response = await _supabase
          .from('v_pending_assignments')
          .select()
          .order('requested_at', ascending: true);
      return response.map((json) => AssetAssignmentPending.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal memuat daftar permintaan: $e');
    }
  }

  /// Approve permintaan aset (oleh admin)
  Future<void> approveRequest(String requestId, String adminUserId) async {
    try {
      final jsonData = {
        'assignment_status': 'active',
        'assigned_by': adminUserId,
        'assigned_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      await _supabase.from('asset_assignments').update(jsonData).eq('id', requestId);
    } catch (e) {
      throw Exception('Gagal menyetujui permintaan: $e');
    }
  }

  /// Reject permintaan aset (oleh admin)
  Future<void> rejectRequest(String requestId, String adminUserId) async {
    try {
      final jsonData = {
        'assignment_status': 'rejected',
        'assigned_by': adminUserId,
        'updated_at': DateTime.now().toIso8601String(),
      };
      await _supabase.from('asset_assignments').update(jsonData).eq('id', requestId);
    } catch (e) {
      throw Exception('Gagal menolak permintaan: $e');
    }
  }
}

final assetAssignmentService = AssetAssignmentService();