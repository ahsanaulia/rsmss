// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/asset_model.dart';
import '../../services/asset_service.dart';

class AssetFormDialog extends StatefulWidget {
  final bool isEditing;
  final Asset? existingAsset;
  final AssetService assetService;
  final String? currentUserId;
  final VoidCallback onSuccess;

  const AssetFormDialog({
    super.key,
    required this.isEditing,
    this.existingAsset,
    required this.assetService,
    required this.currentUserId,
    required this.onSuccess,
  });

  @override
  State<AssetFormDialog> createState() => _AssetFormDialogState();
}

class _AssetFormDialogState extends State<AssetFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _rfidTagController = TextEditingController();
  final _assetNameController = TextEditingController();
  final _inspectionDayController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _otherMaintenanceController = TextEditingController();

  // Dropdown & Selection Values
  String? _selectedTypeId;
  String _selectedStatus = 'Good';
  int _selectedContamination = 0;
  bool _isDangerous = false;
  String? _selectedRoomId;
  String? _selectedMaintenancePattern;
  bool _useOtherMaintenance = false;

  // 🔥 DANGER LEVEL
  String? _selectedDangerLevelId;
  List<Map<String, dynamic>> _dangerLevels = [];

  // Photo Upload - Gunakan XFile (compatible Web & Mobile)
  XFile? _selectedImageXFile;
  String? _existingFotoUrl;
  bool _isUploading = false;

  // Dropdown Data
  List<Map<String, dynamic>> _rooms = [];
  List<Map<String, dynamic>> _assetTypes = [];
  List<String> _maintenancePatterns = [];
  bool _isLoadingData = true;

  // Validation
  bool _isRfidUnique = true;
  String? _originalRfidTag;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
    _loadDangerLevels();

    if (widget.isEditing && widget.existingAsset != null) {
      _populateFormWithExistingAsset();
    }
  }

  @override
  void dispose() {
    _rfidTagController.dispose();
    _assetNameController.dispose();
    _inspectionDayController.dispose();
    _descriptionController.dispose();
    _otherMaintenanceController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final rooms = await widget.assetService.fetchAllRooms();
      final assetTypes = await widget.assetService.fetchAllAssetTypes();
      final maintenancePatterns = await widget.assetService
          .fetchMaintenancePatterns();

      setState(() {
        _rooms = rooms;
        _assetTypes = assetTypes;
        _maintenancePatterns = maintenancePatterns;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      _showErrorSnackbar('Gagal memuat data: $e');
    }
  }

  // 🔥 LOAD DANGER LEVELS
  Future<void> _loadDangerLevels() async {
    try {
      final levels = await widget.assetService.fetchAllDangerLevels();
      setState(() {
        _dangerLevels = levels;
      });
    } catch (e) {
      // print('Error loading danger levels: $e');
    }
  }

  void _populateFormWithExistingAsset() {
    final asset = widget.existingAsset!;

    _rfidTagController.text = asset.rfidTagId;
    _originalRfidTag = asset.rfidTagId;
    _assetNameController.text = asset.assetName;
    _selectedTypeId = asset.typeId;
    _selectedStatus = asset.statusCondition;
    _selectedContamination = asset.levelContaminated;
    _isDangerous = asset.isDangerous;
    _selectedRoomId = asset.lastRoomId;
    _selectedMaintenancePattern = asset.maintenancePattern;
    _existingFotoUrl = asset.fotoUrl;
    _selectedDangerLevelId = asset.dangerLevelId; // 🔥 TAMBAHKAN

    if (asset.inspectionDayOfMonth != null) {
      _inspectionDayController.text = asset.inspectionDayOfMonth.toString();
    }
    if (asset.description != null) {
      _descriptionController.text = asset.description!;
    }
  }

  Future<void> _validateRfidUnique(String value) async {
    if (value.isEmpty) return;

    if (widget.isEditing && _originalRfidTag == value) {
      setState(() {
        _isRfidUnique = true;
      });
      return;
    }

    setState(() {
      _isRfidUnique = true;
    });
  }

  // ==========================================================
  // UPLOAD PHOTO - MENGGUNAKAN XFile (WEB & MOBILE COMPATIBLE)
  // ==========================================================
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // If editing and has existing photo, delete old one
      if (widget.isEditing &&
          _existingFotoUrl != null &&
          _existingFotoUrl!.isNotEmpty) {
        await widget.assetService.deleteAssetPhoto(_existingFotoUrl!);
      }

      // Upload photo (XFile langsung, tanpa konversi ke File)
      if (widget.isEditing && widget.existingAsset != null) {
        final photoUrl = await widget.assetService.uploadAssetPhoto(
          pickedFile,
          widget.existingAsset!.id,
        );
        setState(() {
          _selectedImageXFile = null;
          _existingFotoUrl = photoUrl;
        });
      } else {
        // For create, store XFile temporarily
        setState(() {
          _selectedImageXFile = pickedFile;
        });
      }

      if (mounted) {
        _showSuccessSnackbar('Foto berhasil diupload');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Gagal upload foto: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // ==========================================================
  // SUBMIT FORM
  // ==========================================================
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isRfidUnique) {
      _showErrorSnackbar(
        'RFID Tag ID sudah digunakan, silakan gunakan yang lain',
      );
      return;
    }

    if (_rfidTagController.text.isEmpty) {
      _showErrorSnackbar('RFID Tag ID wajib diisi');
      return;
    }
    if (_assetNameController.text.isEmpty) {
      _showErrorSnackbar('Nama aset wajib diisi');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final maintenancePattern = _useOtherMaintenance
          ? _otherMaintenanceController.text.trim()
          : _selectedMaintenancePattern;

      final inspectionDay = _inspectionDayController.text.isNotEmpty
          ? int.tryParse(_inspectionDayController.text)
          : null;

      final asset = Asset(
        id: widget.isEditing ? widget.existingAsset!.id : '',
        rfidTagId: _rfidTagController.text.trim(),
        assetName: _assetNameController.text.trim(),
        typeId: _selectedTypeId,
        fotoUrl: _existingFotoUrl,
        statusCondition: _selectedStatus,
        levelContaminated: _selectedContamination,
        isDangerous: _isDangerous,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        lastRoomId: _selectedRoomId,
        maintenancePattern: maintenancePattern?.isEmpty ?? true
            ? null
            : maintenancePattern,
        inspectionDayOfMonth: inspectionDay,
        isActive: true,
        registeredAt: widget.isEditing
            ? widget.existingAsset!.registeredAt
            : DateTime.now(),
        updatedAt: DateTime.now(),
        // 🔥 TAMBAHKAN DANGER LEVEL
        dangerLevelId: _selectedDangerLevelId,
      );

      if (widget.currentUserId == null) {
        throw Exception('User tidak ditemukan, silakan login ulang');
      }

      String? finalFotoUrl = _existingFotoUrl;

      // Handle photo upload for create mode
      if (!widget.isEditing && _selectedImageXFile != null) {
        final createdAsset = await widget.assetService.createAsset(
          asset,
          widget.currentUserId!,
        );

        final photoUrl = await widget.assetService.uploadAssetPhoto(
          _selectedImageXFile!,
          createdAsset.id,
        );
        finalFotoUrl = photoUrl;

        final updatedAsset = createdAsset.copyWith(fotoUrl: photoUrl);
        await widget.assetService.updateAsset(
          updatedAsset,
          widget.currentUserId!,
        );
      } else if (widget.isEditing) {
        final updatedAsset = asset.copyWith(fotoUrl: _existingFotoUrl);
        await widget.assetService.updateAsset(
          updatedAsset,
          widget.currentUserId!,
        );
      } else {
        await widget.assetService.createAsset(asset, widget.currentUserId!);
      }

      if (mounted) {
        _showSuccessSnackbar(
          widget.isEditing
              ? 'Aset berhasil diperbarui'
              : 'Aset berhasil ditambahkan',
        );
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Gagal menyimpan aset: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse('0xFF${hexColor.replaceAll('#', '')}'));
    } catch (e) {
      return Colors.orange;
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            widget.isEditing ? Icons.edit : Icons.add_box,
            color: widget.isEditing
                ? Colors.blue.shade700
                : Colors.green.shade700,
          ),
          const SizedBox(width: 8),
          Text(widget.isEditing ? 'Edit Aset' : 'Tambah Aset Baru'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.55,
        height: MediaQuery.of(context).size.height * 0.75,
        child: _isLoadingData
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ROW 1: RFID & Nama Aset
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _rfidTagController,
                              decoration: const InputDecoration(
                                labelText: 'Kode Asset - Track *',
                                hintText: 'RFID Tag ID',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (value) => _validateRfidUnique(value),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'RFID Tag ID harus diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _assetNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nama Aset *',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama aset harus diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ROW 2: Tipe Aset & Status Kondisi
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              isExpanded: true,
                              value: _selectedTypeId,
                              decoration: const InputDecoration(
                                labelText: 'Tipe Aset',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Pilih Tipe'),
                                ),
                                ..._assetTypes.map(
                                  (type) => DropdownMenuItem(
                                    value: type['id'].toString(),
                                    child: Text(
                                      type['display_name'] ??
                                          type['type_name'] ??
                                          '-',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) =>
                                  setState(() => _selectedTypeId = value),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'Status Kondisi',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Good',
                                  child: Text('Good (Baik)'),
                                ),
                                DropdownMenuItem(
                                  value: 'Fair',
                                  child: Text('Fair (Cukup)'),
                                ),
                                DropdownMenuItem(
                                  value: 'Damage',
                                  child: Text('Damage (Rusak)'),
                                ),
                                DropdownMenuItem(
                                  value: 'Critical',
                                  child: Text('Critical (Kritis)'),
                                ),
                              ],
                              onChanged: (value) =>
                                  setState(() => _selectedStatus = value!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ROW 3: Level Kontaminasi & Berbahaya & Tingkat Bahaya
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Level Kontaminasi (0-5)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Slider(
                                        value: _selectedContamination
                                            .toDouble(),
                                        min: 0,
                                        max: 5,
                                        divisions: 5,
                                        label: _selectedContamination
                                            .toString(),
                                        activeColor:
                                            ContaminationLevel.getColor(
                                              _selectedContamination,
                                            ),
                                        onChanged: (value) => setState(() {
                                          _selectedContamination = value
                                              .round();
                                        }),
                                      ),
                                    ),
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: ContaminationLevel.getColor(
                                          _selectedContamination,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: ContaminationLevel.getColor(
                                            _selectedContamination,
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _selectedContamination.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ContaminationLevel.getColor(
                                              _selectedContamination,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _isDangerous,
                                  onChanged: (value) => setState(
                                    () => _isDangerous = value ?? false,
                                  ),
                                ),
                                const Text('Berbahaya'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 🔥 ROW 4: Tingkat Bahaya (Danger Level)
                      DropdownButtonFormField<String?>(
                        isExpanded: true,
                        value: _selectedDangerLevelId,
                        decoration: const InputDecoration(
                          labelText: 'Tingkat Bahaya',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Tidak Ada'),
                          ),
                          ..._dangerLevels.map((level) {
                            final colorHex = level['color_hex'] ?? '#F59E0B';
                            return DropdownMenuItem<String?>(
                              value: level['id'] as String?,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: _getColorFromHex(colorHex),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${level['level_code']} - ${level['level_name']}',
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) => setState(() {
                          _selectedDangerLevelId = value;
                        }),
                      ),
                      const SizedBox(height: 12),

                      // ROW 5: Ruangan
                      DropdownButtonFormField<String?>(
                        isExpanded: true,
                        value: _selectedRoomId,
                        decoration: const InputDecoration(
                          labelText: 'Ruangan (Lokasi Awal)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Pilih Ruangan'),
                          ),
                          ..._rooms.map(
                            (room) => DropdownMenuItem(
                              value: room['id'].toString(),
                              child: Text(
                                room['room_name'] ?? '-',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedRoomId = value),
                      ),
                      const SizedBox(height: 12),

                      // ROW 6: Maintenance Pattern
                      if (!_useOtherMaintenance)
                        DropdownButtonFormField<String?>(
                          isExpanded: true,
                          value: _selectedMaintenancePattern,
                          decoration: const InputDecoration(
                            labelText: 'Pola Perawatan',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Pilih Pola'),
                            ),
                            ..._maintenancePatterns.map(
                              (pattern) => DropdownMenuItem(
                                value: pattern,
                                child: Text(
                                  pattern,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const DropdownMenuItem(
                              value: '__other__',
                              child: Text('Lainnya...'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == '__other__') {
                              setState(() {
                                _useOtherMaintenance = true;
                                _selectedMaintenancePattern = null;
                              });
                            } else {
                              setState(
                                () => _selectedMaintenancePattern = value,
                              );
                            }
                          },
                        ),

                      if (_useOtherMaintenance)
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _otherMaintenanceController,
                                decoration: const InputDecoration(
                                  labelText: 'Pola Perawatan Lainnya',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _useOtherMaintenance = false;
                                  _otherMaintenanceController.clear();
                                });
                              },
                              icon: const Icon(Icons.close, size: 18),
                              tooltip: 'Batal',
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),

                      // ROW 7: Hari Inspeksi & Upload Foto
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kolom kiri - Hari Inspeksi
                          Expanded(
                            child: TextFormField(
                              controller: _inspectionDayController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Hari Inspeksi (1-31)',
                                hintText: 'Opsional',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final day = int.tryParse(value);
                                  if (day == null || day < 1 || day > 31) {
                                    return 'Hari harus antara 1-31';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Kolom kanan - Upload Foto
                          Container(
                            width: 180,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: _isUploading
                                      ? null
                                      : _pickAndUploadImage,
                                  child: Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey.shade50,
                                    ),
                                    child: _isUploading
                                        ? const Center(
                                            child: SizedBox(
                                              width: 124,
                                              height: 124,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          )
                                        : (_existingFotoUrl != null &&
                                              _existingFotoUrl!.isNotEmpty)
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              _existingFotoUrl!,
                                              width: 180,
                                              height: 180,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return _buildUploadPlaceholder();
                                                  },
                                            ),
                                          )
                                        : _buildUploadPlaceholder(),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap untuk upload foto',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ROW 8: Deskripsi
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          border: OutlineInputBorder(),
                          isDense: true,
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isEditing ? Colors.blue : Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.isEditing ? 'Simpan Perubahan' : 'Tambah Aset'),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload, size: 24, color: Colors.grey.shade400),
        Text(
          'Upload Foto',
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
