import 'package:supabase_flutter/supabase_flutter.dart';

class ReportService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 1. Riwayat Insiden
  Future<List<Map<String, dynamic>>> getIncidentHistory(String profileId) async {
    final response = await _supabase
        .from('incidents')
        .select('''
          id,
          title,
          description,
          occurred_at,
          status,
          severity,
          photo_urls,
          created_at,
          ref_incident_categories!category_id (
            id,
            name,
            code,
            icon,
            color
          ),
          rooms!room_id (
            id,
            room_name
          )
        ''')
        .eq('reported_by', profileId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// 2. Riwayat Kehadiran dengan Shift dan Fatigue
  Future<List<Map<String, dynamic>>> getAttendanceHistory(String profileId) async {
    final response = await _supabase
        .from('attendance')
        .select('''
          id,
          check_in,
          check_out,
          status,
          is_overtime,
          lateness_minutes,
          early_leave_minutes,
          total_work_minutes,
          created_at,
          ref_shifts!shift_id (
            id,
            shift_name,
            shift_code,
            start_time,
            end_time
          ),
          employee_shift_rosters!roster_id (
            id,
            roster_date,
            predicted_fatigue_score,
            wellbeing_risk_level,
            location_name
          )
        ''')
        .eq('profile_id', profileId)
        .order('check_in', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// 3. Riwayat Duty Notes
  Future<List<Map<String, dynamic>>> getDutyNotesHistory(String profileId) async {
    final response = await _supabase
        .from('duty_notes')
        .select('''
          id,
          note_text,
          created_at,
          attendance_id
        ''')
        .eq('profile_id', profileId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// 4a. Riwayat Initial Stock
  Future<List<Map<String, dynamic>>> getStockInitialHistory(String profileId) async {
    final response = await _supabase
        .from('stocks')
        .select('''
          id,
          stock_code,
          stock_name,
          unit,
          current_stock,
          minimum_stock,
          stock_condition,
          photo_url,
          created_at,
          storage_locations!storage_location_id (
            location_name
          ),
          ref_stock_types!stock_type_id (
            type_name
          )
        ''')
        .eq('created_by', profileId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// 4b. Riwayat Initial Asset
  Future<List<Map<String, dynamic>>> getAssetInitialHistory(String profileId) async {
    final response = await _supabase
        .from('assets')
        .select('''
          id,
          asset_name,
          rfid_tag_id,
          foto_url,
          status_condition,
          is_dangerous,
          created_at,
          ref_asset_types!type_id (
            type_name
          ),
          rooms!last_room_id (
            room_name
          )
        ''')
        .eq('registered_by', profileId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// 4c. Riwayat Stock Opname
  Future<List<Map<String, dynamic>>> getStockOpnameHistory(String profileId) async {
    final response = await _supabase
        .from('stocks_opnames')
        .select('''
          id,
          stock_before,
          physical_stock,
          adjustment_stock,
          opname_note,
          opname_at,
          stocks!stock_id (
            id,
            stock_code,
            stock_name,
            unit
          )
        ''')
        .eq('opname_by', profileId)
        .order('opname_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// 4d. Riwayat Asset Inspection
  Future<List<Map<String, dynamic>>> getAssetInspectionHistory(String profileId) async {
    final response = await _supabase
        .from('asset_inspections')
        .select('''
          id,
          inspection_type,
          inspection_result,
          condition_status,
          contamination_level,
          notes,
          action_taken,
          recommendation,
          inspected_at,
          photo_url,
          assets!asset_id (
            id,
            asset_name,
            rfid_tag_id,
            foto_url
          )
        ''')
        .eq('inspected_by', profileId)
        .order('inspected_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}