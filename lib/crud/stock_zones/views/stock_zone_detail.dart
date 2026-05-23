import 'package:flutter/material.dart';
import 'package:rsmss/crud/stock_zones/models/stock_zone_model.dart';

class StockZoneDetailPage extends StatelessWidget {
  final StockZoneModel zone;

  const StockZoneDetailPage({
    super.key,
    required this.zone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: ${zone.name}'),
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
                          color: zone.isRestricted == true 
                              ? Colors.red.shade50 
                              : Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          zone.isRestricted == true ? Icons.lock : Icons.map,
                          size: 48,
                          color: zone.isRestricted == true ? Colors.red : Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        zone.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text('Kode: ${zone.code}'),
                        backgroundColor: Colors.teal.shade100,
                      ),
                      if (zone.isRestricted == true)
                        const Chip(
                          label: Text('Restricted Area'),
                          backgroundColor: Colors.red,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                
                _buildDetailRow('ID', zone.id ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Kode Zona', zone.code),
                const SizedBox(height: 12),
                _buildDetailRow('Nama Zona', zone.name),
                const SizedBox(height: 12),
                if (zone.warehouseName != null)
                  _buildDetailRow('Gudang', '${zone.warehouseCode} - ${zone.warehouseName}'),
                if (zone.warehouseName != null)
                  const SizedBox(height: 12),
                if (zone.zoneType != null)
                  _buildDetailRow('Tipe Zona', zone.zoneType!),
                if (zone.zoneType != null)
                  const SizedBox(height: 12),
                if (zone.temperatureMin != null || zone.temperatureMax != null)
                  _buildDetailRow(
                    'Rentang Suhu', 
                    '${zone.temperatureMin?.toString() ?? "?"} - ${zone.temperatureMax?.toString() ?? "?"} °C',
                  ),
                if (zone.temperatureMin != null || zone.temperatureMax != null)
                  const SizedBox(height: 12),
                if (zone.humidityMin != null || zone.humidityMax != null)
                  _buildDetailRow(
                    'Rentang Kelembaban', 
                    '${zone.humidityMin?.toString() ?? "?"} - ${zone.humidityMax?.toString() ?? "?"} %',
                  ),
                if (zone.humidityMin != null || zone.humidityMax != null)
                  const SizedBox(height: 12),
                if (zone.buildingName != null && zone.floorName != null && zone.roomName != null)
                  _buildDetailRow('Lokasi Ruangan', '${zone.buildingName} - Lantai ${zone.floorName} - ${zone.roomName}'),
                if (zone.roomName != null && zone.buildingName == null)
                  _buildDetailRow('Ruangan', zone.roomName!),
                if (zone.roomName != null)
                  const SizedBox(height: 12),
                _buildDetailRow('Area Terbatas', zone.isRestricted == true ? 'Ya' : 'Tidak'),
                const SizedBox(height: 12),
                if (zone.metadata != null)
                  _buildDetailRow('Metadata', zone.metadata.toString()),
                if (zone.metadata != null)
                  const SizedBox(height: 12),
                _buildDetailRow(
                  'Dibuat Pada',
                  zone.createdAt != null
                      ? _formatDateTime(zone.createdAt!)
                      : '-',
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Dibuat Oleh', zone.createdBy ?? '-'),
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
          width: 140,
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