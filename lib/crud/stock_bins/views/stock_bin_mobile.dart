import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rsmss/crud/stock_bins/models/stock_bin_model.dart';
import 'package:rsmss/crud/stock_bins/providers/stock_bin_provider.dart';
import 'package:rsmss/crud/stock_bins/providers/stock_bin_state.dart';
import 'package:rsmss/crud/stock_bins/services/stock_bin_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ==================== HALAMAN UTAMA (LIST BIN) ====================
class StockBinMobilePage extends ConsumerStatefulWidget {
  const StockBinMobilePage({super.key});

  @override
  ConsumerState<StockBinMobilePage> createState() => _StockBinMobilePageState();
}

class _StockBinMobilePageState extends ConsumerState<StockBinMobilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stockBinProvider.notifier).loadBins();
    });
  }

  void _navigateToDetail(StockBinModel bin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockBinMobileDetailPage(bin: bin),
      ),
    ).then((_) {
      if (mounted) ref.read(stockBinProvider.notifier).loadBins();
    });
  }

  void _navigateToAddForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StockBinMobileAddPage(),
      ),
    ).then((_) {
      if (mounted) ref.read(stockBinProvider.notifier).loadBins();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockBinProvider);
    final errorMessage = state.errorMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
          ref.read(stockBinProvider.notifier).clearError();
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF01579B),
        centerTitle: true,
        title: Text(
          'Kelola Bin',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddForm,
        backgroundColor: const Color(0xFF01579B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(StockBinState state) {
    if (state.isLoading && state.bins.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.bins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Belum ada data bin', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToAddForm,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF01579B)),
              child: const Text('Tambah Bin Baru'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(stockBinProvider.notifier).loadBins();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.bins.length,
        itemBuilder: (context, index) {
          final bin = state.bins[index];
          final hasQr = bin.qrcodeUrl != null && bin.qrcodeUrl!.isNotEmpty;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: hasQr ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasQr ? Icons.qr_code : Icons.qr_code_scanner,
                  color: hasQr ? Colors.green : Colors.orange,
                ),
              ),
              title: Text(bin.code, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bin.rackCode != null && bin.shelfCode != null)
                    Text(
                      'Lokasi: ${bin.rackCode} - Level ${bin.shelfLevelNumber} - ${bin.shelfCode}',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                    ),
                  Text(
                    hasQr ? '✅ QR Code tersedia' : '⚠️ QR Code belum dibuat',
                    style: GoogleFonts.poppins(fontSize: 11, color: hasQr ? Colors.green : Colors.orange),
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _navigateToDetail(bin),
            ),
          );
        },
      ),
    );
  }
}

// ==================== FORM TAMBAH BIN BARU ====================
class StockBinMobileAddPage extends ConsumerStatefulWidget {
  const StockBinMobileAddPage({super.key});

  @override
  ConsumerState<StockBinMobileAddPage> createState() => _StockBinMobileAddPageState();
}

