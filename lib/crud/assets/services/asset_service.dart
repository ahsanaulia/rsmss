// ============================================================
// SERVICE: Asset Service
// ============================================================
// TANGGUNG JAWAB:
// 1. Semua operasi CRUD ke tabel 'assets'
// 2. Upload/download foto ke Supabase Storage bucket 'asset_images'
// 3. Menggunakan VIEW v_asset_details untuk mengambil data dengan relasi
// 4. Fetch data untuk dropdown (rooms, asset_types, maintenance_patterns, profiles, danger_levels)
// 5. SUPPORT WEB & MOBILE - menggunakan XFile dari image_picker
// ============================================================

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../models/asset_model.dart';

// ============================================================
// INISIALISASI SUPABASE CLIENT
// ============================================================
final _supabase = Supabase.instance.client;

// ============================================================
// NAMA BUCKET UNTUK STORAGE FOTO ASET
// ============================================================
const String _assetImageBucket = 'asset_images';

// ============================================================
// SERVICE CLASS
// ============================================================
class AssetService {
  
  // ==========================================================
  // SECTION 1: READ / FETCH DATA (MENGGUNAKAN VIEW)
  // ==========================================================

  Future<List<Asset>> fetchAllAssets() async {
    try {
      final response = await _supabase
          .from('v_asset_details')
          .select('*')
          .order('created_at', ascending: false);

      if (response.isEmpty) return [];
      
      return response.map<Asset>((item) {
        return _parseAssetFromViewResponse(item);
      }).toList();
      
    } catch (e) {
      throw Exception('Gagal memuat data aset: $e');
    }
  }

  Future<Asset?> fetchAssetById(String assetId) async {
    try {
      final response = await _supabase
          .from('v_asset_details')
          .select('*')
          .eq('id', assetId)
          .maybeSingle();

      if (response == null) return null;
      
      return _parseAssetFromViewResponse(response);
      
    } catch (e) {
      throw Exception('Gagal memuat detail aset: $e');
    }
  }

