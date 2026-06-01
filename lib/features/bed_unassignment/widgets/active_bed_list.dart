// lib/features/bed_unassignment/widgets/active_bed_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../bed_assignments/models/bed_assignment_model.dart';
import '../services/bed_unassignment_service.dart';

class ActiveBedList extends ConsumerStatefulWidget {
  final String searchQuery;
  final VoidCallback onUnassigned;

  const ActiveBedList({
    super.key,
    required this.searchQuery,
    required this.onUnassigned,
  });

  @override
  ConsumerState<ActiveBedList> createState() => _ActiveBedListState();
}

class _ActiveBedListState extends ConsumerState<ActiveBedList> {
  bool _isLoading = false;

  Future<void> _unassign(String assignmentId, String peopleName, String bedNumber) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Unassign'),
        content: Text(
          'Lepaskan $peopleName dari Bed $bedNumber?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Lepaskan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final service = BedUnassignmentService();
      await service.unassignBed(assignmentId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$peopleName telah dilepaskan dari Bed $bedNumber'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onUnassigned();
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
    return FutureBuilder<List<BedAssignmentModel>>(
      future: BedUnassignmentService().getActiveBedAssignments(widget.searchQuery),
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
                const Icon(Icons.bed_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  widget.searchQuery.isEmpty
                      ? 'Tidak ada bed yang sedang terisi'
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
            final bedLocation = item.bedLocation;
            
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
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.bed, color: Colors.orange.shade700, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bed ${item.bedNumber}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          bedLocation,
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Terisi: ${item.peopleName}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sejak: ${DateFormat('dd/MM/yyyy HH:mm').format(item.assignedAt)}',
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _unassign(item.id, item.peopleName, item.bedNumber),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('KOSONGKAN'),
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