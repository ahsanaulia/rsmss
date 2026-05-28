import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/employee_unit_model.dart';

class EmployeeUnitService {
  final _supabase = Supabase.instance.client;

  Future<List<EmployeeUnitModel>> getAll({
    String? search,
    bool isActive = true,
  }) async {
    try {
      var query = _supabase
          .from('employee_units')
          .select('''
            *,
            parent:parent_unit_id (id, unit_name),
            head:head_of_unit_id (id, full_name)
          ''');

      if (isActive) {
        query = query.eq('is_active', true);
      }
      if (search != null && search.isNotEmpty) {
        query = query.or('unit_code.ilike.%$search%,unit_name.ilike.%$search%');
      }

      final response = await query.order('unit_name', ascending: true);

      return _mapResponseToModels(response);
    } catch (e) {
      debugPrint('Error getAll EmployeeUnits: $e');
      throw Exception('Gagal memuat data Unit: $e');
    }
  }

  Future<EmployeeUnitModel?> getById(String id) async {
    try {
      final response = await _supabase
          .from('employee_units')
          .select('''
            *,
            parent:parent_unit_id (id, unit_name),
            head:head_of_unit_id (id, full_name)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return _mapSingleResponse(response);
    } catch (e) {
      debugPrint('Error getById EmployeeUnit: $e');
      throw Exception('Gagal memuat detail Unit: $e');
    }
  }

  Future<void> insert(EmployeeUnitModel item) async {
    try {
      final data = item.toJson();
      data.remove('parent_unit_name');
      data.remove('head_of_unit_name');

      await _supabase.from('employee_units').insert(data);
    } catch (e) {
      debugPrint('Error insert EmployeeUnit: $e');
      throw Exception('Gagal menyimpan Unit: $e');
    }
  }

  Future<void> update(EmployeeUnitModel item) async {
    try {
      final data = item.toJson();
      data.remove('parent_unit_name');
      data.remove('head_of_unit_name');
      data.remove('created_at');
      data.remove('updated_at');

      await _supabase
          .from('employee_units')
          .update(data)
          .eq('id', item.id);
    } catch (e) {
      debugPrint('Error update EmployeeUnit: $e');
      throw Exception('Gagal mengupdate Unit: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      // Cek apakah unit memiliki child (sub-unit)
      final childResponse = await _supabase
          .from('employee_units')
          .select('id')
          .eq('parent_unit_id', id);

      if (childResponse.isNotEmpty) {
        throw Exception('Tidak dapat menghapus unit yang memiliki sub-unit');
      }

      // Cek apakah unit digunakan di profiles (memiliki pegawai)
      final profileResponse = await _supabase
          .from('profiles')
          .select('id')
          .eq('unit_id', id);

      if (profileResponse.isNotEmpty) {
        throw Exception('Tidak dapat menghapus unit yang masih memiliki pegawai');
      }

      await _supabase.from('employee_units').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error delete EmployeeUnit: $e');
      throw Exception('Gagal menghapus Unit: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getParentUnits() async {
    try {
      final response = await _supabase
          .from('employee_units')
          .select('id, unit_name')
          .eq('is_active', true)
          .order('unit_name');

      return response.map((e) => {
        'id': e['id'],
        'name': e['unit_name'],
      }).toList();
    } catch (e) {
      debugPrint('Error getParentUnits: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getHeadsOfUnit() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id, full_name')
          .order('full_name');

      return response.map((e) => {
        'id': e['id'],
        'name': e['full_name'],
      }).toList();
    } catch (e) {
      debugPrint('Error getHeadsOfUnit: $e');
      return [];
    }
  }

  List<EmployeeUnitModel> _mapResponseToModels(List<dynamic> response) {
    return response.map((json) => _mapSingleResponse(json)).toList();
  }

  EmployeeUnitModel _mapSingleResponse(Map<String, dynamic> json) {
    final parentData = json['parent'] as Map<String, dynamic>?;
    final headData = json['head'] as Map<String, dynamic>?;

    return EmployeeUnitModel(
      id: json['id'] as String,
      unitCode: json['unit_code'] as String,
      unitName: json['unit_name'] as String,
      parentUnitId: json['parent_unit_id'] as String?,
      unitLevel: json['unit_level'] as int? ?? 1,
      headOfUnitId: json['head_of_unit_id'] as String?,
      shiftRequired: json['shift_required'] as bool? ?? true,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      parentUnitName: parentData?['unit_name'] as String?,
      headOfUnitName: headData?['full_name'] as String?,
    );
  }
}