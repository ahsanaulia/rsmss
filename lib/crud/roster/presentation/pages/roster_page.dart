// lib/features/roster/presentation/pages/roster_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/roster_provider.dart';
import '../providers/roster_filter_provider.dart';
import '../providers/roster_state.dart';
import '../widgets/roster_calendar_view.dart';
import '../widgets/roster_form_dialog.dart';
import '../widgets/roster_bulk_assign_dialog.dart';

class RosterPage extends ConsumerStatefulWidget {
  const RosterPage({super.key});

  @override
  ConsumerState<RosterPage> createState() => _RosterPageState();
}

class _RosterPageState extends ConsumerState<RosterPage> {
  // Hapus _currentMonth karena tidak digunakan (state sudah pakai currentMonth dari provider)
  // Tidak perlu PageController karena tidak menggunakan PageView

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(rosterProvider);
      if (state.rosters.isEmpty && !state.isLoading) {
        ref.read(rosterProvider.notifier).loadData();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleMessages(RosterState state, RosterNotifier notifier) {
    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
          notifier.clearMessages();
        }
      });
    }
    
    if (state.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
          notifier.clearMessages();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rosterProvider);
    final notifier = ref.read(rosterProvider.notifier);
    
    _handleMessages(state, notifier);

    return Column(
      children: [
        _buildToolbar(state, notifier),
        Expanded(
          child: RosterCalendarView(
            rosters: state.rosters,
            shifts: state.shifts,
            employees: state.employees,
            currentMonth: state.currentMonth,
            onMonthChanged: (month) => notifier.loadRostersForMonth(month),
            onDateSelected: (date) => notifier.selectDate(date),
            onEditRoster: (roster) => notifier.startEdit(roster.id),
            onDeleteRoster: (id) => _confirmDelete(context, notifier, id),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(RosterState state, RosterNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          // Month navigation
          IconButton(
            onPressed: () {
              final newMonth = DateTime(state.currentMonth.year, state.currentMonth.month - 1);
              notifier.loadRostersForMonth(newMonth);
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            DateFormat('MMMM yyyy', 'id').format(state.currentMonth),
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          IconButton(
            onPressed: () {
              final newMonth = DateTime(state.currentMonth.year, state.currentMonth.month + 1);
              notifier.loadRostersForMonth(newMonth);
            },
            icon: const Icon(Icons.chevron_right),
          ),
          const SizedBox(width: 16),
          // Today button
          ElevatedButton(
            onPressed: () {
              notifier.loadRostersForMonth(DateTime.now());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.black87,
            ),
            child: const Text('Hari Ini'),
          ),
          const Spacer(),
          // Bulk assign button
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => RosterBulkAssignDialog(
                  shifts: state.shifts,
                  employees: state.employees,
                  onAssign: (rosters) async {
                    await notifier.bulkAssignRosters(rosters);
                    if (mounted) Navigator.pop(ctx);
                  },
                ),
              );
            },
            icon: const Icon(Icons.multiple_stop, size: 18),
            label: const Text('Assign Massal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          // Add button
          ElevatedButton.icon(
            onPressed: state.isSaving ? null : () => notifier.startAddNew(),
            icon: state.isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.add, size: 18),
            label: const Text('Tambah Jadwal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF01579B),
              foregroundColor: Colors.white,
            ),
          ),
          // Add New Form Dialog when isAddingNew is true
          if (state.isAddingNew)
            Builder(
              builder: (context) {
                // Trigger dialog when isAddingNew becomes true
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (state.isAddingNew && mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => RosterFormDialog(
                        roster: null,
                        shifts: state.shifts,
                        employees: state.employees,
                        onSave: (roster) async {
                          await notifier.saveRoster(roster);
                          if (mounted) Navigator.pop(ctx);
                        },
                      ),
                    ).then((_) {
                      if (mounted && state.isAddingNew) {
                        notifier.cancelEdit();
                      }
                    });
                  }
                });
                return const SizedBox.shrink();
              },
            ),
          // Edit Form Dialog when editingId is not null
          if (state.editingId != null)
            Builder(
              builder: (context) {
                final editingRoster = state.rosters.firstWhere(
                  (r) => r.id == state.editingId,
                  orElse: () => throw Exception('Roster not found'),
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (state.editingId != null && mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => RosterFormDialog(
                        roster: editingRoster,
                        shifts: state.shifts,
                        employees: state.employees,
                        onSave: (roster) async {
                          await notifier.saveRoster(roster);
                          if (mounted) Navigator.pop(ctx);
                        },
                      ),
                    ).then((_) {
                      if (mounted && state.editingId != null) {
                        notifier.cancelEdit();
                      }
                    });
                  }
                });
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, RosterNotifier notifier, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: const Text('Yakin ingin menghapus jadwal ini?'),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (mounted) Navigator.pop(ctx);
              notifier.deleteRoster(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}