// lib/features/stock_in_bins/presentations/pending_put_away_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stock_in_bins_providers.dart';
import 'put_away_form_mobile.dart';

class PendingPutAwayList extends ConsumerStatefulWidget {
  const PendingPutAwayList({super.key});

  @override
  ConsumerState<PendingPutAwayList> createState() => _PendingPutAwayListState();
}

class _PendingPutAwayListState extends ConsumerState<PendingPutAwayList> {
  @override
  void initState() {
    super.initState();
    // Initial load
    Future.microtask(() {
      ref.read(pendingStockInNotifierProvider.notifier).refresh();
    });
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
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
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
                        Text('${item.stockName} - ${item.quantity} ${item.unit}'),
                        Text('Batch: ${item.batchNumber} | Exp: ${_formatDate(item.expiryDate)}'),
                        const SizedBox(height: 4),
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
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PutAwayFormMobile(stockInId: item.id!),
                        ),
                      );
                      
                      if (result == true && mounted) {
                        // Refresh list setelah put away
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