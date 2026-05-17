// lib/crud/views/tables/announcements_table.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/announcement_state.dart';
import '../../models/announcement_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/di/service_locator.dart';

// ============================================================
// PROVIDER UNTUK FILTER (Dipisah dari UI state)
// ============================================================
final announcementSearchProvider = StateProvider<String>((ref) => '');
final announcementFilterPriorityProvider = StateProvider<String>((ref) => 'all');

// ============================================================
// MAIN WIDGET
// ============================================================
class AnnouncementsTable extends ConsumerStatefulWidget {
  const AnnouncementsTable({super.key});

  @override
  ConsumerState<AnnouncementsTable> createState() => _AnnouncementsTableState();
}

class _AnnouncementsTableState extends ConsumerState<AnnouncementsTable> {
  late final AuthService _authService;
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        ref.read(announcementSearchProvider.notifier).state = _searchController.text.toLowerCase();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(announcementProvider);
      if (currentState.announcements.isEmpty && !currentState.isLoading) {
        ref.read(announcementProvider.notifier).loadData();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String? get _currentUserId => _authService.currentUserId;

  List<AnnouncementModel> _getFilteredAnnouncements(
    List<AnnouncementModel> announcements,
    String searchQuery,
    String priorityFilter,
  ) {
    return announcements.where((ann) {
      if (searchQuery.isNotEmpty) {
        final titleMatch = ann.title.toLowerCase().contains(searchQuery);
        final senderMatch = ann.senderName?.toLowerCase().contains(searchQuery) ?? false;
        if (!titleMatch && !senderMatch) return false;
      }
      if (priorityFilter != 'all' && ann.priority != priorityFilter) return false;
      return true;
    }).toList();
  }

  void _handleMessages(AnnouncementState currentState, AnnouncementNotifier notifier) {
    if (currentState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(currentState.errorMessage!),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
          notifier.clearMessages();
        }
      });
    }
    
    if (currentState.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(currentState.successMessage!),
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
    final currentState = ref.watch(announcementProvider);
    final notifier = ref.read(announcementProvider.notifier);
    final searchQuery = ref.watch(announcementSearchProvider);
    final priorityFilter = ref.watch(announcementFilterPriorityProvider);
    
    _handleMessages(currentState, notifier);
    
    final filteredAnnouncements = _getFilteredAnnouncements(
      currentState.announcements,
      searchQuery,
      priorityFilter,
    );

    return Column(
      children: [
        _buildToolbar(priorityFilter, notifier, currentState),
        Expanded(
          child: _buildBody(currentState, filteredAnnouncements, notifier),
        ),
      ],
    );
  }

  Widget _buildToolbar(String priorityFilter, AnnouncementNotifier notifier, AnnouncementState currentState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        border: const Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari pengumuman...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(announcementSearchProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 140,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: priorityFilter,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Semua Prioritas')),
                  DropdownMenuItem(value: 'normal', child: Text('Normal')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                  DropdownMenuItem(value: 'emergency', child: Text('Emergency')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(announcementFilterPriorityProvider.notifier).state = value;
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: currentState.isSaving ? null : () => notifier.startAddNew(),
            icon: currentState.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.add, size: 18),
            label: const Text('Buat Pengumuman'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF01579B),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    AnnouncementState currentState,
    List<AnnouncementModel> filteredAnnouncements,
    AnnouncementNotifier notifier,
  ) {
    if (currentState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF01579B)));
    }
    
    if (filteredAnnouncements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Belum ada pengumuman',
              style: GoogleFonts.poppins(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredAnnouncements.length + (currentState.isAddingNew ? 1 : 0),
      itemBuilder: (context, index) {
        if (currentState.isAddingNew && index == 0) {
          return _AddNewForm(
            key: const ValueKey('add_new_form'),
            state: currentState,
            notifier: notifier,
            currentUserId: _currentUserId,
          );
        }
        
        final annIndex = currentState.isAddingNew ? index - 1 : index;
        if (annIndex >= filteredAnnouncements.length) return const SizedBox();
        
        final announcement = filteredAnnouncements[annIndex];
        final isEditing = currentState.editingId == announcement.id;
        
        return _AnnouncementItem(
          key: ValueKey('ann_${announcement.id}_${isEditing ? 'edit' : 'view'}'),
          announcement: announcement,
          isEditing: isEditing,
          notifier: notifier,
          state: currentState,
        );
      },
    );
  }
}

