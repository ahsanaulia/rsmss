// lib/features/bed_assignments/widgets/people_search_delegate.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/people_model.dart';
import '../services/bed_assignment_service.dart';

class PeopleSearchDelegate extends SearchDelegate<SimplePeopleModel?> {
  final BedAssignmentService service;

  PeopleSearchDelegate({required this.service});

  @override
  String get searchFieldLabel => 'Cari nama atau RFID...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildResults();

  Widget _buildResults() {
    // Ganti dengan getUnassignedPeople
    return FutureBuilder<List<SimplePeopleModel>>(
      future: service.getUnassignedPeople(query),  // ← GANTI DI SINI
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return Center(
            child: Text(
              query.isEmpty 
                  ? 'Semua people sudah memiliki bed' 
                  : 'Tidak ditemukan',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  item.fullName.isNotEmpty ? item.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(item.fullName, style: GoogleFonts.poppins()),
              subtitle: Text('RFID: ${item.rfidTagId} | ${item.categoryName ?? '-'}'),
              onTap: () => close(context, item),
            );
          },
        );
      },
    );
  }
}