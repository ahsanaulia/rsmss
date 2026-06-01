// File: lib/crud/beds/views/bed_form_page.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/bed_model.dart';

class BedFormPage extends StatefulWidget {
  final BedModel? bed;

  const BedFormPage({super.key, this.bed});

  @override
  State<BedFormPage> createState() => _BedFormPageState();
}

class _BedFormPageState extends State<BedFormPage> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  late String _roomId;
  late String _bedNumber;
  late String _assetId;
  late String _status;
  DateTime? _admittedAt;
  String? _notes;

  List<Map<String, dynamic>> _rooms = [];
  List<Map<String, dynamic>> _assets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _roomId = widget.bed?.roomId ?? '';
    _bedNumber = widget.bed?.bedNumber ?? '';
    _assetId = widget.bed?.assetId ?? '';
    _status = widget.bed?.status ?? 'EMPTY';
    _admittedAt = widget.bed?.admittedAt;
    _notes = widget.bed?.notes;
    _loadDropdowns();
  }

  Future<void> _loadDropdowns() async {
    try {
      final [roomsRes, assetsRes] = await Future.wait([
        _supabase.from('rooms').select('id, room_name'),
        _supabase.from('assets').select('id, asset_name'),
      ]);

      setState(() {
        _rooms = List<Map<String, dynamic>>.from(roomsRes);
        _assets = List<Map<String, dynamic>>.from(assetsRes);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final data = {
      'room_id': _roomId,
      'bed_number': _bedNumber,
      'asset_id': _assetId,
      'status': _status,
      'admitted_at': _status == 'OCCUPIED' && _admittedAt != null
          ? _admittedAt!.toIso8601String()
          : null,
      'notes': _notes,
    };

    try {
      if (widget.bed == null) {
        await _supabase.from('beds').insert(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bed berhasil ditambahkan')),
          );
        }
      } else {
        await _supabase.from('beds').update(data).eq('id', widget.bed!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bed berhasil diperbarui')),
          );
        }
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bed == null ? 'Tambah Bed Baru' : 'Edit Bed',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF01579B),
        foregroundColor: Colors.white,
      ),
      body: _isLoading && _rooms.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Ruangan *',
                                border: OutlineInputBorder(),
                              ),
                              value: _roomId.isEmpty ? null : _roomId,
                              items: _rooms.map((room) {
                                return DropdownMenuItem(
                                  value: room['id'].toString(),
                                  child: Text(room['room_name']),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _roomId = value!),
                              validator: (value) => value == null ? 'Pilih ruangan' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: _bedNumber,
                              decoration: const InputDecoration(
                                labelText: 'Nomor Bed *',
                                border: OutlineInputBorder(),
                              ),
                              onSaved: (value) => _bedNumber = value!,
                              validator: (value) => value == null || value.isEmpty ? 'Masukkan nomor bed' : null,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Aset (Tempat Tidur) *',
                                border: OutlineInputBorder(),
                              ),
                              value: _assetId.isEmpty ? null : _assetId,
                              items: _assets.map((asset) {
                                return DropdownMenuItem(
                                  value: asset['id'].toString(),
                                  child: Text(asset['asset_name']),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _assetId = value!),
                              validator: (value) => value == null ? 'Pilih aset' : null,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                              ),
                              value: _status,
                              items: const [
                                DropdownMenuItem(value: 'EMPTY', child: Text('Kosong')),
                                DropdownMenuItem(value: 'OCCUPIED', child: Text('Terisi')),
                                DropdownMenuItem(value: 'MAINTENANCE', child: Text('Perawatan')),
                              ],
                              onChanged: (value) {
                                setState(() => _status = value!);
                                if (_status != 'OCCUPIED') {
                                  _admittedAt = null;
                                }
                              },
                            ),
                            if (_status == 'OCCUPIED') ...[
                              const SizedBox(height: 16),
                              ListTile(
                                title: const Text('Tanggal Masuk'),
                                subtitle: Text(_admittedAt != null
                                    ? '${_admittedAt!.day}/${_admittedAt!.month}/${_admittedAt!.year}'
                                    : 'Belum diisi'),
                                trailing: const Icon(Icons.calendar_today),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _admittedAt ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setState(() => _admittedAt = date);
                                  }
                                },
                              ),
                            ],
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: _notes,
                              decoration: const InputDecoration(
                                labelText: 'Catatan',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              onSaved: (value) => _notes = value,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                            ),
                            child: Text(widget.bed == null ? 'Simpan' : 'Update'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}