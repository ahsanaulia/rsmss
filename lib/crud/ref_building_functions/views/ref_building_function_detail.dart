import 'package:flutter/material.dart';
import 'package:rsmss/crud/ref_building_functions/models/ref_building_function_model.dart';

class RefBuildingFunctionDetailPage extends StatelessWidget {
  final RefBuildingFunctionModel function;

  const RefBuildingFunctionDetailPage({
    super.key,
    required this.function,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: ${function.functionName}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.business_center, size: 48, color: Colors.purple),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        function.functionName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                
                _buildDetailRow('ID', function.id ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Nama Fungsi', function.functionName),
                const SizedBox(height: 12),
                if (function.description != null && function.description!.isNotEmpty)
                  _buildDetailRow('Deskripsi', function.description!),
                if (function.description != null && function.description!.isNotEmpty)
                  const SizedBox(height: 12),
                _buildDetailRow(
                  'Dibuat Pada',
                  function.createdAt != null
                      ? _formatDateTime(function.createdAt!)
                      : '-',
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Dibuat Oleh', function.createdBy ?? '-'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}