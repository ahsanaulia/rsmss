// lib/features/stock_in_entry/presentations/stock_in_entry_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/stock_in_entry_provider.dart';
import '../models/stock_in_entry_model.dart';
import 'stock_in_entry_form_screen.dart';
import '../../../../crud/stocks/models/stock_model.dart';
import '../../../../crud/stocks/providers/stock_providers.dart';

class StockInEntryListScreen extends ConsumerStatefulWidget {
  const StockInEntryListScreen({super.key});

  @override
  ConsumerState<StockInEntryListScreen> createState() => _StockInEntryListScreenState();
}

class _StockInEntryListScreenState extends ConsumerState<StockInEntryListScreen> {
  String _selectedSourceFilter = 'SEMUA';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stockListProvider.notifier).loadStocks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = StockInEntryFilter(
      sourceType: _selectedSourceFilter == 'SEMUA' ? null : _selectedSourceFilter,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
    );
    
    final entriesAsync = ref.watch(stockInEntryListProvider(filter));
    final stocksState = ref.watch(stockListProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Stok Masuk'),
        backgroundColor: const Color(0xFF01579B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: entriesAsync.when(
              data: (entries) => _buildEntryList(entries, stocksState.stocks),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (ctx) => const StockInEntryFormDialog(),
          );
          if (result == true && mounted) {
            ref.invalidate(stockInEntryListProvider(filter));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Stok masuk berhasil disimpan'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          _buildFilterChip('SEMUA', _selectedSourceFilter == 'SEMUA'),
          const SizedBox(width: 8),
          _buildFilterChip('PURCHASE', _selectedSourceFilter == 'PURCHASE'),
          const SizedBox(width: 8),
          _buildFilterChip('RETURN', _selectedSourceFilter == 'RETURN'),
          const SizedBox(width: 8),
          _buildFilterChip('DONATION', _selectedSourceFilter == 'DONATION'),
          const Spacer(),
          SizedBox(
            width: 200,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedSourceFilter = label;
        });
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: const Color(0xFF01579B).withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF01579B) : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildEntryList(List<StockInEntryWithDetail> entries, List<Stock> stocks) {
    if (entries.isEmpty) {
      return const Center(child: Text('Belum ada data stok masuk'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: entries.length,
      itemBuilder: (context, index) => _buildEntryCard(entries[index], stocks),
    );
  }

  Widget _buildEntryCard(StockInEntryWithDetail item, List<Stock> stocks) {
    final isReturn = item.entry.sourceType == 'RETURN';
    final isExpiringSoon = item.entry.expiryDate.isBefore(DateTime.now().add(const Duration(days: 90)));
    
    final stock = stocks.firstWhere(
      (s) => s.id == item.entry.stockId,
      orElse: () => Stock.empty(),
    );
    final unit = stock.unit;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isReturn ? Colors.orange.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isReturn ? 'RETURN' : item.entry.sourceType,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isReturn ? Colors.orange.shade700 : Colors.green.shade700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  item.entry.entryNumber,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.stockName,
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${item.stockCode} | ${item.entry.batchNumber}',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isExpiringSoon ? Colors.red.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${item.entry.quantity.toStringAsFixed(0)} $unit',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isExpiringSoon ? Colors.red.shade700 : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 12),
                const SizedBox(width: 4),
                Text(
                  'Expiry: ${DateFormat('dd MMM yyyy', 'id').format(item.entry.expiryDate)}',
                  style: TextStyle(fontSize: 11, color: isExpiringSoon ? Colors.red.shade700 : Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.person, size: 12),
                const SizedBox(width: 4),
                Text(
                  item.receivedByName ?? '-',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}