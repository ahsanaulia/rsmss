import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/asset_inspection_input_model.dart';
import 'package:flutter/foundation.dart';

class AssetInspectionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Load daftar asset yang aktif
  Future<List<Map<String, dynamic>>> loadActiveAssets() async {
    try {
      final response = await _supabase
          .from('assets')
          .select('''
            id,
            asset_name,
            rfid_tag_id,
            foto_url,
            status_condition,
            level_contaminated,
            is_dangerous,
            last_inspection_at,
            next_inspection_at,
            type_id,
            ref_asset_types!inner(type_name)
          ''')
          .eq('is_active', true)
          .order('asset_name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Upload foto bukti inspeksi
  Future<String?> uploadInspectionPhoto({
    required File image,
    required String inspectionId,
  }) async {
    try {
      final fileExt = image.path.split('.').last;
      final fileName = "inspection_${DateTime.now().millisecondsSinceEpoch}.$fileExt";
      final path = "inspections/$inspectionId/$fileName";

      await _supabase.storage
          .from('asset_images')
          .upload(path, image, fileOptions: const FileOptions(upsert: true));

      return _supabase.storage.from('asset_images').getPublicUrl(path);
    } catch (e) {
      rethrow;
    }
  }

  /// Upload foto asset baru (replace foto lama)
  Future<String?> uploadNewAssetPhoto({
    required File image,
    required String assetId,
  }) async {
    try {
      // Cek foto lama
      final existingAsset = await _supabase
          .from('assets')
          .select('foto_url')
          .eq('id', assetId)
          .single();

      final oldFotoUrl = existingAsset['foto_url'] as String?;

      // Hapus foto lama jika ada
      if (oldFotoUrl != null && oldFotoUrl.isNotEmpty) {
        try {
          // Extract path from URL
          final uri = Uri.parse(oldFotoUrl);
          final pathSegments = uri.pathSegments;
          if (pathSegments.length >= 2) {
            final oldPath = '${pathSegments[pathSegments.length - 2]}/${pathSegments[pathSegments.length - 1]}';
            await _supabase.storage.from('asset_images').remove([oldPath]);
          }
        } catch (e) {
          debugPrint("Error deleting old photo: $e");
        }
      }

      // Upload foto baru
      final fileExt = image.path.split('.').last;
      final fileName = "asset_${DateTime.now().millisecondsSinceEpoch}.$fileExt";
      final path = "$assetId/$fileName";

      await _supabase.storage
          .from('asset_images')
          .upload(path, image, fileOptions: const FileOptions(upsert: true));

      return _supabase.storage.from('asset_images').getPublicUrl(path);
    } catch (e) {
      rethrow;
    }
  }

  /// Update foto asset di database
  Future<void> updateAssetPhoto({
    required String assetId,
    required String newFotoUrl,
  }) async {
    await _supabase
        .from('assets')
        .update({'foto_url': newFotoUrl, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', assetId);
  }

  /// Simpan hasil inspeksi
  Future<Map<String, String>> saveInspection({
    required AssetInspectionInputModel input,
    required File? photo,
  }) async {
    final inspectionId = const Uuid().v4();

    String? photoUrl;
    String? newAssetPhotoUrl;

    if (photo != null) {
      // Upload foto bukti inspeksi
      photoUrl = await uploadInspectionPhoto(image: photo, inspectionId: inspectionId);

      // Upload foto asset baru (replace foto lama)
      newAssetPhotoUrl = await uploadNewAssetPhoto(image: photo, assetId: input.assetId);
      
      // Update foto asset di database
      if (newAssetPhotoUrl != null) {
        await updateAssetPhoto(assetId: input.assetId, newFotoUrl: newAssetPhotoUrl);
      }
    }

    await _supabase.from('asset_inspections').insert({
      'id': inspectionId,
      'asset_id': input.assetId,
      'inspected_by': input.inspectedBy,
      'inspection_type': input.inspectionType,
      'inspection_result': input.inspectionResult,
      'condition_status': input.conditionStatus,
      'contamination_level': input.contaminationLevel,
      'notes': input.notes,
      'action_taken': input.actionTaken,
      'recommendation': input.recommendation,
      'next_inspection_at': input.nextInspectionAt?.toIso8601String(),
      'inspected_at': DateTime.now().toIso8601String(),
      'photo_url': photoUrl,
      'inspection_duration_minutes': input.inspectionDurationMinutes,
    });

    return {
      'inspectionId': inspectionId,
      'assetId': input.assetId,
    };
  }
}