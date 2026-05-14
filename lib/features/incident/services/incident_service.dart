import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class IncidentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Ambil scoring category ID untuk INCIDENT
  Future<String?> _getIncidentCategoryId() async {
    final response = await _supabase
        .from('scoring_categories')
        .select('id')
        .eq('category_code', 'INCIDENT')
        .maybeSingle();
    return response?['id']?.toString();
  }

  /// Ambil poin berdasarkan category code incident
  int _getPointsByCategory(String categoryCode) {
    switch (categoryCode.toUpperCase()) {
      case 'SAFETY':
        return 15;
      case 'HUMAN':
        return 12;
      case 'ASSET':
        return 10;
      case 'FACILITY':
        return 8;
      case 'STOCK':
        return 5;
      default:
        return 3;
    }
  }

  /// Upload foto insiden
  Future<List<String>> uploadIncidentPhotos({
    required List<File> images,
    required String incidentId,
  }) async {
    List<String> photoUrls = [];

    for (int i = 0; i < images.length; i++) {
      final image = images[i];
      final fileExt = image.path.split('.').last;
      final fileName = "incident_${DateTime.now().millisecondsSinceEpoch}_$i.$fileExt";
      final path = "incidents/$incidentId/$fileName";

      await _supabase.storage
          .from('asset_images')
          .upload(path, image, fileOptions: const FileOptions(upsert: true));

      final url = _supabase.storage.from('asset_images').getPublicUrl(path);
      photoUrls.add(url);
    }

    return photoUrls;
  }

  /// Simpan insiden
  Future<Map<String, String>> saveIncident({
  required String categoryId,
  required String categoryCode,
  required String reportedBy,
  required String title,
  required String description,
  required DateTime occurredAt,
  String? roomId,
  String? locationText,
  String? severity,
  List<File>? photos,
}) async {
  print('=== INCIDENT SERVICE SAVE ===');
  print('categoryId: $categoryId');
  print('reportedBy: $reportedBy');
  print('title: $title');
  
  final incidentId = const Uuid().v4();
  print('incidentId: $incidentId');

  // Upload foto jika ada
  List<String> photoUrls = [];
  if (photos != null && photos.isNotEmpty) {
    print('Uploading ${photos.length} photos...');
    photoUrls = await uploadIncidentPhotos(images: photos, incidentId: incidentId);
    print('Photo URLs: $photoUrls');
  }

  // Insert incident
  print('Inserting incident to Supabase...');
  await _supabase.from('incidents').insert({
    'id': incidentId,
    'category_id': categoryId,
    'reported_by': reportedBy,
    'room_id': roomId,
    'title': title,
    'description': description,
    'occurred_at': occurredAt.toIso8601String(),
    'location_text': locationText,
    'status': 'reported',
    'severity': severity ?? 'MEDIUM',
    'photo_urls': photoUrls.isEmpty ? null : photoUrls,
    'created_at': DateTime.now().toIso8601String(),
  });
  print('Insert success!');

  // Tambah poin scoring
  final points = _getPointsByCategory(categoryCode);
  print('Adding $points points for category $categoryCode');
  await _addScoringPoint(reportedBy, incidentId, points, categoryCode);

  return {
    'incidentId': incidentId,
    'points': points.toString(),
  };
}

  /// Tambahkan poin ke employee_scoring
  Future<void> _addScoringPoint(String profileId, String incidentId, int points, String categoryCode) async {
    final categoryId = await _getIncidentCategoryId();
    if (categoryId == null) return;

    final today = DateTime.now();
    final periodStart = DateTime(today.year, today.month, today.day);
    final periodEnd = DateTime(today.year, today.month, today.day);

    final existing = await _supabase
        .from('employee_scoring')
        .select('id, score')
        .eq('profile_id', profileId)
        .eq('scoring_category_id', categoryId)
        .eq('period_start', periodStart.toIso8601String().split('T')[0])
        .maybeSingle();

    if (existing != null) {
      final currentScore = (existing['score'] as num).toDouble();
      await _supabase.from('employee_scoring').update({
        'score': currentScore + points,
        'notes': 'Incident reported: $incidentId ($categoryCode)',
        'calculated_at': DateTime.now().toIso8601String(),
      }).eq('id', existing['id']);
    } else {
      await _supabase.from('employee_scoring').insert({
        'profile_id': profileId,
        'scoring_category_id': categoryId,
        'score': points,
        'max_score': 100,
        'period_start': periodStart.toIso8601String().split('T')[0],
        'period_end': periodEnd.toIso8601String().split('T')[0],
        'notes': 'Incident reported: $incidentId ($categoryCode)',
        'calculated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Ambil daftar insiden yang dilaporkan user
  Future<List<Map<String, dynamic>>> getUserIncidents(String profileId) async {
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
          category_id,
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

  /// Ambil kategori insiden yang aktif
  Future<List<Map<String, dynamic>>> getIncidentCategories() async {
    final response = await _supabase
        .from('ref_incident_categories')
        .select()
        .eq('is_active', true)
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  /// Ambil daftar rooms untuk dropdown
  Future<List<Map<String, dynamic>>> getRooms() async {
    final response = await _supabase
        .from('rooms')
        .select('id, room_name')
        .order('room_name');

    return List<Map<String, dynamic>>.from(response);
  }
}