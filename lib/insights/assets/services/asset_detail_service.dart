// lib/insights/assets/services/asset_detail_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/asset_detail_model.dart';

class AssetDetailService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AssetDetail?> getAssetDetail(String assetId) async {
    print('📦 [AssetDetailService] Mengambil detail aset: $assetId');

    try {
      final response = await _supabase
          .from('v_asset_master_complete')
          .select('''
            id,
            asset_name,
            rfid_tag_id,
            category_name,
            sub_category_name,
            type_name,
            status_condition,
            level_contaminated,
            is_dangerous,
            room_name,
            detector_code,
            last_movement_status,
            last_detected_at,
            handling_instruction,
            description,
            foto_url,
            danger_level_id,
            danger_level_code,
            danger_level_name,
            danger_risk,
            danger_protection,
            danger_instruction,
            danger_color
          ''')
          .eq('id', assetId)
          .maybeSingle();

      if (response == null) return null;

      return AssetDetail(
        id: response['id'] as String,
        assetName: response['asset_name'] as String? ?? 'Unknown',
        rfidTagId: response['rfid_tag_id'] as String? ?? '',
        categoryName: response['category_name'] as String?,
        subCategoryName: response['sub_category_name'] as String?,
        typeName: response['type_name'] as String?,
        statusCondition: response['status_condition'] as String?,
        levelContaminated: response['level_contaminated'] as int?,
        isDangerous: response['is_dangerous'] == true,
        roomName: response['room_name'] as String?,
        detectorCode: response['detector_code'] as String?,
        lastMovementStatus: response['last_movement_status'] as String?,
        lastDetectedAt: response['last_detected_at'] != null
            ? DateTime.tryParse(response['last_detected_at'] as String)
            : null,
        handlingInstruction: response['handling_instruction'] as String?,
        description: response['description'] as String?,
        fotoUrl: response['foto_url'] as String?,
        // 🔥 Dari ref_asset_danger_levels
        dangerLevelId: response['danger_level_id'] as String?,
        dangerLevelCode: response['danger_level_code'] as String?,
        dangerLevelName: response['danger_level_name'] as String?,
        dangerRisk: response['danger_risk'] as String?,
        dangerProtection: response['danger_protection'] as String?,
        dangerInstruction: response['danger_instruction'] as String?,
        dangerColor: response['danger_color'] as String?,
      );
    } catch (e) {
      print('❌ [AssetDetailService] Error: $e');
      return null;
    }
  }
}