// ============================================================
// WIDGET ANNOUNCEMENT ITEM
// ============================================================
class _AnnouncementItem extends ConsumerStatefulWidget {
  final AnnouncementModel announcement;
  final bool isEditing;
  final AnnouncementNotifier notifier;
  final AnnouncementState state;

  const _AnnouncementItem({
    super.key,
    required this.announcement,
    required this.isEditing,
    required this.notifier,
    required this.state,
  });

  @override
  ConsumerState<_AnnouncementItem> createState() => _AnnouncementItemState();
}

class _AnnouncementItemState extends ConsumerState<_AnnouncementItem> {
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengumuman'),
        content: Text('Yakin ingin menghapus "${widget.announcement.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.notifier.deleteAnnouncement(widget.announcement.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      return _EditForm(
        announcement: widget.announcement,
        notifier: widget.notifier,
        state: widget.state,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: widget.announcement.priorityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.announcement.title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.announcement.priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.announcement.priorityLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: widget.announcement.priorityColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.announcement.content,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildChip('Pengirim: ${widget.announcement.senderName ?? '-'}', Colors.grey),
                      _buildChip('Target: ${widget.announcement.targetDisplayText}', Colors.teal),
                    ],
                  ),
                  Text(
                    'Dibuat: ${_formatDate(widget.announcement.createdAt)}',
                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  tooltip: 'Hapus',
                ),
                IconButton(
                  onPressed: () => widget.notifier.startEdit(widget.announcement.id),
                  icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF01579B)),
                  tooltip: 'Edit',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 10, color: color.withOpacity(0.7)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }
}

// ============================================================
// FORM EDIT
// ============================================================
class _EditForm extends StatefulWidget {
  final AnnouncementModel announcement;
  final AnnouncementNotifier notifier;
  final AnnouncementState state;

  const _EditForm({
    super.key,
    required this.announcement,
    required this.notifier,
    required this.state,
  });

  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();
  
  late String _selectedPriority;
  late DateTime? _expiresAt;
  
