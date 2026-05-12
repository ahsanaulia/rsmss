// File: lib/views/monitor/asset_report_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../../models/asset_report_mode.dart';
import '../../models/asset_report_row_model.dart';
import '../../models/asset_repository.dart';
import '../../models/v_asset_master_complete.dart';

import '../../services/asset_excel_export_service.dart';
import '../../services/asset_pdf_export_service.dart';
import '../../services/asset_report_builder_service.dart';

class AssetReportScreen extends StatefulWidget {
  const AssetReportScreen({super.key});

  @override
  State<AssetReportScreen> createState() => _AssetReportScreenState();
}

class _AssetReportScreenState extends State<AssetReportScreen> {
  final AssetRepository _repository = AssetRepository();

  final AssetReportBuilderService _builder =
      AssetReportBuilderService();

  final AssetPdfExportService _pdfExporter =
      AssetPdfExportService();

  final AssetExcelExportService _excelExporter =
      AssetExcelExportService();

  final ScrollController _pageController =
      ScrollController();

  final ScrollController _horizontalController =
      ScrollController();

  final ScrollController _horizontalTopController =
      ScrollController();

  final ScrollController _verticalController =
      ScrollController();

  bool _isLoading = true;
  bool _isExporting = false;

  List<AssetMasterModel> _assets = [];

  AssetReportMode _mode = AssetReportMode.asset;

  // =========================================================
  // COLORS - CLEAN MINT READABLE UI
  // =========================================================

  static const Color _bg1 =
      Color(0xFFF3FFFC);

  static const Color _bg2 =
      Color(0xFFE8FFF8);

  static const Color _bg3 =
      Color(0xFFD8F8EF);

  static const Color _panel =
      Color(0xFFFFFFFF);

  static const Color _panel2 =
      Color(0xFFF8FFFD);

  static const Color _mint =
      Color(0xFF10B981);

  static const Color _mintSoft =
      Color(0xFF6EE7B7);

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
      Color(0xFFF4FFFB);

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

    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _repository.getAssets();

      if (!mounted) return;

      setState(() {
        _assets = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showSnackBar(
        'Gagal memuat data asset.',
      );
    }
  }

  List<AssetReportRowModel> get _rows {
    return _builder.build(
      assets: _assets,
      mode: _mode,
    );
  }

  double get _tableWidth {
    switch (_mode) {
      case AssetReportMode.asset:
        return 980;

      case AssetReportMode.category:
        return 760;

      case AssetReportMode.subCategory:
        return 1020;

      case AssetReportMode.type:
        return 1280;

      case AssetReportMode.condition:
        return 700;

      case AssetReportMode.contamination:
        return 820;

      case AssetReportMode.dangerous:
        return 800;

      case AssetReportMode.assignment:
        return 760;
    }
  }

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
              controller: _pageController,
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
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(
                    minHeight:
                        MediaQuery.of(
                                  context,
                                ).size.height -
                            32,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),

                      const SizedBox(
                        height: 14,
                      ),

                      _buildExportBar(),

                      const SizedBox(
                        height: 14,
                      ),

                      _buildModeSelector(),

                      const SizedBox(
                        height: 14,
                      ),

                      _buildTopHorizontalScrollbar(),

                      const SizedBox(
                        height: 10,
                      ),

