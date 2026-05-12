// File: lib/views/monitor/stock_overview_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../../models/stocks_view_model.dart';

class StockOverviewScreen extends StatefulWidget {
  const StockOverviewScreen({
    super.key,
  });

  @override
  State<StockOverviewScreen> createState() =>
      _StockOverviewScreenState();
}

class _StockOverviewScreenState
    extends State<StockOverviewScreen> {

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

  static const Color _blue =
      Color(0xFF3B82F6);

  static const Color _orange =
      Color(0xFFF59E0B);

  static const Color _red =
      Color(0xFFEF4444);

  static const Color _textPrimary =
      Color(0xFF0F172A);

  static const Color _textSecondary =
      Color(0xFF475569);

  static const Color _textMuted =
      Color(0xFF64748B);

  static const Color _border =
      Color(0xFFE2E8F0);

  // =========================================================
  // CONTROLLERS
  // =========================================================

  final ScrollController _pageController =
      ScrollController();

  final ScrollController _horizontalController =
      ScrollController();

  // =========================================================
  // LOCAL DATA
  // =========================================================

  List<StocksViewModel> _stocks = [];

  // =========================================================
  // LIFECYCLE
  // =========================================================

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();

    _horizontalController.dispose();

    super.dispose();
  }

  // =========================================================
  // LOAD DATA
  // =========================================================

  // =========================================================
// LOAD DATA
// =========================================================

