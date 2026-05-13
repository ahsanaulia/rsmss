import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/asset_input_model.dart';

class AssetService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  String generateRfidTag() {
    final uuid = const Uuid().v4();
    return "AST-${DateTime.now().millisecondsSinceEpoch}-${uuid.substring(0, 8).toUpperCase()}";
  }
  
  Future<String?> uploadQrImage({
    required Uint8List qrImageBytes,
    required String assetId,
  }) async {
    try {
      final fileName = "qr_${assetId}_${DateTime.now().millisecondsSinceEpoch}.png";
      final path = "$assetId/$fileName";
      
      await _supabase.storage
          .from('asset_images')
          .uploadBinary(path, qrImageBytes, fileOptions: const FileOptions(
            contentType: 'image/png',
            upsert: true,
          ));
      
      return _supabase.storage
          .from('asset_images')
          .getPublicUrl(path);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<String?> uploadAssetImage({
    required File image,
    required String assetId,
  }) async {
    try {
      final fileExt = image.path.split('.').last;
      final fileName = "asset_${DateTime.now().millisecondsSinceEpoch}.$fileExt";
      final path = "$assetId/$fileName";
      
      await _supabase.storage
          .from('asset_images')
          .upload(path, image, fileOptions: const FileOptions(upsert: true));
      
      return _supabase.storage
          .from('asset_images')
          .getPublicUrl(path);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, String>> saveAsset({
    required AssetInputModel input,
    required String registeredBy,
  }) async {
    final assetId = const Uuid().v4();
    
    String? imageUrl;
    if (input.photo != null) {
      imageUrl = await uploadAssetImage(image: input.photo!, assetId: assetId);
    }
    
    await _supabase.from('assets').insert({
      'id': assetId,
      'rfid_tag_id': input.rfidTag,
      'asset_name': input.assetName,
      'type_id': input.typeId,
      'foto_url': imageUrl,
      'status_condition': input.condition,
      'level_contaminated': input.contaminationLevel,
      'is_dangerous': input.isDangerous,
      'handling_instruction': input.handlingInstruction,
      'maintenance_pattern': input.maintenancePattern,
      'inspection_day_of_month': input.inspectionDayOfMonth,
      'description': input.description,
      'registered_by': registeredBy,
      'updated_by': registeredBy,
      'last_room_id': input.roomId,
      'qrcode_url': null,
    });
    
    return {
      'assetId': assetId,
      'rfidTag': input.rfidTag,
    };
  }
  
  Future<List<Map<String, dynamic>>> loadAssetTypes() async {
    try {
      final response = await _supabase
          .from('ref_asset_types')
          .select()
          .order('type_name');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<List<Map<String, dynamic>>> loadRooms() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select()
          .order('room_name');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }
}