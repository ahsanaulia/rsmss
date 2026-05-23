import 'package:flutter/material.dart';
import 'package:rsmss/crud/stock_bins/models/stock_bin_model.dart';

class StockBinDetailPage extends StatelessWidget {
  final StockBinModel bin;

  const StockBinDetailPage({
    super.key,
    required this.bin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: ${bin.code}'),
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
                          color: bin.isActive == true 
                              ? Colors.green.shade50 
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.inventory,
                          size: 48,
                          color: bin.isActive == true ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        bin.code,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (bin.barcode != null)
                        Chip(
                          label: Text('Barcode: ${bin.barcode}'),
                          backgroundColor: Colors.green.shade100,
                        ),
                      if (bin.isActive == false)
                        const Chip(
                          label: Text('Nonaktif'),
                          backgroundColor: Colors.red,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                
                _buildDetailRow('ID', bin.id ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Kode Bin', bin.code),
                const SizedBox(height: 12),
                if (bin.barcode != null)
                  _buildDetailRow('Barcode', bin.barcode!),
                if (bin.barcode != null)
                  const SizedBox(height: 12),
                if (bin.rackCode != null && bin.shelfCode != null)
                  _buildDetailRow('Lokasi', '${bin.rackCode} - Level ${bin.shelfLevelNumber} - ${bin.shelfCode}'),
                if (bin.zoneName != null && bin.warehouseName != null)
                  _buildDetailRow('Zona & Gudang', '${bin.warehouseName} / ${bin.zoneName}'),
                if (bin.positionX != null || bin.positionY != null)
                  _buildDetailRow('Posisi', 'X: ${bin.positionX ?? "-"}, Y: ${bin.positionY ?? "-"}'),
                if (bin.positionX != null || bin.positionY != null)
                  const SizedBox(height: 12),
                if (bin.maxQuantity != null)
                  _buildDetailRow('Kapasitas Maks', '${bin.maxQuantity}'),
                if (bin.maxQuantity != null)
                  const SizedBox(height: 12),
                _buildDetailRow('Stok Saat Ini', '${bin.currentQuantity ?? 0}'),
                const SizedBox(height: 12),
                // if (bin.currentProductName != null)
                //   _buildDetailRow('Produk', '${bin.currentProductCode} - ${bin.currentProductName}'),
                // if (bin.currentProductName != null)
                //   const SizedBox(height: 12),
                if (bin.assetName != null)
                  _buildDetailRow('Aset', '${bin.assetCode} - ${bin.assetName}'),
                if (bin.assetName != null)
                  const SizedBox(height: 12),
                if (bin.qrcodeUrl != null)
                  _buildDetailRow('QR Code URL', bin.qrcodeUrl!),
                if (bin.qrcodeUrl != null)
                  const SizedBox(height: 12),
                _buildDetailRow('Status', bin.isActive == true ? 'Aktif' : 'Nonaktif'),
                const SizedBox(height: 12),
                if (bin.metadata != null)
                  _buildDetailRow('Metadata', bin.metadata.toString()),
                if (bin.metadata != null)
                  const SizedBox(height: 12),
                _buildDetailRow(
                  'Dibuat Pada',
                  bin.createdAt != null
                      ? _formatDateTime(bin.createdAt!)
                      : '-',
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Dibuat Oleh', bin.createdBy ?? '-'),
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