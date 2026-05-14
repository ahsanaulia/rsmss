import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/stock_opname_provider.dart';
import '../providers/stock_opname_state.dart';

class StockOpnameView extends ConsumerStatefulWidget {
  const StockOpnameView({super.key});

  @override
  ConsumerState<StockOpnameView> createState() => _StockOpnameViewState();
}

class _StockOpnameViewState extends ConsumerState<StockOpnameView> {
  // Searchable dropdown variables
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _filteredStocks = [];
  bool _isDropdownOpen = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStocks(String query, List<Map<String, dynamic>> stocks) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredStocks = List.from(stocks);
      } else {
        _filteredStocks = stocks.where((stock) {
          final stockName = stock['stock_name']?.toLowerCase() ?? '';
          final stockCode = stock['stock_code']?.toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return stockName.contains(searchLower) || stockCode.contains(searchLower);
        }).toList();
      }
    });
  }

  void _selectStock(StockOpnameNotifier notifier, Map<String, dynamic> stock) {
    notifier.selectStock(stock['id'].toString());
    setState(() {
      _isDropdownOpen = false;
      _searchQuery = '';
      _searchController.clear();
      _filteredStocks = [];
    });
  }

  void _clearSelectedStock(StockOpnameNotifier notifier) {
    notifier.clearSelectedStock();
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _filteredStocks = [];
      _isDropdownOpen = false;
    });
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
    final state = ref.watch(stockOpnameStateProvider);
    final notifier = ref.read(stockOpnameStateProvider.notifier);
    final isSmall = MediaQuery.of(context).size.width < 380;

    // Update filtered stocks when stocks loaded
    if (_filteredStocks.isEmpty && state.stocks.isNotEmpty && !state.isSaved) {
      _filteredStocks = List.from(state.stocks);
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
          state.isSaved ? "Opname Completed" : "Stock Opname",
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
                _clearSelectedStock(notifier);
              },
              icon: const Icon(Icons.add_box_rounded),
              tooltip: "New Opname",
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
    StockOpnameState state,
    StockOpnameNotifier notifier,
    bool isSmall,
  ) {
    final adjustment = state.physicalStock - state.stockBefore;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select Stock Section (Searchable)
            Text(
              "Select Stock",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: const Color(0xFF01579B),
              ),
            ),
            const SizedBox(height: 8),
            _buildSearchableStockDropdown(notifier, state),
            const SizedBox(height: 20),

            // Stock Info (if selected)
            if (state.selectedStock != null) ...[
              _buildStockInfoCard(state.selectedStock!),
              const SizedBox(height: 20),
            ],

            // Opname Form (only show if stock selected)
            if (state.selectedStock != null) ...[
              Text(
                "Opname Form",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: const Color(0xFF01579B),
                ),
              ),
              const SizedBox(height: 12),

              // Stock Before (readonly)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory, size: 20, color: const Color(0xFF01579B)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Stock Before",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "${state.stockBefore.toStringAsFixed(2)} ${state.selectedStock!['unit'] ?? ''}",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Physical Stock
              _buildNumberField(
                label: "Physical Stock",
                icon: Icons.numbers,
                value: state.physicalStock,
                onChanged: notifier.updatePhysicalStock,
              ),
              const SizedBox(height: 16),

              // Adjustment (auto calculate, readonly)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: adjustment != 0 ? Colors.orange.shade300 : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      adjustment != 0 ? Icons.trending_up : Icons.check_circle,
                      size: 20,
                      color: adjustment != 0 ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Adjustment",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            adjustment >= 0 ? "+${adjustment.toStringAsFixed(2)}" : adjustment.toStringAsFixed(2),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: adjustment != 0 ? Colors.orange : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Opname Note
              _buildTextField(
                label: "Opname Note",
                icon: Icons.description_outlined,
                value: state.opnameNote,
                onChanged: notifier.updateOpnameNote,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: state.isSaving ? null : notifier.saveOpname,
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
                    state.isSaving ? "Saving..." : "Submit Opname",
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

  Widget _buildSearchableStockDropdown(
    StockOpnameNotifier notifier,
    StockOpnameState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected stock info (if already selected)
        if (state.selectedStock != null) ...[
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
                        "Selected Stock:",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.green.shade800,
                        ),
                      ),
                      Text(
                        state.selectedStock!['stock_name'] ?? '-',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Code: ${state.selectedStock!['stock_code'] ?? '-'}",
                        style: GoogleFonts.poppins(fontSize: 11),
                      ),
                      Text(
                        "Current Stock: ${state.selectedStock!['current_stock']} ${state.selectedStock!['unit'] ?? ''}",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _clearSelectedStock(notifier),
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: "Change Stock",
                ),
              ],
            ),
          ),
        ],

        // Search field (show if no stock selected)
        if (state.selectedStock == null) ...[
          TextField(
            controller: _searchController,
            onTap: () => setState(() => _isDropdownOpen = true),
            onChanged: (value) => _filterStocks(value, state.stocks),
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: _inputDecoration(
              "Search by Name or Code",
              Icons.search_rounded,
            ).copyWith(
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _filterStocks('', state.stocks);
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8),

          // Dropdown results
          if (_isDropdownOpen && _filteredStocks.isNotEmpty)
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
                itemCount: _filteredStocks.length > 50 ? 50 : _filteredStocks.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                ),
                itemBuilder: (context, index) {
                  final stock = _filteredStocks[index];
                  return InkWell(
                    onTap: () => _selectStock(notifier, stock),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stock['stock_name'] ?? '-',
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
                                  "Code: ${stock['stock_code'] ?? '-'}",
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
                                  "Stock: ${stock['current_stock']} ${stock['unit'] ?? ''}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    color: Colors.teal.shade800,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: stock['current_stock'] <= stock['minimum_stock']
                                      ? Colors.red.shade100
                                      : Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  stock['stock_condition'] ?? 'GOOD',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    color: stock['current_stock'] <= stock['minimum_stock']
                                        ? Colors.red.shade800
                                        : Colors.green.shade800,
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
          if (_isDropdownOpen && _searchQuery.isNotEmpty && _filteredStocks.isEmpty)
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
                  "No stock found for '$_searchQuery'",
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

  Widget _buildStockInfoCard(Map<String, dynamic> stock) {
  final location = stock['storage_locations'] != null
      ? (stock['storage_locations'] as Map<String, dynamic>)['location_name'] ?? '-'
      : '-';
  
  // Perbaikan: extract nilai dengan benar
  final currentStock = (stock['current_stock'] as num?)?.toDouble() ?? 0.0;
  final minimumStock = (stock['minimum_stock'] as num?)?.toDouble() ?? 0.0;
  final bool isLowStock = currentStock <= minimumStock;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isLowStock ? Colors.red.shade300 : Colors.transparent,
        width: isLowStock ? 1.5 : 0,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                stock['stock_name'] ?? '-',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (isLowStock)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "LOW STOCK",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _buildInfoRow("Code", stock['stock_code'] ?? '-'),
        const SizedBox(height: 4),
        _buildInfoRow("Unit", stock['unit'] ?? '-'),
        const SizedBox(height: 4),
        _buildInfoRow("Location", location),
        const SizedBox(height: 4),
        _buildInfoRow("Current Stock", "$currentStock ${stock['unit'] ?? ''}"),
        const SizedBox(height: 4),
        _buildInfoRow("Min Stock", "$minimumStock ${stock['unit'] ?? ''}"),
      ],
    ),
  );
}

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(":", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildResultScreen(
    StockOpnameState state,
    StockOpnameNotifier notifier,
  ) {
    final adjustment = state.physicalStock - state.stockBefore;

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
              "OPNAME COMPLETED",
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
                  _buildInfoRow("Stock", state.selectedStock?['stock_name'] ?? '-'),
                  const SizedBox(height: 8),
                  _buildInfoRow("Stock Before", "${state.stockBefore.toStringAsFixed(2)} ${state.selectedStock?['unit'] ?? ''}"),
                  const SizedBox(height: 8),
                  _buildInfoRow("Physical Stock", "${state.physicalStock.toStringAsFixed(2)} ${state.selectedStock?['unit'] ?? ''}"),
                  const SizedBox(height: 8),
                  _buildInfoRow("Adjustment", adjustment >= 0 ? "+${adjustment.toStringAsFixed(2)}" : adjustment.toStringAsFixed(2)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  notifier.resetToForm();
                  _clearSelectedStock(notifier);
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
                  "New Opname",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
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
  }) {
    return TextFormField(
      initialValue: value,
      maxLines: maxLines,
      onChanged: onChanged,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: _inputDecoration(label, icon),
    );
  }

  Widget _buildNumberField({
    required String label,
    required IconData icon,
    required double value,
    required Function(double) onChanged,
  }) {
    return TextFormField(
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      onChanged: (v) {
        final doubleVal = double.tryParse(v) ?? 0;
        onChanged(doubleVal);
      },
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: _inputDecoration(label, icon),
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