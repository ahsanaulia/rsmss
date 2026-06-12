// lib/views/monitor/widgets/gps_employee_search_dropdown.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../../providers/gps_tracking_provider.dart';

class GpsEmployeeSearchDropdown extends ConsumerStatefulWidget {
  final Function(List<String>) onSelectionChanged;
  final List<String> initialSelectedIds;

  const GpsEmployeeSearchDropdown({
    super.key,
    required this.onSelectionChanged,
    this.initialSelectedIds = const [],
  });

  @override
  ConsumerState<GpsEmployeeSearchDropdown> createState() =>
      _GpsEmployeeSearchDropdownState();
}

class _GpsEmployeeSearchDropdownState
    extends ConsumerState<GpsEmployeeSearchDropdown> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> _employees = [];
  List<String> _selectedIds = [];

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.initialSelectedIds);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(gpsEmployeesProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F2B5C).withOpacity(0.75),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 20,
                      color: const Color(0xFF3B82F6).withOpacity(0.9),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pilih Pegawai (Maksimal 3)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                    const Spacer(),
                    if (_selectedIds.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedIds.clear();
                            _searchController.clear();
                          });
                          widget.onSelectionChanged(_selectedIds);
                        },
                        child: Text(
                          'Hapus Semua',
                          style: TextStyle(
                            color: const Color(0xFFF59E0B).withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                employeesAsync.when(
                  data: (employees) {
                    _employees = employees;
                    return Column(
                      children: [
                        // Selected chips container
                        if (_selectedIds.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _selectedIds.map((id) {
                                final employee = employees.firstWhere(
                                  (e) => e['id'].toString() == id,
                                  orElse: () => {'full_name': 'Unknown'},
                                );
                                return Chip(
                                  label: Text(
                                    employee['full_name'] ?? id,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color:
                                          Colors.white, // ← putih, bukan merah
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedIds.remove(id);
                                    });
                                    widget.onSelectionChanged(_selectedIds);
                                  },
                                  deleteIcon: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  backgroundColor: const Color(
                                    0xFF3B82F6,
                                  ).withOpacity(0.35), // ← lebih gelap sedikit
                                  side: BorderSide(
                                    color: const Color(
                                      0xFF3B82F6,
                                    ).withOpacity(0.5),
                                    width: 0.5,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        const SizedBox(height: 12),
                        // Search field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Cari pegawai...',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: const Color.fromARGB(
                                  255,
                                  178,
                                  200,
                                  236,
                                ).withOpacity(0.8),
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                        // Dropdown options
                        if (_focusNode.hasFocus &&
                            _getFilteredEmployees().isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F2B5C).withOpacity(0.95),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF3B82F6).withOpacity(0.3),
                                width: 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(maxHeight: 250),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _getFilteredEmployees().length,
                              itemBuilder: (context, index) {
                                final employee = _getFilteredEmployees()[index];
                                final isSelected = _selectedIds.contains(
                                  employee['id'].toString(),
                                );
                                return Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(
                                            0xFF3B82F6,
                                          ).withOpacity(0.15)
                                        : null,
                                    border:
                                        index !=
                                            _getFilteredEmployees().length - 1
                                        ? Border(
                                            bottom: BorderSide(
                                              color: const Color(
                                                0xFF3B82F6,
                                              ).withOpacity(0.15),
                                              width: 0.5,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.person,
                                      color: isSelected
                                          ? const Color(
                                              0xFF10B981,
                                            ).withOpacity(0.9)
                                          : Colors.white.withOpacity(0.5),
                                      size: 20,
                                    ),
                                    title: Text(
                                      employee['full_name'],
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 13,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${employee['employee_id'] ?? '-'} | ${employee['unit_code'] ?? '-'}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 11,
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? Icon(
                                            Icons.check,
                                            color: const Color(
                                              0xFF10B981,
                                            ).withOpacity(0.9),
                                            size: 18,
                                          )
                                        : null,
                                    onTap: () {
                                      final id = employee['id'].toString();
                                      if (!_selectedIds.contains(id) &&
                                          _selectedIds.length < 3) {
                                        setState(() {
                                          _selectedIds.add(id);
                                          _searchController.clear();
                                        });
                                        widget.onSelectionChanged(_selectedIds);
                                      } else if (_selectedIds.length >= 3) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Maksimal 3 pegawai dapat dipilih',
                                            ),
                                            backgroundColor: Colors.orange,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          '${_selectedIds.length} dari 3 pegawai dipilih',
                          style: TextStyle(
                            fontSize: 11,
                            color: _selectedIds.length == 3
                                ? const Color(0xFFF59E0B).withOpacity(0.9)
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                  error: (error, _) => Center(
                    child: Text(
                      'Error: $error',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredEmployees() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return _employees;
    }
    return _employees.where((employee) {
      final fullName = employee['full_name'].toString().toLowerCase();
      final employeeId =
          employee['employee_id']?.toString().toLowerCase() ?? '';
      return fullName.contains(query) || employeeId.contains(query);
    }).toList();
  }
}
