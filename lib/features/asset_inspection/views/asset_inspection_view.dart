import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/asset_inspection_provider.dart';
import '../providers/asset_inspection_state.dart';

class AssetInspectionView extends ConsumerStatefulWidget {
  const AssetInspectionView({super.key});

  @override
  ConsumerState<AssetInspectionView> createState() =>
      _AssetInspectionViewState();
}

class _AssetInspectionViewState extends ConsumerState<AssetInspectionView> {
  final ImagePicker _picker = ImagePicker();

  // Searchable dropdown variables
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _filteredAssets = [];
  bool _isDropdownOpen = false;
  String _searchQuery = '';

  // QR Scanner variables
  bool _isScanning = false;
  final MobileScannerController _scannerController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _filterAssets(String query, List<Map<String, dynamic>> assets) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredAssets = List.from(assets);
      } else {
        _filteredAssets = assets.where((asset) {
          final assetName = asset['asset_name']?.toLowerCase() ?? '';
          final rfidTag = asset['rfid_tag_id']?.toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return assetName.contains(searchLower) ||
              rfidTag.contains(searchLower);
        }).toList();
      }
    });
  }

  void _selectAsset(
    AssetInspectionNotifier notifier,
    Map<String, dynamic> asset,
  ) {
    notifier.selectAsset(asset['id'].toString());
    setState(() {
      _isDropdownOpen = false;
      _searchQuery = '';
      _searchController.clear();
      _filteredAssets = [];
    });
  }

  void _clearSelectedAsset(AssetInspectionNotifier notifier) {
    notifier.selectAsset('');
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _filteredAssets = [];
      _isDropdownOpen = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (picked != null) {
        ref
            .read(assetInspectionStateProvider.notifier)
            .updatePhoto(File(picked.path));
      }
    } catch (e) {
      debugPrint("Error pick image: $e");
    }
  }

  // ==================== QR SCANNER METHODS ====================

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
    });
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildScannerDialog(),
    );
  }

  Widget _buildScannerDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Scan QR Code Asset",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF01579B),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isScanning = false;
                    });
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: MobileScanner(
                  controller: _scannerController,
                  onDetect: _onScanComplete,
                  errorBuilder: (context, error, child) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Please check camera permission and try again",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _scannerController.start();
                            },
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Arahkan kamera ke QR Code asset",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _onScanComplete(BarcodeCapture capture) {
    if (!mounted) return;

    final String? scannedValue = capture.barcodes.first.rawValue;
    if (scannedValue == null) return;

    // Tutup dialog scanner
    Navigator.pop(context);
    setState(() {
      _isScanning = false;
    });

    // Extract Asset ID (UUID) dari QR Code
    // Format: "KODE ASSET: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    final assetIdMatch = RegExp(
      r'KODE ASSET:\s*([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})',
      caseSensitive: false,
    ).firstMatch(scannedValue);

    // Fallback: format "ASSET_ID: xxx" jika ada
    final assetIdMatchOld = RegExp(
      r'ASSET_ID:\s*([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})',
      caseSensitive: false,
    ).firstMatch(scannedValue);

    // Fallback: cari UUID langsung dari text (lebih fleksibel)
    final uuidRegex = RegExp(
      r'[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}',
      caseSensitive: false,
    );
    final uuidMatch = uuidRegex.firstMatch(scannedValue);

    final String? assetId =
        assetIdMatch?.group(1) ??
        assetIdMatchOld?.group(1) ??
        uuidMatch?.group(0);

    if (assetId == null || assetId.isEmpty) {
      _showError("QR Code tidak valid (Asset ID tidak ditemukan)");
      return;
    }

    // Cari asset berdasarkan asset_id
    final state = ref.read(assetInspectionStateProvider);
    final notifier = ref.read(assetInspectionStateProvider.notifier);

    final foundAsset = state.assets.firstWhere(
      (asset) => asset['id'].toString() == assetId,
      orElse: () => {},
    );

    if (foundAsset.isNotEmpty) {
      notifier.selectAsset(foundAsset['id'].toString());
      _showSuccess("Asset ditemukan: ${foundAsset['asset_name']}");
      setState(() {
        _searchQuery = '';
        _searchController.clear();
        _filteredAssets = [];
      });
    } else {
      _showError("Asset dengan ID $assetId tidak ditemukan");
    }
  }

  // ==================== END OF QR SCANNER METHODS ====================

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        content: Text(msg, style: GoogleFonts.poppins()),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade700,
        content: Text(msg, style: GoogleFonts.poppins()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assetInspectionStateProvider);
    final notifier = ref.read(assetInspectionStateProvider.notifier);
    final isSmall = MediaQuery.of(context).size.width < 380;

    // Update filtered assets when assets loaded
    if (_filteredAssets.isEmpty && state.assets.isNotEmpty && !state.isSaved) {
      _filteredAssets = List.from(state.assets);
    }

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
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF01579B),
        centerTitle: true,
        title: Text(
          state.isSaved ? "Inspection Completed" : "Asset Inspection",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF01579B),
            fontSize: isSmall ? 18 : 20,
          ),
        ),
        actions: [
          if (state.isSaved)
            IconButton(
              onPressed: () {
                notifier.resetToForm();
                _clearSelectedAsset(notifier);
              },
              icon: const Icon(Icons.add_box_rounded),
              tooltip: "New Inspection",
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2F1), Color(0xFFB3E5FC), Color(0xFF81D4FA)],
          ),
        ),
        child: SafeArea(
          child: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF01579B)),
                )
              : state.isSaved
              ? _buildResultScreen(state, notifier)
              : _buildFormScreen(state, notifier, isSmall),
        ),
      ),
    );
  }

  Widget _buildFormScreen(
    AssetInspectionState state,
    AssetInspectionNotifier notifier,
    bool isSmall,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select Asset Section (Searchable + Scan QR)
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Select Asset",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF01579B),
                    ),
                  ),
                ),
                // Tombol Scan QR
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF01579B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _startScan,
                    icon: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                    ),
                    tooltip: "Scan QR Code Asset",
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSearchableAssetDropdown(notifier, state),
            const SizedBox(height: 20),

            // Asset Info (if selected)
            if (state.selectedAsset != null) ...[
              _buildAssetInfoCard(state.selectedAsset!),
              const SizedBox(height: 20),
            ],

            // Inspection Form (only show if asset selected)
            if (state.selectedAsset != null) ...[
              Text(
                "Inspection Form",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: const Color(0xFF01579B),
                ),
              ),
              const SizedBox(height: 12),

              // Inspection Type
              _buildTextField(
                label: "Inspection Type",
                icon: Icons.assignment_outlined,
                value: state.inspectionType,
                onChanged: notifier.updateInspectionType,
              ),
              const SizedBox(height: 12),

              // Inspection Result
              _buildDropdownField(
                label: "Inspection Result",
                icon: Icons.check_circle_outline,
                value: state.inspectionResult,
                items: ["Pass", "Fail", "Needs Follow-up", "Deferred"],
                onChanged: notifier.updateInspectionResult,
              ),
              const SizedBox(height: 12),

              // Condition Status
              _buildDropdownField(
                label: "Condition Status",
                icon: Icons.verified_outlined,
                value: state.conditionStatus,
                items: ["Good", "Fair", "Broken", "Maintenance"],
                onChanged: notifier.updateConditionStatus,
              ),
              const SizedBox(height: 12),

              // Contamination Level
              _buildDropdownIntField(
                label: "Contamination Level",
                icon: Icons.coronavirus_outlined,
                value: state.contaminationLevel,
                items: List.generate(6, (i) => i),
                itemLabel: (v) => "Level $v",
                onChanged: notifier.updateContaminationLevel,
              ),
              const SizedBox(height: 12),

              // Inspection Duration
              _buildTextField(
                label: "Duration (minutes)",
                icon: Icons.timer_outlined,
                value: state.inspectionDurationMinutes.toString(),
                onChanged: (v) {
                  final intVal = int.tryParse(v) ?? 0;
                  notifier.updateInspectionDurationMinutes(intVal);
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Next Inspection Date
              _buildDateField(
                label: "Next Inspection Date",
                icon: Icons.calendar_month_outlined,
                value: state.nextInspectionAt,
                onChanged: notifier.updateNextInspectionAt,
              ),
              const SizedBox(height: 12),

              // Notes
              _buildTextField(
                label: "Notes",
                icon: Icons.description_outlined,
                value: state.notes,
                onChanged: notifier.updateNotes,
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // Action Taken
              _buildTextField(
                label: "Action Taken",
                icon: Icons.build_outlined,
                value: state.actionTaken,
                onChanged: notifier.updateActionTaken,
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Recommendation
              _buildTextField(
                label: "Recommendation",
                icon: Icons.lightbulb_outline,
                value: state.recommendation,
                onChanged: notifier.updateRecommendation,
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Photo Section
              _buildPhotoSection(notifier, state),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: state.isSaving ? null : notifier.saveInspection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01579B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: state.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded, color: Colors.white),
                  label: Text(
                    state.isSaving ? "Saving..." : "Submit Inspection",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchableAssetDropdown(
    AssetInspectionNotifier notifier,
    AssetInspectionState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected asset info (if already selected)
        if (state.selectedAsset != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Selected Asset:",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.green.shade800,
                        ),
                      ),
                      Text(
                        state.selectedAsset!['asset_name'] ?? '-',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "RFID: ${state.selectedAsset!['rfid_tag_id'] ?? '-'}",
                        style: GoogleFonts.poppins(fontSize: 11),
                      ),
                      if (state.selectedAsset!['next_inspection_at'] != null)
                        Text(
                          "Next Inspection: ${_formatDate(DateTime.parse(state.selectedAsset!['next_inspection_at']))}",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.orange.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _clearSelectedAsset(notifier),
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: "Change Asset",
                ),
              ],
            ),
          ),
        ],

        // Search field (show if no asset selected)
        if (state.selectedAsset == null) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onTap: () => setState(() => _isDropdownOpen = true),
                  onChanged: (value) => _filterAssets(value, state.assets),
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration:
                      _inputDecoration(
                        "Search by Name or RFID",
                        Icons.search_rounded,
                      ).copyWith(
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterAssets('', state.assets);
                                },
                              )
                            : null,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Dropdown results
          if (_isDropdownOpen && _filteredAssets.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _filteredAssets.length > 50
                    ? 50
                    : _filteredAssets.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final asset = _filteredAssets[index];
                  return InkWell(
                    onTap: () => _selectAsset(notifier, asset),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            asset['asset_name'] ?? '-',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "RFID: ${asset['rfid_tag_id'] ?? '-'}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  asset['ref_asset_types']?['type_name'] ?? '-',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    color: Colors.teal.shade800,
                                  ),
                                ),
                              ),
                              if (asset['status_condition'] != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: asset['status_condition'] == 'Good'
                                        ? Colors.green.shade100
                                        : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    asset['status_condition'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      color: asset['status_condition'] == 'Good'
                                          ? Colors.green.shade800
                                          : Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // No results message
          if (_isDropdownOpen &&
              _searchQuery.isNotEmpty &&
              _filteredAssets.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  "No asset found for '$_searchQuery'",
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
            ),

          // Close dropdown when tap outside
          if (_isDropdownOpen)
            GestureDetector(
              onTap: () => setState(() => _isDropdownOpen = false),
              child: Container(height: 0),
            ),
        ],
      ],
    );
  }

  Widget _buildResultScreen(
    AssetInspectionState state,
    AssetInspectionNotifier notifier,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildGlassCard(
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              "INSPECTION COMPLETED",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: const Color(0xFF01579B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Asset: ${state.selectedAsset?['asset_name'] ?? '-'}",
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              "Condition: ${state.conditionStatus}",
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              "Result: ${state.inspectionResult}",
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  notifier.resetToForm();
                  _clearSelectedAsset(notifier);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF01579B),
                  side: const BorderSide(color: Color(0xFF01579B)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_box_rounded),
                label: Text(
                  "New Inspection",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetInfoCard(Map<String, dynamic> asset) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: asset['foto_url'] != null
                ? Image.network(
                    asset['foto_url'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image, size: 60),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, size: 40),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset['asset_name'] ?? '-',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "RFID: ${asset['rfid_tag_id'] ?? '-'}",
                  style: GoogleFonts.poppins(fontSize: 11),
                ),
                Text(
                  "Type: ${asset['ref_asset_types']?['type_name'] ?? '-'}",
                  style: GoogleFonts.poppins(fontSize: 11),
                ),
                Text(
                  "Current Condition: ${asset['status_condition'] ?? '-'}",
                  style: GoogleFonts.poppins(fontSize: 11),
                ),
                if (asset['next_inspection_at'] != null)
                  Text(
                    "Next Inspection Due: ${_formatDate(DateTime.parse(asset['next_inspection_at']))}",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.orange.shade700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildPhotoSection(
    AssetInspectionNotifier notifier,
    AssetInspectionState state,
  ) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withValues(alpha: 0.35),
        ),
        child: state.photo != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.file(state.photo!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_rounded,
                    size: 50,
                    color: Colors.blueGrey.shade400,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Take Inspection Photo",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "(Will replace asset photo)",
                    style: GoogleFonts.poppins(fontSize: 10),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String value,
    required Function(String) onChanged,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      initialValue: value,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: _inputDecoration(label, icon),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(label, style: GoogleFonts.poppins()),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: GoogleFonts.poppins()),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _buildDropdownIntField({
    required String label,
    required IconData icon,
    required int value,
    required List<int> items,
    required String Function(int) itemLabel,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: value,
          hint: Text(label, style: GoogleFonts.poppins()),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(itemLabel(item), style: GoogleFonts.poppins()),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required DateTime? value,
    required Function(DateTime?) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now().add(const Duration(days: 30)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF01579B)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value != null ? _formatDate(value) : label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: value != null ? Colors.black : Colors.grey.shade600,
                ),
              ),
            ),
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withValues(alpha: 0.25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: child,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.blueGrey),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF01579B)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF01579B), width: 1.4),
      ),
    );
  }
}
