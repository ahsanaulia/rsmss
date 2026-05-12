import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/v_asset_master_complete.dart';
import '../../models/asset_repository.dart';

class AssetIntelligenceScreen extends StatefulWidget {
  const AssetIntelligenceScreen({super.key});

  @override
  State<AssetIntelligenceScreen> createState() =>
      _AssetIntelligenceScreenState();
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
        _assets.where((e) => _sameText(e.categoryName, selectedCategory)).map((e) => e.subCategoryName),
      );
    }

    return _uniqueSortedValues(_assets.map((e) => e.subCategoryName));
  }

  List<String> get availableTypes {
    if (selectedGroup == 'CATEGORY' && selectedCategory != null) {
      return _uniqueSortedValues(
        _assets.where((e) => _sameText(e.categoryName, selectedCategory)).map((e) => e.typeName),
      );
    }

    if (selectedGroup == 'SUBCATEGORY' && selectedSubCategory != null) {
      return _uniqueSortedValues(
        _assets.where((e) => _sameText(e.subCategoryName, selectedSubCategory)).map((e) => e.typeName),
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
          if (selectedCategory != null && !_sameText(e.categoryName, selectedCategory)) {
            return false;
          }
          break;

        case 'SUBCATEGORY':
          if (selectedSubCategory != null && !_sameText(e.subCategoryName, selectedSubCategory)) {
            return false;
          }
          break;

        case 'TYPE':
          if (selectedType != null && !_sameText(e.typeName, selectedType)) {
            return false;
          }
          break;

        case 'CONDITION':
          if (selectedCondition != null && !_sameText(e.statusCondition, selectedCondition)) {
            return false;
          }
          break;
      }

      return true;
    }).toList();
  }

  List<AssetMasterModel> get displayAssets {
    final items = List<AssetMasterModel>.from(filteredAssets);

    items.sort((a, b) {
      return a.assetName.toLowerCase().compareTo(b.assetName.toLowerCase());
    });

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

  int get _visibleCritical => filteredAssets
      .where((e) => (e.statusCondition ?? '').toLowerCase() == 'critical')
      .length;

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
      child: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEAF8F5),
                Color(0xFFDDF4EE),
                Color(0xFFD1F0E8),
              ],
            ),
          ),
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
      ),
    );
  }

  Widget _buildMobileScrollLayout({
    required bool compact,
    required double bodyHeight,
    required bool forceHorizontalScroll,
    required double innerWidth,
  }) {
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
                  SizedBox(
                    height: bodyHeight,
                    child: _buildBodyArea(
                      compact: compact,
                      forceHorizontalScroll: forceHorizontalScroll,
                      innerWidth: innerWidth,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout({
    required bool compact,
    required double bodyHeight,
    required bool forceHorizontalScroll,
    required double innerWidth,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildHeader(compact: compact),
        SizedBox(height: compact ? 8 : 10),
        _buildToolbar(compact: compact),
        SizedBox(height: compact ? 8 : 10),
        _buildStatsRow(compact: compact),
        SizedBox(height: compact ? 8 : 10),
        Expanded(
          child: _buildBodyArea(
            compact: compact,
            forceHorizontalScroll: forceHorizontalScroll,
            innerWidth: innerWidth,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.72),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFB8E5DD).withOpacity(0.8)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF58B7A6).withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF14B8A6),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Loading assets...',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
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
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.78),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFB8E5DD).withOpacity(0.8)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF58B7A6).withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFDC2626),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load asset data',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF475569),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAssets,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B8A6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({required bool compact}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 16,
        vertical: compact ? 12 : 14,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF8FFFD),
            Color(0xFFE9F9F5),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFCDEEE7),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5CAFA0).withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(compact ? 10 : 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF14B8A6),
                  Color(0xFF06B6D4),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.memory,
              color: Colors.white,
              size: compact ? 18 : 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ASSET INTELLIGENCE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF0F172A),
                    fontSize: compact ? 16 : 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hospital Asset Monitoring Center',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF475569),
                    fontSize: compact ? 10 : 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 12,
              vertical: compact ? 6 : 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF14B8A6).withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF14B8A6).withOpacity(0.20),
              ),
            ),
            child: Text(
              'LIVE AUDIT MODE',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF0F766E),
                fontWeight: FontWeight.w700,
                fontSize: compact ? 10 : 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar({required bool compact}) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.74),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFCAE9E2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5CAFA0).withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: compact ? 42 : 46,
            child: TextField(
              controller: _searchController,
              onChanged: (_) {
                setState(() {
                  selectedAsset = null;
                });
              },
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF0F172A),
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'Search Asset / Nomenklatur / Category',
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF64748B),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: const Color(0xFFF7FBFA),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFD6EDE7)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFD6EDE7)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF14B8A6),
                    width: 1.2,
                  ),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF7A8C95),
                  size: 20,
                ),
              ),
            ),
          ),
          SizedBox(height: compact ? 10 : 12),
          SizedBox(
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
                      color: selected ? const Color(0xFF14B8A6) : const Color(0xFFF2F8F6),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF14B8A6).withOpacity(0.45)
                            : const Color(0xFFD6EDE7),
                      ),
                    ),
                    child: Text(
                      group,
                      style: GoogleFonts.plusJakartaSans(
                        color: selected ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (selectedGroup != 'ALL') ...[
            SizedBox(height: compact ? 10 : 12),
            _buildTaxonomyFilters(compact: compact),
          ],
        ],
      ),
    );
  }

  Widget _buildTaxonomyFilters({required bool compact}) {
    List<String> items = const [];

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

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

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
                    selectedCategory =
                        selectedCategory != null && _sameText(selectedCategory, value)
                            ? null
                            : value;
                    selectedSubCategory = null;
                    selectedType = null;
                    selectedCondition = null;
                    break;

                  case 'SUBCATEGORY':
                    selectedSubCategory =
                        selectedSubCategory != null && _sameText(selectedSubCategory, value)
                            ? null
                            : value;
                    selectedType = null;
                    selectedCondition = null;
                    break;

                  case 'TYPE':
                    selectedType =
                        selectedType != null && _sameText(selectedType, value)
                            ? null
                            : value;
                    selectedCondition = null;
                    break;

                  case 'CONDITION':
                    selectedCondition =
                        selectedCondition != null && _sameText(selectedCondition, value)
                            ? null
                            : value;
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
                color: selected ? const Color(0xFFF59E0B) : const Color(0xFFF2F8F6),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFF59E0B).withOpacity(0.45)
                      : const Color(0xFFD6EDE7),
                ),
              ),
              child: Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  color: selected ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow({required bool compact}) {
    final pills = [
      _statPill('Visible', _visibleTotal, const Color(0xFF06B6D4), compact: compact),
      _statPill('Critical', _visibleCritical, const Color(0xFFEF4444), compact: compact),
      _statPill('Dangerous', _visibleDangerous, const Color(0xFFF59E0B), compact: compact),
      _statPill('Overdue', _visibleOverdue, const Color(0xFFEAB308), compact: compact),
    ];

    if (compact) {
      return SizedBox(
        height: 36,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: pills),
        ),
      );
    }

    return Wrap(spacing: 10, runSpacing: 10, children: pills);
  }

  Widget _statPill(
    String label,
    int value,
    Color color, {
    required bool compact,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 7 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.70),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.plusJakartaSans(
            fontSize: compact ? 11 : 12,
            color: const Color(0xFF0F172A),
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: '$value',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyArea({
    required bool compact,
    required bool forceHorizontalScroll,
    required double innerWidth,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final body = Row(
          children: [
            Expanded(
              flex: 7,
              child: _buildAssetTablePanel(compact: compact),
            ),
            SizedBox(width: compact ? 10 : 12),
            Expanded(
              flex: 3,
              child: _buildDetailPanel(_activeAsset, compact: compact),
            ),
          ],
        );

        if (forceHorizontalScroll) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: innerWidth,
              height: constraints.maxHeight,
              child: body,
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          height: constraints.maxHeight,
          child: body,
        );
      },
    );
  }

  Widget _buildAssetTablePanel({
    required bool compact,
  }) {
    final rows = displayAssets;

    if (rows.isEmpty) {
      return _emptyState(
        title: 'No assets found',
        subtitle: 'Try another search or filter',
      );
    }

    final tableWidth = compact ? 1360.0 : 1440.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.76),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD6EDE7),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5CAFA0).withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
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
                      Divider(height: 1, color: const Color(0xFFD6EDE7).withOpacity(0.8)),
                      Expanded(
                        child: Scrollbar(
                          controller: _verticalTableController,
                          thumbVisibility: true,
                          child: ListView.separated(
                            controller: _verticalTableController,
                            padding: EdgeInsets.zero,
                            itemCount: rows.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: const Color(0xFFD6EDE7).withOpacity(0.55),
                            ),
                            itemBuilder: (context, index) {
                              return _buildTableRow(
                                rows[index],
                                compact: compact,
                                index: index,
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
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 16,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF2FAF8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Asset List',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF0F172A),
              fontSize: compact ? 13 : 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF14B8A6).withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFF14B8A6).withOpacity(0.20),
              ),
            ),
            child: Text(
              '$groupLabel • $total rows',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF0F766E),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Horizontal scroll →',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF64748B),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader({required bool compact}) {
    return Container(
      height: compact ? 46 : 50,
      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 16),
      color: const Color(0xFFF7FBFA),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: [
            _tableHeaderCell('Nomenklatur', 160, compact: compact),
            _tableHeaderCell('Nama Asset', 220, compact: compact),
            _tableHeaderCell('Deskripsi', 280, compact: compact),
            _tableHeaderCell(_groupHeaderLabel(), 180, compact: compact),
            _tableHeaderCell('Room', 120, compact: compact),
            _tableHeaderCell('Last Inspection', 170, compact: compact),
            _tableHeaderCell('Condition', 120, compact: compact),
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

  Widget _tableHeaderCell(String title, double width, {required bool compact}) {
    return SizedBox(
      width: width,
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF475569),
          fontSize: compact ? 10.5 : 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildTableRow(
    AssetMasterModel asset, {
    required bool compact,
    required int index,
  }) {
    final selected = selectedAsset?.id == asset.id;

    return InkWell(
      onTap: () {
        setState(() {
          selectedAsset = asset;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: compact ? 58 : 64,
        padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF14B8A6).withOpacity(0.10)
              : index.isEven
                  ? Colors.white.withOpacity(0.50)
                  : const Color(0xFFF7FBFA),
          border: Border(
            left: BorderSide(
              color: selected ? const Color(0xFF14B8A6) : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              _tableCell(
                asset.rfidTagId,
                160,
                compact: compact,
                emphasize: true,
                selected: selected,
              ),
              _tableCell(
                asset.assetName,
                220,
                compact: compact,
                selected: selected,
                emphasize: true,
              ),
              _tableCell(
                asset.description?.trim().isNotEmpty == true ? asset.description! : '-',
                280,
                compact: compact,
                selected: selected,
              ),
              _tableCell(
                _groupValue(asset),
                180,
                compact: compact,
                selected: selected,
              ),
              _tableCell(
                asset.roomName ?? '-',
                120,
                compact: compact,
                selected: selected,
              ),
              _tableCell(
                _formatDateTime(asset.lastInspectionAt),
                170,
                compact: compact,
                selected: selected,
              ),
              _conditionBadge(asset.statusCondition, 120, selected: selected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableCell(
    String value,
    double width, {
    required bool compact,
    required bool selected,
    bool emphasize = false,
  }) {
    return SizedBox(
      width: width,
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.plusJakartaSans(
          color: selected ? const Color(0xFF0F172A) : const Color(0xFF0F172A),
          fontSize: compact ? 10.5 : 11.5,
          fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _conditionBadge(
    String? condition,
    double width, {
    required bool selected,
  }) {
    final color = _conditionColor(condition);

    return SizedBox(
      width: width,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            condition ?? 'Unknown',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              color: selected ? const Color(0xFF0F172A) : color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
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
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.76),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD6EDE7),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5CAFA0).withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: asset == null
          ? Center(
              child: Text(
                'Select Asset',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF64748B),
                  fontSize: compact ? 15 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    asset.assetName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF0F172A),
                      fontSize: compact ? 18 : 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    asset.rfidTagId,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF64748B),
                      fontSize: compact ? 11 : 12,
                    ),
                  ),
                  SizedBox(height: compact ? 12 : 16),
                  _taxonomyBreadcrumbRow(asset, compact: compact),
                  SizedBox(height: compact ? 12 : 16),
                  _detail('Condition', asset.statusCondition, compact: compact),
                  _detail(
                    'Contamination',
                    asset.levelContaminated?.toString(),
                    compact: compact,
                  ),
                  _detail(
                    'Dangerous',
                    asset.isDangerous == true ? 'Yes' : 'No',
                    compact: compact,
                  ),
                  _detail('Room', asset.roomName, compact: compact),
                  _detail('Detector', asset.detectorCode, compact: compact),
                  _detail(
                    'Last Movement',
                    asset.lastMovementStatus,
                    compact: compact,
                  ),
                  _detail(
                    'Last Used By',
                    asset.lastUsedByName,
                    compact: compact,
                  ),
                  _detail(
                    'Assigned To',
                    asset.assignedProfileName,
                    compact: compact,
                  ),
                  _detail(
                    'Last Inspection Result',
                    asset.lastInspectionResult,
                    compact: compact,
                  ),
                  SizedBox(height: compact ? 10 : 12),
                  _notesBlock(
                    title: 'Handling Instruction',
                    value: asset.handlingInstruction,
                    compact: compact,
                  ),
                  _notesBlock(
                    title: 'Maintenance Pattern',
                    value: asset.maintenancePattern,
                    compact: compact,
                  ),
                  _notesBlock(
                    title: 'Last Inspection Notes',
                    value: asset.lastInspectionNotes,
                    compact: compact,
                  ),
                  _notesBlock(
                    title: 'Last Recommendation',
                    value: asset.lastRecommendation,
                    compact: compact,
                  ),
                  SizedBox(height: compact ? 10 : 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.60),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD6EDE7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inspection Timeline',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF0F172A),
                            fontSize: compact ? 12 : 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _detail(
                          'Day of Month',
                          asset.inspectionDayOfMonth?.toString(),
                          compact: compact,
                        ),
                        _detail(
                          'Last Inspection At',
                          _formatDateTime(asset.lastInspectionAt),
                          compact: compact,
                        ),
                        _detail(
                          'Next Inspection At',
                          _formatDateTime(asset.nextInspectionAt),
                          compact: compact,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: compact ? 10 : 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.60),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD6EDE7)),
                    ),
                    child: Text(
                      (asset.description?.trim().isNotEmpty == true)
                          ? asset.description!
                          : 'No description available.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: compact ? 11 : 12,
                        height: 1.5,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _taxonomyBreadcrumbRow(
    AssetMasterModel asset, {
    required bool compact,
  }) {
    final items = <String>[
      if ((asset.categoryName ?? '').trim().isNotEmpty) asset.categoryName!.trim(),
      if ((asset.subCategoryName ?? '').trim().isNotEmpty) asset.subCategoryName!.trim(),
      if ((asset.typeName ?? '').trim().isNotEmpty) asset.typeName!.trim(),
    ];

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    Widget crumb(String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F8F6),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFD6EDE7)),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontSize: compact ? 10.5 : 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      children.add(crumb(items[i]));
      if (i != items.length - 1) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '›',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF64748B),
                fontSize: compact ? 13 : 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.60),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6EDE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Group',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF0F172A),
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: children),
          ),
        ],
      ),
    );
  }

  Widget _detail(String title, String? value, {required bool compact}) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 8 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF64748B),
              fontSize: compact ? 9.5 : 11,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            (value == null || value.trim().isEmpty) ? '-' : value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
              fontSize: compact ? 11.5 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notesBlock({
    required String title,
    required String? value,
    required bool compact,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 8 : 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.60),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD6EDE7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF0F172A),
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              (value == null || value.trim().isEmpty) ? 'No data' : value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: compact ? 11 : 12,
                height: 1.5,
                color: const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState({
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD6EDE7),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: Color(0xFF7A8C95),
                size: 54,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _conditionColor(String? condition) {
    switch ((condition ?? '').toLowerCase()) {
      case 'critical':
        return const Color(0xFFEF4444);
      case 'maintenance':
        return const Color(0xFFF59E0B);
      case 'damaged':
        return const Color(0xFFF97316);
      case 'good':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF06B6D4);
    }
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    final local = value.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
  }
}