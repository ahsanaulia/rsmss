// ============================================================
// PAGE: Stock List Page
// ============================================================
// TANGGUNG JAWAB:
// 1. Menampilkan daftar stok dalam bentuk card
// 2. Search berdasarkan nama stok, kode stok, atau tipe stok
// 3. Filter berdasarkan kondisi (Semua, GOOD, LOW, Habis, Stok Rendah)
// 4. Tombol tambah stok (buka dialog)
// 5. Aksi edit (dialog), delete (konfirmasi), detail (navigasi)
// 6. Pull-to-refresh untuk reload data
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../providers/stock_providers.dart';
import '../../providers/stock_state.dart';
import '../../models/stock_model.dart';
import '../dialogs/stock_form_dialog.dart';
import 'stock_detail_page.dart';
import '../../widgets/stock_card.dart';

class StockListPage extends ConsumerStatefulWidget {
  const StockListPage({super.key});

  @override
  ConsumerState<StockListPage> createState() => _StockListPageState();
}

class _StockListPageState extends ConsumerState<StockListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterCondition = 'all'; // all, GOOD, LOW, empty, low_stock
  
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _authService = getIt<AuthService>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(stockListProvider.notifier);
      notifier.loadStocks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String? get _currentUserId {
    final userId = _authService.currentUserId;
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return userId;
  }

  /// Filter stok berdasarkan search query dan filter kondisi
  List<Stock> _filterStocks(List<Stock> stocks) {
    return stocks.where((stock) {
      // Search query (nama stok, kode stok, tipe stok)
      if (_searchQuery.isNotEmpty) {
        final matchName = stock.stockName.toLowerCase().contains(_searchQuery);
        final matchCode = stock.stockCode?.toLowerCase().contains(_searchQuery) ?? false;
        final matchType = stock.stockTypeName?.toLowerCase().contains(_searchQuery) ?? false;
        
        if (!(matchName || matchCode || matchType)) {
          return false;
        }
      }
      
      // Filter kondisi
      if (_filterCondition != 'all') {
        if (_filterCondition == 'empty' && !stock.isEmpty) return false;
        if (_filterCondition == 'low_stock' && !stock.isLowStock) return false;
        if (_filterCondition == 'GOOD' && stock.stockCondition != 'GOOD') return false;
        if (_filterCondition == 'LOW' && stock.stockCondition != 'LOW') return false;
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockListProvider);
    final notifier = ref.read(stockListProvider.notifier);

    // Handle error message
    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!), backgroundColor: Colors.red.shade700),
        );
      });
    }

    final filteredStocks = _filterStocks(state.stocks);

    return Column(
      children: [
        // ==========================================================
        // HEADER: Search, Filter, Tombol Tambah
        // ==========================================================
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            border: const Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
          ),
          child: Row(
            children: [
              // Search Field
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama, kode, atau tipe stok...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Filter Kondisi Dropdown
              Container(
                width: 160,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filterCondition,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Semua Stok')),
                      DropdownMenuItem(value: 'GOOD', child: Text('Kondisi Baik')),
                      DropdownMenuItem(value: 'LOW', child: Text('Stok Rendah')),
                      DropdownMenuItem(value: 'empty', child: Text('Stok Habis')),
                      DropdownMenuItem(value: 'low_stock', child: Text('Di Bawah Minimum')),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _filterCondition = v!;
                      });
                      notifier.filterByCondition(v);
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Tombol Reset Filter
              if (_filterCondition != 'all' || _searchQuery.isNotEmpty)
                IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _filterCondition = 'all';
                      _searchQuery = '';
                    });
                    notifier.resetFilter();
                  },
                  icon: const Icon(Icons.clear_all, color: Color(0xFF01579B)),
                  tooltip: 'Reset Filter',
                ),
              
              // Tombol Tambah Stok
              ElevatedButton.icon(
                onPressed: () {
                  final userId = _currentUserId;
                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Session expired, silakan login ulang'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  _showStockFormDialog(
                    context: context,
                    ref: ref,
                    isEditing: false,
                    onSuccess: () {
                      notifier.loadStocks();
                    },
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Stok'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01579B),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // ==========================================================
        // BODY: Loading, Empty, atau List
        // ==========================================================
        if (state.isLoading)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF01579B)),
            ),
          ),

        if (!state.isLoading && filteredStocks.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada data stok',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Klik tombol "Tambah Stok" untuk memulai',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (!state.isLoading && filteredStocks.isNotEmpty)
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await notifier.loadStocks();
              },
              color: const Color(0xFF01579B),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredStocks.length,
                itemBuilder: (context, index) {
                  final stock = filteredStocks[index];
                  return StockCard(
                    stock: stock,
                    onTap: () {
                      // Navigasi ke halaman detail
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StockDetailPage(
                            stockId: stock.id,
                            onStockUpdated: () {
                              // Refresh list saat kembali dari detail
                              notifier.loadStocks();
                            },
                          ),
                        ),
                      );
                    },
                    onEdit: () {
                      final userId = _currentUserId;
                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Session expired, silakan login ulang'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      _showStockFormDialog(
                        context: context,
                        ref: ref,
                        isEditing: true,
                        existingStock: stock,
                        onSuccess: () {
                          notifier.loadStocks();
                        },
                      );
                    },
                    onDelete: () {
                      _confirmDelete(
                        context: context,
                        stockId: stock.id,
                        stockName: stock.stockName,
                        onConfirm: () async {
                          final success = await notifier.deleteStock(stock.id);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Stok berhasil dihapus'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  /// Menampilkan dialog form untuk create/edit stok
  void _showStockFormDialog({
    required BuildContext context,
    required WidgetRef ref,
    required bool isEditing,
    Stock? existingStock,
    required VoidCallback onSuccess,
  }) {
    final stockService = ref.read(stockServiceProvider);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StockFormDialog(
          isEditing: isEditing,
          existingStock: existingStock,
          stockService: stockService,
          currentUserId: _currentUserId,
          onSuccess: () {
            Navigator.pop(dialogContext);
            onSuccess();
          },
        );
      },
    );
  }

  /// Konfirmasi delete stok
  void _confirmDelete({
    required BuildContext context,
    required String stockId,
    required String stockName,
    required Future<void> Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus stok "$stockName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}