  // Target fields - menggunakan nullable dengan nilai awal
  late String? _selectedTargetRole;
  late String? _selectedTargetUnitId;
  late String? _selectedTargetPositionId;
  late String? _selectedTargetProfileId;
  late String? _selectedTargetBuildingId;
  late String? _selectedTargetFloorId;
  late String? _selectedTargetRoomId;
  late String? _selectedTargetPermissionAsset;
  late String? _selectedTargetPermissionStock;
  late bool? _selectedTargetFlexibleRoster;
  late String? _selectedTargetWellbeingRisk;
  late int? _targetJoinYearStart;
  late int? _targetJoinYearEnd;
  late String? _selectedTargetSituation;
  late String? _selectedTargetGender;
  late int? _targetRatingTakeCountMin;
  late int? _targetRatingTakeCountMax;
  late double? _targetFatigueScoreMin;
  late double? _targetFatigueScoreMax;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.announcement.title);
    _contentController = TextEditingController(text: widget.announcement.content);
    _selectedPriority = widget.announcement.priority;
    _expiresAt = widget.announcement.expiresAt;
    _selectedTargetRole = widget.announcement.targetRole;
    _selectedTargetUnitId = widget.announcement.targetUnitId;
    _selectedTargetPositionId = widget.announcement.targetPositionId;
    _selectedTargetProfileId = widget.announcement.targetProfileId;
    _selectedTargetBuildingId = widget.announcement.targetBuildingId;
    _selectedTargetFloorId = widget.announcement.targetFloorId;
    _selectedTargetRoomId = widget.announcement.targetRoomId;
    _selectedTargetPermissionAsset = widget.announcement.targetPermissionAsset;
    _selectedTargetPermissionStock = widget.announcement.targetPermissionStock;
    _selectedTargetFlexibleRoster = widget.announcement.targetFlexibleRoster;
    _selectedTargetWellbeingRisk = widget.announcement.targetWellbeingRisk;
    _targetJoinYearStart = widget.announcement.targetJoinYearStart;
    _targetJoinYearEnd = widget.announcement.targetJoinYearEnd;
    _selectedTargetSituation = widget.announcement.targetSituation;
    _selectedTargetGender = widget.announcement.targetGender;
    _targetRatingTakeCountMin = widget.announcement.targetRatingTakeCountMin;
    _targetRatingTakeCountMax = widget.announcement.targetRatingTakeCountMax;
    _targetFatigueScoreMin = widget.announcement.targetFatigueScoreMin;
    _targetFatigueScoreMax = widget.announcement.targetFatigueScoreMax;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _resetTargetToAll() {
    setState(() {
      _selectedTargetRole = null;
      _selectedTargetUnitId = null;
      _selectedTargetPositionId = null;
      _selectedTargetProfileId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D47A1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF42A5F5), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormHeader('EDIT PENGUMUMAN', Icons.announcement, widget.notifier.cancelEdit),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(flex: 3, child: _buildTextField(_titleController, 'Judul *', 'Masukkan judul')),
                    const SizedBox(width: 12),
                    Expanded(flex: 1, child: _buildPriorityDropdown()),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(_contentController, 'Konten *', 'Isi pengumuman', maxLines: 4),
                const SizedBox(height: 16),
                _buildTargetAudienceSection(),
                const SizedBox(height: 12),
                _buildAdvancedFiltersSection(),
                const SizedBox(height: 12),
                _buildDateField('Kadaluarsa (Opsional)', _expiresAt, (date) => setState(() => _expiresAt = date)),
                const SizedBox(height: 16),
                _buildFormActions(widget.notifier.cancelEdit, _save),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader(String title, IconData icon, VoidCallback onClose) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onClose,
          icon: const Icon(Icons.close, size: 16, color: Colors.white70),
          label: const Text('Tutup', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }

  Widget _buildFormActions(VoidCallback onCancel, VoidCallback onSave) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Batal', style: TextStyle(color: Colors.white70)),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF42A5F5)),
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  Widget _buildPriorityDropdown() {
    final items = const ['normal', 'urgent', 'emergency'];
    final labels = {'normal': 'Normal', 'urgent': 'Urgent', 'emergency': 'Emergency'};
    
    return _buildDropdown<String>(
      'Prioritas',
      _selectedPriority,
      items,
      (v) => v,
      (v) => labels[v] ?? v,
      (v) => setState(() => _selectedPriority = v),
    );
  }

  Widget _buildTargetAudienceSection() {
    final isAllSelected = _selectedTargetRole == null &&
        _selectedTargetUnitId == null &&
        _selectedTargetPositionId == null &&
        (_selectedTargetProfileId == null || _selectedTargetProfileId?.isEmpty == true);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TARGET AUDIENCE',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildTargetChip('Semua Pegawai', isAllSelected, _resetTargetToAll),
              _buildTargetChip('Berdasarkan Role', _selectedTargetRole != null, () {
                setState(() {
                  _selectedTargetRole = 'operation';
                  _selectedTargetUnitId = null;
                  _selectedTargetPositionId = null;
                  _selectedTargetProfileId = null;
                });
              }),
              _buildTargetChip('Berdasarkan Unit', _selectedTargetUnitId != null, () {
                setState(() {
                  _selectedTargetUnitId = '';
                  _selectedTargetRole = null;
                  _selectedTargetPositionId = null;
                  _selectedTargetProfileId = null;
                });
              }),
              _buildTargetChip('Berdasarkan Posisi', _selectedTargetPositionId != null, () {
                setState(() {
                  _selectedTargetPositionId = '';
                  _selectedTargetRole = null;
                  _selectedTargetUnitId = null;
                  _selectedTargetProfileId = null;
                });
              }),
              _buildTargetChip('Pegawai Tertentu', _selectedTargetProfileId != null && _selectedTargetProfileId!.isNotEmpty, () {
                setState(() {
                  _selectedTargetProfileId = '';
                  _selectedTargetRole = null;
                  _selectedTargetUnitId = null;
                  _selectedTargetPositionId = null;
                });
              }),
            ],
          ),
          const SizedBox(height: 12),
          
          // Role Dropdown
          if (_selectedTargetRole != null)
            _buildDropdown<String>(
              'Role',
              _selectedTargetRole!,
              const ['operation', 'management', 'admin', 'monitor', 'control_room'],
              (v) => v,
              (v) => v,
              (v) => setState(() => _selectedTargetRole = v),
            ),
          
          // Unit Dropdown
          if (_selectedTargetUnitId != null)
            _buildDropdownWithData(
              'Unit',
              _selectedTargetUnitId!.isEmpty ? null : _selectedTargetUnitId,
              widget.state.units,
              (e) => e['id'].toString(),
              (e) => e['unit_name'] ?? '-',
              (v) => setState(() => _selectedTargetUnitId = v),
            ),
          
          // Position Dropdown
          if (_selectedTargetPositionId != null)
            _buildDropdownWithData(
              'Posisi',
              _selectedTargetPositionId!.isEmpty ? null : _selectedTargetPositionId,
              widget.state.positions,
              (e) => e['id'].toString(),
              (e) => e['position_name'] ?? '-',
              (v) => setState(() => _selectedTargetPositionId = v),
            ),
          
          // Specific Employee Dropdown
          if (_selectedTargetProfileId != null)
            _buildEmployeeDropdown(),
        ],
      ),
    );
  }

  Widget _buildEmployeeDropdown() {
    if (widget.state.employees.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning, size: 16, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Data pegawai tidak tersedia. Silakan muat ulang halaman.',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: _buildDropdownWithData(
        'Pilih Pegawai',
        _selectedTargetProfileId!.isEmpty ? null : _selectedTargetProfileId,
        widget.state.employees,
        (e) => e['id'].toString(),
        (e) => '${e['full_name'] ?? '-'} (${e['employee_id'] ?? 'N/A'})',
        (v) => setState(() => _selectedTargetProfileId = v),
      ),
    );
  }

  Widget _buildAdvancedFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FILTER TAMBAHAN',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          _buildDropdown<String>(
            'Permission Asset',
            _selectedTargetPermissionAsset ?? 'none',
            const ['none', 'initial', 'inspection'],
            (v) => v,
            (v) => v == 'none' ? 'Tidak' : (v == 'initial' ? 'Asset Initial' : 'Asset Inspection'),
            (v) => setState(() => _selectedTargetPermissionAsset = v == 'none' ? null : v),
          ),
          _buildDropdown<String>(
            'Permission Stock',
            _selectedTargetPermissionStock ?? 'none',
            const ['none', 'initial', 'opname'],
            (v) => v,
            (v) => v == 'none' ? 'Tidak' : (v == 'initial' ? 'Stock Initial' : 'Stock Opname'),
            (v) => setState(() => _selectedTargetPermissionStock = v == 'none' ? null : v),
          ),
          _buildDropdown<String>(
            'Flexible Roster',
            _selectedTargetFlexibleRoster?.toString() ?? 'none',
            const ['none', 'true', 'false'],
            (v) => v,
            (v) => v == 'none' ? 'Tidak' : (v == 'true' ? 'Ya' : 'Tidak'),
            (v) => setState(() => _selectedTargetFlexibleRoster = v == 'none' ? null : v == 'true'),
          ),
          _buildDropdown<String>(
            'Wellbeing Risk',
            _selectedTargetWellbeingRisk ?? 'none',
            const ['none', 'low', 'medium', 'high', 'critical'],
            (v) => v,
            (v) => v == 'none' ? 'Tidak' : v,
            (v) => setState(() => _selectedTargetWellbeingRisk = v == 'none' ? null : v),
          ),
          _buildDropdown<String>(
            'Situation',
            _selectedTargetSituation ?? 'none',
            const ['none', 'ACTIVE', 'ON_LEAVE', 'SICK', 'DUTY_OUT'],
            (v) => v,
            (v) => v == 'none' ? 'Tidak' : v,
            (v) => setState(() => _selectedTargetSituation = v == 'none' ? null : v),
          ),
          _buildDropdown<String>(
            'Gender',
            _selectedTargetGender ?? 'none',
            const ['none', 'L', 'P'],
            (v) => v,
            (v) => v == 'none' ? 'Tidak' : (v == 'L' ? 'Laki-laki' : 'Perempuan'),
            (v) => setState(() => _selectedTargetGender = v == 'none' ? null : v),
          ),
          Row(
            children: [
              Expanded(child: _buildNumberField('Join Year Mulai', _targetJoinYearStart, (v) => setState(() => _targetJoinYearStart = v))),
              const SizedBox(width: 12),
              Expanded(child: _buildNumberField('Join Year Sampai', _targetJoinYearEnd, (v) => setState(() => _targetJoinYearEnd = v))),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildDoubleField('Fatigue Score Min', _targetFatigueScoreMin, (v) => setState(() => _targetFatigueScoreMin = v))),
              const SizedBox(width: 12),
              Expanded(child: _buildDoubleField('Fatigue Score Max', _targetFatigueScoreMax, (v) => setState(() => _targetFatigueScoreMax = v))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label, style: GoogleFonts.poppins(fontSize: 11)),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white.withOpacity(0.15),
      selectedColor: const Color(0xFF42A5F5),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87, // ← PERBAIKAN: tulisan jadi gelap saat tidak dipilih
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          validator: (v) => (v?.isEmpty ?? true) ? '$label harus diisi' : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.38)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>(
    String label,
    T value,
    List<T> items,
    T Function(T) displayValue,
    String Function(T) displayText,
    ValueChanged<T> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                dropdownColor: const Color(0xFF1A237E),
                items: items.map((item) {
                  return DropdownMenuItem<T>(
                    value: displayValue(item),
                    child: Text(
                      displayText(item),
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownWithData(
    String label,
    String? selectedId,
    List<Map<String, dynamic>> items,
    String Function(Map<String, dynamic>) idExtractor,
    String Function(Map<String, dynamic>) nameExtractor,
    ValueChanged<String?> onChanged,
  ) {
    final dropdownItems = <DropdownMenuItem<String>>[
      DropdownMenuItem(value: null, child: Text('Pilih $label', style: TextStyle(color: Colors.white70))),
      ...items.map((item) => DropdownMenuItem<String>(
            value: idExtractor(item),
            child: Text(nameExtractor(item), style: const TextStyle(color: Colors.white)),
          )),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedId,
                isExpanded: true,
                dropdownColor: const Color(0xFF1A237E),
                hint: Text('Pilih $label', style: TextStyle(color: Colors.white70)),
                items: dropdownItems,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(String label, int? value, ValueChanged<int?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value?.toString(),
          keyboardType: TextInputType.number,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Kosongkan jika tidak digunakan',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.38)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
          ),
          onChanged: (v) => onChanged(v.isEmpty ? null : int.tryParse(v)),
        ),
      ],
    );
  }

  Widget _buildDoubleField(String label, double? value, ValueChanged<double?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value?.toString(),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Kosongkan jika tidak digunakan',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.38)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
          ),
          onChanged: (v) => onChanged(v.isEmpty ? null : double.tryParse(v)),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? value, ValueChanged<DateTime?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value != null ? DateFormat('dd MMM yyyy').format(value) : 'Pilih tanggal',
                    style: GoogleFonts.poppins(fontSize: 12, color: value != null ? Colors.white : Colors.white54),
                  ),
                ),
                if (value != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 16, color: Colors.white70),
                    onPressed: () => onChanged(null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final updatedAnnouncement = widget.announcement.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        priority: _selectedPriority,
        expiresAt: _expiresAt,
        targetRole: _selectedTargetRole,
        targetUnitId: _selectedTargetUnitId?.isEmpty == true ? null : _selectedTargetUnitId,
        targetPositionId: _selectedTargetPositionId?.isEmpty == true ? null : _selectedTargetPositionId,
        targetProfileId: _selectedTargetProfileId?.isEmpty == true ? null : _selectedTargetProfileId,
        targetBuildingId: _selectedTargetBuildingId,
        targetFloorId: _selectedTargetFloorId,
        targetRoomId: _selectedTargetRoomId,
        targetPermissionAsset: _selectedTargetPermissionAsset,
        targetPermissionStock: _selectedTargetPermissionStock,
        targetFlexibleRoster: _selectedTargetFlexibleRoster,
        targetWellbeingRisk: _selectedTargetWellbeingRisk,
        targetJoinYearStart: _targetJoinYearStart,
        targetJoinYearEnd: _targetJoinYearEnd,
        targetSituation: _selectedTargetSituation,
        targetGender: _selectedTargetGender,
        targetRatingTakeCountMin: _targetRatingTakeCountMin,
        targetRatingTakeCountMax: _targetRatingTakeCountMax,
        targetFatigueScoreMin: _targetFatigueScoreMin,
        targetFatigueScoreMax: _targetFatigueScoreMax,
      );
      await widget.notifier.saveAnnouncement(updatedAnnouncement);
    }
  }
}

