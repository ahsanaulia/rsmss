// lib/features/stock_in/presentations/stock_in_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stock_in_model.dart';
import '../providers/stock_in_providers.dart';
import 'stock_in_form_admin.dart';

class StockInListScreen extends ConsumerStatefulWidget {
  const StockInListScreen({super.key});

  @override
  ConsumerState<StockInListScreen> createState() => _StockInListScreenState();
}

class _StockInListScreenState extends ConsumerState<StockInListScreen> {
  String _filterStatus = 'ALL';
  String _searchQuery = '';

  Color _getStatusColor(String status) {
    switch (status) {
      case 'RECEIVED': return Colors.orange;
      case 'PARTIALLY_PUT_AWAY': return Colors.blue;
      case 'COMPLETED': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'RECEIVED': return 'Diterima';
      case 'PARTIALLY_PUT_AWAY': return 'Sebagian di Bin';
      case 'COMPLETED': return 'Selesai';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stocksAsync = ref.watch(stockInListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Stok Masuk'),
        elevation: 2,
        actions: [
          // Filter dropdown
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _filterStatus,
              items: const [
                DropdownMenuItem(value: 'ALL', child: Text('Semua Status')),
                DropdownMenuItem(value: 'RECEIVED', child: Text('Diterima')),
                DropdownMenuItem(value: 'PARTIALLY_PUT_AWAY', child: Text('Sebagian di Bin')),
                DropdownMenuItem(value: 'COMPLETED', child: Text('Selesai')),
              ],
              onChanged: (value) {
                setState(() => _filterStatus = value!);
              },
              underline: const SizedBox(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          // Search
          Container(
            width: 250,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: stocksAsync.when(
        data: (stocks) {
          var filteredStocks = stocks.where((s) {
            if (_filterStatus != 'ALL' && s.status != _filterStatus) return false;
            if (_searchQuery.isNotEmpty) {
              return s.receiptNumber.toLowerCase().contains(_searchQuery) ||
                  s.stockName.toLowerCase().contains(_searchQuery) ||
                  s.stockCode.toLowerCase().contains(_searchQuery);
            }
            return true;
          }).toList();
          
          if (filteredStocks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada data stok masuk'),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredStocks.length,
            itemBuilder: (context, index) {
              final stock = filteredStocks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(stock.status).withOpacity(0.2),
                    child: Icon(Icons.receipt, color: _getStatusColor(stock.status)),
                  ),
                  title: Text(
                    '${stock.receiptNumber} - ${stock.stockName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Batch: ${stock.batchNumber} | Exp: ${_formatDate(stock.expiryDate)}'),
                      Text('Jumlah: ${stock.quantity} ${stock.unit}'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(stock.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(stock.status),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(stock.receivedAt),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StockInFormAdmin(existingStockIn: stock),
                      ),
                    ).then((_) {
                      ref.invalidate(stockInListProvider);
                    });
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StockInFormAdmin(),
            ),
          ).then((_) {
            ref.invalidate(stockInListProvider);
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Stok Masuk'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}