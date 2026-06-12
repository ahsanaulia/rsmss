// lib/views/monitor/gps_live_tracking_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/gps_tracking_provider.dart';
import 'widgets/gps_employee_search_dropdown.dart';
import 'widgets/gps_tracking_map.dart';
import 'widgets/gps_employee_detail_sheet.dart';

class GpsLiveTrackingScreen extends ConsumerStatefulWidget {
  const GpsLiveTrackingScreen({super.key});

  @override
  ConsumerState<GpsLiveTrackingScreen> createState() =>
      _GpsLiveTrackingScreenState();
}

class _GpsLiveTrackingScreenState extends ConsumerState<GpsLiveTrackingScreen> {
  DateTime _selectedDate = DateTime.now();
  List<String> _selectedProfileIds = [];
  bool _isLoading = false;
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadTrackingData() async {
    if (_selectedProfileIds.isEmpty) return;

    setState(() {
      _isLoading = true;
      _loadingProgress = 0.0;
    });

    final notifier = ref.read(gpsTrackingProvider.notifier);
    
    // Maksimal 3 pegawai
    final limitedIds = _selectedProfileIds.length > 3 
        ? _selectedProfileIds.sublist(0, 3) 
        : _selectedProfileIds;
    
    await notifier.loadTrackingData(
      profileIds: limitedIds,
      date: _selectedDate,
      onProgress: (progress) {
        setState(() {
          _loadingProgress = progress;
        });
      },
    );

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadTrackingData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackedEmployees = ref.watch(gpsTrackingProvider);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 54, 130, 150),
      appBar: AppBar(
        title: const Text('Live Tracking GPS'),
        backgroundColor: const Color(0xFF01579B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Pilih Tanggal',
          ),
          if (_selectedDate != DateTime.now())
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                DateFormat('dd/MM/yyyy').format(_selectedDate),
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          GpsEmployeeSearchDropdown(
            initialSelectedIds: _selectedProfileIds,
            onSelectionChanged: (selectedIds) {
              setState(() {
                _selectedProfileIds = selectedIds;
              });
              if (selectedIds.isNotEmpty) {
                _loadTrackingData();
              } else {
                ref.read(gpsTrackingProvider.notifier).clear();
              }
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: _loadingProgress > 0 ? _loadingProgress : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _loadingProgress > 0
                              ? 'Memuat data routing (${(_loadingProgress * 100).toInt()}%)...'
                              : 'Memuat data tracking...',
                        ),
                      ],
                    ),
                  )
                : _selectedProfileIds.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'Pilih pegawai terlebih dahulu (maksimal 3)',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : trackedEmployees.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_off_outlined, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada data tracking untuk tanggal ini',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: _loadTrackingData,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Refresh'),
                                ),
                              ],
                            ),
                          )
                        : GpsTrackingMap(
                            trackedEmployees: trackedEmployees,
                            onMarkerTap: (employee) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                builder: (context) => GpsEmployeeDetailSheet(employee: employee),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: _selectedProfileIds.isNotEmpty && !_isLoading
          ? FloatingActionButton(
              onPressed: _loadTrackingData,
              child: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            )
          : null,
    );
  }
}