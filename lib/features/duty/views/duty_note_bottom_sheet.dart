import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/duty_note_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/auth_service.dart';
import 'package:rsmss/l10n/app_localizations.dart';

class DutyNoteBottomSheet extends ConsumerStatefulWidget {
  const DutyNoteBottomSheet({super.key});

  @override
  ConsumerState<DutyNoteBottomSheet> createState() => _DutyNoteBottomSheetState();
}

class _DutyNoteBottomSheetState extends ConsumerState<DutyNoteBottomSheet> {
  final TextEditingController _noteController = TextEditingController();
  bool _isSaving = false;
  final DutyNoteService _service = DutyNoteService();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveDutyNote() async {
    final noteText = _noteController.text.trim();
    final localizations = AppLocalizations.of(context);
    
    if (noteText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations?.dutyNote_emptyError ?? "Catatan tidak boleh kosong", style: GoogleFonts.poppins()),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final authService = getIt<AuthService>();
      final userId = authService.currentUserId;

      if (userId == null) {
        throw Exception(localizations?.dutyNote_sessionExpired ?? "Session expired");
      }

      final isCheckedIn = await _service.isCheckedInToday(userId);
      if (!isCheckedIn) {
        throw Exception(localizations?.dutyNote_notCheckedInError ?? "Anda belum check-in hari ini. Silakan check-in terlebih dahulu.");
      }

      await _service.saveDutyNote(
        profileId: userId,
        noteText: noteText,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations?.dutyNote_saveSuccess ?? "Catatan berhasil disimpan", style: GoogleFonts.poppins()),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: GoogleFonts.poppins()),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final now = DateTime.now();
    final formattedDate = "${now.day}/${now.month}/${now.year}";
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: bottomPadding + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations?.dutyNote_title ?? "Catatan Dinas",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: const Color(0xFF01579B),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: Colors.grey.shade500,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      localizations?.dutyNote_infoText ?? "Catat aktivitas pekerjaan Anda hari ini. Setiap catatan akan mendapatkan +5 poin.",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              localizations?.dutyNote_label ?? "Catatan Pekerjaan",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: localizations?.dutyNote_hint ?? "Contoh:\n• Melakukan visit pasien di ruang VIP\n• Memindahkan pasien dari ruang A ke ruang B\n• Membersihkan dan sterilisasi alat",
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF01579B), width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveDutyNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01579B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        localizations?.dutyNote_saveButton ?? "Simpan Catatan",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}