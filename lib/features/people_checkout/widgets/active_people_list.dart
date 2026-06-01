// lib/features/people_checkout/widgets/active_people_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/people_checkout_service.dart';

class ActivePeopleList extends ConsumerStatefulWidget {
  final String searchQuery;
  final VoidCallback onCheckedOut;

  const ActivePeopleList({
    super.key,
    required this.searchQuery,
    required this.onCheckedOut,
  });

  @override
  ConsumerState<ActivePeopleList> createState() => _ActivePeopleListState();
}

class _ActivePeopleListState extends ConsumerState<ActivePeopleList> {
  bool _isLoading = false;

  Future<void> _checkout(String peopleId, String peopleName, String rfidTagId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Check Out'),
        content: Text(
          'Apakah $peopleName (RFID: $rfidTagId) sudah pulang?\n\n'
          'Tag RFID akan dikembalikan dan status menjadi tidak aktif.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Ya, Check Out'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final service = PeopleCheckoutService();
      await service.checkoutPeople(peopleId, peopleName);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$peopleName telah check out (pulang)'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onCheckedOut();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: PeopleCheckoutService().getActivePeople(widget.searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text('Error: ${snapshot.error}', style: GoogleFonts.poppins()),
              ],
            ),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  widget.searchQuery.isEmpty
                      ? 'Tidak ada people yang sedang aktif di RS'
                      : 'Tidak ditemukan',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final category = item['ref_people_categories'] as Map<String, dynamic>?;
            final categoryName = category?['category_name'] ?? '-';
            final markerColor = category?['marker_color'] ?? '#9B59B6';
            
            Color color;
            try {
              color = Color(int.parse(markerColor.replaceFirst('#', '0xFF')));
            } catch (e) {
              color = Colors.purple;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.person, color: color, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['full_name'] ?? '-',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'RFID: ${item['rfid_tag_id'] ?? '-'}',
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            categoryName,
                            style: GoogleFonts.poppins(fontSize: 10, color: color),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _checkout(
                            item['id'],
                            item['full_name'] ?? '-',
                            item['rfid_tag_id'] ?? '-',
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('CHECK OUT'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}