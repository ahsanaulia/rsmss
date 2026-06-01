// lib/features/bed_assignments/widgets/bed_search_delegate.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/bed_model.dart';
import '../services/bed_assignment_service.dart';

class BedSearchDelegate extends SearchDelegate<SimpleBedModel?> {
  final BedAssignmentService service;

  BedSearchDelegate({required this.service});

  @override
  String get searchFieldLabel => 'Cari nomor bed atau ruangan...';

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
    return FutureBuilder<List<SimpleBedModel>>(
      future: service.searchBeds(query),
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
                  ? 'Tidak ada bed yang tersedia (EMPTY)' 
                  : 'Tidak ditemukan bed tersedia',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: Icon(Icons.bed, color: Colors.blue),
              title: Text(
                'Bed ${item.bedNumber}', 
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                item.fullLocation,
                style: GoogleFonts.poppins(fontSize: 11),
              ),
              trailing: Chip(
                label: Text(
                  item.status, 
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                backgroundColor: item.isAvailable ? Colors.green : Colors.red,
              ),
              onTap: () => close(context, item),
            );
          },
        );
      },
    );
  }
}