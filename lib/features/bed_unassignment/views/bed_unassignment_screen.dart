// lib/features/bed_unassignment/views/bed_unassignment_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/active_bed_list.dart';

class BedUnassignmentScreen extends ConsumerStatefulWidget {
  const BedUnassignmentScreen({super.key});

  @override
  ConsumerState<BedUnassignmentScreen> createState() => _BedUnassignmentScreenState();
}

class _BedUnassignmentScreenState extends ConsumerState<BedUnassignmentScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _refreshKey = 0;

  void _refresh() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2F1), Color(0xFFB3E5FC), Color(0xFF81D4FA)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header dengan back button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF01579B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tempat Tidur Dikosongkan',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF01579B),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      hintText: 'Cari nomor bed atau nama pasien...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF01579B)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // List Active Beds
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                        ),
                        child: ActiveBedList(
                          key: ValueKey(_refreshKey),
                          searchQuery: _searchQuery,
                          onUnassigned: _refresh,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}