import 'package:pluto_grid/pluto_grid.dart';

class TableColumnConfig {
  final String field;
  final String title;
  final PlutoColumnType type;
  final bool readOnly;
  final double? width;
  final List<String>? selectItems;

  TableColumnConfig({
    required this.field,
    required this.title,
    required this.type,
    this.readOnly = false,
    this.width,
    this.selectItems,
  });
}

class TableConfig {
  final String tableName;
  final String displayName;
  final List<TableColumnConfig> columns;
  final String? orderBy;

  TableConfig({
    required this.tableName,
    required this.displayName,
    required this.columns,
    this.orderBy,
  });
}

// =====================================================
// KONFIGURASI SEMUA TABEL
// =====================================================
final Map<String, TableConfig> tableConfigs = {
  // ==================== PROFILES ====================
  'profiles': TableConfig(
    tableName: 'profiles',
    displayName: 'Data Pegawai',
    orderBy: 'full_name',
    columns: [
      TableColumnConfig(field: 'id', title: 'ID', type: PlutoColumnType.text(), readOnly: true, width: 280),
      TableColumnConfig(field: 'full_name', title: 'Nama Lengkap', type: PlutoColumnType.text(), width: 180),
      TableColumnConfig(field: 'role', title: 'Role', type: PlutoColumnType.select(['operation', 'management', 'admin', 'monitor', 'control_room']), width: 140),
      TableColumnConfig(field: 'employee_id', title: 'NIK', type: PlutoColumnType.text(), width: 120),
      TableColumnConfig(field: 'phone', title: 'Telepon', type: PlutoColumnType.text(), width: 130),
      TableColumnConfig(field: 'unit_code', title: 'Unit', type: PlutoColumnType.text(), width: 100),
      TableColumnConfig(field: 'current_situation', title: 'Status', type: PlutoColumnType.select(['ACTIVE', 'ON_LEAVE', 'SICK', 'DUTY_OUT']), width: 100),
      TableColumnConfig(field: 'join_year', title: 'Thn Masuk', type: PlutoColumnType.number(), width: 90),
    ],
  ),

  // ==================== ASSETS ====================
  'assets': TableConfig(
    tableName: 'assets',
    displayName: 'Asset',
    orderBy: 'asset_name',
    columns: [
      TableColumnConfig(field: 'id', title: 'ID', type: PlutoColumnType.text(), readOnly: true, width: 280),
      TableColumnConfig(field: 'asset_name', title: 'Nama Asset', type: PlutoColumnType.text(), width: 200),
      TableColumnConfig(field: 'rfid_tag_id', title: 'RFID Tag', type: PlutoColumnType.text(), width: 150),
      TableColumnConfig(field: 'status_condition', title: 'Kondisi', type: PlutoColumnType.select(['Good', 'Fair', 'Broken', 'Maintenance']), width: 110),
      TableColumnConfig(field: 'is_dangerous', title: 'Berbahaya', type: PlutoColumnType.select(['true', 'false']), width: 100),
      TableColumnConfig(field: 'registered_at', title: 'Tgl Registrasi', type: PlutoColumnType.date(), width: 130),
    ],
  ),

  // ==================== STOCKS ====================
  'stocks': TableConfig(
    tableName: 'stocks',
    displayName: 'Stock',
    orderBy: 'stock_name',
    columns: [
      TableColumnConfig(field: 'id', title: 'ID', type: PlutoColumnType.text(), readOnly: true, width: 280),
      TableColumnConfig(field: 'stock_code', title: 'Kode Stock', type: PlutoColumnType.text(), width: 120),
      TableColumnConfig(field: 'stock_name', title: 'Nama Stock', type: PlutoColumnType.text(), width: 200),
      TableColumnConfig(field: 'unit', title: 'Satuan', type: PlutoColumnType.text(), width: 80),
      TableColumnConfig(field: 'current_stock', title: 'Stok Saat Ini', type: PlutoColumnType.number(), width: 120),
      TableColumnConfig(field: 'minimum_stock', title: 'Min Stok', type: PlutoColumnType.number(), width: 100),
      TableColumnConfig(field: 'stock_condition', title: 'Kondisi', type: PlutoColumnType.select(['GOOD', 'LOW', 'EMPTY']), width: 100),
      TableColumnConfig(field: 'expiry_date', title: 'Expired', type: PlutoColumnType.date(), width: 120),
    ],
  ),

  // ==================== EMPLOYEE SHIFT ROSTERS ====================
  'employee_shift_rosters': TableConfig(
    tableName: 'employee_shift_rosters',
    displayName: 'Jadwal Kerja',
    orderBy: 'roster_date',
    columns: [
      TableColumnConfig(field: 'id', title: 'ID', type: PlutoColumnType.text(), readOnly: true, width: 280),
      TableColumnConfig(field: 'profile_id', title: 'Pegawai ID', type: PlutoColumnType.text(), width: 280),
      TableColumnConfig(field: 'roster_date', title: 'Tanggal', type: PlutoColumnType.date(), width: 120),
      TableColumnConfig(field: 'shift_id', title: 'Shift ID', type: PlutoColumnType.text(), width: 280),
      TableColumnConfig(field: 'location_name', title: 'Lokasi', type: PlutoColumnType.text(), width: 180),
      TableColumnConfig(field: 'is_day_off', title: 'Libur', type: PlutoColumnType.select(['true', 'false']), width: 80),
      TableColumnConfig(field: 'attendance_status', title: 'Status', type: PlutoColumnType.select(['scheduled', 'checked_in', 'checked_out', 'late', 'absent']), width: 120),
    ],
  ),

  // ==================== TASKS ====================
  'tasks': TableConfig(
    tableName: 'tasks',
    displayName: 'Penugasan',
    orderBy: 'created_at',
    columns: [
      TableColumnConfig(field: 'id', title: 'ID', type: PlutoColumnType.text(), readOnly: true, width: 280),
      TableColumnConfig(field: 'object_name', title: 'Tugas', type: PlutoColumnType.text(), width: 200),
      TableColumnConfig(field: 'assignee_id', title: 'Penerima', type: PlutoColumnType.text(), width: 280),
      TableColumnConfig(field: 'priority', title: 'Prioritas', type: PlutoColumnType.select(['normal', 'urgent', 'emergency']), width: 100),
      TableColumnConfig(field: 'status', title: 'Status', type: PlutoColumnType.select(['pending', 'accepted', 'done', 'rejected', 'cancelled']), width: 110),
      TableColumnConfig(field: 'created_at', title: 'Dibuat', type: PlutoColumnType.date(), width: 130),
    ],
  ),

  // ==================== INCIDENTS ====================
  'incidents': TableConfig(
    tableName: 'incidents',
    displayName: 'Insiden',
    orderBy: 'created_at',
    columns: [
      TableColumnConfig(field: 'id', title: 'ID', type: PlutoColumnType.text(), readOnly: true, width: 280),
      TableColumnConfig(field: 'title', title: 'Judul', type: PlutoColumnType.text(), width: 200),
      TableColumnConfig(field: 'severity', title: 'Severity', type: PlutoColumnType.select(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']), width: 100),
      TableColumnConfig(field: 'status', title: 'Status', type: PlutoColumnType.select(['reported', 'investigating', 'resolved', 'closed']), width: 120),
      TableColumnConfig(field: 'occurred_at', title: 'Kejadian', type: PlutoColumnType.date(), width: 130),
    ],
  ),
};