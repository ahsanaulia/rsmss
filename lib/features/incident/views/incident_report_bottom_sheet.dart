import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../providers/incident_provider.dart';
import '../providers/incident_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/auth_service.dart';

class IncidentReportBottomSheet extends ConsumerStatefulWidget {
  const IncidentReportBottomSheet({super.key});

  @override
  ConsumerState<IncidentReportBottomSheet> createState() =>
      _IncidentReportBottomSheetState();
}

class _IncidentReportBottomSheetState
    extends ConsumerState<IncidentReportBottomSheet> {
  final ImagePicker _picker = ImagePicker();
  
  // GPS State
  bool _isGettingLocation = false;
  double? _currentLat;
  double? _currentLong;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(incidentStateProvider.notifier);
      notifier.updateOccurredAt(DateTime.now());
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError("Izin lokasi diperlukan untuk mengambil lokasi");
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      String address = "";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks[0];
          address = "${p.street != null ? '${p.street}, ' : ''}${p.subLocality != null ? '${p.subLocality}, ' : ''}${p.locality ?? ''}";
        }
      } catch (_) {
        address = "Lat: ${position.latitude}, Lng: ${position.longitude}";
      }

      setState(() {
        _currentLat = position.latitude;
        _currentLong = position.longitude;
        _currentAddress = address;
      });

      // Update ke notifier
      final notifier = ref.read(incidentStateProvider.notifier);
      notifier.updateGpsLocation(
        lat: position.latitude,
        long: position.longitude,
        address: address,
      );

      _showSuccess("Lokasi berhasil diambil: $address");
    } catch (e) {
      _showError("Gagal mengambil lokasi: $e");
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  void _clearLocation() {
    setState(() {
      _currentLat = null;
      _currentLong = null;
      _currentAddress = null;
    });
    final notifier = ref.read(incidentStateProvider.notifier);
    notifier.clearGpsLocation();
    _showSuccess("Lokasi dibersihkan");
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (picked != null) {
        ref.read(incidentStateProvider.notifier).addPhoto(File(picked.path));
      }
    } catch (e) {
      debugPrint("Error pick image: $e");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  Future<void> _selectDateTime(IncidentNotifier notifier) async {
    final now = DateTime.now();
    final current = ref.read(incidentStateProvider).occurredAt;

    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: now,
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(current),
      );

      if (time != null) {
        notifier.updateOccurredAt(DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(incidentStateProvider);
    final notifier = ref.read(incidentStateProvider.notifier);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showError(state.errorMessage!);
        notifier.clearError();
      });
    }

    if (state.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuccess(state.successMessage!);
        notifier.clearSuccess();
        Navigator.pop(context, true);
      });
    }

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomPadding + 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Lapor",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: const Color(0xFF01579B),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: Colors.grey.shade500,
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (state.categories.isEmpty)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Memuat data..."),
                  ],
                ),
              )
            else ...[
              // Title
              TextField(
                onChanged: notifier.updateTitle,
                decoration: _inputDecoration("Judul Laporan", Icons.title),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              _buildCategoryDropdown(notifier, state),
              const SizedBox(height: 16),

              // Severity Dropdown
              _buildSeverityDropdown(notifier, state),
              const SizedBox(height: 16),

              // Room Dropdown
              _buildRoomDropdown(notifier, state),
              const SizedBox(height: 16),

              // Location Text (Manual)
              TextField(
                onChanged: notifier.updateLocationText,
                decoration: _inputDecoration(
                    "Lokasi Deskripsi (Opsional)", Icons.location_on_outlined),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // 🔴 GPS LOCATION SECTION (Glassmorphism Cerah)
              _buildGpsLocationSection(),
              const SizedBox(height: 16),

              // Date & Time
              InkWell(
                onTap: () => _selectDateTime(notifier),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 20, color: const Color(0xFF01579B)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Waktu Kejadian: ${_formatDateTime(state.occurredAt)}",
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextField(
                onChanged: notifier.updateDescription,
                maxLines: 5,
                decoration: _inputDecoration(
                    "Deskripsi Kejadian", Icons.description_outlined),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Photo Section
              _buildPhotoSection(notifier, state),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: state.isSaving ? null : notifier.saveIncident,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01579B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: state.isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "Kirim Laporan",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 🔴 GPS LOCATION SECTION dengan Glassmorphism Cerah
  Widget _buildGpsLocationSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.gps_fixed, size: 20, color: const Color(0xFF01579B)),
                const SizedBox(width: 8),
                Text(
                  "Lokasi GPS",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: const Color(0xFF01579B),
                  ),
                ),
                const Spacer(),
                if (_currentAddress != null)
                  TextButton.icon(
                    onPressed: _clearLocation,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text("Hapus"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
          if (_currentAddress != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 18, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentAddress!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGettingLocation ? null : _getCurrentLocation,
                icon: _isGettingLocation
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.gps_fixed, size: 18),
                label: Text(
                  _isGettingLocation ? "MENGAMBIL LOKASI..." : "AMBIL LOKASI SAAT INI",
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01579B).withValues(alpha: 0.1),
                  foregroundColor: const Color(0xFF01579B),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: const Color(0xFF01579B).withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(IncidentNotifier notifier, IncidentState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.image_outlined, size: 20, color: const Color(0xFF01579B)),
            const SizedBox(width: 8),
            Text(
              "Foto Pendukung",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "(Opsional, maks 3 foto)",
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (state.photos.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        state.photos[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => notifier.removePhoto(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

        const SizedBox(height: 12),

        if (state.photos.length < 3)
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt,
                      color: const Color(0xFF01579B), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Ambil Foto",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF01579B),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryDropdown(
      IncidentNotifier notifier, IncidentState state) {
    final List<Map<String, dynamic>> items = state.categories;

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          "Memuat kategori...",
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      );
    }

    Map<String, dynamic>? selectedItem;
    if (state.selectedCategoryId != null && state.selectedCategoryId!.isNotEmpty) {
      try {
        final found = items.where((e) => e['id'].toString() == state.selectedCategoryId);
        if (found.isNotEmpty) {
          selectedItem = found.first;
        }
      } catch (e) {
        selectedItem = null;
      }
    }

    if (selectedItem == null && items.isNotEmpty) {
      selectedItem = items.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.selectCategory(
          selectedItem!['id'].toString(),
          selectedItem['name'] ?? '',
          selectedItem['code'] ?? '',
        );
      });
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, dynamic>>(
          isExpanded: true,
          value: selectedItem,
          hint: Text("Pilih Kategori", style: GoogleFonts.poppins()),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  Icon(
                    _getIconForCategory(item['code'] ?? ''),
                    size: 18,
                    color: _getColorForCategory(item['code'] ?? ''),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['name'] ?? '-',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              notifier.selectCategory(
                value['id'].toString(),
                value['name'] ?? '',
                value['code'] ?? '',
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildRoomDropdown(IncidentNotifier notifier, IncidentState state) {
    final List<Map<String, dynamic>> items = state.rooms;

    Map<String, dynamic>? selectedItem;
    if (state.selectedRoomId != null && state.selectedRoomId!.isNotEmpty) {
      try {
        final found = items.where((e) => e['id'].toString() == state.selectedRoomId);
        if (found.isNotEmpty) {
          selectedItem = found.first;
        }
      } catch (e) {
        selectedItem = null;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, dynamic>>(
          isExpanded: true,
          value: selectedItem,
          hint: Text("Pilih Ruangan (Opsional)", style: GoogleFonts.poppins()),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text("Tidak ada ruangan"),
            ),
            ...items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item['room_name'] ?? '-',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              );
            }),
          ],
          onChanged: (value) {
            if (value != null && value.isNotEmpty) {
              notifier.selectRoom(
                value['id'].toString(),
                value['room_name'] ?? '',
              );
            } else {
              notifier.selectRoom('', '');
            }
          },
        ),
      ),
    );
  }

  Widget _buildSeverityDropdown(
      IncidentNotifier notifier, IncidentState state) {
    final List<Map<String, dynamic>> severityItems = [
      {'value': 'LOW', 'label': 'Rendah', 'color': Colors.green},
      {'value': 'MEDIUM', 'label': 'Sedang', 'color': Colors.orange},
      {'value': 'HIGH', 'label': 'Tinggi', 'color': Colors.deepOrange},
      {'value': 'CRITICAL', 'label': 'Kritis', 'color': Colors.red},
    ];

    String currentValue = state.severity;
    if (!severityItems.any((e) => e['value'] == currentValue)) {
      currentValue = 'MEDIUM';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: currentValue,
          hint: Text("Tingkat Keparahan", style: GoogleFonts.poppins()),
          items: severityItems.map((item) {
            return DropdownMenuItem<String>(
              value: item['value'],
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item['label'],
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) notifier.updateSeverity(value);
          },
        ),
      ),
    );
  }

  IconData _getIconForCategory(String code) {
    switch (code.toUpperCase()) {
      case 'SAFETY':
        return Icons.health_and_safety;
      case 'ASSET':
        return Icons.inventory_2;
      case 'FACILITY':
        return Icons.apartment;
      case 'HUMAN':
        return Icons.groups;
      case 'STOCK':
        return Icons.warehouse;
      default:
        return Icons.warning_amber;
    }
  }

  Color _getColorForCategory(String code) {
    switch (code.toUpperCase()) {
      case 'SAFETY':
        return const Color(0xFFD32F2F);
      case 'ASSET':
        return const Color(0xFF1976D2);
      case 'FACILITY':
        return const Color(0xFFEF6C00);
      case 'HUMAN':
        return const Color(0xFF7B1FA2);
      case 'STOCK':
        return const Color(0xFF00897B);
      default:
        return const Color(0xFF546E7A);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF01579B)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF01579B), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}