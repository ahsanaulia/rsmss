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
      return PlutoColumn(
        title: colConfig.title,
        field: colConfig.field,
        type: colConfig.type,
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
      }
    }
  }

  Future<void> _deleteRow(PlutoRow row) async {
    final id = row.cells['id']?.value;
    if (id == null || id.toString().isEmpty) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Hapus data ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    
    if (confirm == true) {
      await _supabase.from(widget.tableName).delete().eq('id', id);
      await _loadData();
    }
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
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text('Error: $_errorMessage', style: GoogleFonts.poppins()),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Toolbar
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _addNewRow,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Baris'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01579B),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
        
        // PlutoGrid
        Expanded(
          child: PlutoGrid(
            key: _gridKey,
            columns: _columns,
            rows: _rows,
            onChanged: (PlutoGridOnChangedEvent event) {
              final row = event.row;
              _saveRow(row);
            },
            onLoaded: (PlutoGridOnLoadedEvent event) {
              _stateManager = event.stateManager;
            },
            configuration: const PlutoGridConfiguration(
              style: PlutoGridStyleConfig(
                oddRowColor: Color(0xFFF5F5F5),
                gridBorderColor: Colors.grey,
                enableGridBorderShadow: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}