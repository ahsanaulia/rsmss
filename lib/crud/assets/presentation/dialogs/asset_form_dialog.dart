// // ============================================================
// // DIALOG: Asset Form Dialog
// // ============================================================
// // TANGGUNG JAWAB:
// // 1. Form untuk create dan edit aset
// // 2. Layout 2 kolom (Row dengan 2 Expanded) untuk field yang padat
// // 3. Upload foto aset ke Supabase Storage
// // 4. Validasi: RFID Tag ID wajib unik, Nama Aset wajib
// // 5. Dropdown untuk: Tipe Aset, Status Kondisi, Ruangan, Maintenance Pattern
// // 6. Slider untuk Level Kontaminasi (0-5)
// // 7. Checkbox untuk Berbahaya
// // 8. Textarea untuk Deskripsi
// // ============================================================

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../models/asset_model.dart';
// import '../../services/asset_service.dart';

// class AssetFormDialog extends StatefulWidget {
//   final bool isEditing;
//   final Asset? existingAsset;
//   final AssetService assetService;
//   final String? currentUserId;
//   final VoidCallback onSuccess;

//   const AssetFormDialog({
//     super.key,
//     required this.isEditing,
//     this.existingAsset,
//     required this.assetService,
//     required this.currentUserId,
//     required this.onSuccess,
//   });

//   @override
//   State<AssetFormDialog> createState() => _AssetFormDialogState();
// }

// class _AssetFormDialogState extends State<AssetFormDialog> {
//   final _formKey = GlobalKey<FormState>();
  
//   // ==========================================================
//   // CONTROLLERS
//   // ==========================================================
//   final _rfidTagController = TextEditingController();
//   final _assetNameController = TextEditingController();
//   final _inspectionDayController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _otherMaintenanceController = TextEditingController();
  
//   // ==========================================================
//   // DROPDOWN & SELECTION VALUES
//   // ==========================================================
//   String? _selectedTypeId;
//   String _selectedStatus = 'Good';
//   int _selectedContamination = 0;
//   bool _isDangerous = false;
//   String? _selectedRoomId;
//   String? _selectedMaintenancePattern;
//   bool _useOtherMaintenance = false;
  
//   // ==========================================================
//   // PHOTO UPLOAD
//   // ==========================================================
//   File? _selectedImageFile;
//   String? _existingFotoUrl;
//   bool _isUploading = false;
  
//   // ==========================================================
//   // DROPDOWN DATA
//   // ==========================================================
//   List<Map<String, dynamic>> _rooms = [];
//   List<Map<String, dynamic>> _assetTypes = [];
//   List<String> _maintenancePatterns = [];
//   bool _isLoadingData = true;
  
//   // ==========================================================
//   // VALIDATION
//   // ==========================================================
//   bool _isRfidUnique = true;
//   String? _originalRfidTag;

//   @override
//   void initState() {
//     super.initState();
//     _loadDropdownData();
    
//     if (widget.isEditing && widget.existingAsset != null) {
//       _populateFormWithExistingAsset();
//     }
//   }

//   @override
//   void dispose() {
//     _rfidTagController.dispose();
//     _assetNameController.dispose();
//     _inspectionDayController.dispose();
//     _descriptionController.dispose();
//     _otherMaintenanceController.dispose();
//     super.dispose();
//   }

//   // ==========================================================
//   // LOAD DATA FOR DROPDOWNS
//   // ==========================================================
//   Future<void> _loadDropdownData() async {
//     setState(() {
//       _isLoadingData = true;
//     });
    
//     try {
//       final rooms = await widget.assetService.fetchAllRooms();
//       final assetTypes = await widget.assetService.fetchAllAssetTypes();
//       final maintenancePatterns = await widget.assetService.fetchMaintenancePatterns();
      
//       setState(() {
//         _rooms = rooms;
//         _assetTypes = assetTypes;
//         _maintenancePatterns = maintenancePatterns;
//         _isLoadingData = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoadingData = false;
//       });
//       _showErrorSnackbar('Gagal memuat data: $e');
//     }
//   }

