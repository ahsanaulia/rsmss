import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/ref_shifts/models/ref_shift_model.dart';
import 'package:rsmss/crud/ref_shifts/providers/ref_shift_provider.dart';

class RefShiftFormPage extends ConsumerStatefulWidget {
  final RefShiftModel? item;

  const RefShiftFormPage({
    super.key,
    this.item,
  });

  @override
  ConsumerState<RefShiftFormPage> createState() => _RefShiftFormPageState();
}

class _RefShiftFormPageState extends ConsumerState<RefShiftFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _shiftNameController;
  late TextEditingController _shiftCodeController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _descriptionController;
  late TextEditingController _breakDurationController;
  late TextEditingController _toleranceLateController;
  late TextEditingController _toleranceEarlyLeaveController;
  late TextEditingController _minimumWorkController;
  late TextEditingController _maximumOvertimeController;
  late TextEditingController _fatigueWeightController;
  late TextEditingController _aiPriorityWeightController;
  late TextEditingController _colorHexController;
  late TextEditingController _iconNameController;

  // String? _selectedAppId;
  // String? _selectedAppName;
  String? _selectedRiskLevel;
  
  bool _isCrossDay = false;
  bool _requiresMedicalFit = false;
  bool _requiresSupervisor = false;
  bool _requiresCheckinPhoto = false;
  bool _requiresLocationValidation = true;
  bool _wellbeingMonitoringEnabled = true;
  bool _autoAssignAllowed = true;
  bool _isActive = true;

  List<Map<String, dynamic>> _apps = [];
  bool _isLoadingApps = true;

  final List<Map<String, dynamic>> _riskLevelOptions = [
    {'value': 'normal', 'label': 'Normal'},
    {'value': 'low', 'label': 'Rendah'},
    {'value': 'medium', 'label': 'Sedang'},
    {'value': 'high', 'label': 'Tinggi'},
    {'value': 'critical', 'label': 'Kritis'},
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _shiftNameController = TextEditingController(text: item?.shiftName ?? '');
    _shiftCodeController = TextEditingController(text: item?.shiftCode ?? '');
    _startTimeController = TextEditingController(text: item?.startTime ?? '08:00:00');
    _endTimeController = TextEditingController(text: item?.endTime ?? '17:00:00');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _breakDurationController = TextEditingController(text: item?.breakDurationMinutes?.toString() ?? '60');
    _toleranceLateController = TextEditingController(text: item?.toleranceLateMinutes?.toString() ?? '15');
    _toleranceEarlyLeaveController = TextEditingController(text: item?.toleranceEarlyLeaveMinutes?.toString() ?? '15');
    _minimumWorkController = TextEditingController(text: item?.minimumWorkMinutes?.toString() ?? '480');
    _maximumOvertimeController = TextEditingController(text: item?.maximumOvertimeMinutes?.toString() ?? '240');
    _fatigueWeightController = TextEditingController(text: item?.fatigueWeight?.toStringAsFixed(2) ?? '1.00');
    _aiPriorityWeightController = TextEditingController(text: item?.aiPriorityWeight?.toStringAsFixed(2) ?? '1.00');
    _colorHexController = TextEditingController(text: item?.colorHex ?? '#2196F3');
    _iconNameController = TextEditingController(text: item?.iconName ?? '');
    
    // _selectedAppId = item?.appId;
    // _selectedAppName = item?.appName;
    _selectedRiskLevel = item?.riskLevel ?? 'normal';
    
    _isCrossDay = item?.isCrossDay ?? false;
    _requiresMedicalFit = item?.requiresMedicalFit ?? false;
    _requiresSupervisor = item?.requiresSupervisor ?? false;
    _requiresCheckinPhoto = item?.requiresCheckinPhoto ?? false;
    _requiresLocationValidation = item?.requiresLocationValidation ?? true;
    _wellbeingMonitoringEnabled = item?.wellbeingMonitoringEnabled ?? true;
    _autoAssignAllowed = item?.autoAssignAllowed ?? true;
    _isActive = item?.isActive ?? true;
    
    // _loadDropdownData();
  }

  @override
  void dispose() {
    _shiftNameController.dispose();
    _shiftCodeController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _descriptionController.dispose();
    _breakDurationController.dispose();
    _toleranceLateController.dispose();
    _toleranceEarlyLeaveController.dispose();
    _minimumWorkController.dispose();
    _maximumOvertimeController.dispose();
    _fatigueWeightController.dispose();
    _aiPriorityWeightController.dispose();
    _colorHexController.dispose();
    _iconNameController.dispose();
    super.dispose();
  }

  // Future<void> _loadDropdownData() async {
  //   final service = ref.read(refShiftServiceProvider);
  //   final apps = await service.getApps();
    
  //   if (mounted) {
  //     setState(() {
  //       _apps = apps;
  //       _isLoadingApps = false;
  //     });
  //   }
  // }

  // Future<void> _showAppPicker() async {
  //   final TextEditingController searchController = TextEditingController();
  //   List<Map<String, dynamic>> filteredApps = List.from(_apps);
    
  //   await showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setStateBottomSheet) {
  //           return DraggableScrollableSheet(
  //             initialChildSize: 0.6,
  //             minChildSize: 0.4,
  //             maxChildSize: 0.9,
  //             expand: false,
  //             builder: (context, scrollController) {
  //               return Column(
  //                 children: [
  //                   Container(
  //                     margin: const EdgeInsets.only(top: 12),
  //                     width: 40,
  //                     height: 4,
  //                     decoration: BoxDecoration(
  //                       color: Colors.grey[300],
  //                       borderRadius: BorderRadius.circular(2),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 8),
  //                   Padding(
  //                     padding: const EdgeInsets.all(16),
  //                     child: TextField(
  //                       controller: searchController,
  //                       autofocus: true,
  //                       decoration: InputDecoration(
  //                         hintText: 'Cari aplikasi...',
  //                         prefixIcon: const Icon(Icons.search),
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(12),
  //                         ),
  //                         filled: true,
  //                         fillColor: Colors.grey[50],
  //                       ),
  //                       onChanged: (value) {
  //                         setStateBottomSheet(() {
  //                           if (value.isEmpty) {
  //                             filteredApps = List.from(_apps);
  //                           } else {
  //                             filteredApps = _apps.where((a) =>
  //                               (a['client_name'] as String).toLowerCase().contains(value.toLowerCase())
  //                             ).toList();
  //                           }
  //                         });
  //                       },
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: filteredApps.isEmpty
  //                         ? Center(
  //                             child: Column(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
  //                                 const SizedBox(height: 8),
  //                                 Text(
  //                                   'Aplikasi tidak ditemukan',
  //                                   style: TextStyle(color: Colors.grey[600]),
  //                                 ),
  //                               ],
  //                             ),
  //                           )
  //                         : ListView.builder(
  //                             controller: scrollController,
  //                             itemCount: filteredApps.length,
  //                             itemBuilder: (context, index) {
  //                               final app = filteredApps[index];
  //                               return ListTile(
  //                                 leading: const Icon(Icons.apps, color: Colors.blue),
  //                                 title: Text(app['client_name']),
  //                                 onTap: () {
  //                                   setState(() {
  //                                     _selectedAppId = app['id'];
  //                                     _selectedAppName = app['client_name'];
  //                                   });
  //                                   Navigator.pop(context);
  //                                 },
  //                               );
  //                             },
  //                           ),
  //                   ),
  //                 ],
  //               );
  //             },
  //           );
  //         },
  //       );
  //     },
  //   );
    
  //   searchController.dispose();
  // }

  Future<void> _showRiskLevelPicker() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Pilih Tingkat Risiko',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              ..._riskLevelOptions.map((option) {
                return ListTile(
                  leading: Icon(
                    _getRiskLevelIcon(option['value']),
                    color: _getRiskLevelColor(option['value']),
                  ),
                  title: Text(option['label']),
                  trailing: _selectedRiskLevel == option['value']
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    Navigator.pop(context, option);
                  },
                );
              }),
            ],
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _selectedRiskLevel = result['value'];
      });
    }
  }

  IconData _getRiskLevelIcon(String level) {
    switch (level) {
      case 'normal': return Icons.check_circle;
      case 'low': return Icons.arrow_downward;
      case 'medium': return Icons.remove;
      case 'high': return Icons.arrow_upward;
      case 'critical': return Icons.warning;
      default: return Icons.help;
    }
  }

  Color _getRiskLevelColor(String level) {
    switch (level) {
      case 'normal': return Colors.green;
      case 'low': return Colors.blue;
      case 'medium': return Colors.orange;
      case 'high': return Colors.deepOrange;
      case 'critical': return Colors.red;
      default: return Colors.grey;
    }
  }

  Future<void> _showColorPicker() async {
    Color selectedColor = Colors.blue;
    final result = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Warna Shift'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: GridView.count(
            crossAxisCount: 4,
            children: [
              Colors.red,
              Colors.pink,
              Colors.purple,
              Colors.deepPurple,
              Colors.indigo,
              Colors.blue,
              Colors.cyan,
              Colors.teal,
              Colors.green,
              Colors.lightGreen,
              Colors.lime,
              Colors.yellow,
              Colors.amber,
              Colors.orange,
              Colors.deepOrange,
              Colors.brown,
              Colors.grey,
              Colors.blueGrey,
            ].map((color) {
              return GestureDetector(
                onTap: () => Navigator.pop(context, color),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _colorHexController.text = '#${result.value.toRadixString(16).substring(2)}';
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.item != null;

    final item = RefShiftModel(
      id: widget.item?.id,
      shiftName: _shiftNameController.text,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      // appId: _selectedAppId,
      shiftCode: _shiftCodeController.text.isNotEmpty ? _shiftCodeController.text : null,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      isCrossDay: _isCrossDay,
      breakDurationMinutes: int.tryParse(_breakDurationController.text) ?? 60,
      toleranceLateMinutes: int.tryParse(_toleranceLateController.text) ?? 15,
      toleranceEarlyLeaveMinutes: int.tryParse(_toleranceEarlyLeaveController.text) ?? 15,
      minimumWorkMinutes: int.tryParse(_minimumWorkController.text) ?? 480,
      maximumOvertimeMinutes: int.tryParse(_maximumOvertimeController.text) ?? 240,
      fatigueWeight: double.tryParse(_fatigueWeightController.text) ?? 1.0,
      riskLevel: _selectedRiskLevel,
      requiresMedicalFit: _requiresMedicalFit,
      requiresSupervisor: _requiresSupervisor,
      requiresCheckinPhoto: _requiresCheckinPhoto,
      requiresLocationValidation: _requiresLocationValidation,
      aiPriorityWeight: double.tryParse(_aiPriorityWeightController.text) ?? 1.0,
      wellbeingMonitoringEnabled: _wellbeingMonitoringEnabled,
      autoAssignAllowed: _autoAssignAllowed,
      colorHex: _colorHexController.text.isNotEmpty ? _colorHexController.text : null,
      iconName: _iconNameController.text.isNotEmpty ? _iconNameController.text : null,
      isActive: _isActive,
    );

    final notifier = ref.read(refShiftProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.update(item);
    } else {
      success = await notifier.create(item);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Shift berhasil diupdate' : 'Shift berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }
    String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  String? _validateTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Waktu wajib diisi';
    }
    final pattern = RegExp(r'^([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$');
    if (!pattern.hasMatch(value)) {
      return 'Format waktu harus HH:MM:SS (contoh: 08:00:00)';
    }
    return null;
  }

  String? _validatePositiveInt(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final number = int.tryParse(value);
    if (number == null || number < 0) {
      return '$fieldName harus angka positif';
    }
    return null;
  }

  String? _validatePositiveDouble(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final number = double.tryParse(value);
    if (number == null || number < 0) {
      return '$fieldName harus angka positif';
    }
    return null;
  }

  String? _validateColorHex(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final regex = RegExp(r'^#[0-9A-Fa-f]{6}$');
    if (!regex.hasMatch(value)) {
      return 'Format warna harus HEX (#RRGGBB)';
    }
    return null;
  }

  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.blue;
    final color = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$color', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(refShiftProvider);
    final isEditing = widget.item != null;
    final isSubmitting = state.isSubmitting;
    final selectedColor = _getColorFromHex(_colorHexController.text);
    final riskLevelColor = _getRiskLevelColor(_selectedRiskLevel ?? 'normal');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Shift' : 'Tambah Shift'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ==================== BASIC INFORMATION ====================
            const Text(
              'Informasi Dasar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            
            // Shift Name
            TextFormField(
              controller: _shiftNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Shift *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.schedule),
                hintText: 'Contoh: Shift Pagi, Shift Siang, Shift Malam',
              ),
              validator: (v) => _validateRequired(v, 'Nama Shift'),
              enabled: !isSubmitting,
            ),
            const SizedBox(height: 16),

            // Shift Code
            TextFormField(
              controller: _shiftCodeController,
              decoration: const InputDecoration(
                labelText: 'Kode Shift',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.code),
                hintText: 'Contoh: MORN, NOON, NIGHT (opsional)',
              ),
              enabled: !isSubmitting,
            ),
            const SizedBox(height: 16),

            // Start Time & End Time
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _startTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Jam Mulai *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                      hintText: '08:00:00',
                    ),
                    validator: _validateTime,
                    enabled: !isSubmitting,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _endTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Jam Selesai *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                      hintText: '17:00:00',
                    ),
                    validator: _validateTime,
                    enabled: !isSubmitting,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Is Cross Day
            SwitchListTile(
              title: const Text('Lintas Hari (Cross Day)'),
              subtitle: const Text('Aktifkan jika shift melewati tengah malam'),
              value: _isCrossDay,
              onChanged: isSubmitting ? null : (v) => setState(() => _isCrossDay = v),
              activeColor: Colors.purple,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
              enabled: !isSubmitting,
            ),
            const SizedBox(height: 16),

            // ==================== APP SELECTOR ====================
            const Text(
              'Aplikasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            
            // _isLoadingApps
            //     ? const Padding(
            //         padding: EdgeInsets.all(16),
            //         child: Center(child: CircularProgressIndicator()),
            //       )
            //     : InkWell(
            //         // onTap: isSubmitting ? null : _showAppPicker,
            //         child: Container(
            //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            //           decoration: BoxDecoration(
            //             border: Border.all(color: Colors.grey[400]!),
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //           child: Row(
            //             children: [
            //               Icon(Icons.apps, color: Colors.grey[600]),
            //               const SizedBox(width: 12),
            //               Expanded(
            //                 child: Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Text(
            //                       'Aplikasi',
            //                       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            //                     ),
            //                     const SizedBox(height: 4),
            //                     // Text(
            //                     //   _selectedAppName ?? 'Pilih aplikasi (opsional)',
            //                     //   style: TextStyle(
            //                     //     fontSize: 14,
            //                     //     color: _selectedAppName == null ? Colors.grey[400] : Colors.black,
            //                     //   ),
            //                     // ),
            //                   ],
            //                 ),
            //               ),
            //               Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
            //             ],
            //           ),
            //         ),
            //       ),
            const SizedBox(height: 16),

            // ==================== TIME & TOLERANCE ====================
            const Text(
              'Waktu & Toleransi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _breakDurationController,
                    decoration: const InputDecoration(
                      labelText: 'Durasi Istirahat (menit)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.free_breakfast),
                      suffixText: 'menit',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => _validatePositiveInt(v, 'Durasi Istirahat'),
                    enabled: !isSubmitting,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _toleranceLateController,
                    decoration: const InputDecoration(
                      labelText: 'Toleransi Terlambat (menit)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                      suffixText: 'menit',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => _validatePositiveInt(v, 'Toleransi Terlambat'),
                    enabled: !isSubmitting,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _toleranceEarlyLeaveController,
                    decoration: const InputDecoration(
                      labelText: 'Toleransi Pulang Cepat (menit)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.exit_to_app),
                      suffixText: 'menit',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => _validatePositiveInt(v, 'Toleransi Pulang Cepat'),
                    enabled: !isSubmitting,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _minimumWorkController,
                    decoration: const InputDecoration(
                      labelText: 'Minimal Kerja (menit)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.work),
                      suffixText: 'menit',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => _validatePositiveInt(v, 'Minimal Kerja'),
                    enabled: !isSubmitting,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _maximumOvertimeController,
              decoration: const InputDecoration(
                labelText: 'Maksimal Lembur (menit)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer_off),
                suffixText: 'menit',
              ),
              keyboardType: TextInputType.number,
              validator: (v) => _validatePositiveInt(v, 'Maksimal Lembur'),
              enabled: !isSubmitting,
            ),
            const SizedBox(height: 16),

            // ==================== RISK & WEIGHT ====================
            const Text(
              'Risiko & Bobot',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _fatigueWeightController,
                    decoration: const InputDecoration(
                      labelText: 'Bobot Kelelahan',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monitor_weight),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => _validatePositiveDouble(v, 'Bobot Kelelahan'),
                    enabled: !isSubmitting,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _aiPriorityWeightController,
                    decoration: const InputDecoration(
                      labelText: 'Bobot Prioritas AI',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.psychology),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => _validatePositiveDouble(v, 'Bobot Prioritas AI'),
                    enabled: !isSubmitting,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Risk Level Picker
            InkWell(
              onTap: isSubmitting ? null : _showRiskLevelPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(_getRiskLevelIcon(_selectedRiskLevel ?? 'normal'), color: riskLevelColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tingkat Risiko',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedRiskLevel != null
                                ? _riskLevelOptions.firstWhere(
                                    (opt) => opt['value'] == _selectedRiskLevel,
                                    orElse: () => {'label': 'Normal'},
                                  )['label']
                                : 'Pilih tingkat risiko',
                            style: TextStyle(
                              fontSize: 14,
                              color: _selectedRiskLevel == null ? Colors.grey[400] : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ==================== REQUIREMENTS ====================
            const Text(
              'Persyaratan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            
            SwitchListTile(
              title: const Text('Perlu Keterangan Medis'),
              value: _requiresMedicalFit,
              onChanged: isSubmitting ? null : (v) => setState(() => _requiresMedicalFit = v),
              activeColor: Colors.red,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Perlu Persetujuan Supervisor'),
              value: _requiresSupervisor,
              onChanged: isSubmitting ? null : (v) => setState(() => _requiresSupervisor = v),
              activeColor: Colors.orange,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Perlu Foto Check-in'),
              value: _requiresCheckinPhoto,
              onChanged: isSubmitting ? null : (v) => setState(() => _requiresCheckinPhoto = v),
              activeColor: Colors.purple,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Perlu Validasi Lokasi'),
              value: _requiresLocationValidation,
              onChanged: isSubmitting ? null : (v) => setState(() => _requiresLocationValidation = v),
              activeColor: Colors.teal,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),

            // ==================== FEATURES ====================
            const Text(
              'Fitur',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            
            SwitchListTile(
              title: const Text('Monitoring Kesejahteraan'),
              value: _wellbeingMonitoringEnabled,
              onChanged: isSubmitting ? null : (v) => setState(() => _wellbeingMonitoringEnabled = v),
              activeColor: Colors.indigo,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Penjadwalan Otomatis'),
              value: _autoAssignAllowed,
              onChanged: isSubmitting ? null : (v) => setState(() => _autoAssignAllowed = v),
              activeColor: Colors.cyan,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),

            // ==================== STYLE ====================
            const Text(
              'Tampilan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            
            // Color Picker
            InkWell(
              onTap: isSubmitting ? null : _showColorPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Warna Shift',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _colorHexController.text,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Icon Name
            TextFormField(
              controller: _iconNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Icon',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
                hintText: 'Contoh: morning, night, holiday (opsional)',
              ),
              enabled: !isSubmitting,
            ),
            const SizedBox(height: 16),

            // ==================== STATUS ====================
            SwitchListTile(
              title: const Text('Status Aktif'),
              subtitle: const Text('Nonaktifkan jika shift ini tidak digunakan lagi'),
              value: _isActive,
              onChanged: isSubmitting ? null : (v) => setState(() => _isActive = v),
              activeColor: Colors.green,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            // ==================== PREVIEW ====================
            Card(
              elevation: 2,
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preview',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: selectedColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.schedule, color: selectedColor, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _shiftNameController.text.isEmpty ? 'Nama Shift' : _shiftNameController.text,
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                '${_startTimeController.text.substring(0, 5)} - ${_endTimeController.text.substring(0, 5)}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              if (_isCrossDay)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Lintas Hari',
                                    style: TextStyle(fontSize: 10, color: Colors.purple.shade800),
                                  ),
                                ),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _isActive ? Colors.green.shade100 : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _isActive ? 'Aktif' : 'Nonaktif',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _isActive ? Colors.green.shade800 : Colors.red.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ==================== BUTTONS ====================
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isEditing ? 'Update' : 'Simpan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}