import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/employee_unit_provider.dart';
import '../providers/employee_unit_state.dart';
import '../models/employee_unit_model.dart';
import 'employee_unit_form.dart';
import 'employee_unit_detail.dart';

class EmployeeUnitListPage extends ConsumerStatefulWidget {
  const EmployeeUnitListPage({super.key});

  @override
  ConsumerState<EmployeeUnitListPage> createState() => _EmployeeUnitListPageState();
}

class _EmployeeUnitListPageState extends ConsumerState<EmployeeUnitListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(employeeUnitStateProvider.notifier).loadItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeUnitStateProvider);
    final notifier = ref.read(employeeUnitStateProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterBar(notifier, state),
          Expanded(
            child: state.isLoading && state.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.items.isEmpty
                    ? _buildEmptyState()
                    : _buildDataTable(state.items),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        backgroundColor: const Color(0xFF01579B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Manajemen Unit / Departemen',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF01579B),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFF01579B)),
    );
  }

  Widget _buildFilterBar(EmployeeUnitNotifier notifier, EmployeeUnitState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Search
          Expanded(
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari unit...',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF01579B), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              ),
              onSubmitted: (value) async {
                await notifier.setFilterSearch(value.trim().isEmpty ? null : value.trim());
              },
            ),
          ),
          const SizedBox(width: 12),

          // Filter Active Status
          Row(
            children: [
              Text(
                'Aktif',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              const SizedBox(width: 8),
              Switch(
                value: state.filterIsActive,
                onChanged: (value) async {
                  await notifier.setFilterIsActive(value);
                },
                activeColor: const Color(0xFF01579B),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Refresh button
          IconButton(
            onPressed: () => notifier.loadItems(),
            icon: const Icon(Icons.refresh),
            color: const Color(0xFF01579B),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<EmployeeUnitModel> items) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 16,
          headingRowColor: WidgetStateProperty.resolveWith(
            (states) => const Color(0xFF01579B).withOpacity(0.1),
          ),
          headingTextStyle: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF01579B),
          ),
          columns: const [
            DataColumn(label: Text('KODE')),
            DataColumn(label: Text('NAMA UNIT')),
            DataColumn(label: Text('INDUK UNIT')),
            DataColumn(label: Text('LEVEL')),
            DataColumn(label: Text('KEPALA UNIT')),
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: items.map((item) => _buildDataRow(item)).toList(),
        ),
      ),
    );
  }

  DataRow _buildDataRow(EmployeeUnitModel item) {
    return DataRow(
      cells: [
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF01579B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.unitCode,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF01579B),
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 200,
            child: Text(
              item.unitName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        DataCell(
          Text(
            item.parentUnitName ?? '-',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Level ${item.unitLevel}',
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 150,
            child: Text(
              item.headOfUnitName ?? '-',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.isActive ? 'Aktif' : 'Nonaktif',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: item.isActive ? Colors.green : Colors.red,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.visibility, size: 18, color: Colors.blue.shade600),
                onPressed: () => _showDetail(context, item),
                tooltip: 'Detail',
              ),
              IconButton(
                icon: Icon(Icons.edit, size: 18, color: Colors.orange.shade700),
                onPressed: () => _showForm(context, item: item),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: Icon(Icons.delete, size: 18, color: Colors.red.shade600),
                onPressed: () => _showDeleteDialog(item),
                tooltip: 'Hapus',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_center, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data unit',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Klik tombol + untuk menambahkan unit',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  void _showForm(BuildContext context, {EmployeeUnitModel? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EmployeeUnitFormPage(
        item: item,
        onSaved: () {
          ref.read(employeeUnitStateProvider.notifier).loadItems();
        },
      ),
    );
  }

  void _showDetail(BuildContext context, EmployeeUnitModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EmployeeUnitDetailPage(item: item),
    );
  }

  void _showDeleteDialog(EmployeeUnitModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Hapus Unit',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus unit "${item.unitName}"?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(employeeUnitStateProvider.notifier).delete(item.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Unit berhasil dihapus', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Hapus', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}