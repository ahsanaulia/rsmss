import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../configs/table_configs.dart';

class DynamicPlutoGrid extends StatefulWidget {
  final String tableName;
  final TableConfig config;

  const DynamicPlutoGrid({
    super.key,
    required this.tableName,
    required this.config,
  });

  @override
  State<DynamicPlutoGrid> createState() => _DynamicPlutoGridState();
}

class _DynamicPlutoGridState extends State<DynamicPlutoGrid> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<PlutoColumn> _columns = [];
  List<PlutoRow> _rows = [];
  PlutoGridStateManager? _stateManager;
  bool _isLoading = true;
  String? _errorMessage;
  final GlobalKey<PlutoGridState> _gridKey = GlobalKey<PlutoGridState>();

  @override
  void initState() {
    super.initState();
    _initColumns();
    _loadData();
  }

  void _initColumns() {
    _columns = widget.config.columns.map((colConfig) {
      PlutoColumnType columnType = colConfig.type;
      
      // Jika ada selectItems, gunakan tipe select
      if (colConfig.selectItems != null && colConfig.selectItems!.isNotEmpty) {
        columnType = PlutoColumnType.select(colConfig.selectItems!);
      }
      
      return PlutoColumn(
        title: colConfig.title,
        field: colConfig.field,
        type: columnType,
        readOnly: colConfig.readOnly,
        width: colConfig.width?.toDouble() ?? 150.0,
        backgroundColor: Colors.white,
        textAlign: PlutoColumnTextAlign.left,
        titleTextAlign: PlutoColumnTextAlign.left,
      );
    }).toList();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final query = _supabase.from(widget.tableName).select();
      
      dynamic data;
      if (widget.config.orderBy != null) {
        data = await query.order(widget.config.orderBy!, ascending: true);
      } else {
        data = await query;
      }
      
      final rows = _convertToRows(data);
      
      setState(() {
        _rows = rows;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<PlutoRow> _convertToRows(List<dynamic> data) {
    return data.map((item) {
      final cells = <String, PlutoCell>{};
      
      for (final column in _columns) {
        dynamic value = item[column.field];
        
        // Format date if needed
        if (column.type == PlutoColumnType.date() && value != null && value is String) {
          try {
            value = DateTime.parse(value);
          } catch (_) {
            value = null;
          }
        }
        
        cells[column.field] = PlutoCell(value: value ?? '');
      }
      
      return PlutoRow(cells: cells);
    }).toList();
  }

  Future<void> _saveRow(PlutoRow row) async {
    final id = row.cells['id']?.value;
    if (id == null || id.toString().isEmpty) {
      // Insert new row
      final newData = <String, dynamic>{};
      for (final column in _columns) {
        if (!column.readOnly) {
          var value = row.cells[column.field]?.value;
          if (value is DateTime) {
            value = value.toIso8601String();
          }
          if (value != null && value.toString().isNotEmpty) {
            newData[column.field] = value;
          }
        }
      }
      
      if (newData.isNotEmpty) {
        await _supabase.from(widget.tableName).insert(newData);
        _showSnackBar('Data berhasil ditambahkan', Colors.green);
        await _loadData();
      }
    } else {
      // Update existing row
      final updateData = <String, dynamic>{};
      for (final column in _columns) {
        if (!column.readOnly) {
          var value = row.cells[column.field]?.value;
          if (value is DateTime) {
            value = value.toIso8601String();
          }
          updateData[column.field] = value;
        }
      }
      
      if (updateData.isNotEmpty) {
        await _supabase
            .from(widget.tableName)
            .update(updateData)
            .eq('id', id);
        _showSnackBar('Data berhasil diupdate', Colors.blue);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addNewRow() {
    final cells = <String, PlutoCell>{};
    for (final column in _columns) {
      cells[column.field] = PlutoCell(value: '');
    }
    final newRow = PlutoRow(cells: cells);
    
    _stateManager?.appendRows([newRow]);
    _stateManager?.setSelectingMode(PlutoGridSelectingMode.row);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF01579B)),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text('Error: $_errorMessage', style: GoogleFonts.poppins()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            border: const Border(
              bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
          ),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _addNewRow,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Baris'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01579B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF01579B),
                  side: const BorderSide(color: Color(0xFF01579B)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // PlutoGrid
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: PlutoGrid(
              key: _gridKey,
              columns: _columns,
              rows: _rows,
              onChanged: (PlutoGridOnChangedEvent event) {
                _saveRow(event.row);
              },
              onLoaded: (PlutoGridOnLoadedEvent event) {
                _stateManager = event.stateManager;
              },
              configuration: const PlutoGridConfiguration(
                scrollbar: PlutoGridScrollbarConfig(
                  isAlwaysShown: true,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}