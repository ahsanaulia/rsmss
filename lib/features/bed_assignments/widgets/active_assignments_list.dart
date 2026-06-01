// lib/features/bed_assignments/widgets/active_assignments_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/bed_assignment_providers.dart';
import '../services/bed_assignment_service.dart';
import '../models/bed_assignment_model.dart';

class ActiveAssignmentsList extends ConsumerWidget {
  final VoidCallback onRefresh;

  const ActiveAssignmentsList({super.key, required this.onRefresh});

  Future<void> _discharge(BuildContext context, WidgetRef ref, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Tandai pasien sudah selesai?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ya'), style: TextButton.styleFrom(foregroundColor: Colors.green)),
        ],
      ),
    );

    if (confirm != true) return;

    final service = ref.read(bedAssignmentServiceProvider);
    await service.discharge(id);
    ref.invalidate(activeAssignmentsProvider);
    onRefresh();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil discharge'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(activeAssignmentsProvider);

    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error', style: GoogleFonts.poppins())),
      data: (assignments) {
        if (assignments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bed_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text('Belum ada assignment aktif', style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: assignments.length,
          itemBuilder: (context, index) {
            final item = assignments[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.person, color: Colors.blue.shade700),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.peopleName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            Text('RFID: ${item.peopleId.substring(0, 8)}...', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)),
                            child: Text('Bed ${item.bedNumber}', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.green.shade700)),
                          ),
                          Text(item.bedLocation, style: GoogleFonts.poppins(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text('Assign: ${DateFormat('dd/MM/yyyy HH:mm').format(item.assignedAt)}', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600)),
                    ],
                  ),
                  if (item.predictedUntil != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.event, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text('Prediksi: ${DateFormat('dd/MM/yyyy HH:mm').format(item.predictedUntil!)}', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                      child: Text(item.notes!, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700)),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => _discharge(context, ref, item.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text('DISCHARGE', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
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