// lib/insights/profiles/services/profile_qualification_service.dart

import 'base_service.dart';
import '../models/models.dart';

class ProfileQualificationService extends BaseService {
  // Ambil semua kualifikasi yang tersedia
  Future<List<QualificationModel>> getAllQualifications() async {
    log('Mengambil semua kualifikasi...');
    
    try {
      final result = await supabase
          .from('employee_qualifications')
          .select('*')
          .eq('is_active', true);
      
      log('Ditemukan ${result.length} kualifikasi', 1);
      
      for (final qual in result) {
        log('  - ${qual['qualification_code']}: ${qual['qualification_name']} (${qual['category']})', 2);
      }
      
      return result.map<QualificationModel>((json) {
        return QualificationModel.fromJson(json);
      }).toList();
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil kualifikasi', e, stackTrace);
      return [];
    }
  }
  
  // Ambil semua kualifikasi dengan assignment (tanpa profile)
  Future<List<QualificationWithAssignment>> getAllQualificationsWithAssignments() async {
    log('Mengambil semua kualifikasi dengan assignment...');
    
    try {
      final qualifications = await getAllQualifications();
      
      final assignments = await supabase
          .from('employee_qualification_assignments')
          .select('''
            *,
            employee_qualifications!inner(*)
          ''')
          .eq('is_active', true);
      
      log('Ditemukan ${assignments.length} assignment', 1);
      
      final Map<String, QualificationAssignmentModel> assignmentByQualId = {};
      for (final row in assignments) {
        final qualId = row['qualification_id'].toString();
        final assignment = QualificationAssignmentModel.fromJson(row);
        assignmentByQualId[qualId] = assignment;
        
        final qualName = row['employee_qualifications'] != null 
            ? row['employee_qualifications']['qualification_name'] 
            : 'Unknown';
        log('  - Assignment: $qualName - Expiry: ${assignment.expiryDate}', 2);
      }
      
      final result = <QualificationWithAssignment>[];
      for (final qual in qualifications) {
        result.add(QualificationWithAssignment(
          qualification: qual,
          assignment: assignmentByQualId[qual.id],
        ));
        
        final assignment = assignmentByQualId[qual.id];
        if (assignment != null) {
          log('  ✅ ${qual.qualificationName}: Dimiliki - Expiry: ${assignment.expiryDate}', 2);
        } else {
          log('  ⭕ ${qual.qualificationName}: Tidak dimiliki', 2);
        }
      }
      
      final ownedCount = result.where((q) => q.isOwned).length;
      log('Kualifikasi dimiliki: $ownedCount dari ${result.length}', 1);
      
      return result;
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil kualifikasi dengan assignment', e, stackTrace);
      return [];
    }
  }
  
  // 🔥 Ambil semua kualifikasi yang dimiliki (dengan data profile pegawai)
  Future<List<QualificationWithAssignment>> getAllOwnedQualifications() async {
    log('Mengambil semua kualifikasi yang dimiliki dengan data pegawai...');
    
    try {
      // 🔥 PERBAIKAN: Gunakan foreign key yang spesifik untuk profile_id
      final assignmentsWithProfile = await supabase
          .from('employee_qualification_assignments')
          .select('''
            *,
            employee_qualifications!inner(*),
            profiles!employee_qualification_assignments_profile_id_fkey(
              id,
              full_name,
              avatar_url,
              unit_code,
              employee_id
            )
          ''')
          .eq('is_active', true);
      
      log('Ditemukan ${assignmentsWithProfile.length} assignment dengan data pegawai', 1);
      
      if (assignmentsWithProfile.isEmpty) {
        log('Tidak ada data assignment', 1);
        return [];
      }
      
      final result = <QualificationWithAssignment>[];
      
      for (final row in assignmentsWithProfile) {
        final qualificationData = row['employee_qualifications'] as Map<String, dynamic>;
        final profileData = row['profiles'] as Map<String, dynamic>?;
        
        final qualification = QualificationModel.fromJson(qualificationData);
        final assignment = QualificationAssignmentModel.fromJson(row);
        
        result.add(QualificationWithAssignment(
          qualification: qualification,
          assignment: assignment,
          profileName: profileData != null ? profileData['full_name'] : null,
          profileId: profileData != null ? profileData['id'] : null,
          unitCode: profileData != null ? profileData['unit_code'] : null,
          avatarUrl: profileData != null ? profileData['avatar_url'] : null,
        ));
        
        final profileName = profileData != null ? profileData['full_name'] : 'Unknown';
        log('  📜 $profileName - ${qualification.qualificationName} - Expiry: ${assignment.expiryDate}', 2);
      }
      
      log('Total kualifikasi dimiliki: ${result.length}', 1);
      
      return result;
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil kualifikasi yang dimiliki', e, stackTrace);
      return [];
    }
  }
  
  // Ambil kualifikasi per profile
  Future<List<QualificationWithAssignment>> getProfileQualifications(String profileId) async {
    log('Mengambil kualifikasi untuk profile $profileId');
    
    try {
      final assignments = await supabase
          .from('employee_qualification_assignments')
          .select('''
            *,
            employee_qualifications!inner(*)
          ''')
          .eq('profile_id', profileId)
          .eq('is_active', true);
      
      log('Ditemukan ${assignments.length} assignment untuk profile ini', 1);
      
      final result = <QualificationWithAssignment>[];
      for (final row in assignments) {
        final qualificationData = row['employee_qualifications'] as Map<String, dynamic>;
        final qualification = QualificationModel.fromJson(qualificationData);
        final assignment = QualificationAssignmentModel.fromJson(row);
        
        result.add(QualificationWithAssignment(
          qualification: qualification,
          assignment: assignment,
        ));
        
        log('  - ${qualification.qualificationName}', 2);
      }
      
      return result;
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil kualifikasi profile $profileId', e, stackTrace);
      return [];
    }
  }
  
  // Ambil kualifikasi yang akan kadaluarsa (dalam 30 hari)
  Future<List<QualificationWithAssignment>> getExpiringQualifications() async {
    log('Mencari kualifikasi yang akan kadaluarsa...');
    
    final qualifications = await getAllQualificationsWithAssignments();
    final expiring = qualifications.where((q) => q.isExpiringSoon).toList();
    
    log('Ditemukan ${expiring.length} kualifikasi akan kadaluarsa dalam 30 hari', 1);
    
    for (final q in expiring) {
      final daysLeft = q.expiryDate?.difference(DateTime.now()).inDays ?? 0;
      log('  ⚠️ ${q.qualification.qualificationName}: Expiry ${q.expiryDate} ($daysLeft hari lagi)', 2);
    }
    
    return expiring;
  }
  
  // Ambil kualifikasi yang sudah kadaluarsa
  Future<List<QualificationWithAssignment>> getExpiredQualifications() async {
    log('Mencari kualifikasi yang sudah kadaluarsa...');
    
    final qualifications = await getAllQualificationsWithAssignments();
    final expired = qualifications.where((q) => q.isExpired).toList();
    
    log('Ditemukan ${expired.length} kualifikasi sudah kadaluarsa', 1);
    
    for (final q in expired) {
      log('  🔴 ${q.qualification.qualificationName}: Expired sejak ${q.expiryDate}', 2);
    }
    
    return expired;
  }
}