// File: lib/insights/hospital/services/incident_realtime_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/incident_summary_model.dart';
import '../models/incident_response_model.dart';

class IncidentRealtimeService {
  final _supabase = Supabase.instance.client;

  // ============================================================
  // 1. SUMMARY KPI - REALTIME
  // ============================================================
  Stream<IncidentSummaryModel> watchSummary() {
    debugPrint('🟢 [REALTIME] watchIncidentSummary: initializing...');
    final controller = StreamController<IncidentSummaryModel>.broadcast();
    
    _fetchSummary().then((value) {
      debugPrint('✅ [REALTIME] watchIncidentSummary: initial data loaded');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchIncidentSummary: initial error - $e');
      if (!controller.isClosed) controller.add(IncidentSummaryModel.empty());
    });
    
    final channel = _supabase
        .channel('incident_summary')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'incidents',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchIncidentSummary: change detected, refetching...');
            final newData = await _fetchSummary();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchIncidentSummary: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<IncidentSummaryModel> _fetchSummary() async {
    try {
      final incidents = await _supabase
          .from('incidents')
          .select('status, severity, created_at, action_taken_at');
      
      final data = incidents as List;
      
      int total = data.length;
      int open = 0;
      int resolved = 0;
      int critical = 0;
      int high = 0;
      int medium = 0;
      int low = 0;
      double totalResponseMinutes = 0;
      int respondedCount = 0;
      
      for (final incident in data) {
        final status = incident['status']?.toString().toLowerCase() ?? '';
        final severity = incident['severity']?.toString().toUpperCase() ?? '';
        
        // Hitung status
        if (status == 'reported' || status == 'in_progress') {
          open++;
        } else if (status == 'resolved' || status == 'closed') {
          resolved++;
        }
        
        // Hitung severity
        if (severity == 'CRITICAL') critical++;
        else if (severity == 'HIGH') high++;
        else if (severity == 'MEDIUM') medium++;
        else low++;
        
        // Hitung response time (dari created_at ke action_taken_at)
        final createdAtStr = incident['created_at']?.toString();
        final actionTakenAtStr = incident['action_taken_at']?.toString();
        
        if (createdAtStr != null && actionTakenAtStr != null) {
          final createdAt = DateTime.tryParse(createdAtStr);
          final actionTakenAt = DateTime.tryParse(actionTakenAtStr);
          if (createdAt != null && actionTakenAt != null) {
            final minutes = actionTakenAt.difference(createdAt).inMinutes;
            totalResponseMinutes += minutes.toDouble();
            respondedCount++;
          }
        }
      }
      
      final avgResponseTime = respondedCount > 0 ? totalResponseMinutes / respondedCount : 0.0;
      
      return IncidentSummaryModel(
        totalIncidents: total,
        openIncidents: open,
        resolvedIncidents: resolved,
        criticalIncidents: critical,
        highIncidents: high,
        mediumIncidents: medium,
        lowIncidents: low,
        avgResponseTimeMinutes: avgResponseTime,
      );
    } catch (e) {
      debugPrint('❌ _fetchSummary error: $e');
      return IncidentSummaryModel.empty();
    }
  }

  // ============================================================
  // 2. DISTRIBUSI INSIDEN PER KATEGORI - REALTIME
  // ============================================================
  Stream<List<IncidentCategoryDistribution>> watchCategoryDistribution() {
    debugPrint('🟢 [REALTIME] watchCategoryDistribution: initializing...');
    final controller = StreamController<List<IncidentCategoryDistribution>>.broadcast();
    
    _fetchCategoryDistribution().then((value) {
      debugPrint('✅ [REALTIME] watchCategoryDistribution: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchCategoryDistribution: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('incident_category_dist')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'incidents',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchCategoryDistribution: change detected, refetching...');
            final newData = await _fetchCategoryDistribution();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchCategoryDistribution: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<IncidentCategoryDistribution>> _fetchCategoryDistribution() async {
    try {
      // Ambil semua kategori dulu
      final categories = await _supabase
          .from('ref_incident_categories')
          .select('id, name, icon, color')
          .eq('is_active', true);
      
      final Map<String, Map<String, dynamic>> categoryMap = {};
      for (final cat in categories as List) {
        categoryMap[cat['id'].toString()] = {
          'name': cat['name'] ?? 'Unknown',
          'icon': cat['icon'],
          'color': cat['color'],
          'count': 0,
        };
      }
      
      // Ambil incident count per category
      final incidents = await _supabase
          .from('incidents')
          .select('category_id');
      
      for (final incident in incidents as List) {
        final catId = incident['category_id']?.toString();
        if (catId != null && categoryMap.containsKey(catId)) {
          categoryMap[catId]!['count'] = categoryMap[catId]!['count'] + 1;
        }
      }
      
      final result = <IncidentCategoryDistribution>[];
      for (final entry in categoryMap.entries) {
        if (entry.value['count'] > 0) {
          result.add(IncidentCategoryDistribution(
            categoryId: entry.key,
            categoryName: entry.value['name'],
            icon: entry.value['icon']?.toString(),
            color: entry.value['color']?.toString(),
            totalIncidents: entry.value['count'],
          ));
        }
      }
      
      result.sort((a, b) => b.totalIncidents.compareTo(a.totalIncidents));
      return result;
    } catch (e) {
      debugPrint('❌ _fetchCategoryDistribution error: $e');
      return [];
    }
  }

  // ============================================================
  // 3. DISTRIBUSI PER SEVERITY - REALTIME
  // ============================================================
  Stream<List<IncidentSeverityDistribution>> watchSeverityDistribution() {
    debugPrint('🟢 [REALTIME] watchSeverityDistribution: initializing...');
    final controller = StreamController<List<IncidentSeverityDistribution>>.broadcast();
    
    _fetchSeverityDistribution().then((value) {
      debugPrint('✅ [REALTIME] watchSeverityDistribution: initial data loaded');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchSeverityDistribution: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('incident_severity_dist')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'incidents',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchSeverityDistribution: change detected, refetching...');
            final newData = await _fetchSeverityDistribution();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchSeverityDistribution: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<IncidentSeverityDistribution>> _fetchSeverityDistribution() async {
    try {
      final incidents = await _supabase
          .from('incidents')
          .select('severity');
      
      final Map<String, int> severityMap = {
        'CRITICAL': 0,
        'HIGH': 0,
        'MEDIUM': 0,
        'LOW': 0,
      };
      
      for (final incident in incidents as List) {
        final severity = incident['severity']?.toString().toUpperCase() ?? 'LOW';
        if (severityMap.containsKey(severity)) {
          severityMap[severity] = severityMap[severity]! + 1;
        } else {
          severityMap['LOW'] = severityMap['LOW']! + 1;
        }
      }
      
      final result = <IncidentSeverityDistribution>[];
      for (final entry in severityMap.entries) {
        if (entry.value > 0) {
          result.add(IncidentSeverityDistribution(
            severity: entry.key,
            count: entry.value,
          ));
        }
      }
      
      return result;
    } catch (e) {
      debugPrint('❌ _fetchSeverityDistribution error: $e');
      return [];
    }
  }

  // ============================================================
  // 4. RESPONSE RATE - REALTIME
  // ============================================================
  Stream<IncidentResponseStats> watchResponseRate() {
    debugPrint('🟢 [REALTIME] watchResponseRate: initializing...');
    final controller = StreamController<IncidentResponseStats>.broadcast();
    
    _fetchResponseRate().then((value) {
      debugPrint('✅ [REALTIME] watchResponseRate: initial data loaded');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchResponseRate: initial error - $e');
      if (!controller.isClosed) controller.add(IncidentResponseStats.empty());
    });
    
    final channel = _supabase
        .channel('incident_response_rate')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'incidents',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchResponseRate: change detected, refetching...');
            final newData = await _fetchResponseRate();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchResponseRate: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<IncidentResponseStats> _fetchResponseRate() async {
    try {
      final incidents = await _supabase
          .from('incidents')
          .select('action_taken_at');
      
      int total = (incidents as List).length;
      int responded = 0;
      
      for (final incident in incidents) {
        if (incident['action_taken_at'] != null) {
          responded++;
        }
      }
      
      final responseRate = total > 0 ? (responded / total) * 100 : 0.0;
      
      return IncidentResponseStats(
        responded: responded,
        notResponded: total - responded,
        responseRate: responseRate,
      );
    } catch (e) {
      debugPrint('❌ _fetchResponseRate error: $e');
      return IncidentResponseStats.empty();
    }
  }

  // ============================================================
  // 5. TOP REPORTERS - REALTIME
  // ============================================================
  Stream<List<IncidentReporterStats>> watchTopReporters() {
    debugPrint('🟢 [REALTIME] watchTopReporters: initializing...');
    final controller = StreamController<List<IncidentReporterStats>>.broadcast();
    
    _fetchTopReporters().then((value) {
      debugPrint('✅ [REALTIME] watchTopReporters: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchTopReporters: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('incident_reporters')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'incidents',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchTopReporters: change detected, refetching...');
            final newData = await _fetchTopReporters();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchTopReporters: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<IncidentReporterStats>> _fetchTopReporters({int limit = 5}) async {
    try {
      final incidents = await _supabase
          .from('incidents')
          .select('reported_by');
      
      final Map<String, int> reporterCounts = {};
      for (final incident in incidents as List) {
        final reporterId = incident['reported_by']?.toString();
        if (reporterId != null) {
          reporterCounts[reporterId] = (reporterCounts[reporterId] ?? 0) + 1;
        }
      }
      
      if (reporterCounts.isEmpty) return [];
      
      final profiles = await _supabase
          .from('profiles')
          .select('id, full_name, unit_id, employee_units!profiles_unit_id_fkey(unit_name)')
          .inFilter('id', reporterCounts.keys.toList());
      
      final Map<String, Map<String, dynamic>> reporterMap = {};
      for (final profile in profiles as List) {
        final unit = profile['employee_units'];
        reporterMap[profile['id'].toString()] = {
          'full_name': profile['full_name'] ?? 'Unknown',
          'unit_name': unit?['unit_name']?.toString(),
        };
      }
      
      final List<IncidentReporterStats> reporters = [];
      for (final entry in reporterCounts.entries) {
        final reporter = reporterMap[entry.key];
        if (reporter != null) {
          reporters.add(IncidentReporterStats(
            profileId: entry.key,
            fullName: reporter['full_name'],
            totalReports: entry.value,
            unitName: reporter['unit_name'],
          ));
        }
      }
      
      reporters.sort((a, b) => b.totalReports.compareTo(a.totalReports));
      return reporters.take(limit).toList();
    } catch (e) {
      debugPrint('❌ _fetchTopReporters error: $e');
      return [];
    }
  }

  // ============================================================
  // 6. RECENT INCIDENTS - REALTIME
  // ============================================================
  Stream<List<IncidentRecentModel>> watchRecentIncidents() {
    debugPrint('🟢 [REALTIME] watchRecentIncidents: initializing...');
    final controller = StreamController<List<IncidentRecentModel>>.broadcast();
    
    _fetchRecentIncidents().then((value) {
      debugPrint('✅ [REALTIME] watchRecentIncidents: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchRecentIncidents: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('incident_recent')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'incidents',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchRecentIncidents: change detected, refetching...');
            final newData = await _fetchRecentIncidents();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchRecentIncidents: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<IncidentRecentModel>> _fetchRecentIncidents({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('incidents')
          .select('''
            id,
            title,
            description,
            severity,
            status,
            occurred_at,
            reported_by,
            action_taken,
            category_id,
            room_id,
            ref_incident_categories!incidents_category_id_fkey(name),
            profiles!incidents_reported_by_fkey(full_name),
            rooms!incidents_room_id_fkey(room_name)
          ''')
          .order('created_at', ascending: false)
          .limit(limit);
      
      final data = response as List;
      final List<IncidentRecentModel> incidents = [];
      
      for (final item in data) {
        final category = item['ref_incident_categories'];
        final reporter = item['profiles'];
        final room = item['rooms'];
        
        incidents.add(IncidentRecentModel(
          id: item['id']?.toString() ?? '',
          title: item['title'] ?? '',
          description: item['description'] ?? '',
          severity: item['severity'] ?? 'MEDIUM',
          status: item['status'] ?? 'reported',
          occurredAt: DateTime.tryParse(item['occurred_at']?.toString() ?? '') ?? DateTime.now(),
          reporterName: reporter?['full_name'] ?? 'Unknown',
          categoryName: category?['name']?.toString(),
          roomName: room?['room_name']?.toString(),
          actionTaken: item['action_taken']?.toString(),
        ));
      }
      
      return incidents;
    } catch (e) {
      debugPrint('❌ _fetchRecentIncidents error: $e');
      return [];
    }
  }
}