// ============================================================
// FORM ADD NEW
// ============================================================
class _AddNewForm extends StatefulWidget {
  final AnnouncementState state;
  final AnnouncementNotifier notifier;
  final String? currentUserId;

  const _AddNewForm({
    super.key,
    required this.state,
    required this.notifier,
    required this.currentUserId,
  });

  @override
  State<_AddNewForm> createState() => _AddNewFormState();
}

class _AddNewFormState extends State<_AddNewForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();
  
  String _selectedPriority = 'normal';
  DateTime? _expiresAt;
  
  String? _selectedTargetRole;
  String? _selectedTargetUnitId;
  String? _selectedTargetPositionId;
  String? _selectedTargetProfileId;
  String? _selectedTargetBuildingId;
  String? _selectedTargetFloorId;
  String? _selectedTargetRoomId;
  String? _selectedTargetPermissionAsset;
  String? _selectedTargetPermissionStock;
  bool? _selectedTargetFlexibleRoster;
  String? _selectedTargetWellbeingRisk;
  int? _targetJoinYearStart;
  int? _targetJoinYearEnd;
  String? _selectedTargetSituation;
  String? _selectedTargetGender;
  int? _targetRatingTakeCountMin;
  int? _targetRatingTakeCountMax;
  double? _targetFatigueScoreMin;
  double? _targetFatigueScoreMax;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _resetTargetToAll() {
    setState(() {
      _selectedTargetRole = null;
      _selectedTargetUnitId = null;
      _selectedTargetPositionId = null;
      _selectedTargetProfileId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade400, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormHeader('TAMBAH PENGUMUMAN BARU', Icons.add_circle, Colors.green.shade300, widget.notifier.cancelEdit),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(flex: 3, child: _buildTextField(_titleController, 'Judul *', 'Masukkan judul')),
                    const SizedBox(width: 12),
                    Expanded(flex: 1, child: _buildPriorityDropdown()),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(_contentController, 'Konten *', 'Isi pengumuman', maxLines: 4),
                const SizedBox(height: 16),
                _buildTargetAudienceSection(),
                const SizedBox(height: 12),
                _buildAdvancedFiltersSection(),
                const SizedBox(height: 12),
                _buildDateField('Kadaluarsa (Opsional)', _expiresAt, (date) => setState(() => _expiresAt = date)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader(String title, IconData icon, Color iconColor, VoidCallback onClose) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onClose,
          icon: const Icon(Icons.close, size: 16, color: Colors.white70),
          label: const Text('Batal', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }

  Widget _buildPriorityDropdown() {
    final items = const ['normal', 'urgent', 'emergency'];
    final labels = {'normal': 'Normal', 'urgent': 'Urgent', 'emergency': 'Emergency'};
    
    return _buildDropdown<String>(
      'Prioritas',
      _selectedPriority,
      items,
      (v) => v,
      (v) => labels[v] ?? v,
      (v) => setState(() => _selectedPriority = v),
    );
  }

  Widget _buildTargetAudienceSection() {
    final isAllSelected = _selectedTargetRole == null &&
        _selectedTargetUnitId == null &&
        _selectedTargetPositionId == null &&
        (_selectedTargetProfileId == null || _selectedTargetProfileId?.isEmpty == true);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TARGET AUDIENCE',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildTargetChip('Semua Pegawai', isAllSelected, _resetTargetToAll),
              _buildTargetChip('Berdasarkan Role', _selectedTargetRole != null, () {
                setState(() {
                  _selectedTargetRole = 'operation';
                  _selectedTargetUnitId = null;
                  _selectedTargetPositionId = null;
                  _selectedTargetProfileId = null;
                });
              }),
              _buildTargetChip('Berdasarkan Unit', _selectedTargetUnitId != null, () {
                setState(() {
                  _selectedTargetUnitId = '';
                  _selectedTargetRole = null;
                  _selectedTargetPositionId = null;
                  _selectedTargetProfileId = null;
                });
              }),
              _buildTargetChip('Berdasarkan Posisi', _selectedTargetPositionId != null, () {
                setState(() {
                  _selectedTargetPositionId = '';
                  _selectedTargetRole = null;
                  _selectedTargetUnitId = null;
                  _selectedTargetProfileId = null;
                });
              }),
              _buildTargetChip('Pegawai Tertentu', _selectedTargetProfileId != null && _selectedTargetProfileId!.isNotEmpty, () {
                setState(() {
                  _selectedTargetProfileId = '';
                  _selectedTargetRole = null;
                  _selectedTargetUnitId = null;
                  _selectedTargetPositionId = null;
                });
              }),
            ],
          ),
          const SizedBox(height: 12),
          
          if (_selectedTargetRole != null)
            _buildDropdown<String>(
              'Role',
              _selectedTargetRole!,
              const ['operation', 'management', 'admin', 'monitor', 'control_room'],
              (v) => v,
              (v) => v,
              (v) => setState(() => _selectedTargetRole = v),
            ),
          
          if (_selectedTargetUnitId != null)
            _buildDropdownWithData(
              'Unit',
              _selectedTargetUnitId!.isEmpty ? null : _selectedTargetUnitId,
              widget.state.units,
              (e) => e['id'].toString(),
              (e) => e['unit_name'] ?? '-',
              (v) => setState(() => _selectedTargetUnitId = v),
            ),
          
          if (_selectedTargetPositionId != null)
            _buildDropdownWithData(
              'Posisi',
              _selectedTargetPositionId!.isEmpty ? null : _selectedTargetPositionId,
              widget.state.positions,
              (e) => e['id'].toString(),
              (e) => e['position_name'] ?? '-',
              (v) => setState(() => _selectedTargetPositionId = v),
            ),
          
          if (_selectedTargetProfileId != null)
            _buildEmployeeDropdown(),
        ],
      ),
    );
  }

  Widget _buildEmployeeDropdown() {
    if (widget.state.employees.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning, size: 16, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Data pegawai tidak tersedia. Silakan muat ulang halaman.',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: _buildDropdownWithData(
        'Pilih Pegawai',
        _selectedTargetProfileId!.isEmpty ? null : _selectedTargetProfileId,
        widget.state.employees,
        (e) => e['id'].toString(),
        (e) => '${e['full_name'] ?? '-'} (${e['employee_id'] ?? 'N/A'})',
        (v) => setState(() => _selectedTargetProfileId = v),
      ),
    );
  }

  Widget _buildAdvancedFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FILTER TAMBAHAN',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          _buildDropdown<String>(
            'Permission Asset',
            _selectedTargetPermissionAsset ?? 'none',
            const ['none', 'initial', 'inspection'],
            (v) => v,
            (v) => v == 'none' ? 'Tidak' : (v == 'initial' ? 'Asset Initial' : 'Asset Inspection'),
            (v) => setState(() => _selectedTargetPermissionAsset = v == 'none' ? null : v),
          ),
          _buildDropdown<String>(
            'Permission Stock',
            _selectedTargetPermissionStock ?? 'none',
            const ['none', 'initial', 'opname'],
            (v) => v,
            (v) => v == 'none' ? 'Tidak' : (v == 'initial' ? 'Stock Initial' : 'Stock Opname'),
            (v) => setState(() => _selectedTargetPermissionStock = v == 'none' ? null : v),
          ),
          _buildDropdown<String>(
            'Flexible Roster',
            _selectedTargetFlexibleRoster?.toString() ?? 'none',
            const ['none', 'true', 'false'],
            (v) => v,
            (v) => v == 'none' ? 'Tidak' : (v == 'true' ? 'Ya' : 'Tidak'),
            (v) => setState(() => _selectedTargetFlexibleRoster = v == 'none' ? null : v == 'true'),
          ),
          _buildDropdown<String>(
            'Wellbeing Risk',
            _selectedTargetWellbeingRisk ?? 'none',
            const ['none', 'low', 'medium', 'high', 'critical'],
            (v) => v,
            (v) => v == 'none' ? 'Tidak' : v,
            (v) => setState(() => _selectedTargetWellbeingRisk = v == 'none' ? null : v),
          ),
          _buildDropdown<String>(
            'Situation',
            _selectedTargetSituation ?? 'none',
            const ['none', 'ACTIVE', 'ON_LEAVE', 'SICK', 'DUTY_OUT'],
            (v) => v,
            (v) => v == 'none' ? 'Tidak' : v,
            (v) => setState(() => _selectedTargetSituation = v == 'none' ? null : v),
          ),
          _buildDropdown<String>(
            'Gender',
            _selectedTargetGender ?? 'none',
            const ['none', 'L', 'P'],
            (v) => v,
            (v) => v == 'none' ? 'Tidak' : (v == 'L' ? 'Laki-laki' : 'Perempuan'),
            (v) => setState(() => _selectedTargetGender = v == 'none' ? null : v),
          ),
          Row(
            children: [
              Expanded(child: _buildNumberField('Join Year Mulai', _targetJoinYearStart, (v) => setState(() => _targetJoinYearStart = v))),
              const SizedBox(width: 12),
              Expanded(child: _buildNumberField('Join Year Sampai', _targetJoinYearEnd, (v) => setState(() => _targetJoinYearEnd = v))),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildDoubleField('Fatigue Score Min', _targetFatigueScoreMin, (v) => setState(() => _targetFatigueScoreMin = v))),
              const SizedBox(width: 12),
              Expanded(child: _buildDoubleField('Fatigue Score Max', _targetFatigueScoreMax, (v) => setState(() => _targetFatigueScoreMax = v))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label, style: GoogleFonts.poppins(fontSize: 11)),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white.withOpacity(0.15),
      selectedColor: const Color(0xFF42A5F5),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87, // ← PERBAIKAN: tulisan jadi gelap saat tidak dipilih
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          validator: (v) => (v?.isEmpty ?? true) ? '$label harus diisi' : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.38)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>(
    String label,
    T value,
    List<T> items,
    T Function(T) displayValue,
    String Function(T) displayText,
    ValueChanged<T> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                dropdownColor: const Color(0xFF1A237E),
                items: items.map((item) {
                  return DropdownMenuItem<T>(
                    value: displayValue(item),
                    child: Text(
                      displayText(item),
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownWithData(
    String label,
    String? selectedId,
    List<Map<String, dynamic>> items,
    String Function(Map<String, dynamic>) idExtractor,
    String Function(Map<String, dynamic>) nameExtractor,
    ValueChanged<String?> onChanged,
  ) {
    final dropdownItems = <DropdownMenuItem<String>>[
      DropdownMenuItem(value: null, child: Text('Pilih $label', style: TextStyle(color: Colors.white70))),
      ...items.map((item) => DropdownMenuItem<String>(
            value: idExtractor(item),
            child: Text(nameExtractor(item), style: const TextStyle(color: Colors.white)),
          )),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedId,
                isExpanded: true,
                dropdownColor: const Color(0xFF1A237E),
                hint: Text('Pilih $label', style: TextStyle(color: Colors.white70)),
                items: dropdownItems,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(String label, int? value, ValueChanged<int?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value?.toString(),
          keyboardType: TextInputType.number,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Kosongkan jika tidak digunakan',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.38)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
          ),
          onChanged: (v) => onChanged(v.isEmpty ? null : int.tryParse(v)),
        ),
      ],
    );
  }

  Widget _buildDoubleField(String label, double? value, ValueChanged<double?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value?.toString(),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Kosongkan jika tidak digunakan',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.38)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
          ),
          onChanged: (v) => onChanged(v.isEmpty ? null : double.tryParse(v)),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? value, ValueChanged<DateTime?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value != null ? DateFormat('dd MMM yyyy').format(value) : 'Pilih tanggal',
                    style: GoogleFonts.poppins(fontSize: 12, color: value != null ? Colors.white : Colors.white54),
                  ),
                ),
                if (value != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 16, color: Colors.white70),
                    onPressed: () => onChanged(null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate() && widget.currentUserId != null) {
      final newAnnouncement = AnnouncementModel(
        id: '',
        senderId: widget.currentUserId!,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        priority: _selectedPriority,
        createdAt: DateTime.now(),
        expiresAt: _expiresAt,
        targetRole: _selectedTargetRole,
        targetUnitId: _selectedTargetUnitId?.isEmpty == true ? null : _selectedTargetUnitId,
        targetPositionId: _selectedTargetPositionId?.isEmpty == true ? null : _selectedTargetPositionId,
        targetProfileId: _selectedTargetProfileId?.isEmpty == true ? null : _selectedTargetProfileId,
        targetBuildingId: _selectedTargetBuildingId,
        targetFloorId: _selectedTargetFloorId,
        targetRoomId: _selectedTargetRoomId,
        targetPermissionAsset: _selectedTargetPermissionAsset,
        targetPermissionStock: _selectedTargetPermissionStock,
        targetFlexibleRoster: _selectedTargetFlexibleRoster,
        targetWellbeingRisk: _selectedTargetWellbeingRisk,
        targetJoinYearStart: _targetJoinYearStart,
        targetJoinYearEnd: _targetJoinYearEnd,
        targetSituation: _selectedTargetSituation,
        targetGender: _selectedTargetGender,
        targetRatingTakeCountMin: _targetRatingTakeCountMin,
        targetRatingTakeCountMax: _targetRatingTakeCountMax,
        targetFatigueScoreMin: _targetFatigueScoreMin,
        targetFatigueScoreMax: _targetFatigueScoreMax,
      );
      await widget.notifier.saveAnnouncement(newAnnouncement);
    }
  }
}