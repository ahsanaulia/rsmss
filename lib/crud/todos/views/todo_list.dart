import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/todo_provider.dart';
import '../providers/todo_state.dart';
import '../models/todo_model.dart';
import 'todo_form.dart';
import 'todo_detail.dart';

class TodoListPage extends ConsumerStatefulWidget {
  const TodoListPage({super.key});

  @override
  ConsumerState<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends ConsumerState<TodoListPage> {
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _timeFormat = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(todoStateProvider.notifier).loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(todoStateProvider);
    final notifier = ref.read(todoStateProvider.notifier);

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
        'Manajemen Rutinitas Harian',
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

  Widget _buildFilterBar(TodoNotifier notifier, TodoState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Filter by Date
          Expanded(
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: state.filterDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  await notifier.setFilterDate(picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: const Color(0xFF01579B)),
                    const SizedBox(width: 8),
                    Text(
                      _dateFormat.format(state.filterDate),
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Filter by Unit
          Expanded(
            child: _buildUnitFilter(notifier, state),
          ),
          const SizedBox(width: 12),

          // Filter by Active Status
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

  Widget _buildUnitFilter(TodoNotifier notifier, TodoState state) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ref.read(todoServiceProvider).getUnits(),
      builder: (context, snapshot) {
        final units = snapshot.data ?? [];
        final selectedUnit = units.firstWhere(
          (u) => u['id'] == state.filterUnitId,
          orElse: () => {'id': '', 'name': 'Semua Unit'},
        );

        return InkWell(
          onTap: () async {
            final result = await showModalBottomSheet<Map<String, dynamic>>(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => _SearchableDropdownSheet(
                title: 'Pilih Unit',
                items: [{'id': '', 'name': 'Semua Unit'}, ...units],
                selectedId: state.filterUnitId ?? '',
              ),
            );
            if (result != null && mounted) {
              final unitId = result['id'] == '' ? null : result['id'];
              await notifier.setFilterUnitId(unitId);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.business, size: 16, color: const Color(0xFF01579B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedUnit['name'] ?? 'Semua Unit',
                    style: GoogleFonts.poppins(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataTable(List<TodoModel> items) {
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
            DataColumn(label: Text('TITLE')),
            DataColumn(label: Text('TARGET')),
            DataColumn(label: Text('TANGGAL')),
            DataColumn(label: Text('JAM')),
            DataColumn(label: Text('PRIORITY')),
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: items.map((item) => _buildDataRow(item)).toList(),
        ),
      ),
    );
  }

  DataRow _buildDataRow(TodoModel item) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 200,
            child: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.targetUnitName != null)
                  Text(
                    item.targetUnitName!,
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700),
                  ),
                if (item.targetPositionName != null)
                  Text(
                    item.targetPositionName!,
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700),
                  ),
                if (item.targetShiftName != null)
                  Text(
                    item.targetShiftName!,
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700),
                  ),
                if (item.targetUnitName == null &&
                    item.targetPositionName == null &&
                    item.targetShiftName == null)
                  Text(
                    'Semua',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ),
        ),
        DataCell(
          Text(
            _dateFormat.format(item.todoDate),
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
        DataCell(
          Text(
            '${item.startTime != null ? _timeFormat.format(DateTime(0, 0, 0, item.startTime!.hour, item.startTime!.minute)) : "-"} - '
            '${item.endTime != null ? _timeFormat.format(DateTime(0, 0, 0, item.endTime!.hour, item.endTime!.minute)) : "-"}',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.priorityColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.priorityLabel,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: item.priorityColor,
              ),
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
                onPressed: () => _showForm(context, todo: item),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: Icon(Icons.copy, size: 18, color: Colors.purple.shade600),
                onPressed: () => _showCopyDialog(item),
                tooltip: 'Copy ke tanggal lain',
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
          Icon(Icons.checklist, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Tidak ada To Do',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Klik tombol + untuk menambahkan To Do',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  void _showForm(BuildContext context, {TodoModel? todo}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TodoFormPage(
        todo: todo,
        onSaved: () {
          ref.read(todoStateProvider.notifier).loadItems();
        },
      ),
    );
  }

  void _showDetail(BuildContext context, TodoModel todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TodoDetailPage(todo: todo),
    );
  }

  void _showDeleteDialog(TodoModel todo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Hapus To Do',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${todo.title}"?',
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
              await ref.read(todoStateProvider.notifier).delete(todo.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('To Do berhasil dihapus', style: GoogleFonts.poppins()),
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

  void _showCopyDialog(TodoModel todo) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: todo.todoDate.add(const Duration(days: 1)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (newDate != null && mounted) {
      await ref.read(todoStateProvider.notifier).copyToDate(todo.id, newDate);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'To Do berhasil digandakan ke ${DateFormat('dd MMM yyyy').format(newDate)}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

// ==================== SEARCHABLE DROPDOWN SHEET ====================

class _SearchableDropdownSheet extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String selectedId;

  const _SearchableDropdownSheet({
    required this.title,
    required this.items,
    required this.selectedId,
  });

  @override
  State<_SearchableDropdownSheet> createState() => _SearchableDropdownSheetState();
}

class _SearchableDropdownSheetState extends State<_SearchableDropdownSheet> {
  late List<Map<String, dynamic>> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          final name = item['name']?.toString().toLowerCase() ?? '';
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF01579B),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterItems,
              decoration: InputDecoration(
                hintText: 'Cari...',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF01579B)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                final isSelected = item['id'] == widget.selectedId;
                return ListTile(
                  title: Text(
                    item['name'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: Colors.green.shade600)
                      : null,
                  tileColor: isSelected ? Colors.green.withOpacity(0.1) : null,
                  onTap: () => Navigator.pop(context, item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}