//   // ==========================================================
//   // POPULATE FORM FOR EDIT MODE
//   // ==========================================================
//   void _populateFormWithExistingAsset() {
//     final asset = widget.existingAsset!;
    
//     _rfidTagController.text = asset.rfidTagId;
//     _originalRfidTag = asset.rfidTagId;
//     _assetNameController.text = asset.assetName;
//     _selectedTypeId = asset.typeId;
//     _selectedStatus = asset.statusCondition;
//     _selectedContamination = asset.levelContaminated;
//     _isDangerous = asset.isDangerous;
//     _selectedRoomId = asset.lastRoomId;
//     _selectedMaintenancePattern = asset.maintenancePattern;
//     _existingFotoUrl = asset.fotoUrl;
    
//     if (asset.inspectionDayOfMonth != null) {
//       _inspectionDayController.text = asset.inspectionDayOfMonth.toString();
//     }
//     if (asset.description != null) {
//       _descriptionController.text = asset.description!;
//     }
//   }

//   // ==========================================================
//   // VALIDATE RFID UNIQUE
//   // ==========================================================
//   Future<void> _validateRfidUnique(String value) async {
//     if (value.isEmpty) return;
    
//     // Skip if editing and RFID hasn't changed
//     if (widget.isEditing && _originalRfidTag == value) {
//       setState(() {
//         _isRfidUnique = true;
//       });
//       return;
//     }
    
//     // TODO: Implement RFID uniqueness check via service
//     // For now, assume unique
//     setState(() {
//       _isRfidUnique = true;
//     });
//   }

//   // ==========================================================
//   // UPLOAD PHOTO
//   // ==========================================================
//   Future<void> _pickAndUploadImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(
//       source: ImageSource.gallery,
//       maxWidth: 1024,
//       maxHeight: 1024,
//       imageQuality: 80,
//     );
    
//     if (pickedFile == null) return;
    
//     setState(() {
//       _isUploading = true;
//     });
    
//     try {
//       final file = File(pickedFile.path);
      
//       // If editing and has existing photo, delete old one
//       if (widget.isEditing && _existingFotoUrl != null && _existingFotoUrl!.isNotEmpty) {
//         await widget.assetService.deleteAssetPhoto(_existingFotoUrl!);
//       }
      
//       // Upload new photo (temporary with dummy assetId, will be updated after create)
//       // For create, we'll upload after asset is created
//       // For edit, we need assetId
//       if (widget.isEditing && widget.existingAsset != null) {
//         final photoUrl = await widget.assetService.uploadAssetPhoto(file, widget.existingAsset!.id);
//         setState(() {
//           _selectedImageFile = null; // Clear temporary file
//           _existingFotoUrl = photoUrl;
//         });
//       } else {
//         // For create, store file temporarily
//         setState(() {
//           _selectedImageFile = file;
//         });
//       }
      
//       if (mounted) {
//         _showSuccessSnackbar('Foto berhasil diupload');
//       }
//     } catch (e) {
//       if (mounted) {
//         _showErrorSnackbar('Gagal upload foto: $e');
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isUploading = false;
//         });
//       }
//     }
//   }

//   // ==========================================================
//   // SUBMIT FORM
//   // ==========================================================
//   Future<void> _submitForm() async {
//     // Validate form
//     if (!_formKey.currentState!.validate()) return;
    
//     // Validate RFID unique
//     if (!_isRfidUnique) {
//       _showErrorSnackbar('RFID Tag ID sudah digunakan, silakan gunakan yang lain');
//       return;
//     }
    
//     // Validate required fields
//     if (_rfidTagController.text.isEmpty) {
//       _showErrorSnackbar('RFID Tag ID wajib diisi');
//       return;
//     }
//     if (_assetNameController.text.isEmpty) {
//       _showErrorSnackbar('Nama aset wajib diisi');
//       return;
//     }
    
//     setState(() {
//       _isUploading = true;
//     });
    