  Asset _parseAssetFromViewResponse(Map<String, dynamic> response) {
    return Asset(
      id: response['id'] as String,
      rfidTagId: response['rfid_tag_id'] as String,
      assetName: response['asset_name'] as String,
      fotoUrl: response['foto_url'] as String?,
      qrcodeUrl: response['qrcode_url'] as String?,
      typeId: response['type_id'] as String?,
      typeName: response['type_name'] as String?,
      subCategoryName: response['sub_category_name'] as String?,
      categoryName: response['category_name'] as String?,
      statusCondition: response['status_condition'] as String? ?? 'Good',
      levelContaminated: (response['level_contaminated'] as int?) ?? 0,
      isDangerous: (response['is_dangerous'] as bool?) ?? false,
      handlingInstruction: response['handling_instruction'] as String?,
      maintenancePattern: response['maintenance_pattern'] as String?,
      inspectionDayOfMonth: response['inspection_day_of_month'] as int?,
      lastInspectionAt: _parseDateTime(response['last_inspection_at']),
      nextInspectionAt: _parseDateTime(response['next_inspection_at']),
      isActive: (response['is_active'] as bool?) ?? true,
      description: response['description'] as String?,
      lastRoomId: response['last_room_id'] as String?,
      lastRoomName: response['room_name'] as String?,
      lastDetectorId: response['last_detector_id'] as String?,
      lastDetectedAt: _parseDateTime(response['last_detected_at']),
      lastMovementStatus: response['last_movement_status'] as String?,
      lastUsedBy: response['last_used_by'] as String?,
      lastUsedByName: response['last_used_by_name'] as String?,
      lastAssignedAt: _parseDateTime(response['last_assigned_at']),
      lastInspectionId: response['last_inspection_id'] as String?,
      lastInspectionResult: response['last_inspection_result'] as String?,
      lastInspectionNotes: response['last_inspection_notes'] as String?,
      lastActionTaken: response['last_action_taken'] as String?,
      lastRecommendation: response['last_recommendation'] as String?,
      registeredBy: response['registered_by'] as String?,
      registeredByName: response['registered_by_name'] as String?,
      registeredAt: _parseDateTime(response['registered_at']) ?? DateTime.now(),
      updatedBy: response['updated_by'] as String?,
      updatedByName: response['updated_by_name'] as String?,
      updatedAt: _parseDateTime(response['updated_at']) ?? DateTime.now(),
      // 🔥 DANGER LEVEL
      dangerLevelId: response['danger_level_id'] as String?,
      dangerLevelName: response['danger_level_name'] as String?,
      dangerLevelCode: response['danger_level_code'] as String?,
      dangerColor: response['danger_color'] as String?,
    );
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value as String);
    } catch (e) {
      return null;
    }
  }

  // ==========================================================
  // SECTION 2: FETCH DATA UNTUK DROPDOWN
  // ==========================================================

  Future<List<Map<String, dynamic>>> fetchAllRooms() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('id, room_name')
          .order('room_name', ascending: true);
      return response;
    } catch (e) {
      throw Exception('Gagal memuat data ruangan: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllAssetTypes() async {
    try {
      final response = await _supabase
          .from('ref_asset_types')
          .select('''
            id,
            type_name,
            ref_asset_sub_categories!ref_asset_types_sub_category_id_fkey (
              sub_category_name,
              ref_asset_categories!ref_asset_sub_categories_category_id_fkey (
                category_name
              )
            )
          ''')
          .order('type_name', ascending: true);
      
      if (response.isEmpty) return [];
      
      return response.map((item) {
        final subCategoryData = item['ref_asset_sub_categories'] as Map<String, dynamic>?;
        final categoryData = subCategoryData?['ref_asset_categories'] as Map<String, dynamic>?;
        final categoryName = categoryData?['category_name'] as String? ?? '-';
        final subCategoryName = subCategoryData?['sub_category_name'] as String? ?? '-';
        final typeName = item['type_name'] as String;
        final displayName = '$categoryName → $subCategoryName → $typeName';
        return {
          'id': item['id'],
          'type_name': typeName,
          'display_name': displayName,
          'category_name': categoryName,
          'sub_category_name': subCategoryName,
        };
      }).toList();
      
    } catch (e) {
      return await _fetchAllAssetTypesSimple();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAllAssetTypesSimple() async {
    try {
      final response = await _supabase
          .from('ref_asset_types')
          .select('id, type_name')
          .order('type_name', ascending: true);
      if (response.isEmpty) return [];
      return response.map((item) {
        final typeName = item['type_name'] as String;
        return {
          'id': item['id'],
          'type_name': typeName,
          'display_name': typeName,
          'category_name': '-',
          'sub_category_name': '-',
        };
      }).toList();
    } catch (e) {
      throw Exception('Gagal memuat tipe aset: $e');
    }
  }

  Future<List<String>> fetchMaintenancePatterns() async {
    try {
      final response = await _supabase
          .from('assets')
          .select('maintenance_pattern')
          .not('maintenance_pattern', 'is', null);
      if (response.isEmpty) return [];
      final patterns = response
          .map((item) => item['maintenance_pattern'] as String)
          .where((pattern) => pattern.isNotEmpty)
          .toSet()
          .toList();
      patterns.sort();
      return patterns;
    } catch (e) {
      throw Exception('Gagal memuat pola perawatan: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProfiles() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id, full_name')
          .order('full_name', ascending: true);
      return response;
    } catch (e) {
      throw Exception('Gagal memuat data profil: $e');
    }
  }

  // 🔥 FETCH DANGER LEVELS UNTUK DROPDOWN
  Future<List<Map<String, dynamic>>> fetchAllDangerLevels() async {
    try {
      final response = await _supabase
          .from('ref_asset_danger_levels')
          .select('id, level_code, level_name, color_hex')
          .eq('is_active', true)
          .order('sort_order', ascending: true);
      return response;
    } catch (e) {
      print('Error loading danger levels: $e');
      return [];
    }
  }

  // ==========================================================
  // SECTION 3: CREATE / UPDATE / DELETE
  // ==========================================================

  Future<Asset> createAsset(Asset asset, String userId) async {
    try {
      if (asset.rfidTagId.isEmpty) {
        throw Exception('RFID Tag ID wajib diisi');
      }
      if (asset.assetName.isEmpty) {
        throw Exception('Nama aset wajib diisi');
      }
      final jsonData = asset.toJsonForCreate(userId);
      final response = await _supabase
          .from('assets')
          .insert(jsonData)
          .select()
          .single();
      final createdAsset = await fetchAssetById(response['id'] as String);
      if (createdAsset == null) {
        throw Exception('Gagal mengambil data aset yang baru dibuat');
      }
      return createdAsset;
    } catch (e) {
      throw Exception('Gagal menambah aset: $e');
    }
  }

  Future<Asset> updateAsset(Asset asset, String userId) async {
    try {
      if (asset.id.isEmpty) {
        throw Exception('ID aset tidak ditemukan untuk update');
      }
      if (asset.rfidTagId.isEmpty) {
        throw Exception('RFID Tag ID wajib diisi');
      }
      if (asset.assetName.isEmpty) {
        throw Exception('Nama aset wajib diisi');
      }
      final jsonData = asset.toJson();
      jsonData['updated_by'] = userId;
      final response = await _supabase
          .from('assets')
          .update(jsonData)
          .eq('id', asset.id)
          .select()
          .single();
      final updatedAsset = await fetchAssetById(response['id'] as String);
      if (updatedAsset == null) {
        throw Exception('Gagal mengambil data aset yang diperbarui');
      }
      return updatedAsset;
    } catch (e) {
      throw Exception('Gagal memperbarui aset: $e');
    }
  }

  Future<bool> deleteAsset(String assetId, String userId) async {
    try {
      await _supabase
          .from('assets')
          .update({
            'is_active': false,
            'updated_by': userId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', assetId);
      return true;
    } catch (e) {
      throw Exception('Gagal menghapus aset: $e');
    }
  }

  Future<bool> hardDeleteAsset(String assetId) async {
    try {
      await _supabase.from('assets').delete().eq('id', assetId);
      return true;
    } catch (e) {
      throw Exception('Gagal menghapus aset permanen: $e');
    }
  }

  // ==========================================================
  // SECTION 4: UPLOAD FOTO (FINAL - WORKING FOR WEB & MOBILE)
  // ==========================================================

  /// -----------------------------------------------------------------
  /// UPLOAD FOTO ASET KE SUPABASE STORAGE
  /// -----------------------------------------------------------------
  /// Menerima XFile dari image_picker (bukan File)
  /// Support Web dan Mobile secara otomatis
  /// -----------------------------------------------------------------
  Future<String> uploadAssetPhoto(XFile xFile, String assetId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${assetId}_$timestamp.jpg';
      
      // Baca bytes dari XFile (work di Web & Mobile)
      final bytes = await xFile.readAsBytes();
      
      // Upload bytes ke Supabase Storage
      await _supabase.storage
          .from(_assetImageBucket)
          .uploadBinary(fileName, bytes);
      
      final publicUrl = _supabase.storage
          .from(_assetImageBucket)
          .getPublicUrl(fileName);
      
      return publicUrl;
      
    } catch (e) {
      print('UploadAssetPhoto error: $e');
      throw Exception('Gagal upload foto: ${e.toString()}');
    }
  }

  /// -----------------------------------------------------------------
  /// HAPUS FOTO ASET DARI STORAGE
  /// -----------------------------------------------------------------
  Future<void> deleteAssetPhoto(String photoUrl) async {
    try {
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;
      final assetImagesIndex = pathSegments.indexWhere(
        (segment) => segment == _assetImageBucket
      );
      if (assetImagesIndex != -1 && assetImagesIndex + 1 < pathSegments.length) {
        final filePath = pathSegments.sublist(assetImagesIndex + 1).join('/');
        await _supabase.storage
            .from(_assetImageBucket)
            .remove([filePath]);
      }
    } catch (e) {
      print('Gagal menghapus foto aset: $e');
    }
  }

  // ==========================================================
  // SECTION 5: SEARCH DAN FILTER
  // ==========================================================

  Future<List<Asset>> searchAssets(String keyword) async {
    if (keyword.isEmpty) {
      return fetchAllAssets();
    }
    try {
      final response = await _supabase
          .from('v_asset_details')
          .select('*')
          .or(
            'rfid_tag_id.ilike.%$keyword%, asset_name.ilike.%$keyword%, type_name.ilike.%$keyword%, category_name.ilike.%$keyword%, sub_category_name.ilike.%$keyword%'
          )
          .order('created_at', ascending: false);
      if (response.isEmpty) return [];
      return response.map<Asset>((item) {
        return _parseAssetFromViewResponse(item);
      }).toList();
    } catch (e) {
      throw Exception('Gagal mencari aset: $e');
    }
  }

  Future<List<Asset>> filterAssetsByStatus(String statusCondition) async {
    try {
      final response = await _supabase
          .from('v_asset_details')
          .select('*')
          .eq('status_condition', statusCondition)
          .order('created_at', ascending: false);
      if (response.isEmpty) return [];
      return response.map<Asset>((item) {
        return _parseAssetFromViewResponse(item);
      }).toList();
    } catch (e) {
      throw Exception('Gagal memfilter aset: $e');
    }
  }
}

// ============================================================
// SINGLETON INSTANCE
// ============================================================
final assetService = AssetService();