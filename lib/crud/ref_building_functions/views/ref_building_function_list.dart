import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/ref_building_functions/providers/ref_building_function_provider.dart';
import 'package:rsmss/crud/ref_building_functions/providers/ref_building_function_state.dart';
import 'package:rsmss/crud/ref_building_functions/models/ref_building_function_model.dart';
import 'ref_building_function_form.dart';
import 'ref_building_function_detail.dart';

class RefBuildingFunctionListPage extends ConsumerStatefulWidget {
  const RefBuildingFunctionListPage({super.key});

  @override
  ConsumerState<RefBuildingFunctionListPage> createState() => _RefBuildingFunctionListPageState();
}

class _RefBuildingFunctionListPageState extends ConsumerState<RefBuildingFunctionListPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      ref.read(refBuildingFunctionProvider.notifier).loadFunctions();
    });
  }

  Future<void> _refreshData() async {
    await ref.read(refBuildingFunctionProvider.notifier).loadFunctions();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    ref.read(refBuildingFunctionProvider.notifier).clearError();
  }

  Future<void> _confirmDelete(BuildContext context, RefBuildingFunctionModel function) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Fungsi Gedung'),
        content: Text('Apakah Anda yakin ingin menghapus "${function.functionName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(refBuildingFunctionProvider.notifier).deleteFunction(function.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fungsi gedung berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToForm({RefBuildingFunctionModel? function}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefBuildingFunctionFormPage(
          function: function,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToDetail(RefBuildingFunctionModel function) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefBuildingFunctionDetailPage(
          function: function,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(refBuildingFunctionProvider);
    final errorMessage = state.errorMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(errorMessage);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fungsi Gedung'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
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

  Widget _buildBody(RefBuildingFunctionState state) {
    if (state.isLoading && state.functions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.functions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data fungsi gedung',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _navigateToForm(),
              child: const Text('Tambah Fungsi Gedung'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: state.functions.length,
        itemBuilder: (context, index) {
          final function = state.functions[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.business_center, color: Colors.purple),
              ),
              title: Text(
                function.functionName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: function.description != null && function.description!.isNotEmpty
                  ? Text(
                      function.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _navigateToForm(function: function);
                      break;
                    case 'detail':
                      _navigateToDetail(function);
                      break;
                    case 'delete':
                      _confirmDelete(context, function);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'detail',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 20),
                        SizedBox(width: 12),
                        Text('Detail'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () => _navigateToDetail(function),
            ),
          );
        },
      ),
    );
  }
}