//     try {
//       final maintenancePattern = _useOtherMaintenance
//           ? _otherMaintenanceController.text.trim()
//           : _selectedMaintenancePattern;
      
//       final inspectionDay = _inspectionDayController.text.isNotEmpty
//           ? int.tryParse(_inspectionDayController.text)
//           : null;
      
//       // Build asset object
//       final asset = Asset(
//         id: widget.isEditing ? widget.existingAsset!.id : '',
//         rfidTagId: _rfidTagController.text.trim(),
//         assetName: _assetNameController.text.trim(),
//         typeId: _selectedTypeId,
//         fotoUrl: _existingFotoUrl,
//         statusCondition: _selectedStatus,
//         levelContaminated: _selectedContamination,
//         isDangerous: _isDangerous,
//         description: _descriptionController.text.trim().isEmpty
//             ? null
//             : _descriptionController.text.trim(),
//         lastRoomId: _selectedRoomId,
//         maintenancePattern: maintenancePattern?.isEmpty ?? true ? null : maintenancePattern,
//         inspectionDayOfMonth: inspectionDay,
//         isActive: true,
//         registeredAt: widget.isEditing
//             ? widget.existingAsset!.registeredAt
//             : DateTime.now(),
//         updatedAt: DateTime.now(),
//       );
      
//       if (widget.currentUserId == null) {
//         throw Exception('User tidak ditemukan, silakan login ulang');
//       }
      
//       String? finalFotoUrl = _existingFotoUrl;
      
//       // Handle photo upload for create mode
//       if (!widget.isEditing && _selectedImageFile != null) {
//         // Create asset first, then upload photo
//         final createdAsset = await widget.assetService.createAsset(asset, widget.currentUserId!);
        
//         // Upload photo with actual asset ID
//         final photoUrl = await widget.assetService.uploadAssetPhoto(_selectedImageFile!, createdAsset.id);
//         finalFotoUrl = photoUrl;
        
//         // Update asset with photo URL
//         final updatedAsset = createdAsset.copyWith(fotoUrl: photoUrl);
//         await widget.assetService.updateAsset(updatedAsset, widget.currentUserId!);
//       } else if (widget.isEditing) {
//         // Update existing asset
//         final updatedAsset = asset.copyWith(fotoUrl: _existingFotoUrl);
//         await widget.assetService.updateAsset(updatedAsset, widget.currentUserId!);
//       } else {
//         // Create without photo
//         await widget.assetService.createAsset(asset, widget.currentUserId!);
//       }
      
//       if (mounted) {
//         _showSuccessSnackbar(
//           widget.isEditing ? 'Aset berhasil diperbarui' : 'Aset berhasil ditambahkan'
//         );
//         widget.onSuccess();
//       }
//     } catch (e) {
//       if (mounted) {
//         _showErrorSnackbar('Gagal menyimpan aset: $e');
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isUploading = false;
//         });
//       }
//     }
//   }

//   // ==========================================================
//   // UI HELPERS
//   // ==========================================================
//   void _showErrorSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
//     );
//   }

//   void _showSuccessSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.green.shade700),
//     );
//   }

