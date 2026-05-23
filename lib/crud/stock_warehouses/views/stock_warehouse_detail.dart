import 'package:flutter/material.dart';
import 'package:rsmss/crud/stock_warehouses/models/stock_warehouse_model.dart';

class StockWarehouseDetailPage extends StatelessWidget {
  final StockWarehouseModel warehouse;

  const StockWarehouseDetailPage({
    super.key,
    required this.warehouse,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: ${warehouse.name}'),
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
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.warehouse, size: 48, color: Colors.indigo),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        warehouse.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text('Kode: ${warehouse.code}'),
                        backgroundColor: Colors.indigo.shade100,
                      ),
                      if (warehouse.isActive == false)
                        const Chip(
                          label: Text('Nonaktif'),
                          backgroundColor: Colors.red,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                
                _buildDetailRow('ID', warehouse.id ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Kode Gudang', warehouse.code),
                const SizedBox(height: 12),
                _buildDetailRow('Nama Gudang', warehouse.name),
                const SizedBox(height: 12),
                if (warehouse.address != null && warehouse.address!.isNotEmpty)
                  _buildDetailRow('Alamat', warehouse.address!),
                if (warehouse.address != null && warehouse.address!.isNotEmpty)
                  const SizedBox(height: 12),
                if (warehouse.buildingName != null && warehouse.floorName != null)
                  _buildDetailRow('Lokasi', '${warehouse.buildingName} - Lantai ${warehouse.floorName}'),
                if (warehouse.buildingName != null && warehouse.floorName != null)
                  const SizedBox(height: 12),
                if (warehouse.managerName != null)
                  _buildDetailRow('Manager', warehouse.managerName!),
                if (warehouse.managerName != null)
                  const SizedBox(height: 12),
                _buildDetailRow('Status', warehouse.isActive == true ? 'Aktif' : 'Nonaktif'),
                const SizedBox(height: 12),
                if (warehouse.metadata != null)
                  _buildDetailRow('Metadata', warehouse.metadata.toString()),
                if (warehouse.metadata != null)
                  const SizedBox(height: 12),
                _buildDetailRow(
                  'Dibuat Pada',
                  warehouse.createdAt != null
                      ? _formatDateTime(warehouse.createdAt!)
                      : '-',
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Dibuat Oleh', warehouse.createdBy ?? '-'),
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