class _StockBinMobileAddPageState extends ConsumerState<StockBinMobileAddPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _barcodeController;
  late TextEditingController _positionXController;
  late TextEditingController _positionYController;
  late TextEditingController _maxQuantityController;
  late TextEditingController _currentQuantityController;

  String? _selectedShelfId;
  String? _selectedShelfDisplay;
  String? _selectedAssetId;
  String? _selectedAssetDisplay;
  bool _isActive = true;

  List<Map<String, dynamic>> _shelves = [];
  List<Map<String, dynamic>> _assets = [];

  bool _isLoadingData = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _barcodeController = TextEditingController();
    _positionXController = TextEditingController();
    _positionYController = TextEditingController();
    _maxQuantityController = TextEditingController();
    _currentQuantityController = TextEditingController(text: '0');
    _loadData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _barcodeController.dispose();
    _positionXController.dispose();
    _positionYController.dispose();
    _maxQuantityController.dispose();
    _currentQuantityController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final service = ref.read(stockBinServiceProvider);
    final shelves = await service.getShelves();
    final assets = await service.getAssets();
    if (mounted) {
      setState(() {
        _shelves = shelves;
        _assets = assets;
        _isLoadingData = false;
      });
    }
  }

  Future<void> _showShelfPicker() async {
    if (_shelves.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data shelf masih kosong'), backgroundColor: Colors.orange),
      );
      return;
    }
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => _buildPickerSheet(sheetContext, _shelves, Icons.shelves, Colors.cyan, 'Shelf'),
    );
    if (result != null && mounted) {
      setState(() {
        _selectedShelfId = result['id'];
        _selectedShelfDisplay = result['display_name'];
      });
    }
  }

  Future<void> _showAssetPicker() async {
    if (_assets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data aset masih kosong'), backgroundColor: Colors.orange),
      );
      return;
    }
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => _buildPickerSheet(sheetContext, _assets, Icons.inventory_2, Colors.purple, 'Aset'),
    );
    if (result != null && mounted) {
      setState(() {
        _selectedAssetId = result['id'];
        _selectedAssetDisplay = result['display_name'];
      });
    }
  }

  Widget _buildPickerSheet(BuildContext sheetContext, List<Map<String, dynamic>> items, IconData icon, Color color, String title) {
    final searchController = TextEditingController();
    List<Map<String, dynamic>> filtered = List.from(items);
    return StatefulBuilder(
      builder: (context, setStateSheet) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Cari $title...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (value) {
                      setStateSheet(() {
                        if (value.isEmpty) filtered = List.from(items);
                        else filtered = items.where((i) => (i['display_name'] as String).toLowerCase().contains(value.toLowerCase())).toList();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(child: Text('$title tidak ditemukan', style: GoogleFonts.poppins()))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return ListTile(
                              leading: Icon(icon, color: color),
                              title: Text(item['display_name']),
                              onTap: () => Navigator.pop(sheetContext, item),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedShelfId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih shelf terlebih dahulu'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isSubmitting = true);
    final bin = StockBinModel(
      shelfId: _selectedShelfId!,
      code: _codeController.text,
      barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text,
      positionX: _positionXController.text.trim().isEmpty ? null : int.tryParse(_positionXController.text),
      positionY: _positionYController.text.trim().isEmpty ? null : int.tryParse(_positionYController.text),
      maxQuantity: _maxQuantityController.text.trim().isEmpty ? null : double.tryParse(_maxQuantityController.text),
      currentQuantity: _currentQuantityController.text.trim().isEmpty ? 0 : double.tryParse(_currentQuantityController.text),
      isActive: _isActive,
      assetId: _selectedAssetId,
    );
    final success = await ref.read(stockBinProvider.notifier).createBin(bin);
    if (mounted) setState(() => _isSubmitting = false);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bin berhasil ditambahkan'), backgroundColor: Colors.green));
      Navigator.pop(context, true);
    }
  }

  String? _validateCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'Kode bin wajib diisi';
    if (value.trim().length < 2) return 'Minimal 2 karakter';
    if (value.trim().length > 30) return 'Maksimal 30 karakter';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(
        backgroundColor: Color(0xFFE0F2F1),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('Tambah Bin Baru', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InkWell(
                onTap: _showShelfPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey[400]!), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.shelves),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_selectedShelfDisplay ?? 'Pilih Shelf *', style: TextStyle(color: _selectedShelfDisplay == null ? Colors.grey : Colors.black))),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Kode Bin *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.qr_code)),
                validator: _validateCode,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _barcodeController,
                decoration: const InputDecoration(labelText: 'Barcode', border: OutlineInputBorder(), prefixIcon: Icon(Icons.qr_code_2)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _positionXController, decoration: const InputDecoration(labelText: 'Posisi X', border: OutlineInputBorder()))),
                  const SizedBox(width: 16),
                  Expanded(child: TextFormField(controller: _positionYController, decoration: const InputDecoration(labelText: 'Posisi Y', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _maxQuantityController, decoration: const InputDecoration(labelText: 'Kapasitas Maks', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: TextFormField(controller: _currentQuantityController, decoration: const InputDecoration(labelText: 'Stok Saat Ini', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _showAssetPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey[400]!), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_selectedAssetDisplay ?? 'Pilih Aset (opsional)', style: TextStyle(color: _selectedAssetDisplay == null ? Colors.grey : Colors.black))),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Status Aktif'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                activeColor: Colors.green,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF01579B)),
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan Bin', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== DETAIL + GENERATE QR + PDF ====================
class StockBinMobileDetailPage extends ConsumerStatefulWidget {
  final StockBinModel bin;
  const StockBinMobileDetailPage({super.key, required this.bin});

  @override
  ConsumerState<StockBinMobileDetailPage> createState() => _StockBinMobileDetailPageState();
}

class _StockBinMobileDetailPageState extends ConsumerState<StockBinMobileDetailPage> {
  bool _isGenerating = false;
  bool _isPrinting = false;
  final ScreenshotController _screenshotController = ScreenshotController();
  StockBinModel? _currentBin;

  @override
  void initState() {
    super.initState();
    _currentBin = widget.bin;
  }

  Future<void> _generateQr() async {
    setState(() => _isGenerating = true);
    try {
      final service = ref.read(stockBinServiceProvider);
      final qrUrl = await service.generateAndUploadQr(
        binId: _currentBin!.id!,
        binCode: _currentBin!.code,
        shelfCode: _currentBin!.shelfCode ?? '-',
        rackCode: _currentBin!.rackCode ?? '-',
        warehouseName: _currentBin!.warehouseName ?? '-',
      );
      if (qrUrl != null) {
        await service.updateQrCodeUrl(_currentBin!.id!, qrUrl);
        // Reload bin data to get updated qrcode_url
        final updated = await service.getBinById(_currentBin!.id!);
        if (updated != null && mounted) {
          setState(() {
            _currentBin = StockBinModel.fromJson(updated);
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR Code berhasil digenerate'), backgroundColor: Colors.green),
        );
      } else {
        throw Exception('Gagal generate QR');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _saveAsPdf() async {
    setState(() => _isPrinting = true);
    try {
      // Capture QR widget as image
      final imageBytes = await _screenshotController.captureFromWidget(
        Material(
          child: Container(
            width: 350,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "QR CODE STORAGE BIN",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF01579B),
                  ),
                ),
                const SizedBox(height: 20),
                QrImageView(data: _currentBin!.id!, size: 200, backgroundColor: Colors.white),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow("Kode Bin", _currentBin!.code),
                      const SizedBox(height: 6),
                      _buildInfoRow("Rak", _currentBin!.rackCode ?? '-'),
                      const SizedBox(height: 6),
                      _buildInfoRow("Shelf", _currentBin!.shelfCode ?? '-'),
                      const SizedBox(height: 6),
                      _buildInfoRow("Gudang", _currentBin!.warehouseName ?? '-'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "RSMSS IoT - Inventory Management System",
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );

      if (imageBytes == null) throw Exception('Gagal generate gambar QR');

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context ctx) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    "STORAGE BIN QR CODE",
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Image(pw.MemoryImage(imageBytes), width: 200, height: 200),
                  pw.SizedBox(height: 30),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(children: [pw.Text("Kode Bin: ", style:  pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(_currentBin!.code)]),
                        pw.SizedBox(height: 6),
                        pw.Row(children: [pw.Text("Rak: ", style:  pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(_currentBin!.rackCode ?? '-')]),
                        pw.SizedBox(height: 6),
                        pw.Row(children: [pw.Text("Shelf: ", style:  pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(_currentBin!.shelfCode ?? '-')]),
                        pw.SizedBox(height: 6),
                        pw.Row(children: [pw.Text("Gudang: ", style:  pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(_currentBin!.warehouseName ?? '-')]),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text("RSMSS IoT - Inventory Management System", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                ],
              ),
            );
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: "bin_qr_${_currentBin!.code}_${DateTime.now().millisecondsSinceEpoch}.pdf",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF siap dibagikan"), backgroundColor: Colors.green),
      );
    } catch (e) {
      debugPrint("PDF error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membuat PDF: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Text(":", style: GoogleFonts.poppins(fontSize: 12)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasQr = _currentBin!.qrcodeUrl != null && _currentBin!.qrcodeUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('Detail Bin: ${_currentBin!.code}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kode Bin: ${_currentBin!.code}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Lokasi: ${_currentBin!.rackCode ?? '-'} - Level ${_currentBin!.shelfLevelNumber ?? '-'} - ${_currentBin!.shelfCode ?? '-'}'),
                    const SizedBox(height: 8),
                    Text('Gudang: ${_currentBin!.warehouseName ?? '-'}'),
                    const SizedBox(height: 8),
                    Text('Zona: ${_currentBin!.zoneName ?? '-'}'),
                    const SizedBox(height: 16),
                    if (hasQr) ...[
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text('QR Code:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Image.network(
                        _currentBin!.qrcodeUrl!,
                        width: 150,
                        height: 150,
                        errorBuilder: (_, __, ___) => const Icon(Icons.qr_code, size: 150),
                      ),
                    ] else
                      const Text('Belum ada QR Code', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateQr,
                icon: _isGenerating
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.qr_code),
                label: Text(_isGenerating ? 'Mengenerate...' : (hasQr ? 'Generate Ulang QR' : 'Generate QR')),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF01579B)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isPrinting ? null : _saveAsPdf,
                icon: _isPrinting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.picture_as_pdf),
                label: const Text('Save as PDF'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}