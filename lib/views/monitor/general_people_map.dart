import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/entity_people_model.dart';

class GeneralPeopleMap extends StatefulWidget {
  const GeneralPeopleMap({super.key});

  @override
  State<GeneralPeopleMap> createState() => _GeneralPeopleMapState();
}

class _GeneralPeopleMapState extends State<GeneralPeopleMap>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  final Map<String, EntityPeopleModel> peopleMap = {};
  List<Map<String, dynamic>> floors = [];

  String? selectedFloorId;
  String? selectedFloorMap;

  bool isLoading = true;

  Timer? _debounce;
  Timer? _searchDebounce;
  DateTime? _lastUpdate;
  int _searchSeq = 0;

  static const double BASE_SIZE = 2000;

  final TransformationController _controller = TransformationController();
  bool _initDone = false;

  RealtimeChannel? _channel;

  final ValueNotifier<String?> selectedEntityId = ValueNotifier<String?>(null);
  final ValueNotifier<Set<String>> selectedCategories =
      ValueNotifier<Set<String>>(<String>{});
  final ValueNotifier<List<EntityPeopleModel>> searchResults =
      ValueNotifier<List<EntityPeopleModel>>(<EntityPeopleModel>[]);

  final TextEditingController _searchCtrl = TextEditingController();

  late AnimationController _pulseController;

  final Map<String, Offset> _positionCache = {};

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (selectedFloorMap != null && selectedFloorMap!.isNotEmpty) {
      precacheImage(NetworkImage(selectedFloorMap!), context);
    }
  }

  @override
  void dispose() {
    if (_channel != null) {
      supabase.removeChannel(_channel!);
    }

    _debounce?.cancel();
    _searchDebounce?.cancel();

    _pulseController.dispose();
    _searchCtrl.dispose();
    selectedEntityId.dispose();
    selectedCategories.dispose();
    searchResults.dispose();

    super.dispose();
  }

  // ======================
  // NORMALIZE FLOORS
  // ======================
  List<Map<String, dynamic>> _normalizeFloors(List data) {
    final result = <Map<String, dynamic>>[];

    for (final item in data) {
      final m = Map<String, dynamic>.from(item as Map);

      result.add({
        ...m,
        'id': m['id']?.toString(),
        'floor_alias': m['floor_alias'] ?? '-',
        'map_image_url': m['map_image_url'] ?? '',
      });
    }

    result.sort(
      (a, b) => (a['floor_alias'] ?? '').toString().compareTo(
        (b['floor_alias'] ?? '').toString(),
      ),
    );

    return result;
  }

  Map<String, dynamic>? _findFloorById(String? floorId) {
    if (floorId == null) return null;

    for (final floor in floors) {
      if (floor['id']?.toString() == floorId) {
        return floor;
      }
    }
    return null;
  }

  String _floorLabel(Map<String, dynamic> f) {
    final buildingRaw = f['buildings'];
    final building = buildingRaw is Map
        ? (buildingRaw['building_name']?.toString() ?? 'Gedung')
        : 'Gedung';
    final alias = f['floor_alias']?.toString() ?? 'Lantai';
    return '$building - $alias';
  }

  String _floorLabelById(String? floorId) {
    final f = _findFloorById(floorId);
    if (f == null) return 'Pilih Lantai';
    return _floorLabel(f);
  }

  // ======================
  // INIT
  // ======================
  Future<void> _init() async {
    try {
      final res = await supabase.from('floors').select('''
        id,
        floor_number,
        floor_alias,
        map_image_url,
        building_id,
        buildings (building_name)
      ''');

      floors = _normalizeFloors(res);

      if (floors.isNotEmpty) {
        final first = floors.first;
        selectedFloorId = first['id']?.toString();
        selectedFloorMap = first['map_image_url']?.toString();
      }

      if (mounted) setState(() => isLoading = false);

      await _loadInitialPeople();
      _initRealtime();
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ======================
  // LOAD PEOPLE (CURRENT FLOOR)
  // ======================
  Future<void> _loadInitialPeople() async {
    if (selectedFloorId == null) return;

    try {
      final res = await supabase
          .from('view_people_live')
          .select('''
            entity_id,
            full_name,
            rfid_tag_id,
            category_name,
            marker_color,
            x_pos,
            y_pos,
            floor_id,
            room_x_min,
            room_y_min,
            room_x_max,
            room_y_max,
            floor_alias,
            building_id
          ''')
          .eq('floor_id', selectedFloorId!);

      final raw = List<Map<String, dynamic>>.from(res);

      peopleMap.clear();
      _positionCache.clear();

      for (final e in raw) {
        final p = EntityPeopleModel.fromJson(e);
        peopleMap[p.entityId] = p;
      }

      if (mounted) setState(() {});
    } catch (_) {}
  }

  // ======================
  // REALTIME
  // ======================
  void _initRealtime() {
    _channel = supabase.channel('people-live-channel');

    void triggerDebounced(void Function() action) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), action);
    }

    _channel!
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'people',
        callback: (_) {
          triggerDebounced(() {
            if (_canUpdate()) {
              _handleRealtimeUpdate();
            }
          });
        },
      )
      ..subscribe();
  }

  bool _canUpdate() {
    final now = DateTime.now();
    if (_lastUpdate == null ||
        now.difference(_lastUpdate!) > const Duration(milliseconds: 100)) {
      _lastUpdate = now;
      return true;
    }
    return false;
  }

  void _handleRealtimeUpdate() {
    if (selectedFloorId == null) return;
    _loadInitialPeople();
  }

  // ======================
  // SEARCH
  // ======================
  void _onSearchChanged(String value) {
    final q = value.trim();

    if (q.isEmpty) {
      searchResults.value = const <EntityPeopleModel>[];
      return;
    }

    selectedEntityId.value = null;
    selectedCategories.value = const <String>{};

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      _searchPeople(q);
    });
  }

  Future<void> _runSearchNow() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    await _searchPeople(q, force: true);
  }

  Future<void> _searchPeople(String query, {bool force = false}) async {
    final q = query.trim();
    if (q.isEmpty) {
      searchResults.value = const <EntityPeopleModel>[];
      return;
    }

    if (!force && q.length < 2) {
      searchResults.value = const <EntityPeopleModel>[];
      return;
    }

    final seq = ++_searchSeq;

    try {
      final res = await supabase
          .from('view_people_live')
          .select('''
            entity_id,
            full_name,
            rfid_tag_id,
            category_name,
            marker_color,
            floor_id,
            floor_alias,
            building_id,
            x_pos,
            y_pos,
            room_x_min,
            room_y_min,
            room_x_max,
            room_y_max
          ''')
          .ilike('full_name', '%$q%')
          .order('full_name')
          .limit(12);

      if (!mounted || seq != _searchSeq) return;

      final raw = List<Map<String, dynamic>>.from(res);
      final results = raw.map((e) => EntityPeopleModel.fromJson(e)).toList();
      searchResults.value = results;
    } catch (_) {
      if (mounted && seq == _searchSeq) {
        searchResults.value = const <EntityPeopleModel>[];
      }
    }
  }

  // ======================
  // CATEGORY FILTER
  // ======================
  void _toggleCategory(String category) {
    selectedEntityId.value = null;
    _searchCtrl.clear();
    searchResults.value = const <EntityPeopleModel>[];

    final next = Set<String>.from(selectedCategories.value);
    if (next.contains(category)) {
      next.remove(category);
    } else {
      next.add(category);
    }

    selectedCategories.value = next;
  }

  void _clearFilters() {
    selectedEntityId.value = null;
    selectedCategories.value = const <String>{};
    _searchCtrl.clear();
    searchResults.value = const <EntityPeopleModel>[];
  }

  // ======================
  // FLOOR SWITCH
  // ======================
  Future<void> _selectFloorById(
    String floorId, {
    bool clearSelections = true,
  }) async {
    final floor = _findFloorById(floorId);
    if (floor == null) return;

    FocusScope.of(context).unfocus();

    setState(() {
      selectedFloorId = floor['id']?.toString();
      selectedFloorMap = floor['map_image_url']?.toString();
      _initDone = false;
      _controller.value = Matrix4.identity();
    });

    _positionCache.clear();

    if (clearSelections) {
      _clearFilters();
    }

    if (selectedFloorMap != null && selectedFloorMap!.isNotEmpty) {
      await precacheImage(NetworkImage(selectedFloorMap!), context);
    }

    await _loadInitialPeople();
  }

  // ======================
  // POSITION IN BOUNDING BOX
  // ======================
  Offset _getPosition(EntityPeopleModel p) {
    if (_positionCache.containsKey(p.entityId)) {
      return _positionCache[p.entityId]!;
    }

    final rand = Random(p.entityId.hashCode);

    final minX = min(
      (p.roomXMin ?? p.xPos ?? 0).toDouble(),
      (p.roomXMax ?? p.xPos ?? 0).toDouble(),
    );
    final maxX = max(
      (p.roomXMin ?? p.xPos ?? 0).toDouble(),
      (p.roomXMax ?? p.xPos ?? 0).toDouble(),
    );
    final minY = min(
      (p.roomYMin ?? p.yPos ?? 0).toDouble(),
      (p.roomYMax ?? p.yPos ?? 0).toDouble(),
    );
    final maxY = max(
      (p.roomYMin ?? p.yPos ?? 0).toDouble(),
      (p.roomYMax ?? p.yPos ?? 0).toDouble(),
    );

    final x = minX + rand.nextDouble() * (maxX - minX);
    final y = minY + rand.nextDouble() * (maxY - minY);

    final pos = Offset(x, y);
    _positionCache[p.entityId] = pos;

    return pos;
  }

  // ======================
  // FOCUS TARGET
  // ======================
  Future<void> _focusToPerson(EntityPeopleModel p) async {
    FocusScope.of(context).unfocus();

    if (p.floorId != null && p.floorId != selectedFloorId) {
      await _selectFloorById(p.floorId!, clearSelections: true);
    } else {
      selectedEntityId.value = null;
      selectedCategories.value = const <String>{};
      _searchCtrl.clear();
      searchResults.value = const <EntityPeopleModel>[];
    }

    selectedEntityId.value = p.entityId;

    final pos = _getPosition(p);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _controller.value = Matrix4.identity()
        ..scale(1.5)
        ..translate((-pos.dx + 220).toDouble(), (-pos.dy + 220).toDouble());
    });
  }

  // ======================
  // BUILD
  // ======================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (selectedFloorMap == null || selectedFloorMap!.isEmpty) {
      return const Center(child: Text("Map tidak tersedia"));
    }

    final people = peopleMap.values.toList();

    return Stack(children: [_buildMap(people), _buildOverlayCard(people)]);
  }

  Widget _buildMap(List<EntityPeopleModel> people) {
    return Positioned.fill(
      child: RepaintBoundary(
        child: InteractiveViewer(
          transformationController: _controller,
          constrained: false,
          alignment: Alignment.topLeft,
          boundaryMargin: const EdgeInsets.all(3000),
          minScale: 0.2,
          maxScale: 5,
          child: SizedBox(
            width: BASE_SIZE,
            height: BASE_SIZE,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.modulate,
                    ),
                    child: Opacity(
                      opacity: 0.4,
                      child: Image.network(
                        selectedFloorMap!,
                        fit: BoxFit.fill,
                        cacheWidth: 2000,
                        filterQuality: FilterQuality.low,
                      ),
                    ),
                  ),
                ),
                ...people.map((p) {
                  final pos = _getPosition(p);

                  return Positioned(
                    left: pos.dx,
                    top: pos.dy,
                    child: _MarkerWidget(
                      person: p,
                      markerColor: _parseColor(p.markerColor),
                      pulse: _pulseController,
                      selectedEntityId: selectedEntityId,
                      selectedCategories: selectedCategories,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayCard(List<EntityPeopleModel> people) {
    final categories = <String>{
      for (final p in people)
        if (p.categoryName != null && p.categoryName!.trim().isNotEmpty)
          p.categoryName!.trim(),
    }.toList()..sort();

    return Positioned(
      top: 2,
      left: 6,
      right: 6,
      child: SafeArea(
        bottom: false,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D47A1).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchCtrl,
                builder: (context, searchValue, _) {
                  final query = searchValue.text.trim();
                  final showCategories =
                      query.isEmpty && (searchResults.value.isEmpty);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 162, 198, 247).withOpacity(0.88),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  isDense: true,
                                  value:
                                      floors.any(
                                        (f) =>
                                            f['id']?.toString() ==
                                            selectedFloorId,
                                      )
                                      ? selectedFloorId
                                      : null,
                                  iconSize: 18,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  items: floors.map((f) {
                                    final label = _floorLabel(f);
                                    return DropdownMenuItem<String>(
                                      value: f['id']?.toString(),
                                      child: Text(
                                        label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    );
                                  }).toList(),
                                  selectedItemBuilder: (context) {
                                    return floors.map((f) {
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          _floorLabel(f),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      );
                                    }).toList();
                                  },
                                  onChanged: (val) async {
                                    if (val == null) return;
                                    await _selectFloorById(
                                      val,
                                      clearSelections: true,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 36,
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: _onSearchChanged,
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  hintText: 'Cari orang...',
                                  hintStyle: const TextStyle(fontSize: 11),
                                  isDense: true,
                                  filled: true,
                                  fillColor: const Color.fromARGB(255, 162, 198, 247).withOpacity(0.88),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    size: 18,
                                  ),
                                  suffixIconConstraints: const BoxConstraints(
                                    minHeight: 30,
                                    minWidth: 60,
                                  ),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Cari',
                                        icon: const Icon(
                                          Icons.arrow_forward,
                                          size: 18,
                                        ),
                                        onPressed: _runSearchNow,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minHeight: 28,
                                          minWidth: 28,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Bersihkan',
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () {
                                          _searchCtrl.clear();
                                          searchResults.value =
                                              const <EntityPeopleModel>[];
                                          selectedEntityId.value = null;
                                          selectedCategories.value =
                                              const <String>{};
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minHeight: 28,
                                          minWidth: 28,
                                        ),
                                      ),
                                    ],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onSubmitted: (_) => _runSearchNow(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      ValueListenableBuilder<List<EntityPeopleModel>>(
                        valueListenable: searchResults,
                        builder: (_, results, __) {
                          if (results.isEmpty) return const SizedBox.shrink();

                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            constraints: const BoxConstraints(maxHeight: 170),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 162, 198, 247).withOpacity(0.88),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color.fromARGB(255, 162, 198, 247).withOpacity(0.88),
                              ),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: results.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: const Color.fromARGB(255, 86, 122, 139).withOpacity(0.15),
                              ),
                              itemBuilder: (_, i) {
                                final p = results[i];
                                return ListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 0,
                                  ),
                                  title: Text(
                                    p.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Kategori: ${p.categoryName ?? '-'}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      Text(
                                        'RFID: ${p.rfidTagId ?? '-'}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      Text(
                                        _floorLabelById(p.floorId),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                  onTap: () => _focusToPerson(p),
                                );
                              },
                            ),
                          );
                        },
                      ),

                      if (showCategories && categories.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 34,
                          child: Row(
                            children: [
                              Expanded(
                                child: ValueListenableBuilder<Set<String>>(
                                  valueListenable: selectedCategories,
                                  builder: (_, selected, __) {
                                    return ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: categories.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 6),
                                      itemBuilder: (_, index) {
                                        final cat = categories[index];
                                        final active = selected.contains(cat);

                                        return ChoiceChip(
                                          label: Text(
                                            cat,
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                          selected: active,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                          selectedColor: const Color.fromARGB(255, 162, 198, 247).withOpacity(0.88),
                                          backgroundColor: const Color.fromARGB(255, 162, 198, 247).withOpacity(0.60),
                                          onSelected: (_) =>
                                              _toggleCategory(cat),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ======================
  // TRANSFORM
  // ======================
  void _setInitialTransform(BoxConstraints c) {
    final scale = c.maxWidth / BASE_SIZE;
    final scaledHeight = BASE_SIZE * scale;
    final offsetY = (c.maxHeight - scaledHeight) / 2;

    _controller.value = Matrix4.identity()
      ..scale(scale)
      ..translate(0.0, offsetY / scale);
  }

  // ======================
  // COLOR PARSER
  // ======================
  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.blue;

    final cleaned = hexColor.replaceAll('#', '');

    if (cleaned.length != 6 && cleaned.length != 8) {
      return Colors.blue;
    }

    final hex = cleaned.length == 6 ? 'FF$cleaned' : cleaned;
    final intColor = int.tryParse(hex, radix: 16);

    if (intColor == null) return Colors.blue;

    return Color(intColor);
  }
}

class _MarkerWidget extends StatelessWidget {
  final EntityPeopleModel person;
  final Color markerColor;
  final AnimationController pulse;
  final ValueNotifier<String?> selectedEntityId;
  final ValueNotifier<Set<String>> selectedCategories;

  const _MarkerWidget({
    required this.person,
    required this.markerColor,
    required this.pulse,
    required this.selectedEntityId,
    required this.selectedCategories,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: selectedEntityId,
      builder: (_, selectedId, __) {
        return ValueListenableBuilder<Set<String>>(
          valueListenable: selectedCategories,
          builder: (_, cats, __) {
            final isFocus = selectedId == person.entityId;
            final hasCategoryFilter = cats.isNotEmpty;
            final isCategoryMatch = cats.contains(person.categoryName);

            final markerBody = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_pin_circle_rounded,
                  color: markerColor,
                  size: 40,
                ),
                const SizedBox(height: 2),
                Column(
                  children: [
                    Text(
                      person.name,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      person.categoryName ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ],
            );

            if (isFocus) {
              return AnimatedBuilder(
                animation: pulse,
                builder: (_, __) {
                  final wave = (sin(pulse.value * 2 * pi) + 1) / 2;
                  final opacity = 0.70 + (0.30 * wave);
                  final scale = 1.05 + (0.22 * wave);

                  return Opacity(
                    opacity: opacity,
                    child: Transform.scale(scale: scale, child: markerBody),
                  );
                },
              );
            }

            if (hasCategoryFilter && !isCategoryMatch) {
              return Opacity(opacity: 0.18, child: markerBody);
            }

            if (hasCategoryFilter && isCategoryMatch) {
              return AnimatedBuilder(
                animation: pulse,
                builder: (_, __) {
                  final wave = (sin(pulse.value * 2 * pi) + 1) / 2;
                  final opacity = 0.78 + (0.22 * wave);
                  final scale = 1.00 + (0.08 * wave);

                  return Opacity(
                    opacity: opacity,
                    child: Transform.scale(scale: scale, child: markerBody),
                  );
                },
              );
            }

            return markerBody;
          },
        );
      },
    );
  }
}