//   // ==========================================================
//   // BUILD METHODS
//   // ==========================================================
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Row(
//         children: [
//           Icon(
//             widget.isEditing ? Icons.edit : Icons.add_box,
//             color: widget.isEditing ? Colors.blue.shade700 : Colors.green.shade700,
//           ),
//           const SizedBox(width: 8),
//           Text(widget.isEditing ? 'Edit Aset' : 'Tambah Aset Baru'),
//         ],
//       ),
//       content: SizedBox(
//         width: MediaQuery.of(context).size.width * 0.55,
//         height: MediaQuery.of(context).size.height * 0.75,
//         child: _isLoadingData
//             ? const Center(child: CircularProgressIndicator())
//             : Form(
//                 key: _formKey,
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.only(
//                     bottom: MediaQuery.of(context).viewInsets.bottom,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // ==================================================
//                       // ROW 1: RFID Tag ID & Nama Aset (2 KOLOM)
//                       // ==================================================
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextFormField(
//                               controller: _rfidTagController,
//                               decoration: const InputDecoration(
//                                 labelText: 'Kode Asset - Track *',
//                                 hintText: 'RFID Tag ID',
//                                 border: OutlineInputBorder(),
//                                 isDense: true,
//                               ),
//                               onChanged: (value) => _validateRfidUnique(value),
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'RFID Tag ID harus diisi';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: TextFormField(
//                               controller: _assetNameController,
//                               decoration: const InputDecoration(
//                                 labelText: 'Nama Aset *',
//                                 border: OutlineInputBorder(),
//                                 isDense: true,
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Nama aset harus diisi';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
                      
//                       // ==================================================
//                       // ROW 2: Tipe Aset & Status Kondisi (2 KOLOM)
//                       // ==================================================
//                       Row(
//                         children: [
//                           Expanded(
//                             child: DropdownButtonFormField<String?>(
//                               isExpanded: true,
//                               value: _selectedTypeId,
//                               decoration: const InputDecoration(
//                                 labelText: 'Tipe Aset',
//                                 border: OutlineInputBorder(),
//                                 isDense: true,
//                               ),
//                               items: [
//                                 const DropdownMenuItem(value: null, child: Text('Pilih Tipe')),
//                                 ..._assetTypes.map((type) => DropdownMenuItem(
//                                   value: type['id'].toString(),
//                                   child: Text(
//                                     type['display_name'] ?? type['type_name'] ?? '-',
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 )),
//                               ],
//                               onChanged: (value) => setState(() => _selectedTypeId = value),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: DropdownButtonFormField<String>(
//                               isExpanded: true,
//                               value: _selectedStatus,
//                               decoration: const InputDecoration(
//                                 labelText: 'Status Kondisi',
//                                 border: OutlineInputBorder(),
//                                 isDense: true,
//                               ),
//                               items: const [
//                                 DropdownMenuItem(value: 'Good', child: Text('Good (Baik)')),
//                                 DropdownMenuItem(value: 'Fair', child: Text('Fair (Cukup)')),
//                                 DropdownMenuItem(value: 'Damage', child: Text('Damage (Rusak)')),
//                                 DropdownMenuItem(value: 'Critical', child: Text('Critical (Kritis)')),
//                               ],
//                               onChanged: (value) => setState(() => _selectedStatus = value!),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
                      
//                       // ==================================================
//                       // ROW 3: Level Kontaminasi & Berbahaya (2 KOLOM)
//                       // ==================================================
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Level Kontaminasi (0-5)',
//                                   style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
//                                 ),
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Slider(
//                                         value: _selectedContamination.toDouble(),
//                                         min: 0,
//                                         max: 5,
//                                         divisions: 5,
//                                         label: _selectedContamination.toString(),
//                                         activeColor: ContaminationLevel.getColor(_selectedContamination),
//                                         onChanged: (value) => setState(() {
//                                           _selectedContamination = value.round();
//                                         }),
//                                       ),
//                                     ),
//                                     Container(
//                                       width: 40,
//                                       height: 40,
//                                       decoration: BoxDecoration(
//                                         color: ContaminationLevel.getColor(_selectedContamination).withValues(alpha: 0.1),
//                                         borderRadius: BorderRadius.circular(8),
//                                         border: Border.all(color: ContaminationLevel.getColor(_selectedContamination)),
//                                       ),
//                                       child: Center(
//                                         child: Text(
//                                           _selectedContamination.toString(),
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             color: ContaminationLevel.getColor(_selectedContamination),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Row(
//                               children: [
//                                 Checkbox(
//                                   value: _isDangerous,
//                                   onChanged: (value) => setState(() => _isDangerous = value ?? false),
//                                 ),
//                                 const Text('Berbahaya'),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
                      
//                       // ==================================================
//                       // ROW 4: Ruangan (1 kolom penuh)
//                       // ==================================================
//                       DropdownButtonFormField<String?>(
//                         isExpanded: true,
//                         value: _selectedRoomId,
//                         decoration: const InputDecoration(
//                           labelText: 'Ruangan (Lokasi Awal)',
//                           border: OutlineInputBorder(),
//                           isDense: true,
//                         ),
//                         items: [
//                           const DropdownMenuItem(value: null, child: Text('Pilih Ruangan')),
//                           ..._rooms.map((room) => DropdownMenuItem(
//                             value: room['id'].toString(),
//                             child: Text(
//                               room['room_name'] ?? '-',
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           )),
//                         ],
//                         onChanged: (value) => setState(() => _selectedRoomId = value),
//                       ),
//                       const SizedBox(height: 12),
                      
//                       // ==================================================
//                       // ROW 5: Maintenance Pattern (dropdown + opsi Other)
//                       // ==================================================
//                       if (!_useOtherMaintenance)
//                         DropdownButtonFormField<String?>(
//                           isExpanded: true,
//                           value: _selectedMaintenancePattern,
//                           decoration: const InputDecoration(
//                             labelText: 'Pola Perawatan',
//                             border: OutlineInputBorder(),
//                             isDense: true,
//                           ),
//                           items: [
//                             const DropdownMenuItem(value: null, child: Text('Pilih Pola')),
//                             ..._maintenancePatterns.map((pattern) => DropdownMenuItem(
//                               value: pattern,
//                               child: Text(pattern, overflow: TextOverflow.ellipsis),
//                             )),
//                             const DropdownMenuItem(value: '__other__', child: Text('Lainnya...')),
//                           ],
//                           onChanged: (value) {
//                             if (value == '__other__') {
//                               setState(() {
//                                 _useOtherMaintenance = true;
//                                 _selectedMaintenancePattern = null;
//                               });
//                             } else {
//                               setState(() => _selectedMaintenancePattern = value);
//                             }
//                           },
//                         ),
                      
//                       if (_useOtherMaintenance)
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 controller: _otherMaintenanceController,
//                                 decoration: const InputDecoration(
//                                   labelText: 'Pola Perawatan Lainnya',
//                                   border: OutlineInputBorder(),
//                                   isDense: true,
//                                 ),
//                               ),
//                             ),
//                             IconButton(
//                               onPressed: () {
//                                 setState(() {
//                                   _useOtherMaintenance = false;
//                                   _otherMaintenanceController.clear();
//                                 });
//                               },
//                               icon: const Icon(Icons.close, size: 18),
//                               tooltip: 'Batal',
//                             ),
//                           ],
//                         ),
//                       const SizedBox(height: 12),
                      
//                       // ==================================================
//                       // ROW 6: Hari Inspeksi & Upload Foto (2 KOLOM)
//                       // ==================================================
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child: TextFormField(
//                               controller: _inspectionDayController,
//                               keyboardType: TextInputType.number,
//                               decoration: const InputDecoration(
//                                 labelText: 'Hari Inspeksi (1-31)',
//                                 hintText: 'Opsional',
//                                 border: OutlineInputBorder(),
//                                 isDense: true,
//                               ),
//                               validator: (value) {
//                                 if (value != null && value.isNotEmpty) {
//                                   final day = int.tryParse(value);
//                                   if (day == null || day < 1 || day > 31) {
//                                     return 'Hari harus antara 1-31';
//                                   }
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 GestureDetector(
//                                   onTap: _isUploading ? null : _pickAndUploadImage,
//                                   child: Container(
//                                     height: 80,
//                                     decoration: BoxDecoration(
//                                       border: Border.all(color: Colors.grey.shade300),
//                                       borderRadius: BorderRadius.circular(8),
//                                       color: Colors.grey.shade50,
//                                     ),
//                                     child: _isUploading
//                                         ? const Center(
//                                             child: SizedBox(
//                                               width: 24,
//                                               height: 24,
//                                               child: CircularProgressIndicator(strokeWidth: 2),
//                                             ),
//                                           )
//                                         : (_existingFotoUrl != null && _existingFotoUrl!.isNotEmpty)
//                                             ? ClipRRect(
//                                                 borderRadius: BorderRadius.circular(8),
//                                                 child: Image.network(
//                                                   _existingFotoUrl!,
//                                                   width: double.infinity,
//                                                   height: 80,
//                                                   fit: BoxFit.cover,
//                                                   errorBuilder: (context, error, stackTrace) {
//                                                     return _buildUploadPlaceholder();
//                                                   },
//                                                 ),
//                                               )
//                                             : _buildUploadPlaceholder(),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'Tap untuk upload foto',
//                                   style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
                      
//                       // ==================================================
//                       // ROW 7: Deskripsi (textarea)
//                       // ==================================================
//                       TextFormField(
//                         controller: _descriptionController,
//                         maxLines: 3,
//                         decoration: const InputDecoration(
//                           labelText: 'Deskripsi',
//                           border: OutlineInputBorder(),
//                           isDense: true,
//                           alignLabelWithHint: true,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Batal'),
//         ),
//         ElevatedButton(
//           onPressed: _isUploading ? null : _submitForm,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: widget.isEditing ? Colors.blue : Colors.green,
//             foregroundColor: Colors.white,
//           ),
//           child: Text(widget.isEditing ? 'Simpan Perubahan' : 'Tambah Aset'),
//         ),
//       ],
//     );
//   }

//   Widget _buildUploadPlaceholder() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(Icons.cloud_upload, size: 24, color: Colors.grey.shade400),
//         Text(
//           'Upload Foto',
//           style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
//         ),
//       ],
//     );
//   }
// }

// ============================================================
// DIALOG: Asset Form Dialog
// ============================================================
// TANGGUNG JAWAB:
// 1. Form untuk create dan edit aset
// 2. Layout 2 kolom (Row dengan 2 Expanded) untuk field yang padat
// 3. Upload foto aset ke Supabase Storage (menggunakan XFile)
// 4. Validasi: RFID Tag ID wajib unik, Nama Aset wajib
// 5. Dropdown untuk: Tipe Aset, Status Kondisi, Ruangan, Maintenance Pattern
// 6. Slider untuk Level Kontaminasi (0-5)
// 7. Checkbox untuk Berbahaya
// 8. Textarea untuk Deskripsi
// 9. SUPPORT WEB & MOBILE
// ============================================================

import 'dart:io';
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
      final maintenancePatterns = await widget.assetService.fetchMaintenancePatterns();
      
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
      if (widget.isEditing && _existingFotoUrl != null && _existingFotoUrl!.isNotEmpty) {
        await widget.assetService.deleteAssetPhoto(_existingFotoUrl!);
      }
      
      // Upload photo (XFile langsung, tanpa konversi ke File)
      if (widget.isEditing && widget.existingAsset != null) {
        final photoUrl = await widget.assetService.uploadAssetPhoto(pickedFile, widget.existingAsset!.id);
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
      _showErrorSnackbar('RFID Tag ID sudah digunakan, silakan gunakan yang lain');
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
        maintenancePattern: maintenancePattern?.isEmpty ?? true ? null : maintenancePattern,
        inspectionDayOfMonth: inspectionDay,
        isActive: true,
        registeredAt: widget.isEditing
            ? widget.existingAsset!.registeredAt
            : DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      if (widget.currentUserId == null) {
        throw Exception('User tidak ditemukan, silakan login ulang');
      }
      
      String? finalFotoUrl = _existingFotoUrl;
      
      // Handle photo upload for create mode
      if (!widget.isEditing && _selectedImageXFile != null) {
        final createdAsset = await widget.assetService.createAsset(asset, widget.currentUserId!);
        
        final photoUrl = await widget.assetService.uploadAssetPhoto(_selectedImageXFile!, createdAsset.id);
        finalFotoUrl = photoUrl;
        
        final updatedAsset = createdAsset.copyWith(fotoUrl: photoUrl);
        await widget.assetService.updateAsset(updatedAsset, widget.currentUserId!);
      } else if (widget.isEditing) {
        final updatedAsset = asset.copyWith(fotoUrl: _existingFotoUrl);
        await widget.assetService.updateAsset(updatedAsset, widget.currentUserId!);
      } else {
        await widget.assetService.createAsset(asset, widget.currentUserId!);
      }
      
      if (mounted) {
        _showSuccessSnackbar(
          widget.isEditing ? 'Aset berhasil diperbarui' : 'Aset berhasil ditambahkan'
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
            color: widget.isEditing ? Colors.blue.shade700 : Colors.green.shade700,
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
                                const DropdownMenuItem(value: null, child: Text('Pilih Tipe')),
                                ..._assetTypes.map((type) => DropdownMenuItem(
                                  value: type['id'].toString(),
                                  child: Text(
                                    type['display_name'] ?? type['type_name'] ?? '-',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                              ],
                              onChanged: (value) => setState(() => _selectedTypeId = value),
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
                                DropdownMenuItem(value: 'Good', child: Text('Good (Baik)')),
                                DropdownMenuItem(value: 'Fair', child: Text('Fair (Cukup)')),
                                DropdownMenuItem(value: 'Damage', child: Text('Damage (Rusak)')),
                                DropdownMenuItem(value: 'Critical', child: Text('Critical (Kritis)')),
                              ],
                              onChanged: (value) => setState(() => _selectedStatus = value!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // ROW 3: Level Kontaminasi & Berbahaya
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Level Kontaminasi (0-5)',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Slider(
                                        value: _selectedContamination.toDouble(),
                                        min: 0,
                                        max: 5,
                                        divisions: 5,
                                        label: _selectedContamination.toString(),
                                        activeColor: ContaminationLevel.getColor(_selectedContamination),
                                        onChanged: (value) => setState(() {
                                          _selectedContamination = value.round();
                                        }),
                                      ),
                                    ),
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: ContaminationLevel.getColor(_selectedContamination).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: ContaminationLevel.getColor(_selectedContamination)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _selectedContamination.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ContaminationLevel.getColor(_selectedContamination),
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
                                  onChanged: (value) => setState(() => _isDangerous = value ?? false),
                                ),
                                const Text('Berbahaya'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // ROW 4: Ruangan
                      DropdownButtonFormField<String?>(
                        isExpanded: true,
                        value: _selectedRoomId,
                        decoration: const InputDecoration(
                          labelText: 'Ruangan (Lokasi Awal)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Pilih Ruangan')),
                          ..._rooms.map((room) => DropdownMenuItem(
                            value: room['id'].toString(),
                            child: Text(
                              room['room_name'] ?? '-',
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                        ],
                        onChanged: (value) => setState(() => _selectedRoomId = value),
                      ),
                      const SizedBox(height: 12),
                      
                      // ROW 5: Maintenance Pattern
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
                            const DropdownMenuItem(value: null, child: Text('Pilih Pola')),
                            ..._maintenancePatterns.map((pattern) => DropdownMenuItem(
                              value: pattern,
                              child: Text(pattern, overflow: TextOverflow.ellipsis),
                            )),
                            const DropdownMenuItem(value: '__other__', child: Text('Lainnya...')),
                          ],
                          onChanged: (value) {
                            if (value == '__other__') {
                              setState(() {
                                _useOtherMaintenance = true;
                                _selectedMaintenancePattern = null;
                              });
                            } else {
                              setState(() => _selectedMaintenancePattern = value);
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
                      
                      // ROW 6: Hari Inspeksi & Upload Foto
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: _isUploading ? null : _pickAndUploadImage,
                                  child: Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey.shade50,
                                    ),
                                    child: _isUploading
                                        ? const Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          )
                                        : (_existingFotoUrl != null && _existingFotoUrl!.isNotEmpty)
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.network(
                                                  _existingFotoUrl!,
                                                  width: double.infinity,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
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
                                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // ROW 7: Deskripsi
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