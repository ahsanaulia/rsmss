import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/task_provider.dart';
import '../../providers/task_state.dart';
import '../../models/task_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/di/service_locator.dart';

class TasksTable extends ConsumerStatefulWidget {
  final String? filterByAssigneeId;

  const TasksTable({super.key, this.filterByAssigneeId});

  @override
  ConsumerState<TasksTable> createState() => _TasksTableState();
}

class _TasksTableState extends ConsumerState<TasksTable> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'all';
  String _filterPriority = 'all';
  
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _authService = getIt<AuthService>();
    
    // Load reference data (taskTypes, employees, rooms, etc) once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(taskProvider.notifier);
      notifier.loadData(filterByAssigneeId: widget.filterByAssigneeId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String? get _currentUserId {
    final userId = _authService.currentUserId;
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return userId;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskProvider);
    final notifier = ref.read(taskProvider.notifier);
    
    // 🔴 REALTIME STREAM UNTUK TASKS
    final tasksStream = notifier.streamTasks(filterByAssigneeId: widget.filterByAssigneeId);

    // Handle error messages (dari operasi CRUD)
    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red.shade700),
        );
        notifier.clearMessages();
      });
    }

    if (state.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.successMessage!), backgroundColor: Colors.green.shade700),
        );
        notifier.clearMessages();
      });
    }

    return Column(
      children: [
        // Toolbar (Filter & Search)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            border: const Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari tugas atau pegawai...',
                    prefixIcon: const Icon(Icons.search),
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
                    value: _filterStatus,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Semua Status')),
                      DropdownMenuItem(value: 'pending', child: Text('Menunggu')),
                      DropdownMenuItem(value: 'accepted', child: Text('Diterima')),
                      DropdownMenuItem(value: 'in_progress', child: Text('Proses')),
                      DropdownMenuItem(value: 'done', child: Text('Selesai')),
                      DropdownMenuItem(value: 'rejected', child: Text('Ditolak')),
                    ],
                    onChanged: (v) => setState(() => _filterStatus = v!),
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
                    value: _filterPriority,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Semua Prioritas')),
                      DropdownMenuItem(value: 'normal', child: Text('Normal')),
                      DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                      DropdownMenuItem(value: 'emergency', child: Text('Emergency')),
                    ],
                    onChanged: (v) => setState(() => _filterPriority = v!),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  _showAddTaskDialog(state, notifier);
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Tugas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01579B),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // 🔴 REALTIME TASK LIST
        Expanded(
          child: StreamBuilder<List<TaskModel>>(
            stream: tasksStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF01579B)),
                );
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {});
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }
              
              final allTasks = snapshot.data ?? [];
              
              // Apply filters
              final filteredTasks = allTasks.where((task) {
                if (_searchQuery.isNotEmpty) {
                  if (!task.objectName.toLowerCase().contains(_searchQuery) &&
                      !(task.assigneeName?.toLowerCase().contains(_searchQuery) ?? false)) {
                    return false;
                  }
                }
                if (_filterStatus != 'all' && task.status != _filterStatus) return false;
                if (_filterPriority != 'all' && task.priority != _filterPriority) return false;
                return true;
              }).toList();
              
              if (filteredTasks.isEmpty) {
                return const Center(
                  child: Text('Belum ada tugas', style: TextStyle(color: Colors.grey)),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return _buildTaskRow(task, notifier, state);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskRow(TaskModel task, TaskNotifier notifier, TaskState state) {
    // Cari nama assignee dari state.employees
    String assigneeName = '-';
    for (var emp in state.employees) {
      if (emp['id'].toString() == task.assigneeId) {
        assigneeName = emp['full_name'] ?? '-';
        break;
      }
    }
    
    // Cari nama task type
    String typeName = '-';
    for (var type in state.taskTypes) {
      if (type['id'].toString() == task.typeId) {
        typeName = type['task_type_name'] ?? '-';
        break;
      }
    }
    
    // Warna prioritas
    Color priorityColor = task.priority == 'emergency' 
        ? Colors.red 
        : (task.priority == 'urgent' ? Colors.orange : Colors.blue);
    
    // Label prioritas
    String priorityLabel = task.priority == 'emergency' 
        ? 'Emergency' 
        : (task.priority == 'urgent' ? 'Urgent' : 'Normal');
    
    // Warna status
    Color statusColor = task.status == 'done' 
        ? Colors.green 
        : (task.status == 'accepted' ? Colors.blue : Colors.orange);
    
    // Label status
    String statusLabel = task.status == 'done' 
        ? 'Selesai' 
        : (task.status == 'accepted' ? 'Diterima' : 'Menunggu');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                task.priority == 'emergency' ? Icons.warning_amber : Icons.assignment,
                color: priorityColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.objectName,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildChip('Pegawai: $assigneeName', Colors.blue),
                      _buildChip(priorityLabel, priorityColor),
                      _buildChip(statusLabel, statusColor),
                      if (typeName != '-') _buildChip(typeName, Colors.teal),
                    ],
                  ),
                  Text(
                    'Dibuat: ${_formatDate(task.createdAt)}',
                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => _confirmDelete(notifier, task.id),
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  tooltip: 'Hapus',
                ),
                IconButton(
                  onPressed: () => _showEditDialog(task, notifier, state),
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

  bool _isValidUuid(String? id) {
    if (id == null || id.isEmpty) return false;
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(id);
  }

  void _showAddTaskDialog(TaskState state, TaskNotifier notifier) {
    final _formKey = GlobalKey<FormState>();
    final _objectNameController = TextEditingController();
    final _slaMinutesController = TextEditingController();
    final _estimatedDurationController = TextEditingController();
    
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired, silakan login ulang'), backgroundColor: Colors.red),
      );
      return;
    }
    
    String? _selectedTypeId;
    String? _selectedAssigneeId = widget.filterByAssigneeId;
    String _selectedPriority = 'normal';
    String _selectedStatus = 'pending';
    String? _selectedFromRoomId;
    String? _selectedToRoomId;
    String? _selectedAssetId;
    String? _selectedStockId;
    bool _requiresConfirmation = false;
    bool _requiresPhotoProof = false;
    bool _requiresQrValidation = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.add_task, color: Colors.green.shade700),
                const SizedBox(width: 8),
                const Text('Tambah Tugas Baru'),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(dialogContext).size.width * 0.45,
              height: MediaQuery.of(dialogContext).size.height * 0.75,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _objectNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Tugas *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'Nama tugas harus diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              isExpanded: true,
                              value: _selectedTypeId,
                              decoration: const InputDecoration(
                                labelText: 'Tipe Tugas',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Pilih')),
                                ...state.taskTypes.map((type) => DropdownMenuItem(
                                  value: type['id'].toString(),
                                  child: Text(
                                    type['task_type_name'] ?? '-',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                              ],
                              onChanged: (v) => setDialogState(() => _selectedTypeId = v),
                              validator: (v) => v == null ? 'Tipe tugas harus dipilih' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              isExpanded: true,
                              value: _selectedAssigneeId,
                              decoration: const InputDecoration(
                                labelText: 'Pegawai',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Pilih')),
                                ...state.employees.map((emp) => DropdownMenuItem(
                                  value: emp['id'].toString(),
                                  child: Text(
                                    emp['full_name'] ?? '-',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                              ],
                              onChanged: (v) => setDialogState(() => _selectedAssigneeId = v),
                              validator: (v) => v == null ? 'Pegawai harus dipilih' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              isExpanded: true,
                              value: _selectedFromRoomId,
                              decoration: const InputDecoration(
                                labelText: 'Ruangan Asal',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Pilih')),
                                ...state.rooms.map((room) => DropdownMenuItem(
                                  value: room['id'].toString(),
                                  child: Text(
                                    room['room_name'] ?? '-',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                              ],
                              onChanged: (v) => setDialogState(() => _selectedFromRoomId = v),
                              validator: (v) => v == null ? 'Ruangan asal harus dipilih' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              isExpanded: true,
                              value: _selectedToRoomId,
                              decoration: const InputDecoration(
                                labelText: 'Ruangan Tujuan',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Pilih')),
                                ...state.rooms.map((room) => DropdownMenuItem(
                                  value: room['id'].toString(),
                                  child: Text(
                                    room['room_name'] ?? '-',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                              ],
                              onChanged: (v) => setDialogState(() => _selectedToRoomId = v),
                              validator: (v) => v == null ? 'Ruangan tujuan harus dipilih' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _selectedPriority,
                              decoration: const InputDecoration(
                                labelText: 'Prioritas',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'normal', child: Text('Normal')),
                                DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                                DropdownMenuItem(value: 'emergency', child: Text('Emergency')),
                              ],
                              onChanged: (v) => setDialogState(() => _selectedPriority = v!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                                DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
                                DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                                DropdownMenuItem(value: 'done', child: Text('Done')),
                                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                              ],
                              onChanged: (v) => setDialogState(() => _selectedStatus = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              isExpanded: true,
                              value: _selectedAssetId,
                              decoration: const InputDecoration(
                                labelText: 'Asset',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('-')),
                                ...state.assets.map((asset) => DropdownMenuItem(
                                  value: asset['id'].toString(),
                                  child: Text(
                                    asset['asset_name'] ?? '-',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                              ],
                              onChanged: (v) => setDialogState(() => _selectedAssetId = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              isExpanded: true,
                              value: _selectedStockId,
                              decoration: const InputDecoration(
                                labelText: 'Stock',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('-')),
                                ...state.stocks.map((stock) => DropdownMenuItem(
                                  value: stock['id'].toString(),
                                  child: Text(
                                    stock['stock_name'] ?? '-',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                              ],
                              onChanged: (v) => setDialogState(() => _selectedStockId = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _slaMinutesController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'SLA (menit)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _estimatedDurationController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Estimasi Durasi',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _requiresConfirmation,
                                  onChanged: (v) => setDialogState(() => _requiresConfirmation = v ?? false),
                                ),
                              ),
                              const Text('Confirm'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _requiresPhotoProof,
                                  onChanged: (v) => setDialogState(() => _requiresPhotoProof = v ?? false),
                                ),
                              ),
                              const Text('Photo'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _requiresQrValidation,
                                  onChanged: (v) => setDialogState(() => _requiresQrValidation = v ?? false),
                                ),
                              ),
                              const Text('QR'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (!_isValidUuid(_selectedTypeId)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tipe tugas tidak valid'), backgroundColor: Colors.orange),
                      );
                      return;
                    }
                    if (!_isValidUuid(_selectedAssigneeId)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pegawai tidak valid'), backgroundColor: Colors.orange),
                      );
                      return;
                    }
                    if (!_isValidUuid(_selectedFromRoomId)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ruangan asal tidak valid'), backgroundColor: Colors.orange),
                      );
                      return;
                    }
                    if (!_isValidUuid(_selectedToRoomId)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ruangan tujuan tidak valid'), backgroundColor: Colors.orange),
                      );
                      return;
                    }
                    
                    Navigator.pop(dialogContext);
                    
                    final newTask = TaskModel(
                      id: '',
                      typeId: _selectedTypeId!,
                      assigneeId: _selectedAssigneeId!,
                      objectName: _objectNameController.text.trim(),
                      fromRoomId: _selectedFromRoomId!,
                      toRoomId: _selectedToRoomId!,
                      priority: _selectedPriority,
                      status: _selectedStatus,
                      assetId: (_selectedAssetId != null && _selectedAssetId!.isNotEmpty) ? _selectedAssetId : null,
                      stockId: (_selectedStockId != null && _selectedStockId!.isNotEmpty) ? _selectedStockId : null,
                      createdAt: DateTime.now(),
                      createdById: currentUserId,
                      slaMinutes: int.tryParse(_slaMinutesController.text),
                      estimatedDurationMinutes: int.tryParse(_estimatedDurationController.text),
                      requiresConfirmation: _requiresConfirmation,
                      requiresPhotoProof: _requiresPhotoProof,
                      requiresQrValidation: _requiresQrValidation,
                    );
                    
                    await notifier.saveTask(newTask);
                    
                    _objectNameController.dispose();
                    _slaMinutesController.dispose();
                    _estimatedDurationController.dispose();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditDialog(TaskModel task, TaskNotifier notifier, TaskState state) {
    final _formKey = GlobalKey<FormState>();
    final _objectNameController = TextEditingController(text: task.objectName);
    final _slaMinutesController = TextEditingController(text: task.slaMinutes?.toString() ?? '');
    final _estimatedDurationController = TextEditingController(text: task.estimatedDurationMinutes?.toString() ?? '');
    
    String? _selectedTypeId = task.typeId;
    String? _selectedAssigneeId = task.assigneeId;
    String _selectedPriority = task.priority;
    String _selectedStatus = task.status;
    String? _selectedFromRoomId = task.fromRoomId;
    String? _selectedToRoomId = task.toRoomId;
    String? _selectedAssetId = task.assetId;
    String? _selectedStockId = task.stockId;
    bool _requiresConfirmation = task.requiresConfirmation;
    bool _requiresPhotoProof = task.requiresPhotoProof;
    bool _requiresQrValidation = task.requiresQrValidation;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.edit, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text('Edit Tugas'),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(dialogContext).size.width * 0.45,
              height: MediaQuery.of(dialogContext).size.height * 0.8,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _objectNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Tugas *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'Nama tugas harus diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              isExpanded: true,
                              value: _selectedTypeId,
                              decoration: const InputDecoration(
                                labelText: 'Tipe Tugas',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Pilih')),
                                ...state.taskTypes.map((type) => DropdownMenuItem(
                                  value: type['id'].toString(),
                                  child: Text(
                                    type['task_type_name'] ?? '-',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                              ],
                              onChanged: (v) => setDialogState(() => _selectedTypeId = v),
                              validator: (v) => v == null ? 'Tipe tugas harus dipilih' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              isExpanded: true,
                              value: _selectedAssigneeId,
                              decoration: const InputDecoration(
                                labelText: 'Pegawai',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Pilih')),
                                ...state.employees.map((emp) => DropdownMenuItem(
                                  value: emp['id'].toString(),
                                  child: Text(
                                    emp['full_name'] ?? '-',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                              ],
                              onChanged: (v) => setDialogState(() => _selectedAssigneeId = v),
                              validator: (v) => v == null ? 'Pegawai harus dipilih' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              isExpanded: true,
                              value: _selectedFromRoomId,
                              decoration: const InputDecoration(
                                labelText: 'Ruangan Asal',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Pilih')),
                                ...state.rooms.map((room) => DropdownMenuItem(
                                  value: room['id'].toString(),
                                  child: Text(
                                    room['room_name'] ?? '-',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                              ],
                              onChanged: (v) => setDialogState(() => _selectedFromRoomId = v),
                              validator: (v) => v == null ? 'Ruangan asal harus dipilih' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              isExpanded: true,
                              value: _selectedToRoomId,
                              decoration: const InputDecoration(
                                labelText: 'Ruangan Tujuan',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Pilih')),
                                ...state.rooms.map((room) => DropdownMenuItem(
                                  value: room['id'].toString(),
                                  child: Text(
                                    room['room_name'] ?? '-',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                              ],
                              onChanged: (v) => setDialogState(() => _selectedToRoomId = v),
                              validator: (v) => v == null ? 'Ruangan tujuan harus dipilih' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _selectedPriority,
                              decoration: const InputDecoration(
                                labelText: 'Prioritas',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'normal', child: Text('Normal')),
                                DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                                DropdownMenuItem(value: 'emergency', child: Text('Emergency')),
                              ],
                              onChanged: (v) => setDialogState(() => _selectedPriority = v!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                                DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
                                DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                                DropdownMenuItem(value: 'done', child: Text('Done')),
                                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                              ],
                              onChanged: (v) => setDialogState(() => _selectedStatus = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              isExpanded: true,
                              value: _selectedAssetId,
                              decoration: const InputDecoration(
                                labelText: 'Asset',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('-')),
                                ...state.assets.map((asset) => DropdownMenuItem(
                                  value: asset['id'].toString(),
                                  child: Text(
                                    asset['asset_name'] ?? '-',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                              ],
                              onChanged: (v) => setDialogState(() => _selectedAssetId = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              isExpanded: true,
                              value: _selectedStockId,
                              decoration: const InputDecoration(
                                labelText: 'Stock',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('-')),
                                ...state.stocks.map((stock) => DropdownMenuItem(
                                  value: stock['id'].toString(),
                                  child: Text(
                                    stock['stock_name'] ?? '-',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                              ],
                              onChanged: (v) => setDialogState(() => _selectedStockId = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _slaMinutesController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'SLA (menit)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _estimatedDurationController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Estimasi Durasi',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _requiresConfirmation,
                                  onChanged: (v) => setDialogState(() => _requiresConfirmation = v ?? false),
                                ),
                              ),
                              const Text('Confirm'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _requiresPhotoProof,
                                  onChanged: (v) => setDialogState(() => _requiresPhotoProof = v ?? false),
                                ),
                              ),
                              const Text('Photo'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _requiresQrValidation,
                                  onChanged: (v) => setDialogState(() => _requiresQrValidation = v ?? false),
                                ),
                              ),
                              const Text('QR'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (!_isValidUuid(_selectedTypeId)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tipe tugas tidak valid'), backgroundColor: Colors.orange),
                      );
                      return;
                    }
                    if (!_isValidUuid(_selectedAssigneeId)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pegawai tidak valid'), backgroundColor: Colors.orange),
                      );
                      return;
                    }
                    if (!_isValidUuid(_selectedFromRoomId)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ruangan asal tidak valid'), backgroundColor: Colors.orange),
                      );
                      return;
                    }
                    if (!_isValidUuid(_selectedToRoomId)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ruangan tujuan tidak valid'), backgroundColor: Colors.orange),
                      );
                      return;
                    }
                    
                    Navigator.pop(dialogContext);
                    
                    final updatedTask = TaskModel(
                      id: task.id,
                      typeId: _selectedTypeId!,
                      assigneeId: _selectedAssigneeId!,
                      objectName: _objectNameController.text.trim(),
                      fromRoomId: _selectedFromRoomId!,
                      toRoomId: _selectedToRoomId!,
                      priority: _selectedPriority,
                      status: _selectedStatus,
                      assetId: (_selectedAssetId != null && _selectedAssetId!.isNotEmpty) ? _selectedAssetId : null,
                      stockId: (_selectedStockId != null && _selectedStockId!.isNotEmpty) ? _selectedStockId : null,
                      createdAt: task.createdAt,
                      createdById: task.createdById,
                      slaMinutes: int.tryParse(_slaMinutesController.text),
                      estimatedDurationMinutes: int.tryParse(_estimatedDurationController.text),
                      requiresConfirmation: _requiresConfirmation,
                      requiresPhotoProof: _requiresPhotoProof,
                      requiresQrValidation: _requiresQrValidation,
                    );
                    
                    await notifier.saveTask(updatedTask);
                    
                    _objectNameController.dispose();
                    _slaMinutesController.dispose();
                    _estimatedDurationController.dispose();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Simpan Perubahan'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 10, color: color)),
    );
  }

  void _confirmDelete(TaskNotifier notifier, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus tugas ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () { 
              Navigator.pop(context); 
              notifier.deleteTask(id); 
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red), 
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}