import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/employee_qualifications/providers/employee_qualification_provider.dart';
import 'package:rsmss/crud/employee_qualifications/providers/employee_qualification_state.dart';
import 'package:rsmss/crud/employee_qualifications/models/employee_qualification_model.dart';
import 'employee_qualification_form.dart';
import 'employee_qualification_detail.dart';
import 'package:rsmss/l10n/app_localizations.dart';

class EmployeeQualificationListPage extends ConsumerStatefulWidget {
  const EmployeeQualificationListPage({super.key});

  @override
  ConsumerState<EmployeeQualificationListPage> createState() => _EmployeeQualificationListPageState();
}

class _EmployeeQualificationListPageState extends ConsumerState<EmployeeQualificationListPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      ref.read(employeeQualificationProvider.notifier).loadItems();
    });
  }

  Future<void> _refreshData() async {
    await ref.read(employeeQualificationProvider.notifier).loadItems();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    ref.read(employeeQualificationProvider.notifier).clearError();
  }

  Future<void> _confirmDelete(BuildContext context, EmployeeQualificationModel item) async {
    final localizations = AppLocalizations.of(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations?.crud_eq_delete_title ?? 'Hapus Kualifikasi'),
        content: Text('${localizations?.crud_eq_delete_confirm_content ?? 'Apakah Anda yakin ingin menghapus kualifikasi ini?'}\n\n"${item.qualificationName}"\n${localizations?.crud_eq_code_label ?? 'Kode: '}${item.qualificationCode}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizations?.crud_eq_delete_cancel ?? 'Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(localizations?.crud_eq_delete_confirm ?? 'Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(employeeQualificationProvider.notifier).delete(item.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations?.crud_eq_delete_success ?? 'Kualifikasi berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToForm({EmployeeQualificationModel? item}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeQualificationFormPage(
          item: item,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToDetail(EmployeeQualificationModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeQualificationDetailPage(
          item: item,
        ),
      ),
    );
  }

  String _getCategoryLabel(String? category) {
    switch (category) {
      case 'medical':
        return 'Medis';
      case 'nursing':
        return 'Keperawatan';
      case 'administrative':
        return 'Administrasi';
      case 'technical':
        return 'Teknis';
      default:
        return category ?? '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final state = ref.watch(employeeQualificationProvider);
    final errorMessage = state.errorMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(errorMessage);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.crud_eq_title ?? 'Kualifikasi Pegawai'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: localizations?.crud_eq_refresh_tooltip ?? 'Refresh',
          ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(EmployeeQualificationState state) {
    final localizations = AppLocalizations.of(context);
    
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              localizations?.crud_eq_empty_data ?? 'Belum ada data kualifikasi',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _navigateToForm(),
              child: Text(localizations?.crud_eq_add_button ?? 'Tambah Kualifikasi'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          final isActive = item.isActive ?? true;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.shade50 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.verified,
                  color: isActive ? Colors.green : Colors.grey,
                ),
              ),
              title: Text(
                item.qualificationName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${localizations?.crud_eq_code_label ?? 'Kode: '}${item.qualificationCode}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (item.category != null)
                    Text(
                      '${localizations?.crud_eq_category_label ?? 'Kategori: '}${_getCategoryLabel(item.category)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  if (item.validityPeriodMonths != null)
                    Text(
                      '${localizations?.crud_eq_validity_label ?? 'Masa Berlaku: '}${item.validityPeriodMonths}${localizations?.crud_eq_months_suffix ?? ' bulan'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isActive 
                              ? (localizations?.crud_eq_status_active ?? 'Aktif') 
                              : (localizations?.crud_eq_status_inactive ?? 'Nonaktif'),
                          style: TextStyle(
                            fontSize: 10,
                            color: isActive ? Colors.green.shade800 : Colors.red.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (item.requiresRenewal == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            localizations?.crud_eq_requires_renewal ?? 'Perlu Perpanjangan',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _navigateToForm(item: item);
                      break;
                    case 'detail':
                      _navigateToDetail(item);
                      break;
                    case 'delete':
                      _confirmDelete(context, item);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'detail',
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 20),
                        const SizedBox(width: 12),
                        Text(localizations?.crud_eq_menu_detail ?? 'Detail'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 20),
                        const SizedBox(width: 12),
                        Text(localizations?.crud_eq_menu_edit ?? 'Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        const SizedBox(width: 12),
                        Text(localizations?.crud_eq_menu_delete ?? 'Hapus', style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () => _navigateToDetail(item),
            ),
          );
        },
      ),
    );
  }
}