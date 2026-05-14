import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/stock_provider.dart';
import '../providers/stock_state.dart';

class StockInitialView extends ConsumerStatefulWidget {
  const StockInitialView({super.key});

  @override
  ConsumerState<StockInitialView> createState() => _StockInitialViewState();
}

class _StockInitialViewState extends ConsumerState<StockInitialView> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (picked != null) {
        ref.read(stockInitialStateProvider.notifier).updatePhoto(File(picked.path));
      }
    } catch (e) {
      debugPrint("Error pick image: $e");
    }
  }

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
    final state = ref.watch(stockInitialStateProvider);
    final notifier = ref.read(stockInitialStateProvider.notifier);
    final isSmall = MediaQuery.of(context).size.width < 380;

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
          state.isSaved ? "Stock Saved" : "Stock Initial",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF01579B),
            fontSize: isSmall ? 18 : 20,
          ),
        ),
        actions: [
          if (state.isSaved)
            IconButton(
              onPressed: notifier.resetToForm,
              icon: const Icon(Icons.add_box_rounded),
              tooltip: "New Stock",
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
                  child: CircularProgressIndicator(color: Color(0xFF01579B)))
              : state.isSaved
                  ? _buildResultScreen(state, notifier)
                  : _buildFormScreen(state, notifier, isSmall),
        ),
      ),
    );
  }

  Widget _buildFormScreen(
    StockInitialState state,
    StockInitialNotifier notifier,
    bool isSmall,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stock Code
            _buildTextField(
              label: "Stock Code",
              icon: Icons.qr_code,
              value: state.stockCode,
              onChanged: notifier.updateStockCode,
              validator: (v) => v.trim().isEmpty ? "Stock code required" : null,
            ),
            const SizedBox(height: 16),

            // Stock Name
            _buildTextField(
              label: "Stock Name",
              icon: Icons.inventory_2_outlined,
              value: state.stockName,
              onChanged: notifier.updateStockName,
              validator: (v) => v.trim().isEmpty ? "Stock name required" : null,
            ),
            const SizedBox(height: 16),

            // Stock Type
            _buildDropdownField(
              label: "Stock Type",
              icon: Icons.category_outlined,
              value: state.selectedTypeId,
              items: state.stockTypes,
              itemId: (e) => e['id'].toString(),
              itemName: (e) => e['type_name'] ?? '-',
              onChanged: (id, name) => notifier.selectStockType(id, name),
              validator: (v) => v == null ? "Select stock type" : null,
            ),
            const SizedBox(height: 16),

            // Unit
            _buildTextField(
              label: "Unit",
              icon: Icons.square_foot,
              value: state.unit,
              onChanged: notifier.updateUnit,
              validator: (v) => v.trim().isEmpty ? "Unit required" : null,
              hint: "pcs, box, kg, liter, etc",
            ),
            const SizedBox(height: 16),

            // Row: Minimum Stock & Current Stock
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: "Minimum Stock",
                    icon: Icons.warning_amber_rounded,
                    value: state.minimumStock,
                    onChanged: notifier.updateMinimumStock,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: "Current Stock",
                    icon: Icons.inventory,
                    value: state.currentStock,
                    onChanged: notifier.updateCurrentStock,
                    keyboardType: TextInputType.number,
                    validator: (v) => v.trim().isEmpty ? "Current stock required" : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Storage Location
            _buildDropdownField(
              label: "Storage Location",
              icon: Icons.location_on_outlined,
              value: state.selectedLocationId,
              items: state.storageLocations,
              itemId: (e) => e['id'].toString(),
              itemName: (e) => e['location_name'] ?? '-',
              onChanged: (id, name) => notifier.selectStorageLocation(id, name),
            ),
            const SizedBox(height: 16),

            // Stock Condition
            _buildDropdownStringField(
              label: "Stock Condition",
              icon: Icons.verified_outlined,
              value: state.stockCondition,
              items: ["GOOD", "DAMAGED", "EXPIRED", "EXPIRING_SOON"],
              onChanged: notifier.updateStockCondition,
            ),
            const SizedBox(height: 16),

            // Batch Number & Expiry Date
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: "Batch Number",
                    icon: Icons.numbers,
                    value: state.batchNumber,
                    onChanged: notifier.updateBatchNumber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    label: "Expiry Date",
                    icon: Icons.calendar_month_outlined,
                    value: state.expiryDate,
                    onChanged: notifier.updateExpiryDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            _buildTextField(
              label: "Description",
              icon: Icons.description_outlined,
              value: state.description,
              onChanged: notifier.updateDescription,
              maxLines: 3,
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
                onPressed: state.isSaving ? null : notifier.saveStock,
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
                  state.isSaving ? "Saving..." : "Save Stock",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen(
    StockInitialState state,
    StockInitialNotifier notifier,
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
              "STOCK SUCCESSFULLY SAVED",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: const Color(0xFF01579B),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("Stock Code", state.stockCode),
                  const SizedBox(height: 8),
                  _buildInfoRow("Stock Name", state.stockName),
                  const SizedBox(height: 8),
                  _buildInfoRow("Type", state.selectedTypeName ?? '-'),
                  const SizedBox(height: 8),
                  _buildInfoRow("Unit", state.unit),
                  const SizedBox(height: 8),
                  _buildInfoRow("Current Stock", "${state.currentStock} ${state.unit}"),
                  const SizedBox(height: 8),
                  _buildInfoRow("Location", state.selectedLocationName ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: notifier.resetToForm,
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
                  "Register New Stock",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Text(":", style: GoogleFonts.poppins(fontSize: 12)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(
    StockInitialNotifier notifier,
    StockInitialState state,
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
                    "Take Stock Photo",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
    String? Function(String)? validator,
    String? hint,
  }) {
    return TextFormField(
      initialValue: value,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator != null ? (v) => validator(v ?? '') : null,
      onChanged: onChanged,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: _inputDecoration(label, icon).copyWith(
        hintText: hint,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<Map<String, dynamic>> items,
    required String Function(Map<String, dynamic>) itemId,
    required String Function(Map<String, dynamic>) itemName,
    required Function(String, String) onChanged,
    String? Function(String?)? validator,
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
              value: itemId(item),
              child: Text(itemName(item), style: GoogleFonts.poppins()),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) {
              final selected = items.firstWhere((e) => itemId(e) == v);
              onChanged(v, itemName(selected));
            }
          },
        ),
      ),
    );
  }

  Widget _buildDropdownStringField({
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
          initialDate: value ?? DateTime.now().add(const Duration(days: 365)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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