                      SizedBox(
                        height:
                            MediaQuery.of(
                                      context,
                                    )
                                    .size
                                    .height *
                                0.68,
                        child: _isLoading
                            ? const Center(
                                child:
                                    CircularProgressIndicator(
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
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(28),

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
            offset: const Offset(
              0,
              10,
            ),
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
                end: Alignment
                    .bottomRight,
                colors: [
                  Color(0xFF34D399),
                  Color(0xFF10B981),
                  Color(0xFF059669),
                ],
              ),
            ),
            child: const Icon(
              Icons.analytics_rounded,
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
                  'ASSET REPORT CENTER',
                  style: GoogleFonts
                      .plusJakartaSans(
                    color:
                        _textPrimary,
                    fontWeight:
                        FontWeight
                            .w800,
                    fontSize: 20,
                    letterSpacing:
                        0.4,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  'Hospital Asset Intelligence Reporting',
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
                  Icons.table_rows,
                  size: 16,
                  color: _mintDark,
                ),

                const SizedBox(
                  width: 8,
                ),

                Text(
                  '${_rows.length} ROWS',
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
  // EXPORT BAR
  // =========================================================

  Widget _buildExportBar() {
    return Container(
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(24),
        color: _panel,
        border: Border.all(
          color: _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(
              0.03,
            ),
            blurRadius: 18,
            offset:
                const Offset(0, 8),
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
                  decoration:
                      BoxDecoration(
                    color: _mint,
                    shape:
                        BoxShape.circle,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    'Export report sesuai mode aktif.',
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
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          _exportButton(
            label: 'PDF',
            icon:
                Icons.picture_as_pdf,
            color:
                const Color(
              0xFFEF4444,
            ),
            onPressed:
                _isExporting
                    ? null
                    : _exportPdf,
          ),

          const SizedBox(width: 10),

          _exportButton(
            label: 'XLSX',
            icon: Icons
                .table_chart_outlined,
            color:
                const Color(
              0xFF10B981,
            ),
            onPressed:
                _isExporting
                    ? null
                    : _exportExcel,
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
      child:
          ElevatedButton.icon(
        onPressed: onPressed,
        icon: _isExporting
            ? const SizedBox(
                width: 16,
                height: 16,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color:
                      Colors.white,
                ),
              )
            : Icon(
                icon,
                size: 18,
              ),
        label: Text(label),
        style:
            ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              color,
          foregroundColor:
              Colors.white,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              999,
            ),
          ),
          textStyle: GoogleFonts
              .plusJakartaSans(
            fontWeight:
                FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // TOP HORIZONTAL SCROLLBAR
  // =========================================================

  Widget _buildTopHorizontalScrollbar() {
    return SizedBox(
      height: 18,
      child: Scrollbar(
        controller:
            _horizontalTopController,
        thumbVisibility: true,
        radius:
            const Radius.circular(
          999,
        ),
        notificationPredicate:
            (_) => true,
        child:
            SingleChildScrollView(
          controller:
              _horizontalTopController,
          scrollDirection:
              Axis.horizontal,
          child: SizedBox(
            width: _tableWidth,
            height: 1,
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
      _showSnackBar(
        'Tidak ada data untuk diexport.',
      );

      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final bytes =
          await _pdfExporter.generate(
        rows: _rows,
        mode: _mode,
        hospitalName:
            'RS MODERN DIGITAL',
      );

      final filename =
          'asset_report_${_mode.name}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      await Printing.sharePdf(
        bytes: bytes,
        filename: filename,
      );

      _showSnackBar(
        'PDF siap diexport.',
      );
    } catch (e) {
      _showSnackBar(
        'Gagal export PDF: $e',
      );
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
      _showSnackBar(
        'Tidak ada data untuk diexport.',
      );

      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final excel =
          _excelExporter.generate(
        rows: _rows,
        mode: _mode,
      );

      final bytes = excel.encode();

      if (bytes == null) {
        throw Exception(
          'Gagal encode Excel.',
        );
      }

      final dir =
          await getApplicationDocumentsDirectory();

      final filename =
          'asset_report_${_mode.name}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';

      final file = File(
        '${dir.path}/$filename',
      );

      await file.writeAsBytes(
        bytes,
        flush: true,
      );

      _showSnackBar(
        'Excel tersimpan: ${file.path}',
      );
    } catch (e) {
      _showSnackBar(
        'Gagal export Excel: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  void _showSnackBar(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            _textPrimary,
        behavior:
            SnackBarBehavior
                .floating,
      ),
    );
  }

  // =========================================================
  // MODE SELECTOR
  // =========================================================

  Widget _buildModeSelector() {
    final modes =
        AssetReportMode.values;

    return SizedBox(
      height: 46,
      child:
          ListView.separated(
        scrollDirection:
            Axis.horizontal,
        itemCount: modes.length,
        separatorBuilder:
            (_, __) =>
                const SizedBox(
          width: 10,
        ),
        itemBuilder:
            (context, index) {
          final mode =
              modes[index];

          final active =
              _mode == mode;

          return GestureDetector(
            onTap: () {
              setState(() {
                _mode = mode;
              });
            },
            child:
                AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 180,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              alignment:
                  Alignment.center,
              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  999,
                ),

                gradient: active
                    ? const LinearGradient(
                        begin:
                            Alignment.topLeft,
                        end: Alignment
                            .bottomRight,
                        colors: [
                          Color(
                            0xFF34D399,
                          ),
                          Color(
                            0xFF10B981,
                          ),
                        ],
                      )
                    : null,

                color: active
                    ? null
                    : Colors.white,

                border: Border.all(
                  color: active
                      ? Colors
                          .transparent
                      : _border,
                ),

                boxShadow: active
                    ? [
                        BoxShadow(
                          color: _mint
                              .withOpacity(
                            0.25,
                          ),
                          blurRadius:
                              16,
                          offset:
                              const Offset(
                            0,
                            6,
                          ),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                _modeText(mode),
                style: GoogleFonts
                    .plusJakartaSans(
                  color: active
                      ? Colors.white
                      : _textSecondary,
                  fontWeight:
                      FontWeight
                          .w800,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // TABLE
  // =========================================================

  Widget _buildTable() {
    final rows = _rows;

    if (rows.isEmpty) {
      return Container(
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
        child: Center(
          child: Text(
            'No assets found',
            style: GoogleFonts
                .plusJakartaSans(
              color:
                  _textSecondary,
              fontWeight:
                  FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(28),
        color: _panel,
        border: Border.all(
          color: _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(
              0.04,
            ),
            blurRadius: 24,
            offset:
                const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        child: LayoutBuilder(
          builder:
              (context, constraints) {
            return Scrollbar(
              controller:
                  _horizontalController,
              thumbVisibility:
                  true,
              radius:
                  const Radius
                      .circular(
                999,
              ),
              child:
                  SingleChildScrollView(
                controller:
                    _horizontalController,
                scrollDirection:
                    Axis.horizontal,
                child: SizedBox(
                  width:
                      _tableWidth,
                  height: constraints
                      .maxHeight,
                  child: Column(
                    children: [
                      _buildHeaderRow(),

                      Expanded(
                        child:
                            Scrollbar(
                          controller:
                              _verticalController,
                          thumbVisibility:
                              true,
                          radius:
                              const Radius.circular(
                            999,
                          ),
                          child:
                              ListView.builder(
                            controller:
                                _verticalController,
                            itemCount:
                                rows.length,
                            itemBuilder:
                                (
                              context,
                              index,
                            ) {
                              return _buildRow(
                                rows[
                                    index],
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
      height: 54,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      decoration: BoxDecoration(
        gradient:
            LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            _mint.withOpacity(
              0.10,
            ),
            _teal.withOpacity(
              0.08,
            ),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: _border,
          ),
        ),
      ),
      child: Row(
        children:
            _buildColumns(),
      ),
    );
  }

  Widget _buildRow(
    AssetReportRowModel row,
    int index,
  ) {
    return Container(
      height: 56,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      decoration: BoxDecoration(
        color: index.isEven
            ? _rowAlt
            : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: _border
                .withOpacity(
              0.7,
            ),
          ),
        ),
      ),
      child: Row(
        children:
            _buildCells(row),
      ),
    );
  }

  // =========================================================
  // COLUMNS
  // =========================================================

  List<Widget> _buildColumns() {
    final style =
        GoogleFonts.plusJakartaSans(
      color: _mintDark,
      fontWeight:
          FontWeight.w800,
      fontSize: 11,
    );

    final columns = <Widget>[];

    void add(
      String title,
      double width,
    ) {
      columns.add(
        SizedBox(
          width: width,
          child: Text(
            title,
            maxLines: 1,
            overflow:
                TextOverflow
                    .ellipsis,
            style: style,
          ),
        ),
      );
    }

    add('No', 60);

    add('Golongan', 180);

    switch (_mode) {
      case AssetReportMode.asset:
        add(
          'Nama Barang',
          280,
        );

        add(
          'Penanggung Jawab',
          260,
        );
        break;

      case AssetReportMode.category:
        add(
          'Category',
          220,
        );

        add('Jumlah', 120);
        break;

      case AssetReportMode.subCategory:
        add(
          'Category',
          220,
        );

        add(
          'Sub Category',
          240,
        );

        add('Jumlah', 120);
        break;

      case AssetReportMode.type:
        add(
          'Category',
          220,
        );

        add(
          'Sub Category',
          220,
        );

        add('Type', 240);

        add('Jumlah', 120);
        break;

      case AssetReportMode.condition:
        add(
          'Condition',
          240,
        );

        add('Jumlah', 120);
        break;

      case AssetReportMode.contamination:
        add(
          'Nama Barang',
          280,
        );

        add(
          'Contamination',
          160,
        );
        break;

      case AssetReportMode.dangerous:
        add(
          'Nama Barang',
          280,
        );

        add(
          'Dangerous',
          140,
        );
        break;

      case AssetReportMode.assignment:
        add(
          'PIC Asset',
          260,
        );

        add('Jumlah', 120);
        break;
    }

    return columns;
  }

  // =========================================================
  // CELLS
  // =========================================================

  List<Widget> _buildCells(
    AssetReportRowModel row,
  ) {
    final style =
        GoogleFonts.plusJakartaSans(
      color: _textPrimary,
      fontWeight:
          FontWeight.w600,
      fontSize: 11,
    );

    final cells = <Widget>[];

    void add(
      String text,
      double width,
    ) {
      cells.add(
        SizedBox(
          width: width,
          child: Text(
            text,
            maxLines: 1,
            overflow:
                TextOverflow
                    .ellipsis,
            style: style,
          ),
        ),
      );
    }

    add(
      row.no.toString(),
      60,
    );

    add(
      row.rfidTagId,
      180,
    );

    switch (_mode) {
      case AssetReportMode.asset:
        add(
          row.assetName,
          280,
        );

        add(
          row.assignmentName ??
              '-',
          260,
        );
        break;

      case AssetReportMode.category:
        add(
          row.categoryName ??
              '-',
          220,
        );

        add(
          row.total.toString(),
          120,
        );
        break;

      case AssetReportMode.subCategory:
        add(
          row.categoryName ??
              '-',
          220,
        );

        add(
          row.subCategoryName ??
              '-',
          240,
        );

        add(
          row.total.toString(),
          120,
        );
        break;

      case AssetReportMode.type:
        add(
          row.categoryName ??
              '-',
          220,
        );

        add(
          row.subCategoryName ??
              '-',
          220,
        );

        add(
          row.typeName ??
              '-',
          240,
        );

        add(
          row.total.toString(),
          120,
        );
        break;

      case AssetReportMode.condition:
        add(
          row.condition ??
              '-',
          240,
        );

        add(
          row.total.toString(),
          120,
        );
        break;

      case AssetReportMode.contamination:
        add(
          row.assetName,
          280,
        );

        add(
          row.contaminationLevel
                  ?.toString() ??
              '-',
          160,
        );
        break;

      case AssetReportMode.dangerous:
        add(
          row.assetName,
          280,
        );

        add(
          row.isDangerous
              ? 'YES'
              : 'NO',
          140,
        );
        break;

      case AssetReportMode.assignment:
        add(
          row.assignmentName ??
              '-',
          260,
        );

        add(
          row.total.toString(),
          120,
        );
        break;
    }

    return cells;
  }

  // =========================================================
  // MODE TEXT
  // =========================================================

  String _modeText(
    AssetReportMode mode,
  ) {
    switch (mode) {
      case AssetReportMode.asset:
        return 'ASSET';

      case AssetReportMode.category:
        return 'CATEGORY';

      case AssetReportMode.subCategory:
        return 'SUB CATEGORY';

      case AssetReportMode.type:
        return 'TYPE';

      case AssetReportMode.condition:
        return 'CONDITION';

      case AssetReportMode.contamination:
        return 'CONTAMINATION';

      case AssetReportMode.dangerous:
        return 'DANGEROUS';

      case AssetReportMode.assignment:
        return 'ASSIGNMENT';
    }
  }
}