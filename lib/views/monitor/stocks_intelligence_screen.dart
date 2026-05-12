// File: lib/views/monitor/stocks_intelligence_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/stocks_view_model.dart';

class StocksIntelligenceScreen extends StatefulWidget {
  const StocksIntelligenceScreen({super.key});

  @override
  State<StocksIntelligenceScreen> createState() =>
      _StocksIntelligenceScreenState();
}

class _StocksIntelligenceScreenState extends State<StocksIntelligenceScreen> {
  final TextEditingController _searchController = TextEditingController();

  final ScrollController _verticalTableController = ScrollController();

  final ScrollController _horizontalTableController = ScrollController();

  bool _isLoading = true;

  String? _errorMessage;

  List<StocksViewModel> _stocks = [];

  StocksViewModel? selectedStock;

  String selectedGroup = 'ALL';

  String? selectedType;

  final List<String> groupFilters = const ['ALL', 'TYPE', 'LOW STOCK', 'EMPTY'];

  @override
  void initState() {
    super.initState();

    _loadStocks();
  }

  @override
  void dispose() {
    _searchController.dispose();

    _verticalTableController.dispose();

    _horizontalTableController.dispose();

    super.dispose();
  }

  Future<void> _loadStocks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;

      final response = await supabase.from('v_stocks').select();

      final data = List<Map<String, dynamic>>.from(response);

      // ============================================
      // FIX:
      // gunakan fromMap BUKAN fromJson
      // ============================================

      final items = data.map((e) {
        return StocksViewModel.fromMap(e);
      }).toList();

      if (!mounted) return;

