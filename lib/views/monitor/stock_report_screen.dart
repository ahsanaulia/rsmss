// File: lib/views/monitor/stock_report_screen.dart

import 'dart:io';

import 'package:excel/excel.dart' as ex;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/stocks_view_model.dart';

class StockReportScreen extends StatefulWidget {
  const StockReportScreen({
    super.key,
  });

  @override
  State<StockReportScreen> createState() =>
      _StockReportScreenState();
}

class _StockReportScreenState
    extends State<StockReportScreen> {
  // =========================================================
  // CONTROLLERS
  // =========================================================

  final ScrollController _pageController =
      ScrollController();

  final ScrollController _horizontalController =
      ScrollController();

  final ScrollController _horizontalTopController =
      ScrollController();

  final ScrollController _verticalController =
      ScrollController();

  final TextEditingController _searchController =
      TextEditingController();

  // =========================================================
  // STATE
  // =========================================================

  bool _isLoading = true;
  bool _isExporting = false;

  List<StocksViewModel> _stocks = [];

  // =========================================================
  // COLORS
  // =========================================================

  static const Color _bg1 =
      Color(0xFFF3FFFC);

  static const Color _bg2 =
      Color(0xFFE8FFF8);

  static const Color _bg3 =
      Color(0xFFD8F8EF);

  static const Color _panel =
      Color(0xFFFFFFFF);

  static const Color _mint =
      Color(0xFF10B981);

  static const Color _mintDark =
      Color(0xFF047857);

  static const Color _teal =
      Color(0xFF14B8A6);

  static const Color _textPrimary =
      Color(0xFF0F172A);

  static const Color _textSecondary =
      Color(0xFF475569);

  static const Color _textMuted =
      Color(0xFF64748B);

  static const Color _border =
      Color(0xFFE2E8F0);

  static const Color _rowAlt =
      Color(0xFFF8FFFD);

  static const Color _rowLow =
      Color(0xFFFFF7ED);

  static const Color _rowEmpty =
      Color(0xFFFFF1F2);

  @override
  void initState() {
    super.initState();

    _horizontalTopController.addListener(() {
      if (_horizontalController.hasClients &&
          _horizontalController.offset !=
              _horizontalTopController.offset) {
        _horizontalController.jumpTo(
          _horizontalTopController.offset,
        );
      }
    });

    _horizontalController.addListener(() {
      if (_horizontalTopController.hasClients &&
          _horizontalTopController.offset !=
              _horizontalController.offset) {
        _horizontalTopController.jumpTo(
          _horizontalController.offset,
        );
      }
    });

    _load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _horizontalController.dispose();
    _horizontalTopController.dispose();
    _verticalController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // =========================================================
  // LOAD
  // =========================================================

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      final response =
          await supabase.from('v_stocks').select();

      final data =
          List<Map<String, dynamic>>.from(
        response,
      );

      final items = data
          .map(
            (e) => StocksViewModel.fromMap(e),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _stocks = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showSnackBar(
        'Gagal memuat data stock: $e',
      );
    }
  }

  // =========================================================
  // COMPUTED
  // =========================================================

  List<StocksViewModel> get _rows {
    final q = _searchController.text.trim().toLowerCase();

    final rows = _stocks.where((e) {
      return e.stockName.toLowerCase().contains(q) ||
          (e.stockCode ?? '').toLowerCase().contains(q) ||
          (e.stockTypeName ?? '').toLowerCase().contains(q) ||
          e.unit.toLowerCase().contains(q) ||
          e.stockCondition.toLowerCase().contains(q) ||
          (e.lastOpnameByName ?? '').toLowerCase().contains(q) ||
          (e.lastPurchaseByName ?? '').toLowerCase().contains(q) ||
          (e.lastUsageByName ?? '').toLowerCase().contains(q);
    }).toList();

    rows.sort(
      (a, b) => a.stockName.toLowerCase().compareTo(
            b.stockName.toLowerCase(),
          ),
    );

    return rows;
  }

  int get _totalItems => _rows.length;

  int get _lowItems => _rows.where((e) => e.isLowStock).length;

  int get _emptyItems => _rows.where((e) => e.isEmpty).length;

  int get _safeItems => _rows.where((e) => e.isStockSafe).length;

  double get _totalQuantity =>
      _rows.fold(0, (p, e) => p + e.currentStock);

  double get _totalMinimum =>
      _rows.fold(0, (p, e) => p + e.minimumStock);

  Map<String, int> get _groupByType {
    final map = <String, int>{};

    for (final item in _rows) {
      final key = item.stockTypeName ?? 'Unknown';
      map[key] = (map[key] ?? 0) + 1;
    }

    return map;
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _bg1,
            _bg2,
            _bg3,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _mint.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _teal.withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            child: Scrollbar(
              controller: _pageController,
              thumbVisibility: true,
              radius: const Radius.circular(999),
              child: SingleChildScrollView(
                controller: _pageController,
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height - 32,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 14),
                      _buildExportBar(),
                      const SizedBox(height: 14),
                      _buildSearchBar(),
                      // const SizedBox(height: 14),
                      // _buildStatsBar(),
                      // const SizedBox(height: 14),
                      // _buildTypeDistribution(),
                      const SizedBox(height: 14),
                      _buildTopHorizontalScrollbar(),
                      const SizedBox(height: 10),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.68,
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: _mint,
                                ),
                              )
                            : _buildTable(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF7FFFC),
          ],
        ),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _mint.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF34D399),
                  Color(0xFF10B981),
                  Color(0xFF059669),
                ],
              ),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STOCK REPORT CENTER',
                  style: GoogleFonts.plusJakartaSans(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Hospital Stock Intelligence Reporting',
                  style: GoogleFonts.plusJakartaSans(
                    color: _textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: _mint.withOpacity(0.10),
              border: Border.all(
                color: _mint.withOpacity(0.18),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.table_rows,
                  size: 16,
                  color: _mintDark,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_rows.length} ROWS',
                  style: GoogleFonts.plusJakartaSans(
                    color: _mintDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SEARCH
  // =========================================================

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: _panel,
        border: Border.all(color: _border),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) {
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: 'Search stock / code / type / unit / user',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: _mint,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // STATS
  // =========================================================

  // Widget _buildStatsBar() {
  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       final isSmall = constraints.maxWidth < 900;

  //       return Wrap(
  //         spacing: 12,
  //         runSpacing: 12,
  //         children: [
  //           _statCard(
  //             title: 'Total',
  //             value: _totalItems.toString(),
  //             color: const Color(0xFF06B6D4),
  //             width: isSmall
  //                 ? constraints.maxWidth
  //                 : (constraints.maxWidth / 5) - 10,
  //           ),
  //           _statCard(
  //             title: 'Low',
  //             value: _lowItems.toString(),
  //             color: const Color(0xFFF59E0B),
  //             width: isSmall
  //                 ? constraints.maxWidth
  //                 : (constraints.maxWidth / 5) - 10,
  //           ),
  //           _statCard(
  //             title: 'Empty',
  //             value: _emptyItems.toString(),
  //             color: const Color(0xFFEF4444),
  //             width: isSmall
  //                 ? constraints.maxWidth
  //                 : (constraints.maxWidth / 5) - 10,
  //           ),
  //           _statCard(
  //             title: 'Safe',
  //             value: _safeItems.toString(),
  //             color: const Color(0xFF10B981),
  //             width: isSmall
  //                 ? constraints.maxWidth
  //                 : (constraints.maxWidth / 5) - 10,
  //           ),
  //           _statCard(
  //             title: 'Total Qty',
  //             value: NumberFormat('#,##0.##').format(_totalQuantity),
  //             color: const Color(0xFF3B82F6),
  //             width: isSmall
  //                 ? constraints.maxWidth
  //                 : (constraints.maxWidth / 5) - 10,
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _statCard({
    required String title,
    required String value,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TYPE DISTRIBUTION
  // =========================================================

  // Widget _buildTypeDistribution() {
  //   final entries = _groupByType.entries.toList()
  //     ..sort((a, b) => b.value.compareTo(a.value));

  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(28),
  //       color: _panel,
  //       border: Border.all(color: _border),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.03),
  //           blurRadius: 18,
  //           offset: const Offset(0, 8),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Stock Type Distribution',
  //           style: GoogleFonts.plusJakartaSans(
  //             color: _textPrimary,
  //             fontWeight: FontWeight.w800,
  //             fontSize: 16,
  //           ),
  //         ),
  //         const SizedBox(height: 18),
  //         if (entries.isEmpty)
  //           SizedBox(
  //             height: 90,
  //             child: Center(
  //               child: Text(
  //                 'No distribution data.',
  //                 style: GoogleFonts.plusJakartaSans(
  //                   color: _textSecondary,
  //                   fontWeight: FontWeight.w600,
  //                   fontSize: 12,
  //                 ),
  //               ),
  //             ),
  //           )
  //         else
  //           Scrollbar(
  //             controller: _horizontalTopController,
  //             thumbVisibility: true,
  //             radius: const Radius.circular(999),
  //             child: SingleChildScrollView(
  //               controller: _horizontalTopController,
  //               scrollDirection: Axis.horizontal,
  //               child: Row(
  //                 children: entries.map((entry) {
  //                   return Container(
  //                     width: 220,
  //                     margin: const EdgeInsets.only(right: 14),
  //                     padding: const EdgeInsets.all(18),
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(22),
  //                       gradient: LinearGradient(
  //                         begin: Alignment.topLeft,
  //                         end: Alignment.bottomRight,
  //                         colors: [
  //                           _mint.withOpacity(0.10),
  //                           _teal.withOpacity(0.06),
  //                         ],
  //                       ),
  //                       border: Border.all(color: _border),
  //                     ),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           entry.key,
  //                           maxLines: 1,
  //                           overflow: TextOverflow.ellipsis,
  //                           style: GoogleFonts.plusJakartaSans(
  //                             color: _textPrimary,
  //                             fontWeight: FontWeight.w800,
  //                             fontSize: 14,
  //                           ),
  //                         ),
  //                         const SizedBox(height: 18),
  //                         Text(
  //                           '${entry.value}',
  //                           style: GoogleFonts.plusJakartaSans(
  //                             color: _mintDark,
  //                             fontWeight: FontWeight.w800,
  //                             fontSize: 30,
  //                           ),
  //                         ),
  //                         const SizedBox(height: 4),
  //                         Text(
  //                           'Items',
  //                           style: GoogleFonts.plusJakartaSans(
  //                             color: _textMuted,
  //                             fontWeight: FontWeight.w600,
  //                             fontSize: 11,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 }).toList(),
  //               ),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  // =========================================================
  // TOP HORIZONTAL BAR
  // =========================================================

  Widget _buildTopHorizontalScrollbar() {
    return SizedBox(
      height: 18,
      child: Scrollbar(
        controller: _horizontalTopController,
        thumbVisibility: true,
        radius: const Radius.circular(999),
        child: SingleChildScrollView(
          controller: _horizontalTopController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: _tableWidth,
            height: 1,
          ),
        ),
      ),
    );
  }

  double get _tableWidth => 2250;

  // =========================================================
  // TABLE
  // =========================================================

  Widget _buildTable() {
    final rows = _rows;

    if (rows.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: _panel,
          border: Border.all(color: _border),
        ),
        child: Center(
          child: Text(
            'No stock data found',
            style: GoogleFonts.plusJakartaSans(
              color: _textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: _panel,
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              radius: const Radius.circular(999),
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: _tableWidth,
                  height: constraints.maxHeight,
                  child: Column(
                    children: [
                      _buildHeaderRow(),
                      Expanded(
                        child: Scrollbar(
                          controller: _verticalController,
                          thumbVisibility: true,
                          radius: const Radius.circular(999),
                          child: ListView.builder(
                            controller: _verticalController,
                            itemCount: rows.length,
                            itemBuilder: (context, index) {
                              return _buildRow(
                                rows[index],
                                index,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _mint.withOpacity(0.10),
            _teal.withOpacity(0.08),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: _border),
        ),
      ),
      child: Row(
        children: [
          _header('No', 60),
          _header('Code', 110),
          _header('Stock Name', 260),
          _header('Type', 190),
          _header('Unit', 90),
          _header('Current', 110),
          _header('Minimum', 110),
          _header('Condition', 140),
          _header('Status', 120),
          _header('Last Opname At', 160),
          _header('Last Opname By', 180),
          _header('Last Purchase At', 160),
          _header('Last Purchase By', 180),
          _header('Last Usage At', 160),
          _header('Last Usage By', 180),
          _header('Active', 90),
        ],
      ),
    );
  }

  Widget _buildRow(
    StocksViewModel stock,
    int index,
  ) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: _rowColor(stock, index),
        border: Border(
          bottom: BorderSide(
            color: _border.withOpacity(0.7),
          ),
        ),
      ),
      child: Row(
        children: [
          _cell('${index + 1}', 60),
          _cell(stock.stockCode ?? '-', 110),
          _cell(stock.stockName, 260, bold: true),
          _cell(stock.stockTypeName ?? '-', 190),
          _cell(stock.unit, 90),
          _cell(_fmtNumber(stock.currentStock), 110),
          _cell(_fmtNumber(stock.minimumStock), 110),
          _cell(stock.stockCondition, 140),
          // SizedBox(
          //   width: 120,
          //   child: _statusBadge(stock),
          // ),
          _cell(_formatDate(stock.lastOpnameAt), 160),
          _cell(stock.lastOpnameByName ?? '-', 180),
          _cell(_formatDate(stock.lastPurchaseAt), 160),
          _cell(stock.lastPurchaseByName ?? '-', 180),
          _cell(_formatDate(stock.lastUsageAt), 160),
          _cell(stock.lastUsageByName ?? '-', 180),
          _cell(stock.isActive ? 'YES' : 'NO', 90),
        ],
      ),
    );
  }

  Widget _header(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.plusJakartaSans(
          color: _mintDark,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _cell(
    String text,
    double width, {
    bool bold = false,
  }) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.plusJakartaSans(
          color: _textPrimary,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Color _rowColor(
    StocksViewModel stock,
    int index,
  ) {
    if (stock.isEmpty) {
      return _rowEmpty;
    }

    if (stock.isLowStock) {
      return _rowLow;
    }

    return index.isEven ? _rowAlt : Colors.white;
  }

  // Widget _statusBadge(StocksViewModel stock) {
  //   Color bg;
  //   Color fg;
  //   String text;

  //   if (stock.isEmpty) {
  //     bg = const Color(0xFFFECDD3);
  //     fg = const Color(0xFFBE123C);
  //     text = 'EMPTY';
  //   } else if (stock.isLowStock) {
  //     bg = const Color(0xFFFED7AA);
  //     fg = const Color(0xFF9A3412);
  //     text = 'LOW';
  //   } else {
  //     bg = const Color(0xFFD1FAE5);
  //     fg = const Color(0xFF065F46);
  //     text = 'SAFE';
  //   }

  //   return Container(
  //     padding: const EdgeInsets.symmetric(
  //       horizontal: 10,
  //       vertical: 6,
  //     ),
  //     decoration: BoxDecoration(
  //       color: bg,
  //       borderRadius: BorderRadius.circular(999),
  //     ),
  //     child: Text(
  //       text,
  //       textAlign: TextAlign.center,
  //       style: GoogleFonts.plusJakartaSans(
  //         color: fg,
  //         fontWeight: FontWeight.w800,
  //         fontSize: 11,
  //       ),
  //     ),
  //   );
  // }

  // =========================================================
  // EXPORT BAR
  // =========================================================

  Widget _buildExportBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: _panel,
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: _mint,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Export stock report sesuai data aktif.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: _textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _exportButton(
            label: 'PDF',
            icon: Icons.picture_as_pdf,
            color: const Color(0xFFEF4444),
            onPressed: _isExporting ? null : _exportPdf,
          ),
          const SizedBox(width: 10),
          _exportButton(
            label: 'XLSX',
            icon: Icons.table_chart_outlined,
            color: const Color(0xFF10B981),
            onPressed: _isExporting ? null : _exportExcel,
          ),
        ],
      ),
    );
  }

  Widget _exportButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: _isExporting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // EXPORT PDF
  // =========================================================

  Future<void> _exportPdf() async {
    if (_rows.isEmpty) {
      _showSnackBar('Tidak ada data untuk diexport.');
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a3.landscape,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => [
            pw.Text(
              'STOCK REPORT',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Hospital Stock Intelligence Reporting',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 18),
            pw.Table.fromTextArray(
              headers: [
                'No',
                'Code',
                'Stock Name',
                'Type',
                'Unit',
                'Current',
                'Minimum',
                'Condition',
                'Status',
                'Last Opname',
                'Last Purchase',
                'Last Usage',
                'Active',
              ],
              data: _rows.asMap().entries.map((entry) {
                final i = entry.key;
                final s = entry.value;

                return [
                  '${i + 1}',
                  s.stockCode ?? '-',
                  s.stockName,
                  s.stockTypeName ?? '-',
                  s.unit,
                  _fmtNumber(s.currentStock),
                  _fmtNumber(s.minimumStock),
                  s.stockCondition,
                  s.isEmpty
                      ? 'EMPTY'
                      : s.isLowStock
                          ? 'LOW'
                          : 'SAFE',
                  _formatDate(s.lastOpnameAt),
                  s.lastOpnameByName ?? '-',
                  _formatDate(s.lastPurchaseAt),
                  s.lastPurchaseByName ?? '-',
                  _formatDate(s.lastUsageAt),
                  s.lastUsageByName ?? '-',
                  s.isActive ? 'YES' : 'NO',
                ];
              }).toList(),
            ),
          ],
        ),
      );

      final bytes = await pdf.save();

      final filename =
          'stock_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      await Printing.sharePdf(
        bytes: bytes,
        filename: filename,
      );

      _showSnackBar('PDF siap diexport.');
    } catch (e) {
      _showSnackBar('Gagal export PDF: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  // =========================================================
  // EXPORT EXCEL
  // =========================================================

  Future<void> _exportExcel() async {
    if (_rows.isEmpty) {
      _showSnackBar('Tidak ada data untuk diexport.');
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final excel = ex.Excel.createExcel();
      final sheet = excel['Stocks'];

      sheet.appendRow([
        ex.TextCellValue('No'),
        ex.TextCellValue('Code'),
        ex.TextCellValue('Stock Name'),
        ex.TextCellValue('Type'),
        ex.TextCellValue('Unit'),
        ex.TextCellValue('Current'),
        ex.TextCellValue('Minimum'),
        ex.TextCellValue('Condition'),
        ex.TextCellValue('Status'),
        ex.TextCellValue('Last Opname'),
        ex.TextCellValue('Last Opname By'),
        ex.TextCellValue('Last Purchase'),
        ex.TextCellValue('Last Purchase By'),
        ex.TextCellValue('Last Usage'),
        ex.TextCellValue('Last Usage By'),
        ex.TextCellValue('Active'),
      ]);

      for (int i = 0; i < _rows.length; i++) {
        final s = _rows[i];

        sheet.appendRow([
          ex.TextCellValue('${i + 1}'),
          ex.TextCellValue(s.stockCode ?? '-'),
          ex.TextCellValue(s.stockName),
          ex.TextCellValue(s.stockTypeName ?? '-'),
          ex.TextCellValue(s.unit),
          ex.TextCellValue(_fmtNumber(s.currentStock)),
          ex.TextCellValue(_fmtNumber(s.minimumStock)),
          ex.TextCellValue(s.stockCondition),
          ex.TextCellValue(
            s.isEmpty
                ? 'EMPTY'
                : s.isLowStock
                    ? 'LOW'
                    : 'SAFE',
          ),
          ex.TextCellValue(_formatDate(s.lastOpnameAt)),
          ex.TextCellValue(s.lastOpnameByName ?? '-'),
          ex.TextCellValue(_formatDate(s.lastPurchaseAt)),
          ex.TextCellValue(s.lastPurchaseByName ?? '-'),
          ex.TextCellValue(_formatDate(s.lastUsageAt)),
          ex.TextCellValue(s.lastUsageByName ?? '-'),
          ex.TextCellValue(s.isActive ? 'YES' : 'NO'),
        ]);
      }

      final bytes = excel.encode();

      if (bytes == null) {
        throw Exception('Excel encode failed.');
      }

      final dir = await getApplicationDocumentsDirectory();

      final filename =
          'stock_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';

      final file = File('${dir.path}/$filename');

      await file.writeAsBytes(
        bytes,
        flush: true,
      );

      _showSnackBar('Excel tersimpan: ${file.path}');
    } catch (e) {
      _showSnackBar('Gagal export Excel: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  // =========================================================
  // HELPERS
  // =========================================================

  String _fmtNumber(double value) {
    return NumberFormat('#,##0.##').format(value);
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '-';
    }

    return DateFormat('dd MMM yyyy HH:mm').format(
      value.toLocal(),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}