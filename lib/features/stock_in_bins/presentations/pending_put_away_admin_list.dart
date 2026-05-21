// lib/features/stock_in_bins/presentations/pending_put_away_admin_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stock_in_bins_providers.dart';
import 'put_away_form_admin.dart';

class PendingPutAwayAdminList extends ConsumerStatefulWidget {
  const PendingPutAwayAdminList({super.key});

  @override
  ConsumerState<PendingPutAwayAdminList> createState() => _PendingPutAwayAdminListState();
}

class _PendingPutAwayAdminListState extends ConsumerState<PendingPutAwayAdminList> {
  // Map untuk menyimpan sisa stok per stock_in_id
  final Map<String, double> _remainingMap = {};
  final Map<String, double> _totalPutAwayMap = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(pendingStockInNotifierProvider.notifier).refresh();
    });
  }

  Future<void> _loadRemaining(String stockInId) async {
    try {
      final detail = await ref.read(pendingStockInDetailProvider(stockInId).future);
      final remaining = detail['remaining'] as double;
      final totalPutAway = detail['totalPutAway'] as double;
      setState(() {
        _remainingMap[stockInId] = remaining;
        _totalPutAwayMap[stockInId] = totalPutAway;
      });
    } catch (e) {
      print('Error loading remaining for $stockInId: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(pendingStockInNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Yang Belum Ditempatkan'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              _remainingMap.clear();
              _totalPutAwayMap.clear();
              await ref.read(pendingStockInNotifierProvider.notifier).refresh();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data diperbarui')),
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _remainingMap.clear();
          _totalPutAwayMap.clear();
          await ref.read(pendingStockInNotifierProvider.notifier).refresh();
        },
        child: pendingAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 64, color: Colors.green),
                    SizedBox(height: 16),
                    Text('Tidak ada stok yang menunggu ditempatkan'),
                  ],
                ),
              );
            }
            
            // Load remaining untuk setiap item yang belum
            for (var item in items) {
              if (!_remainingMap.containsKey(item.id)) {
                _loadRemaining(item.id!);
              }
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final remaining = _remainingMap[item.id] ?? item.quantity;
                final totalPutAway = _totalPutAwayMap[item.id] ?? 0;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.withOpacity(0.2),
                      child: const Icon(Icons.inventory, color: Colors.orange),
                    ),
                    title: Text(item.receiptNumber),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item.stockName}'),
                        Text('Batch: ${item.batchNumber} | Exp: ${_formatDate(item.expiryDate)}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: item.status == 'RECEIVED' ? Colors.orange : Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.status == 'RECEIVED' ? 'BELUM DITEMPATKAN' : 'SEBAGIAN',
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sudah: ${totalPutAway.toInt()} ${item.unit}',
                              style: const TextStyle(fontSize: 12, color: Colors.green),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sisa: ${remaining.toInt()} ${item.unit}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PutAwayFormAdmin(stockInId: item.id!),
                        ),
                      );
                      
                      if (result == true && mounted) {
                        _remainingMap.clear();
                        _totalPutAwayMap.clear();
                        await ref.read(pendingStockInNotifierProvider.notifier).refresh();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Stok berhasil ditempatkan')),
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _remainingMap.clear();
                    ref.read(pendingStockInNotifierProvider.notifier).refresh();
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}