      setState(() {
        _stocks = items;

        selectedStock = items.isNotEmpty ? items.first : null;

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();

        _isLoading = false;
      });
    }
  }

  bool _sameText(String? a, String? b) {
    return (a ?? '').trim().toLowerCase() == (b ?? '').trim().toLowerCase();
  }

  List<String> _uniqueSortedValues(Iterable<String?> values) {
    final map = <String, String>{};

    for (final raw in values) {
      final value = raw?.trim();

      if (value == null || value.isEmpty) {
        continue;
      }

      map.putIfAbsent(value.toLowerCase(), () => value);
    }

    final result = map.values.toList();

    result.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return result;
  }

  List<String> get availableTypes {
    return _uniqueSortedValues(_stocks.map((e) => e.stockTypeName));
  }

  List<StocksViewModel> get filteredStocks {
    final q = _searchController.text.trim().toLowerCase();

    return _stocks.where((e) {
      // ============================================
      // FIX:
      // unitName -> unit
      // ============================================

      final matchesSearch =
          e.stockName.toLowerCase().contains(q) ||
          (e.stockTypeName ?? '').toLowerCase().contains(q) ||
          e.unit.toLowerCase().contains(q);

      if (!matchesSearch) {
        return false;
      }

      switch (selectedGroup) {
        case 'TYPE':
          if (selectedType != null &&
              !_sameText(e.stockTypeName, selectedType)) {
            return false;
          }
          break;

        case 'LOW STOCK':
          return e.isLowStock;

        case 'EMPTY':
          return e.isEmpty;
      }

      return true;
    }).toList();
  }

  List<StocksViewModel> get displayStocks {
    final items = List<StocksViewModel>.from(filteredStocks);

    items.sort(
      (a, b) => a.stockName.toLowerCase().compareTo(b.stockName.toLowerCase()),
    );

    return items;
  }

  int get _visibleTotal => filteredStocks.length;

  int get _visibleLowStock => filteredStocks.where((e) => e.isLowStock).length;

  int get _visibleEmpty => filteredStocks.where((e) => e.isEmpty).length;

  double get _visibleQty =>
      filteredStocks.fold(0, (p, e) => p + e.currentStock);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    final size = media.size;

    final bool compact = size.height < 720;

    final bool useMobileLayout = size.width < 1100;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF8F5), Color(0xFFDDF4EE), Color(0xFFD1F0E8)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(compact ? 10 : 14),
          child: _isLoading
              ? _buildLoading()
              : _errorMessage != null
              ? _buildError()
              : useMobileLayout
              ? _buildMobileLayout(compact: compact)
              : _buildDesktopLayout(compact: compact),
        ),
      ),
    );
  }

  Widget _buildMobileLayout({required bool compact}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(compact: compact),
          SizedBox(height: compact ? 10 : 12),
          _buildToolbar(compact: compact),
          SizedBox(height: compact ? 10 : 12),
          _buildStatsRow(),
          SizedBox(height: compact ? 10 : 12),
          SizedBox(height: 720, child: _buildBodyArea(compact: compact)),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout({required bool compact}) {
    return Column(
      children: [
        _buildHeader(compact: compact),
        SizedBox(height: compact ? 10 : 12),
        _buildToolbar(compact: compact),
        SizedBox(height: compact ? 10 : 12),
        _buildStatsRow(),
        SizedBox(height: compact ? 10 : 12),
        Expanded(child: _buildBodyArea(compact: compact)),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF10B981)),
    );
  }

  Widget _buildError() {
    return Center(
      child: Text(
        _errorMessage ?? 'Unknown Error',
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildHeader({required bool compact}) {
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FFFD), Color(0xFFE9F9F5)],
        ),
        border: Border.all(color: const Color(0xFFCDEEE7)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
              ),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STOCKS INTELLIGENCE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    fontSize: compact ? 16 : 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hospital Stock Monitoring Center',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 10 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar({required bool compact}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.74),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Search stock / type / unit',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _statCard(
          title: 'Visible',
          value: _visibleTotal.toString(),
          color: const Color(0xFF06B6D4),
        ),
        _statCard(
          title: 'Low Stock',
          value: _visibleLowStock.toString(),
          color: const Color(0xFFF59E0B),
        ),
        _statCard(
          title: 'Empty',
          value: _visibleEmpty.toString(),
          color: const Color(0xFFEF4444),
        ),
        _statCard(
          title: 'Total Qty',
          value: _visibleQty.toStringAsFixed(0),
          color: const Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyArea({required bool compact}) {
    return Row(
      children: [
        Expanded(flex: 7, child: _buildTablePanel()),
        const SizedBox(width: 12),
        Expanded(flex: 3, child: _buildDetailPanel()),
      ],
    );
  }

  Widget _buildTablePanel() {
    final rows = displayStocks;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.76),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: ListView.builder(
              controller: _verticalTableController,
              itemCount: rows.length,
              itemBuilder: (context, index) {
                final stock = rows[index];

                // ============================================
                // FIX:
                // stockId -> id
                // ============================================

                final selected = selectedStock?.id == stock.id;

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedStock = stock;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    color: selected
                        ? const Color(0xFF10B981).withOpacity(0.14)
                        // =========================================
                        // EMPTY STOCK
                        // =========================================
                        : stock.isEmpty
                        ? const Color(0xFFEF4444).withOpacity(0.10)
                        // =========================================
                        // LOW STOCK
                        // =========================================
                        : stock.isLowStock
                        ? const Color(0xFFF59E0B).withOpacity(0.10)
                        // =========================================
                        // NORMAL ROW
                        // =========================================
                        : index.isEven
                        ? Colors.white
                        : const Color(0xFFF8FAFC),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _horizontalTableController,
                      child: Row(
                        children: [
                          _cell(stock.stockName, 240, bold: true),
                          _cell(stock.stockTypeName ?? '-', 180),

                          // FIX:
                          // unitName -> unit
                          _cell(stock.unit, 100),

                          _cell(stock.currentStock.toStringAsFixed(2), 120),

                          _cell(stock.minimumStock.toStringAsFixed(2), 120),

                          // FIX:
                          // maximumStock tidak ada
                          // gunakan "-"
                          _cell('-', 120),

                          SizedBox(width: 120, child: _statusBadge(stock)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      color: const Color(0xFFF1F5F9),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _headerCell('Stock Name', 240),
            _headerCell('Type', 180),
            _headerCell('Unit', 100),
            _headerCell('Current', 120),
            _headerCell('Minimum', 120),
            _headerCell('Maximum', 120),
            _headerCell('Status', 120),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _cell(String text, double width, {bool bold = false}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _statusBadge(StocksViewModel stock) {
    Color color;
    String text;

    if (stock.isEmpty) {
      color = const Color(0xFFEF4444);

      text = 'EMPTY';
    } else if (stock.isLowStock) {
      color = const Color(0xFFF59E0B);

      text = 'LOW';
    } else {
      color = const Color(0xFF10B981);

      text = 'GOOD';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildDetailPanel() {
    final stock = selectedStock;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.76),
        borderRadius: BorderRadius.circular(24),
      ),
      child: stock == null
          ? const Center(child: Text('Select Stock'))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.stockName,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _detailItem('Type', stock.stockTypeName),

                  // FIX:
                  // unitName -> unit
                  _detailItem('Unit', stock.unit),

                  _detailItem(
                    'Current Stock',
                    stock.currentStock.toStringAsFixed(2),
                  ),

                  _detailItem(
                    'Minimum Stock',
                    stock.minimumStock.toStringAsFixed(2),
                  ),

                  // FIX:
                  // maximumStock tidak ada
                  _detailItem('Maximum Stock', '-'),

                  _detailItem('Created At', _formatDate(stock.createdAt)),

                  const SizedBox(height: 16),

                  Text(
                    _buildInsight(stock),
                    style: GoogleFonts.plusJakartaSans(height: 1.5),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _detailItem(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF64748B),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value == null || value.isEmpty ? '-' : value,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _buildInsight(StocksViewModel stock) {
    if (stock.isEmpty) {
      return 'Stock sudah habis dan membutuhkan restock segera.';
    }

    if (stock.isLowStock) {
      return 'Stock berada di bawah batas minimum.';
    }

    return 'Stock berada dalam kondisi aman.';
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '-';
    }

    return DateFormat('dd MMM yyyy HH:mm').format(value.toLocal());
  }
}
