// ======================
// IMPORT
// ======================
import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/asset_entity_model.dart';
import '../../models/floor_model.dart';

// ======================
// MAIN WIDGET
// ======================
class GeneralAssetMap extends StatefulWidget {
  const GeneralAssetMap({super.key});

  @override
  State<GeneralAssetMap> createState() => _GeneralAssetMapState();
}

class _GeneralAssetMapState extends State<GeneralAssetMap>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  final Map<String, AssetEntityModel> assetMap = {};
  final FocusNode _searchFocus = FocusNode();
  List<FloorModel> floors = [];

  String? selectedFloorId;
  String? selectedFloorMap;

  /// 🔥 FILTER CATEGORY
  String? selectedCategory;
  List<String> categories = [];

  bool isLoading = true;

  static const double BASE_SIZE = 2000;

  final TransformationController _controller = TransformationController();

  final ValueNotifier<String?> selectedEntityId = ValueNotifier(null);
  final ValueNotifier<List<AssetEntityModel>> searchResults = ValueNotifier([]);

  final TextEditingController _searchCtrl = TextEditingController();

  late AnimationController _pulse;

  final Map<String, Offset> _posCache = {};

  QuadTree<AssetEntityModel>? _quadTree;

  Timer? _searchDebounce;
  int _searchSeq = 0;

  @override
  void initState() {
    super.initState();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _init();
  }

  // @override
  // void dispose() {
  //   _pulse.dispose();
  //   _searchCtrl.dispose();
  //   selectedEntityId.dispose();
  //   searchResults.dispose();
  //   super.dispose();
  // }

  @override
  void dispose() {
    _pulse.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose(); // 🔥 WAJIB
    selectedEntityId.dispose();
    searchResults.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final res = await supabase.from('floors').select();

    floors = (res as List).map((e) => FloorModel.fromJson(e)).toList()
      ..sort((a, b) => a.floorAlias.compareTo(b.floorAlias));

    if (floors.isNotEmpty) {
      selectedFloorId = floors.first.id;
      selectedFloorMap = floors.first.mapImageUrl;
    }

    await _loadAssets();

    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _loadAssets() async {
    if (selectedFloorId == null) return;

    final res = await supabase
        .from('view_asset_live')
        .select()
        .eq('floor_id', selectedFloorId!);

    assetMap.clear();
    _posCache.clear();

    for (final e in List<Map<String, dynamic>>.from(res)) {
      final a = AssetEntityModel.fromJson(e);
      assetMap[a.entityId] = a;
    }

    /// 🔥 BUILD CATEGORY LIST
    final set = <String>{};
    for (final a in assetMap.values) {
      if (a.categoryName != null && a.categoryName!.isNotEmpty) {
        set.add(a.categoryName!);
      }
    }
    categories = set.toList()..sort();

    _buildQuadTree();

    if (mounted) setState(() {});
  }

  void _buildQuadTree() {
    final qt = QuadTree<AssetEntityModel>(
      Rect.fromLTWH(0, 0, BASE_SIZE, BASE_SIZE),
    );

    for (final a in assetMap.values) {
      qt.insert(_getPos(a), a);
    }

    _quadTree = qt;
  }

  List<AssetEntityModel> _visibleAssets(Rect viewport) {
    if (_quadTree == null) return [];
    return _quadTree!.query(viewport);
  }

  Offset _getPos(AssetEntityModel a) {
    if (_posCache.containsKey(a.entityId)) {
      return _posCache[a.entityId]!;
    }

    final rand = Random(a.entityId.hashCode);

    final minX = min(a.roomXMin ?? a.xPos ?? 0, a.roomXMax ?? a.xPos ?? 0);
    final maxX = max(a.roomXMin ?? a.xPos ?? 0, a.roomXMax ?? a.xPos ?? 0);

    final minY = min(a.roomYMin ?? a.yPos ?? 0, a.roomYMax ?? a.yPos ?? 0);
    final maxY = max(a.roomYMin ?? a.yPos ?? 0, a.roomYMax ?? a.yPos ?? 0);

    final pos = Offset(
      minX + rand.nextDouble() * (maxX - minX),
      minY + rand.nextDouble() * (maxY - minY),
    );

    _posCache[a.entityId] = pos;
    return pos;
  }

  AssetEntityModel? _hitTest(Offset localPos, List<AssetEntityModel> visible) {
    const radius = 24.0;

    for (final a in visible) {
      final p = _getPos(a);
      if ((p - localPos).distance <= radius) {
        return a;
      }
    }
    return null;
  }

  void _onSearchChanged(String v) {
    final q = v.trim();

    _searchDebounce?.cancel();

    if (q.isEmpty) {
      searchResults.value = [];
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (_searchFocus.hasFocus) {
        _search(q);
      }
    });
  }

  void _triggerSearchNow() {
    _searchDebounce?.cancel(); // 🔥 hentikan debounce lama

    final q = _searchCtrl.text.trim();
    if (q.isNotEmpty) {
      _search(q);
    } else {
      searchResults.value = [];
    }
  }

  // Future<void> _search(String q) async {
  //   final seq = ++_searchSeq;

  //   final res = await supabase
  //       .from('view_asset_live')
  //       .select()
  //       .ilike('asset_name', '%$q%')
  //       .limit(10);

  //   if (!mounted || seq != _searchSeq) return;

  //   searchResults.value = List<Map<String, dynamic>>.from(
  //     res,
  //   ).map((e) => AssetEntityModel.fromJson(e)).toList();
  // }
  Future<void> _search(String q) async {
    final seq = ++_searchSeq;

    var query = supabase
        .from('view_asset_live')
        .select()
        .ilike('asset_name', '%$q%');

    /// 🔥 FILTER CATEGORY
    if (selectedCategory != null) {
      query = query.eq('category_name', selectedCategory!);
    }

    final res = await query.limit(10);

    if (!mounted || seq != _searchSeq) return;

    searchResults.value = List<Map<String, dynamic>>.from(
      res,
    ).map((e) => AssetEntityModel.fromJson(e)).toList();
  }

  Future<void> _focus(AssetEntityModel a) async {
    searchResults.value = [];
    _searchCtrl.clear();

    if (a.floorId != selectedFloorId) {
      await _selectFloor(a.floorId!);
    }

    selectedEntityId.value = a.entityId;

    final pos = _getPos(a);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.value = Matrix4.identity()
        ..translate(-pos.dx + 250, -pos.dy + 250)
        ..scale(1.6);
    });
  }

  Future<void> _selectFloor(String id) async {
    final f = floors.firstWhere((e) => e.id == id);

    setState(() {
      selectedFloorId = f.id;
      selectedFloorMap = f.mapImageUrl;
      selectedCategory = null; // reset filter
    });

    await _loadAssets();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return InteractiveViewer(
                transformationController: _controller,
                constrained: false,
                boundaryMargin: const EdgeInsets.all(3000),
                minScale: 0.2,
                maxScale: 5,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_pulse, _controller]),
                  builder: (_, __) {
                    final m = _controller.value;
                    final scale = m.getMaxScaleOnAxis();

                    final tx = m.storage[12];
                    final ty = m.storage[13];

                    final viewport = Rect.fromLTWH(
                      -tx / scale,
                      -ty / scale,
                      constraints.maxWidth / scale,
                      constraints.maxHeight / scale,
                    );

                    final visible = _visibleAssets(viewport);

                    return SizedBox(
                      width: BASE_SIZE,
                      height: BASE_SIZE,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapDown: (details) {
                          final tapped = _hitTest(
                            details.localPosition,
                            visible,
                          );
                          if (tapped != null) {
                            _focus(tapped);
                          }
                        },
                        child: Stack(
                          children: [
                            ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.modulate,
                              ),
                              child: Opacity(
                                opacity: 0.4,
                                child: Image.network(
                                  selectedFloorMap ?? '',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            CustomPaint(
                              size: const Size(BASE_SIZE, BASE_SIZE),
                              painter: _AssetPainter(
                                assets: visible,
                                getPos: _getPos,
                                selectedId: selectedEntityId.value,
                                pulse: _pulse.value,
                                selectedCategory: selectedCategory,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        // ======================
        // OVERLAY
        // ======================
        Positioned(
          top: 8,
          left: 8,
          right: 8,
          child: SafeArea(
            child: Material(
              color: Colors.transparent, // 🔥 jangan putih
              borderRadius: BorderRadius.circular(18),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(10),

                    /// 🔥 GLASS PANEL
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color.fromARGB(
                        255,
                        13,
                        77,
                        160,
                      ).withOpacity(0.15),
                      border: Border.all(
                        color: const Color.fromARGB(
                          255,
                          107,
                          139,
                          228,
                        ).withOpacity(0.25),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 25,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ],
                    ),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            /// FLOOR
                            /// FLOOR
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Colors.white.withOpacity(0.1),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: selectedFloorId,

                                    /// 🔥 STYLE DROPDOWN MENU
                                    dropdownColor: const Color.fromARGB(
                                      255,
                                      4,
                                      113,
                                      209,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      16,
                                    ), // 🔥 INI YANG BIKIN ROUNDED
                                    menuMaxHeight: 260,

                                    style: const TextStyle(color: Colors.white),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white,
                                    ),

                                    items: floors
                                        .map(
                                          (f) => DropdownMenuItem(
                                            value: f.id,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              child: Text(
                                                f.label,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),

                                    onChanged: (v) {
                                      if (v != null) _selectFloor(v);
                                    },
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 6),

                            /// CATEGORY FILTER (LOGIC TIDAK DIUBAH)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Colors.white.withOpacity(0.1),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: selectedCategory,

                                    /// 🔥 STYLE DROPDOWN MENU
                                    dropdownColor: Colors.grey.shade900,
                                    borderRadius: BorderRadius.circular(
                                      16,
                                    ), // 🔥 penting
                                    menuMaxHeight: 260,

                                    hint: Text(
                                      "Filter Kategori",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),

                                    style: const TextStyle(color: Colors.white),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white,
                                    ),

                                    items: [
                                      const DropdownMenuItem(
                                        value: null,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          child: Text("Semua"),
                                        ),
                                      ),
                                      ...categories.map(
                                        (c) => DropdownMenuItem(
                                          value: c,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            child: Text(c),
                                          ),
                                        ),
                                      ),
                                    ],

                                    onChanged: (v) {
                                      setState(() => selectedCategory = v);

                                      _triggerSearchNow();

                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            _searchFocus.requestFocus();
                                          });
                                    },
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 6),

                            /// SEARCH (LOGIC TIDAK DIUBAH)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white.withOpacity(0.1),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: TextField(
                                  focusNode: _searchFocus,
                                  controller: _searchCtrl,
                                  onChanged: _onSearchChanged,
                                  onSubmitted: (_) => _triggerSearchNow(),
                                  textInputAction: TextInputAction.search,
                                  style: const TextStyle(color: Colors.white),

                                  decoration: InputDecoration(
                                    hintText: 'Cari asset',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    suffixIcon: IconButton(
                                      icon: const Icon(
                                        Icons.search,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        _triggerSearchNow();

                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              _searchFocus.requestFocus();
                                            });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        /// ======================
                        /// RESULT LIST (SUDAH GLASS)
                        /// ======================
                        ValueListenableBuilder<List<AssetEntityModel>>(
                          valueListenable: searchResults,
                          builder: (_, results, __) {
                            if (results.isEmpty) return const SizedBox();

                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {},
                              child: Container(
                                margin: const EdgeInsets.only(top: 8),
                                constraints: const BoxConstraints(
                                  maxHeight: 220,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 18,
                                      sigmaY: 18,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.25),
                                        ),
                                      ),
                                      child: ListView.separated(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        itemCount: results.length,
                                        separatorBuilder: (_, __) => Divider(
                                          height: 1,
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                        itemBuilder: (_, i) {
                                          final a = results[i];

                                          return InkWell(
                                            onTap: () {
                                              _focus(a);

                                              FocusScope.of(context).unfocus();

                                              Future.delayed(
                                                const Duration(
                                                  milliseconds: 50,
                                                ),
                                                () {
                                                  FocusManager
                                                      .instance
                                                      .primaryFocus
                                                      ?.unfocus();
                                                },
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 36,
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                    ),
                                                    child: const Icon(
                                                      Icons.devices,
                                                      size: 18,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          a.name,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                        ),
                                                        Text(
                                                          a.categoryName ?? '-',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.7,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons
                                                        .arrow_forward_ios_rounded,
                                                    size: 14,
                                                    color: Colors.white
                                                        .withOpacity(0.6),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ======================
// PAINTER
// ======================
class _AssetPainter extends CustomPainter {
  final List<AssetEntityModel> assets;
  final Offset Function(AssetEntityModel) getPos;
  final String? selectedId;
  final double pulse;
  final String? selectedCategory;

  _AssetPainter({
    required this.assets,
    required this.getPos,
    required this.selectedId,
    required this.pulse,
    required this.selectedCategory,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final a in assets) {
      final pos = getPos(a);

      final isSelected = a.entityId == selectedId;
      final isFiltered =
          selectedCategory != null && a.categoryName == selectedCategory;

      double scale = 1.0;

      if (isSelected || isFiltered) {
        final wave = (sin(pulse * 2 * pi) + 1) / 2;
        scale = 1.2 + (0.3 * wave);
      }

      final r = 18 * scale;

      final color = isFiltered ? Colors.orange : Colors.red;

      final paint = Paint()..color = color;

      canvas.drawCircle(pos, r, paint);

      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(Icons.place.codePoint),
          style: TextStyle(
            fontSize: r,
            fontFamily: Icons.place.fontFamily,
            package: Icons.place.fontPackage,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      iconPainter.paint(
        canvas,
        pos - Offset(iconPainter.width / 2, iconPainter.height / 2),
      );

      final tp = TextPainter(
        text: TextSpan(
          text: "${a.name}\n${a.rfidTagId ?? '-'}",
          style: const TextStyle(fontSize: 7, color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 120);

      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy + r + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _AssetPainter old) => true;
}

// ======================
// QUADTREE (UNCHANGED)
// ======================
class QuadTree<T> {
  final Rect boundary;
  final int capacity;
  final List<_Node<T>> points = [];

  bool divided = false;
  QuadTree<T>? ne, nw, se, sw;

  QuadTree(this.boundary, {this.capacity = 20});

  bool insert(Offset p, T data) {
    if (!boundary.contains(p)) return false;

    if (points.length < capacity) {
      points.add(_Node(p, data));
      return true;
    }

    if (!divided) subdivide();

    return ne!.insert(p, data) ||
        nw!.insert(p, data) ||
        se!.insert(p, data) ||
        sw!.insert(p, data);
  }

  void subdivide() {
    final x = boundary.left;
    final y = boundary.top;
    final w = boundary.width / 2;
    final h = boundary.height / 2;

    ne = QuadTree(Rect.fromLTWH(x + w, y, w, h));
    nw = QuadTree(Rect.fromLTWH(x, y, w, h));
    se = QuadTree(Rect.fromLTWH(x + w, y + h, w, h));
    sw = QuadTree(Rect.fromLTWH(x, y + h, w, h));

    divided = true;
  }

  List<T> query(Rect range, [List<T>? found]) {
    found ??= [];

    if (!boundary.overlaps(range)) return found;

    for (final p in points) {
      if (range.contains(p.point)) {
        found.add(p.data);
      }
    }

    if (divided) {
      ne!.query(range, found);
      nw!.query(range, found);
      se!.query(range, found);
      sw!.query(range, found);
    }

    return found;
  }
}

class _Node<T> {
  final Offset point;
  final T data;

  _Node(this.point, this.data);
}
