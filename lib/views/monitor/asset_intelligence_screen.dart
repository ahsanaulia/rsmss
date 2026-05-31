// File: lib/insights/assets/views/asset_intelligence_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/v_asset_master_complete.dart';
import '../../models/asset_repository.dart';

class AssetIntelligenceScreen extends StatefulWidget {
  const AssetIntelligenceScreen({super.key});

  @override
  State<AssetIntelligenceScreen> createState() => _AssetIntelligenceScreenState();
}

class _AssetIntelligenceScreenState extends State<AssetIntelligenceScreen> {
  final AssetRepository _repository = AssetRepository();
  final TextEditingController _searchController = TextEditingController();

  final ScrollController _verticalTableController = ScrollController();
  final ScrollController _horizontalTableController = ScrollController();

  bool _isLoading = true;
  String? _errorMessage;

  List<AssetMasterModel> _assets = [];
  AssetMasterModel? selectedAsset;

  String selectedGroup = 'ALL';

  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedType;
  String? selectedCondition;

  final List<String> groupFilters = const [
    'ALL',
    'CATEGORY',
    'SUBCATEGORY',
    'TYPE',
    'CONDITION',
  ];

  // ============================================================
  // HOIP 5.0 COLOR PALETTE (BIRU TUA + GLASSMORPHISM)
  // ============================================================
  static const Color _primaryBlue = Color(0xFF052D9C);
  static const Color _primaryLightBlue = Color(0xFF1E3A8A);
  static const Color _accentGreen = Color(0xFF10B981);
  static const Color _accentOrange = Color(0xFFF59E0B);
  static const Color _accentPurple = Color(0xFF8B5CF6);
  static const Color _dangerRed = Color(0xFFEF4444);
  static const Color _warningYellow = Color(0xFFEAB308);
  static const Color _infoBlue = Color(0xFF3B82F6);
  static const Color _infoCyan = Color(0xFF06B6D4);

