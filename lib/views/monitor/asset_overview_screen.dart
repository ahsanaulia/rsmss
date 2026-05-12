import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/asset_overview_controller.dart';

import '../../widgets/asset_kpi_card.dart';
import '../../widgets/dashboard_error.dart';
import '../../widgets/dashboard_glass_card.dart';
import '../../widgets/dashboard_loading.dart';
import '../../widgets/dashboard_section_title.dart';

class AssetOverviewScreen extends StatefulWidget {
  const AssetOverviewScreen({super.key});

  @override
  State<AssetOverviewScreen> createState() =>
      _AssetOverviewScreenState();
}

class _AssetOverviewScreenState
    extends State<AssetOverviewScreen> {
        // =========================================================
  // LIGHT MINT HOSPITAL COLOR SYSTEM
  // =========================================================

  // BACKGROUND
  static const Color _bg1 =
      Color(0xFFF8FBFF);

  static const Color _bg2 =
      Color(0xFFEAF8F5);

  static const Color _bg3 =
      Color(0xFFDDF4EE);

  // PANEL
  static const Color _panel =
      Color(0xFFFFFFFF);

  static const Color _panel2 =
      Color(0xFFF7FCFA);

  // PRIMARY
  static const Color _mint =
      Color(0xFF10B981);

  static const Color _mintSoft =
      Color(0xFF6EE7B7);

  static const Color _mintDark =
      Color(0xFF047857);

  static const Color _teal =
      Color(0xFF14B8A6);

  // TEXT
  static const Color _textPrimary =
      Color(0xFF0F172A);

  static const Color _textSecondary =
      Color(0xFF334155);

  static const Color _textMuted =
      Color(0xFF64748B);

  // BORDER
  static const Color _border =
      Color(0xFFDCE7E3);

  // ALT ROW
  static const Color _rowAlt =
      Color(0xFFF1FAF6);
  late final AssetOverviewController _controller;

  final ScrollController _scrollController =
      ScrollController();

  @override
  void initState() {
    super.initState();

    _controller = AssetOverviewController();

    _controller.initialize();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final bool isUltraWide =
        size.width >= 1800;

    final bool isTablet =
        size.width < 1400;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FBFF),
            Color(0xFFEAF8F5),
            Color(0xFFDDF4EE),
          ],
        ),
      ),
      child: SafeArea(
        child:
            ValueListenableBuilder<
              AssetOverviewState
            >(
              valueListenable:
                  _controller,
              builder:
                  (_, state, __) {
                    // =====================================================
                    // LOADING
                    // =====================================================

                    if (state.isLoading &&
                        !state.hasData) {
                      return const Padding(
                        padding:
                            EdgeInsets.all(
                              24,
                            ),
                        child:
                            DashboardLoading(),
                      );
                    }

                    // =====================================================
                    // ERROR
                    // =====================================================

                    if (state.hasError &&
                        !state.hasData) {
                      return DashboardError(
                        title:
                            'Failed Loading Asset Intelligence',
                        message:
                            state
                                .errorMessage,
                        onRetry: () {
                          _controller
                              .loadDashboard();
                        },
                      );
                    }

                    final overview =
                        state
                            .overviewKpi;

                    final inspection =
                        state
                            .inspectionSummary;

                    final alert =
                        state
                            .alertSummary;

                    return FocusTraversalGroup(
                      policy:
                          OrderedTraversalPolicy(),
                      child:
                          RefreshIndicator(
                            onRefresh:
                                _controller
                                    .refresh,
                            child:
                                CustomScrollView(
                                  controller:
                                      _scrollController,
                                  physics:
                                      const BouncingScrollPhysics(),
                                  slivers: [
                                    // =================================================
                                    // HEADER
                                    // =================================================

                                    SliverPadding(
                                      padding:
                                          const EdgeInsets.fromLTRB(
                                            32,
                                            24,
                                            32,
                                            18,
                                          ),
                                      sliver:
                                          SliverToBoxAdapter(
                                            child:
                                                DashboardSectionTitle(
                                                  title:
                                                      'ASSET OVERVIEW',
                                                  subtitle:
                                                      'Enterprise Asset Monitoring Overview',
                                                  icon:
                                                      Icons.dashboard_customize,
                                                ),
                                          ),
                                    ),

                                    // =================================================
                                    // KPI GRID
                                    // =================================================

                                    SliverPadding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                            horizontal:
                                                32,
                                          ),
                                      sliver:
                                          SliverGrid(
                                            delegate:
                                                SliverChildListDelegate(
                                                  [
                                                    AssetKpiCard(
                                                      title:
                                                          'Total Aset',
                                                      value:
                                                          '${overview?.totalAssets ?? 0}',
                                                      icon:
                                                          Icons.inventory_2_rounded,
                                                      color:
                                                          Colors.lightBlueAccent,
                                                    ),

                                                    AssetKpiCard(
                                                      title:
                                                          'Aset Aktif',
                                                      value:
                                                          '${overview?.activeAssets ?? 0}',
                                                      icon:
                                                          Icons.check_circle,
                                                      color:
                                                          Colors.greenAccent,
                                                    ),

                                                    AssetKpiCard(
                                                      title:
                                                          'Aset Berbahaya',
                                                      value:
                                                          '${overview?.dangerousAssets ?? 0}',
                                                      icon:
                                                          Icons.warning_amber,
                                                      color:
                                                          Colors.orangeAccent,
                                                    ),

                                                    AssetKpiCard(
                                                      title:
                                                          'Aset Kondisi Kritis',
                                                      value:
                                                          '${overview?.criticalAssets ?? 0}',
                                                      icon:
                                                          Icons.error,
                                                      color:
                                                          Colors.redAccent,
                                                    ),

                                                    if (isUltraWide)
                                                      AssetKpiCard(
                                                        title:
                                                            'Inspeksi Hari Ini',
                                                        value:
                                                            '${inspection?.inspectionDueToday ?? 0}',
                                                        icon:
                                                            Icons.rule_folder,
                                                        color:
                                                            Colors.amberAccent,
                                                      ),
                                                  ],
                                                ),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount:
                                                      isUltraWide
                                                          ? 5
                                                          : isTablet
                                                          ? 2
                                                          : 4,
                                                  crossAxisSpacing:
                                                      18,
                                                  mainAxisSpacing:
                                                      18,
                                                  mainAxisExtent:
                                                      150,
                                                ),
                                          ),
                                    ),

                                    // =================================================
                                    // MAIN CONTENT
                                    // =================================================

                                    SliverPadding(
                                      padding:
                                          const EdgeInsets.fromLTRB(
                                            32,
                                            24,
                                            32,
                                            0,
                                          ),
                                      sliver:
                                          SliverToBoxAdapter(
                                            child:
                                                isTablet
                                                    ? Column(
                                                      children: [
                                                        _buildCategoryPanel(
                                                          state,
                                                        ),

                                                        const SizedBox(
                                                          height:
                                                              22,
                                                        ),

                                                        _buildHealthPanel(
                                                          state,
                                                        ),
                                                      ],
                                                    )
                                                    : Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          flex:
                                                              6,
                                                          child:
                                                              _buildCategoryPanel(
                                                                state,
                                                              ),
                                                        ),

                                                        const SizedBox(
                                                          width:
                                                              22,
                                                        ),

                                                        Expanded(
                                                          flex:
                                                              4,
                                                          child:
                                                              _buildHealthPanel(
                                                                state,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                          ),
                                    ),

                                    // =================================================
                                    // BOTTOM PANELS
                                    // =================================================

                                    SliverPadding(
                                      padding:
                                          const EdgeInsets.fromLTRB(
                                            32,
                                            24,
                                            32,
                                            0,
                                          ),
                                      sliver:
                                          SliverToBoxAdapter(
                                            child:
                                                isTablet
                                                    ? Column(
                                                      children: [
                                                        _buildInspectionPanel(
                                                          inspection,
                                                        ),

                                                        const SizedBox(
                                                          height:
                                                              22,
                                                        ),

                                                        _buildAlertPanel(
                                                          alert,
                                                        ),
                                                      ],
                                                    )
                                                    : Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          child:
                                                              _buildInspectionPanel(
                                                                inspection,
                                                              ),
                                                        ),

                                                        const SizedBox(
                                                          width:
                                                              22,
                                                        ),

                                                        Expanded(
                                                          child:
                                                              _buildAlertPanel(
                                                                alert,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                          ),
                                    ),

                                    // =================================================
                                    // FOOTER
                                    // =================================================

                                    SliverPadding(
                                      padding:
                                          const EdgeInsets.fromLTRB(
                                            32,
                                            24,
                                            32,
                                            40,
                                          ),
                                      sliver:
                                          SliverToBoxAdapter(
                                            child:
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                    state.lastUpdated ==
                                                            null
                                                        ? 'No update'
                                                        : 'Last Updated : ${state.lastUpdated}',
                                                    style:
                                                        GoogleFonts.plusJakartaSans(
                                                          color:
                                                              _textMuted.withOpacity(
                                                                0.95,
                                                              ),
                                                          fontSize:
                                                              11,
                                                        ),
                                                  ),
                                                ),
                                          ),
                                    ),
                                  ],
                                ),
                          ),
                    );
                  },
            ),
      ),
    );
  }

  Widget _buildCategoryPanel(
    AssetOverviewState state,
  ) {
    return DashboardGlassCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const DashboardSectionTitle(
            title:
                'Distribusi Kategori Aset',
            subtitle:
                'Hospital asset taxonomy overview',
            icon:
                Icons.account_tree,
          ),

          const SizedBox(height: 12),

          ...state.categorySummary.map((
            category,
          ) {
            return Padding(
              padding:
                  const EdgeInsets.only(
                    bottom: 14,
                  ),
              child: _buildCategoryTile(
                title:
                    category.categoryName,
                total:
                    category.totalAssets,
                active:
                    category.activeAssets,
                good:
                    category.goodAssets,
                maintenance:
                    category
                        .maintenanceAssets,
                damaged:
                    category
                        .damagedAssets,
                critical:
                    category
                        .criticalAssets,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHealthPanel(
    AssetOverviewState state,
  ) {
    return DashboardGlassCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const DashboardSectionTitle(
            title:
                'Ringkasan Kondisi Aset',
            subtitle:
                'Condition monitoring status',
            icon:
                Icons.monitor_heart,
          ),

          const SizedBox(height: 10),

          ...state.healthSummary.map((
            health,
          ) {
            return Padding(
              padding:
                  const EdgeInsets.only(
                    bottom: 14,
                  ),
              child: _buildHealthTile(
                status:
                    health
                        .statusCondition,
                total:
                    health.totalAssets,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInspectionPanel(
    inspection,
  ) {
    return DashboardGlassCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const DashboardSectionTitle(
            title:
                'Ringkasan Inspeksi',
            subtitle:
                'Jadwal pemeliharaan dan inspeksi',
            icon:
                Icons.fact_check,
          ),

          const SizedBox(height: 20),

          _buildInfoRow(
            'Inspeksi Terlambat',
            '${inspection?.overdueInspectionAssets ?? 0}',
            Colors.redAccent,
          ),

          _buildInfoRow(
            'Inspeksi Hari Ini',
            '${inspection?.inspectionDueToday ?? 0}',
            Colors.orangeAccent,
          ),

          _buildInfoRow(
            'Inspeksi Minggu Ini',
            '${inspection?.inspectionDueThisWeek ?? 0}',
            Colors.amberAccent,
          ),

          _buildInfoRow(
            'Belum Pernah Diinspeksi',
            '${inspection?.neverInspectedAssets ?? 0}',
            Colors.blueGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertPanel(alert) {
    return DashboardGlassCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const DashboardSectionTitle(
            title:
                'Panel Alert Kritis',
            subtitle:
                'Alert operasional real-time',
            icon:
                Icons.notification_important,
          ),

          const SizedBox(height: 20),

          _buildAlertRow(
            'Aset State Berbahaya',
            '${alert?.dangerousAssets ?? 0}',
            Colors.redAccent,
          ),

          _buildAlertRow(
            'Kontaminasi Kritis',
            '${alert?.criticalContaminationAssets ?? 0}',
            Colors.orangeAccent,
          ),

          _buildAlertRow(
            'Kondisi Kritis',
            '${alert?.criticalConditionAssets ?? 0}',
            Colors.deepOrangeAccent,
          ),

          _buildAlertRow(
            'Aset Rusak',
            '${alert?.damagedAssets ?? 0}',
            Colors.amberAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile({
    required String title,
    required int total,
    required int active,
    required int good,
    required int maintenance,
    required int damaged,
    required int critical,
  }) {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: _border,
        ),
        boxShadow: [
          BoxShadow(
            color: _mint.withOpacity(
              0.06,
            ),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style:
                      GoogleFonts.plusJakartaSans(
                        color:
                            _textPrimary,
                        fontWeight:
                            FontWeight.w700,
                        fontSize: 14,
                      ),
                ),
              ),

              Text(
                '$total Assets',
                style:
                    GoogleFonts.plusJakartaSans(
                      color:
                          _textMuted,
                      fontSize: 12,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _miniIndicator(
                'Good',
                good,
                Colors.green,
              ),

              _miniIndicator(
                'Maint.',
                maintenance,
                Colors.orange,
              ),

              _miniIndicator(
                'Damaged',
                damaged,
                Colors.red,
              ),

              _miniIndicator(
                'Critical',
                critical,
                Colors.deepOrange,
              ),
            ],
          ),

          const SizedBox(height: 12),

          LinearProgressIndicator(
            value:
                total == 0
                    ? 0
                    : active / total,
            minHeight: 8,
            borderRadius:
                BorderRadius.circular(
                  30,
                ),
            backgroundColor:
                _border.withOpacity(0.9),
            valueColor:
                const AlwaysStoppedAnimation(
                  Color(0xFF10B981),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTile({
    required String status,
    required int total,
  }) {
    Color color = Colors.blueGrey;

    switch (
      status.toLowerCase()
    ) {
      case 'good':
        color = Colors.green;
        break;

      case 'maintenance':
        color = Colors.orange;
        break;

      case 'damaged':
        color = Colors.red;
        break;

      case 'critical':
        color = Colors.deepOrange;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(
        14,
      ),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              status,
              style:
                  GoogleFonts.plusJakartaSans(
                    color:
                        _textPrimary,
                    fontWeight:
                        FontWeight.w600,
                  ),
            ),
          ),

          Text(
            '$total',
            style:
                GoogleFonts.plusJakartaSans(
                  color:
                      _textPrimary,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 20,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertRow(
    String title,
    String value,
    Color color,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
            bottom: 16,
          ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style:
                  GoogleFonts.plusJakartaSans(
                    color:
                        _textPrimary,
                    fontSize: 13,
                  ),
            ),
          ),

          Text(
            value,
            style:
                GoogleFonts.plusJakartaSans(
                  color:
                      _textPrimary,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 20,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String title,
    String value,
    Color color,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
            bottom: 16,
          ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 12,
            color: color,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style:
                  GoogleFonts.plusJakartaSans(
                    color:
                        _textPrimary,
                    fontSize: 13,
                  ),
            ),
          ),

          Text(
            value,
            style:
                GoogleFonts.plusJakartaSans(
                  color:
                      _textPrimary,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 20,
                ),
          ),
        ],
      ),
    );
  }

  Widget _miniIndicator(
    String title,
    int value,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '$value',
            style:
                GoogleFonts.plusJakartaSans(
                  color:
                      _textPrimary,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 13,
                ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            style:
                GoogleFonts.plusJakartaSans(
                  color: _textMuted,
                  fontSize: 9,
                ),
          ),
        ],
      ),
    );
  }
}