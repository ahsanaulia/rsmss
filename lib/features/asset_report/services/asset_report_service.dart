// ============================================================
// SERVICE: Asset Report Service
// ============================================================
// TANGGUNG JAWAB:
// 1. Fetch data dari view v_asset_report untuk laporan aset
// 2. Mendukung filter: tipe aset, status kondisi, status ketersediaan, inspeksi terlewat
// 3. Menyediakan data untuk export PDF/Print
// ============================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/asset_report_model.dart';

final _supabase = Supabase.instance.client;

class AssetReportService {
  
  /// Fetch semua data aset dari view v_asset_report
  Future<List<AssetReport>> fetchAllAssets() async {
    try {
      final response = await _supabase
          .from('v_asset_report')
          .select()
          .order('asset_name', ascending: true);
      
      if (response.isEmpty) return [];
      
      return response.map((json) => AssetReport.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal memuat data laporan aset: $e');
    }
  }

  /// Fetch data dengan filter
    Future<List<AssetReport>> fetchFilteredAssets({
    String? typeId,
    String? statusCondition,
    String? availabilityStatus,
    bool? onlyOverdueInspection,
  }) async {
    try {
      print('========== FILTER DEBUG ==========');
      print('typeId: $typeId');
      print('statusCondition: $statusCondition');
      print('availabilityStatus: $availabilityStatus');
      print('onlyOverdueInspection: $onlyOverdueInspection');
      
      var query = _supabase.from('v_asset_report').select();
      
      if (typeId != null && typeId.isNotEmpty) {
        print('Applying type filter: $typeId');
        query = query.eq('type_id', typeId);
      }
      
      if (statusCondition != null && statusCondition.isNotEmpty && statusCondition != 'all') {
        print('Applying status condition filter: $statusCondition');
        query = query.eq('status_condition', statusCondition);
      }
      
      if (availabilityStatus != null && availabilityStatus.isNotEmpty && availabilityStatus != 'all') {
        print('Applying availability status filter: $availabilityStatus');
        query = query.eq('availability_status', availabilityStatus);
      }
      
      if (onlyOverdueInspection == true) {
        print('Applying overdue inspection filter');
        query = query.eq('inspection_status', 'Terlewat');
      }
      
      final response = await query.order('asset_name', ascending: true);
      
      print('Response length: ${response.length}');
      print('==================================');
      
      if (response.isEmpty) return [];
      
      return response.map((json) => AssetReport.fromJson(json)).toList();
    } catch (e) {
      print('Error: $e');
      throw Exception('Gagal memuat data laporan aset: $e');
    }
  }

  /// Fetch daftar tipe aset untuk dropdown filter
  Future<List<Map<String, dynamic>>> fetchAssetTypes() async {
    try {
      final response = await _supabase
          .from('ref_asset_types')
          .select('id, type_name')
          .order('type_name', ascending: true);
      
      return response;
    } catch (e) {
      throw Exception('Gagal memuat tipe aset: $e');
    }
  }

  /// Fetch daftar nilai status_condition yang unik untuk dropdown filter
  Future<List<String>> fetchStatusConditions() async {
    try {
      final response = await _supabase
          .from('assets')
          .select('status_condition')
          .not('status_condition', 'is', null);
      
      final conditions = response
          .map((item) => item['status_condition'] as String)
          .toSet()
          .toList();
      
      conditions.sort();
      return conditions;
    } catch (e) {
      return ['Good', 'Fair', 'Damage', 'Critical'];
    }
  }

  /// Fetch daftar status ketersediaan untuk dropdown filter
  List<String> getAvailabilityStatusOptions() {
    return [
      'Tersedia',
      'Digunakan',
      'Rusak',
      'Perawatan',
      'Tidak Aktif',
    ];
  }
}

final assetReportService = AssetReportService();