  // Glassmorphism gradients (BIRU THEME)
  static const LinearGradient _backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF052D9C),
      Color(0xFF1E3A8A),
    ],
  );

  static const LinearGradient _headerGradient = LinearGradient(
    colors: [
      Color(0xFF1E3A8A),
      Color(0xFF2E4A8E),
    ],
  );

  static const LinearGradient _iconGradient = LinearGradient(
    colors: [
      _infoBlue,
      _infoCyan,
    ],
  );

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _verticalTableController.dispose();
    _horizontalTableController.dispose();
    super.dispose();
  }

  Future<void> _loadAssets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _repository.getAssets();
      if (!mounted) return;

      setState(() {
        _assets = data;
        selectedAsset = data.isNotEmpty ? data.first : null;
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

  void _clearTaxonomySelections() {
    selectedCategory = null;
    selectedSubCategory = null;
    selectedType = null;
    selectedCondition = null;
  }

  bool _sameText(String? a, String? b) {
    return (a ?? '').trim().toLowerCase() == (b ?? '').trim().toLowerCase();
  }

  List<String> _uniqueSortedValues(Iterable<String?> values) {
    final map = <String, String>{};

    for (final raw in values) {
      final value = raw?.trim();
      if (value == null || value.isEmpty) continue;

      map.putIfAbsent(value.toLowerCase(), () => value);
    }

    final result = map.values.toList();
    result.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return result;
  }

  List<String> get availableCategories {
    return _uniqueSortedValues(_assets.map((e) => e.categoryName));
  }

  List<String> get availableSubCategories {
    if (selectedGroup == 'CATEGORY' && selectedCategory != null) {
      return _uniqueSortedValues(
        _assets
            .where((e) => _sameText(e.categoryName, selectedCategory))
            .map((e) => e.subCategoryName),
      );
    }
    return _uniqueSortedValues(_assets.map((e) => e.subCategoryName));
  }

  List<String> get availableTypes {
    if (selectedGroup == 'CATEGORY' && selectedCategory != null) {
      return _uniqueSortedValues(
        _assets
            .where((e) => _sameText(e.categoryName, selectedCategory))
            .map((e) => e.typeName),
      );
    }
    if (selectedGroup == 'SUBCATEGORY' && selectedSubCategory != null) {
      return _uniqueSortedValues(
        _assets
            .where((e) => _sameText(e.subCategoryName, selectedSubCategory))
            .map((e) => e.typeName),
      );
    }
    return _uniqueSortedValues(_assets.map((e) => e.typeName));
  }

  List<String> get availableConditions {
    return _uniqueSortedValues(_assets.map((e) => e.statusCondition));
  }

  List<AssetMasterModel> get filteredAssets {
    final q = _searchController.text.trim().toLowerCase();

    return _assets.where((e) {
      final matchesSearch = e.assetName.toLowerCase().contains(q) ||
          e.rfidTagId.toLowerCase().contains(q) ||
          (e.categoryName ?? '').toLowerCase().contains(q) ||
          (e.subCategoryName ?? '').toLowerCase().contains(q) ||
          (e.typeName ?? '').toLowerCase().contains(q) ||
          (e.statusCondition ?? '').toLowerCase().contains(q) ||
          (e.roomName ?? '').toLowerCase().contains(q) ||
          (e.lastMovementStatus ?? '').toLowerCase().contains(q) ||
          (e.lastUsedByName ?? '').toLowerCase().contains(q) ||
          (e.assignedProfileName ?? '').toLowerCase().contains(q);

      if (!matchesSearch) return false;

      switch (selectedGroup) {
        case 'CATEGORY':
          if (selectedCategory != null && !_sameText(e.categoryName, selectedCategory)) return false;
          break;
        case 'SUBCATEGORY':
          if (selectedSubCategory != null && !_sameText(e.subCategoryName, selectedSubCategory)) return false;
          break;
        case 'TYPE':
          if (selectedType != null && !_sameText(e.typeName, selectedType)) return false;
          break;
        case 'CONDITION':
          if (selectedCondition != null && !_sameText(e.statusCondition, selectedCondition)) return false;
          break;
      }
      return true;
    }).toList();
  }

  List<AssetMasterModel> get displayAssets {
    final items = List<AssetMasterModel>.from(filteredAssets);
    items.sort((a, b) => a.assetName.toLowerCase().compareTo(b.assetName.toLowerCase()));
    return items;
  }

  AssetMasterModel? get _activeAsset {
    final current = selectedAsset;
    if (current == null) return null;
    for (final asset in filteredAssets) {
      if (asset.id == current.id) return current;
    }
    return null;
  }

  int get _visibleTotal => filteredAssets.length;
  int get _visibleCritical => filteredAssets.where((e) => (e.statusCondition ?? '').toLowerCase() == 'critical').length;
  int get _visibleDangerous => filteredAssets.where((e) => e.isDangerous == true).length;
  int get _visibleOverdue => filteredAssets.where((e) {
        final next = e.nextInspectionAt;
        return next != null && next.isBefore(DateTime.now());
      }).length;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;

    final bool isCompactLandscape = size.height < 720 && size.width < 1100;
    final bool useScrollablePageLayout = size.width < 900 || size.height < 800;
    final bool isSmallWidth = size.width < 1100;

    final double bodyHeight = useScrollablePageLayout
        ? (size.height * 0.50).clamp(320.0, 520.0).toDouble()
        : (size.height * 0.62).clamp(420.0, 760.0).toDouble();

    final double innerWidth = isSmallWidth ? (isCompactLandscape ? 1280 : 1400) : size.width;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(gradient: _backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isCompactLandscape ? 8 : 12),
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : useScrollablePageLayout
                        ? _buildMobileScrollLayout(
                            compact: isCompactLandscape,
                            bodyHeight: bodyHeight,
                            forceHorizontalScroll: isSmallWidth,
                            innerWidth: innerWidth,
                          )
                        : _buildDesktopLayout(
                            compact: isCompactLandscape,
                            bodyHeight: bodyHeight,
                            forceHorizontalScroll: isSmallWidth,
                            innerWidth: innerWidth,
                          ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GLASSMORPHISM STYLED WIDGETS (BIRU THEME)
  // ============================================================

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
            const SizedBox(height: 14),
            Text('Loading assets...', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        decoration: _glassDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: _dangerRed, size: 48),
            const SizedBox(height: 12),
            Text('Failed to load asset data', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(_errorMessage ?? 'Unknown error', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAssets,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: _accentGreen, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileScrollLayout({required bool compact, required double bodyHeight, required bool forceHorizontalScroll, required double innerWidth}) {
    return LayoutBuilder(
      builder: (context, box) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight),
            child: Padding(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(compact: compact),
                  SizedBox(height: compact ? 8 : 10),
                  _buildToolbar(compact: compact),
                  SizedBox(height: compact ? 8 : 10),
                  _buildStatsRow(compact: compact),
                  SizedBox(height: compact ? 8 : 10),
                  SizedBox(height: bodyHeight, child: _buildBodyArea(compact: compact, forceHorizontalScroll: forceHorizontalScroll, innerWidth: innerWidth)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout({required bool compact, required double bodyHeight, required bool forceHorizontalScroll, required double innerWidth}) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildHeader(compact: compact),
        SizedBox(height: compact ? 8 : 10),
        _buildToolbar(compact: compact),
        SizedBox(height: compact ? 8 : 10),
        _buildStatsRow(compact: compact),
        SizedBox(height: compact ? 8 : 10),
        Expanded(child: _buildBodyArea(compact: compact, forceHorizontalScroll: forceHorizontalScroll, innerWidth: innerWidth)),
      ],
    );
  }

  Widget _buildHeader({required bool compact}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 16, vertical: compact ? 12 : 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: _headerGradient,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(compact ? 10 : 12),
            decoration: BoxDecoration(gradient: _iconGradient, borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.memory, color: Colors.white, size: compact ? 18 : 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ASSET INTELLIGENCE', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: Colors.white, fontSize: compact ? 16 : 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('Hospital Asset Monitoring Center', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: Colors.white70, fontSize: compact ? 10 : 11)),
              ],
            ),
          ),
          _buildGlassChip('LIVE AUDIT MODE', compact: compact),
        ],
      ),
    );
  }

  Widget _buildGlassChip(String text, {required bool compact}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 6 : 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(text, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: compact ? 10 : 11)),
    );
  }

  Widget _buildToolbar({required bool compact}) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: _glassDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSearchField(compact: compact),
          SizedBox(height: compact ? 10 : 12),
          _buildGroupFilterChips(compact: compact),
          if (selectedGroup != 'ALL') ...[
            SizedBox(height: compact ? 10 : 12),
            _buildTaxonomyFilters(compact: compact),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField({required bool compact}) {
    return SizedBox(
      height: compact ? 42 : 46,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() => selectedAsset = null),
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search Asset / Nomenklatur / Category',
          hintStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _accentGreen, width: 1.2)),
          prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
        ),
      ),
    );
  }

  Widget _buildGroupFilterChips({required bool compact}) {
    return SizedBox(
      height: compact ? 36 : 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: groupFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final group = groupFilters[index];
          final selected = selectedGroup == group;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedGroup = group;
                _clearTaxonomySelections();
                selectedAsset = null;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? _accentGreen : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: selected ? _accentGreen : Colors.white.withValues(alpha: 0.2)),
              ),
              child: Text(group, style: GoogleFonts.poppins(color: selected ? Colors.white : Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaxonomyFilters({required bool compact}) {
    List<String> items = [];
    switch (selectedGroup) {
      case 'CATEGORY':
        items = availableCategories;
        break;
      case 'SUBCATEGORY':
        items = availableSubCategories;
        break;
      case 'TYPE':
        items = availableTypes;
        break;
      case 'CONDITION':
        items = availableConditions;
        break;
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: compact ? 36 : 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final value = items[index];
          final selected = switch (selectedGroup) {
            'CATEGORY' => _sameText(selectedCategory, value),
            'SUBCATEGORY' => _sameText(selectedSubCategory, value),
            'TYPE' => _sameText(selectedType, value),
            'CONDITION' => _sameText(selectedCondition, value),
            _ => false,
          };
          return GestureDetector(
            onTap: () {
              setState(() {
                switch (selectedGroup) {
                  case 'CATEGORY':
                    selectedCategory = selectedCategory != null && _sameText(selectedCategory, value) ? null : value;
                    selectedSubCategory = null;
                    selectedType = null;
                    selectedCondition = null;
                    break;
                  case 'SUBCATEGORY':
                    selectedSubCategory = selectedSubCategory != null && _sameText(selectedSubCategory, value) ? null : value;
                    selectedType = null;
                    selectedCondition = null;
                    break;
                  case 'TYPE':
                    selectedType = selectedType != null && _sameText(selectedType, value) ? null : value;
                    selectedCondition = null;
                    break;
                  case 'CONDITION':
                    selectedCondition = selectedCondition != null && _sameText(selectedCondition, value) ? null : value;
                    break;
                }
                selectedAsset = null;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? _accentOrange : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: selected ? _accentOrange : Colors.white.withValues(alpha: 0.2)),
              ),
              child: Text(value, style: GoogleFonts.poppins(color: selected ? Colors.white : Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow({required bool compact}) {
    final pills = [
      _buildStatPill('Visible', _visibleTotal, _infoCyan, compact: compact),
      _buildStatPill('Critical', _visibleCritical, _dangerRed, compact: compact),
      _buildStatPill('Dangerous', _visibleDangerous, _accentOrange, compact: compact),
      _buildStatPill('Overdue', _visibleOverdue, _warningYellow, compact: compact),
    ];

    if (compact) {
      return SizedBox(height: 36, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: pills)));
    }
    return Wrap(spacing: 10, runSpacing: 10, children: pills);
  }

  Widget _buildStatPill(String label, int value, Color color, {required bool compact}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 7 : 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(fontSize: compact ? 11 : 12, color: Colors.white),
          children: [
            TextSpan(text: '$label: ', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            TextSpan(text: '$value', style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyArea({required bool compact, required bool forceHorizontalScroll, required double innerWidth}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final body = Row(
          children: [
            Expanded(flex: 7, child: _buildAssetTablePanel(compact: compact)),
            SizedBox(width: compact ? 10 : 12),
            Expanded(flex: 3, child: _buildDetailPanel(_activeAsset, compact: compact)),
          ],
        );

        if (forceHorizontalScroll) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: innerWidth, height: constraints.maxHeight, child: body),
          );
        }
        return SizedBox(width: double.infinity, height: constraints.maxHeight, child: body);
      },
    );
  }

  Widget _buildAssetTablePanel({required bool compact}) {
    final rows = displayAssets;

    if (rows.isEmpty) {
      return _buildEmptyState(title: 'No assets found', subtitle: 'Try another search or filter');
    }

    final tableWidth = compact ? 1360.0 : 1440.0;

    return Container(
      decoration: _glassDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Scrollbar(
              controller: _horizontalTableController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalTableController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  height: constraints.maxHeight,
                  child: Column(
                    children: [
                      _buildTableTopBar(compact: compact, total: rows.length),
                      _buildTableHeader(compact: compact),
                      Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
                      Expanded(
                        child: Scrollbar(
                          controller: _verticalTableController,
                          thumbVisibility: true,
                          child: ListView.separated(
                            controller: _verticalTableController,
                            padding: EdgeInsets.zero,
                            itemCount: rows.length,
                            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
                            itemBuilder: (context, index) => _buildTableRow(rows[index], compact: compact, index: index),
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

  Widget _buildTableTopBar({required bool compact, required int total}) {
    String groupLabel;
    switch (selectedGroup) {
      case 'CATEGORY':
        groupLabel = 'Category';
        break;
      case 'SUBCATEGORY':
        groupLabel = 'Sub Category';
        break;
      case 'TYPE':
        groupLabel = 'Type';
        break;
      case 'CONDITION':
        groupLabel = 'Condition';
        break;
      default:
        groupLabel = 'All Assets';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 16, vertical: compact ? 10 : 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A8A),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Text('Asset List', style: GoogleFonts.poppins(color: Colors.white, fontSize: compact ? 13 : 15, fontWeight: FontWeight.w800)),
          const SizedBox(width: 10),
          _buildGlassChip('$groupLabel • $total rows', compact: compact),
          const Spacer(),
          Text('Horizontal scroll →', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildTableHeader({required bool compact}) {
    return Container(
      height: compact ? 46 : 50,
      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 16),
      color: const Color(0xFF2E4A8E),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: [
            _buildTableHeaderCell('Nomenklatur', 160, compact: compact),
            _buildTableHeaderCell('Nama Asset', 220, compact: compact),
            _buildTableHeaderCell('Deskripsi', 280, compact: compact),
            _buildTableHeaderCell(_groupHeaderLabel(), 180, compact: compact),
            _buildTableHeaderCell('Room', 120, compact: compact),
            _buildTableHeaderCell('Last Inspection', 170, compact: compact),
            _buildTableHeaderCell('Condition', 120, compact: compact),
          ],
        ),
      ),
    );
  }

  String _groupHeaderLabel() {
    switch (selectedGroup) {
      case 'CATEGORY':
        return 'Category';
      case 'SUBCATEGORY':
        return 'Sub Category';
      case 'TYPE':
        return 'Type';
      case 'CONDITION':
        return 'Condition Group';
      default:
        return 'Group';
    }
  }

  Widget _buildTableHeaderCell(String title, double width, {required bool compact}) {
    return SizedBox(
      width: width,
      child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: Colors.white70, fontSize: compact ? 10.5 : 11, fontWeight: FontWeight.w800)),
    );
  }

  Widget _buildTableRow(AssetMasterModel asset, {required bool compact, required int index}) {
    final selected = selectedAsset?.id == asset.id;

    return InkWell(
      onTap: () => setState(() => selectedAsset = asset),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: compact ? 58 : 64,
        padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 16),
        decoration: BoxDecoration(
          color: selected ? _accentGreen.withValues(alpha: 0.15) : (index.isEven ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.02)),
          border: Border(left: BorderSide(color: selected ? _accentGreen : Colors.transparent, width: 4)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              _buildTableCell(asset.rfidTagId, 160, compact: compact, selected: selected, emphasize: true),
              _buildTableCell(asset.assetName, 220, compact: compact, selected: selected, emphasize: true),
              _buildTableCell(asset.description?.trim().isNotEmpty == true ? asset.description! : '-', 280, compact: compact, selected: selected),
              _buildTableCell(_groupValue(asset), 180, compact: compact, selected: selected),
              _buildTableCell(asset.roomName ?? '-', 120, compact: compact, selected: selected),
              _buildTableCell(_formatDateTime(asset.lastInspectionAt), 170, compact: compact, selected: selected),
              _buildConditionBadge(asset.statusCondition, 120, selected: selected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(String value, double width, {required bool compact, required bool selected, bool emphasize = false}) {
    return SizedBox(
      width: width,
      child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: selected ? Colors.white : Colors.white70, fontSize: compact ? 10.5 : 11.5, fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500)),
    );
  }

  Widget _buildConditionBadge(String? condition, double width, {required bool selected}) {
    final color = _getConditionColor(condition);
    return SizedBox(
      width: width,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
          child: Text(condition ?? 'Unknown', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: selected ? Colors.white : color, fontWeight: FontWeight.w800, fontSize: 11)),
        ),
      ),
    );
  }

  String _groupValue(AssetMasterModel asset) {
    switch (selectedGroup) {
      case 'CATEGORY':
        return asset.categoryName ?? 'Uncategorized';
      case 'SUBCATEGORY':
        return asset.subCategoryName ?? 'Uncategorized';
      case 'TYPE':
        return asset.typeName ?? 'Uncategorized';
      case 'CONDITION':
        return asset.statusCondition ?? 'Unknown';
      default:
        return 'All Assets';
    }
  }

  Widget _buildDetailPanel(AssetMasterModel? asset, {required bool compact}) {
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: _glassDecoration(),
      child: asset == null
          ? Center(child: Text('Select Asset', style: GoogleFonts.poppins(color: Colors.white70, fontSize: compact ? 15 : 16, fontWeight: FontWeight.w700)))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(asset.assetName, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: Colors.white, fontSize: compact ? 18 : 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(asset.rfidTagId, style: GoogleFonts.poppins(color: Colors.white70, fontSize: compact ? 11 : 12)),
                  SizedBox(height: compact ? 12 : 16),
                  _buildTaxonomyBreadcrumb(asset, compact: compact),
                  SizedBox(height: compact ? 12 : 16),
                  _buildDetailRow('Condition', asset.statusCondition, compact: compact),
                  _buildDetailRow('Contamination', asset.levelContaminated?.toString(), compact: compact),
                  _buildDetailRow('Dangerous', asset.isDangerous == true ? 'Yes' : 'No', compact: compact),
                  _buildDetailRow('Room', asset.roomName, compact: compact),
                  _buildDetailRow('Detector', asset.detectorCode, compact: compact),
                  _buildDetailRow('Last Movement', asset.lastMovementStatus, compact: compact),
                  _buildDetailRow('Last Used By', asset.lastUsedByName, compact: compact),
                  _buildDetailRow('Assigned To', asset.assignedProfileName, compact: compact),
                  _buildDetailRow('Last Inspection Result', asset.lastInspectionResult, compact: compact),
                  SizedBox(height: compact ? 10 : 12),
                  _buildGlassNote('Handling Instruction', asset.handlingInstruction, compact: compact),
                  _buildGlassNote('Maintenance Pattern', asset.maintenancePattern, compact: compact),
                  _buildGlassNote('Last Inspection Notes', asset.lastInspectionNotes, compact: compact),
                  _buildGlassNote('Last Recommendation', asset.lastRecommendation, compact: compact),
                  SizedBox(height: compact ? 10 : 12),
                  _buildInspectionTimeline(asset, compact: compact),
                  SizedBox(height: compact ? 10 : 12),
                  _buildDescriptionBox(asset, compact: compact),
                ],
              ),
            ),
    );
  }

  Widget _buildTaxonomyBreadcrumb(AssetMasterModel asset, {required bool compact}) {
    final items = <String>[
      if ((asset.categoryName ?? '').trim().isNotEmpty) asset.categoryName!.trim(),
      if ((asset.subCategoryName ?? '').trim().isNotEmpty) asset.subCategoryName!.trim(),
      if ((asset.typeName ?? '').trim().isNotEmpty) asset.typeName!.trim(),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    Widget crumb(String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
        child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: Colors.white, fontSize: compact ? 10.5 : 11, fontWeight: FontWeight.w700)),
      );
    }

    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      children.add(crumb(items[i]));
      if (i != items.length - 1) {
        children.add(Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('›', style: GoogleFonts.poppins(color: Colors.white54, fontSize: compact ? 13 : 14, fontWeight: FontWeight.w800))));
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Group', style: GoogleFonts.poppins(color: Colors.white, fontSize: compact ? 12 : 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: children)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String? value, {required bool compact}) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 8 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: GoogleFonts.poppins(color: Colors.white54, fontSize: compact ? 9.5 : 11)),
          const SizedBox(height: 3),
          Text((value == null || value.trim().isEmpty) ? '-' : value, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: compact ? 11.5 : 14)),
        ],
      ),
    );
  }

  Widget _buildGlassNote(String title, String? value, {required bool compact}) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 8 : 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: compact ? 12 : 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text((value == null || value.trim().isEmpty) ? 'No data' : value, style: GoogleFonts.poppins(fontSize: compact ? 11 : 12, height: 1.5, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionTimeline(AssetMasterModel asset, {required bool compact}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Inspection Timeline', style: GoogleFonts.poppins(color: Colors.white, fontSize: compact ? 12 : 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _buildDetailRow('Day of Month', asset.inspectionDayOfMonth?.toString(), compact: compact),
          _buildDetailRow('Last Inspection At', _formatDateTime(asset.lastInspectionAt), compact: compact),
          _buildDetailRow('Next Inspection At', _formatDateTime(asset.nextInspectionAt), compact: compact),
        ],
      ),
    );
  }

  Widget _buildDescriptionBox(AssetMasterModel asset, {required bool compact}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
      child: Text((asset.description?.trim().isNotEmpty == true) ? asset.description! : 'No description available.', style: GoogleFonts.poppins(fontSize: compact ? 11 : 12, height: 1.5, color: Colors.white70)),
    );
  }

  Widget _buildEmptyState({required String title, required String subtitle}) {
    return Container(
      decoration: _glassDecoration(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inventory_2_outlined, color: Colors.white54, size: 54),
              const SizedBox(height: 12),
              Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================
  Color _getConditionColor(String? condition) {
    switch ((condition ?? '').toLowerCase()) {
      case 'critical':
        return _dangerRed;
      case 'maintenance':
        return _accentOrange;
      case 'damaged':
        return const Color(0xFFF97316);
      case 'good':
        return _accentGreen;
      default:
        return _infoCyan;
    }
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    final local = value.toLocal();
    return DateFormat('yyyy-MM-dd HH:mm').format(local);
  }

  Decoration _glassDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white.withValues(alpha: 0.08),
      border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.5),
    );
  }
}