Future<void> _loadData() async {

  try {

    final supabase =
        Supabase.instance.client;

    final response =
        await supabase
            .from('v_stocks')
            .select();

    final data =
        List<Map<String, dynamic>>.from(
      response,
    );

    final items = data.map(
      (e) {

        return StocksViewModel.fromJson(
          jsonEncode(e),
        );

      },
    ).toList();

    if (!mounted) return;

    setState(() {
      _stocks = items;
    });

  } catch (e) {

    debugPrint(
      'ERROR LOAD STOCKS: $e',
    );
  }
}
  // =========================================================
  // COMPUTED
  // =========================================================

  int get _totalItems {
    return _stocks.length;
  }

  int get _lowStocks {
    return _stocks
        .where(
          (e) => e.isLowStock,
        )
        .length;
  }

  int get _emptyStocks {
    return _stocks
        .where(
          (e) => e.isEmpty,
        )
        .length;
  }

  double get _totalStockQty {
    return _stocks.fold(
      0,
      (previousValue, element) =>
          previousValue +
          element.currentStock,
    );
  }

  Map<String, int> get _groupByType {

    final map = <String, int>{};

    for (final item in _stocks) {

      final key =
          item.stockTypeName ??
              'Unknown';

      map[key] =
          (map[key] ?? 0) + 1;
    }

    return map;
  }

  List<StocksViewModel> get _criticalStocks {

    final list = _stocks
        .where(
          (e) =>
              e.isEmpty ||
              e.isLowStock,
        )
        .toList();

    list.sort(
      (a, b) => a.currentStock
          .compareTo(
        b.currentStock,
      ),
    );

    return list.take(10).toList();
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
          end:
              Alignment.bottomRight,
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
                color: _mint.withOpacity(
                  0.08,
                ),
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
                color: _teal.withOpacity(
                  0.08,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Scrollbar(
              controller:
                  _pageController,
              thumbVisibility: true,
              radius:
                  const Radius.circular(
                999,
              ),
              child:
                  SingleChildScrollView(
                controller:
                    _pageController,
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  children: [

                    _buildHeader(),

                    const SizedBox(
                      height: 16,
                    ),

                    _buildSummaryCards(),

                    const SizedBox(
                      height: 16,
                    ),

                    _buildTypeDistribution(),

                    const SizedBox(
                      height: 16,
                    ),

                    _buildCriticalStocks(),
                  ],
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
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF7FFFC),
          ],
        ),
        border: Border.all(
          color: _border,
        ),
        boxShadow: [
          BoxShadow(
            color: _mint.withOpacity(
              0.08,
            ),
            blurRadius: 24,
            offset:
                const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [

          Container(
            padding:
                const EdgeInsets.all(
              14,
            ),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
              gradient:
                  const LinearGradient(
                begin:
                    Alignment.topLeft,
                end:
                    Alignment.bottomRight,
                colors: [
                  Color(0xFF34D399),
                  Color(0xFF10B981),
                  Color(0xFF059669),
                ],
              ),
            ),
            child: const Icon(
              Icons.inventory_2,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [

                Text(
                  'STOCK OVERVIEW',
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style: GoogleFonts
                      .plusJakartaSans(
                    color:
                        _textPrimary,
                    fontWeight:
                        FontWeight
                            .w800,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  'Hospital Stock Intelligence Dashboard',
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style: GoogleFonts
                      .plusJakartaSans(
                    color:
                        _textSecondary,
                    fontWeight:
                        FontWeight
                            .w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                999,
              ),
              color:
                  _mint.withOpacity(
                0.10,
              ),
              border: Border.all(
                color:
                    _mint.withOpacity(
                  0.18,
                ),
              ),
            ),
            child: Row(
              children: [

                const Icon(
                  Icons.storage_rounded,
                  size: 16,
                  color: _mintDark,
                ),

                const SizedBox(
                  width: 8,
                ),

                Text(
                  '$_totalItems STOCKS',
                  style: GoogleFonts
                      .plusJakartaSans(
                    color:
                        _mintDark,
                    fontWeight:
                        FontWeight
                            .w800,
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
  // SUMMARY CARDS
  // =========================================================

  Widget _buildSummaryCards() {

    return LayoutBuilder(
      builder:
          (context, constraints) {

        final isMobile =
            constraints.maxWidth < 900;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [

            _summaryCard(
              title: 'Total Stock Item',
              value:
                  NumberFormat(
                '#,##0',
              ).format(
                _totalItems,
              ),
              icon:
                  Icons.inventory_2,
              color: _blue,
              width: isMobile
                  ? constraints.maxWidth
                  : (constraints.maxWidth / 4) - 12,
            ),

            _summaryCard(
              title:
                  'Total Quantity',
              value:
                  NumberFormat(
                '#,##0.##',
              ).format(
                _totalStockQty,
              ),
              icon:
                  Icons.scale,
              color: _mint,
              width: isMobile
                  ? constraints.maxWidth
                  : (constraints.maxWidth / 4) - 12,
            ),

            _summaryCard(
              title:
                  'Low Stock',
              value:
                  NumberFormat(
                '#,##0',
              ).format(
                _lowStocks,
              ),
              icon:
                  Icons.warning_amber,
              color: _orange,
              width: isMobile
                  ? constraints.maxWidth
                  : (constraints.maxWidth / 4) - 12,
            ),

            _summaryCard(
              title:
                  'Empty Stock',
              value:
                  NumberFormat(
                '#,##0',
              ).format(
                _emptyStocks,
              ),
              icon:
                  Icons.error_outline,
              color: _red,
              width: isMobile
                  ? constraints.maxWidth
                  : (constraints.maxWidth / 4) - 12,
            ),
          ],
        );
      },
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double width,
  }) {

    return Container(
      width: width,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          26,
        ),
        color: _panel,
        border: Border.all(
          color: _border,
        ),
      ),
      child: Row(
        children: [

          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
              color:
                  color.withOpacity(
                0.12,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [

                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style: GoogleFonts
                      .plusJakartaSans(
                    color:
                        _textMuted,
                    fontWeight:
                        FontWeight
                            .w700,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style: GoogleFonts
                      .plusJakartaSans(
                    color:
                        _textPrimary,
                    fontWeight:
                        FontWeight
                            .w800,
                    fontSize: 24,
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
  // DISTRIBUTION
  // =========================================================

  Widget _buildTypeDistribution() {

  final entries =
      _groupByType.entries.toList();

  entries.sort(
    (a, b) => b.value.compareTo(
      a.value,
    ),
  );

  return Container(
    padding:
        const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _panel,
      borderRadius:
          BorderRadius.circular(
        28,
      ),
      border: Border.all(
        color: _border,
      ),
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Text(
          'Stock Type Distribution',
          style: GoogleFonts
              .plusJakartaSans(
            color:
                _textPrimary,
            fontWeight:
                FontWeight.w800,
            fontSize: 16,
          ),
        ),

        const SizedBox(
          height: 20,
        ),

        if (entries.isEmpty)

          SizedBox(
            height: 120,
            child: Center(
              child: Text(
                'No distribution data.',
                style: GoogleFonts
                    .plusJakartaSans(
                  color:
                      _textSecondary,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          )

        else

          Scrollbar(
            controller:
                _horizontalController,
            thumbVisibility: true,
            child:
                SingleChildScrollView(
              controller:
                  _horizontalController,
              scrollDirection:
                  Axis.horizontal,
              child: Row(
                children: entries.map(
                  (entry) {

                    return Container(
                      width: 220,
                      margin:
                          const EdgeInsets.only(
                        right: 14,
                      ),
                      padding:
                          const EdgeInsets.all(
                        18,
                      ),
                      decoration:
                          BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(
                          24,
                        ),
                        gradient:
                            LinearGradient(
                          begin:
                              Alignment.topLeft,
                          end: Alignment
                              .bottomRight,
                          colors: [
                            _mint.withOpacity(
                              0.10,
                            ),
                            _teal.withOpacity(
                              0.05,
                            ),
                          ],
                        ),
                        border: Border.all(
                          color:
                              _border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [

                          Text(
                            entry.key,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style: GoogleFonts
                                .plusJakartaSans(
                              color:
                                  _textPrimary,
                              fontWeight:
                                  FontWeight
                                      .w800,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(
                            height: 18,
                          ),

                          Text(
                            '${entry.value}',
                            style: GoogleFonts
                                .plusJakartaSans(
                              color:
                                  _mintDark,
                              fontWeight:
                                  FontWeight
                                      .w800,
                              fontSize: 32,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            'Items',
                            style: GoogleFonts
                                .plusJakartaSans(
                              color:
                                  _textMuted,
                              fontWeight:
                                  FontWeight
                                      .w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
      ],
    ),
  );
}

  // =========================================================
  // CRITICAL STOCKS
  // =========================================================

  Widget _buildCriticalStocks() {

    return Container(
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        color: _panel,
        border: Border.all(
          color: _border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Text(
            'Critical Stock Monitoring',
            style: GoogleFonts
                .plusJakartaSans(
              color:
                  _textPrimary,
              fontWeight:
                  FontWeight.w800,
              fontSize: 16,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          if (_criticalStocks.isEmpty)

            Container(
              height: 120,
              alignment:
                  Alignment.center,
              child: Text(
                'No critical stock detected.',
                style: GoogleFonts
                    .plusJakartaSans(
                  color:
                      _textSecondary,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            )

          else

            Column(
              children:
                  _criticalStocks.map(
                (item) {

                  final isEmpty =
                      item.isEmpty;

                  return Container(
                    margin:
                        const EdgeInsets.only(
                      bottom: 12,
                    ),
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                      color: isEmpty
                          ? _red.withOpacity(
                              0.05,
                            )
                          : _orange.withOpacity(
                              0.05,
                            ),
                    ),
                    child: Row(
                      children: [

                        Icon(
                          isEmpty
                              ? Icons.error_outline
                              : Icons.warning_amber_rounded,
                          color: isEmpty
                              ? _red
                              : _orange,
                        ),

                        const SizedBox(
                          width: 14,
                        ),

                        Expanded(
                          child: Text(
                            item.stockName,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style: GoogleFonts
                                .plusJakartaSans(
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ).toList(),
            ),
        ],
      ),
    );
  }
}