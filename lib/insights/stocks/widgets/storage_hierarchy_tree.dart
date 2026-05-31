// File: lib/insights/stocks/widgets/storage_hierarchy_tree.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/storage_hierarchy_model.dart';

class StorageHierarchyTree extends ConsumerWidget {
  final List<StorageWarehouseModel> warehouses;
  final Function(StorageBinNodeModel, String) onBinTap;
  final String? selectedBinId;

  const StorageHierarchyTree({
    super.key,
    required this.warehouses,
    required this.onBinTap,
    this.selectedBinId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (warehouses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data warehouse',
            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_tree, color: const Color(0xFF8B5CF6), size: 20),
              const SizedBox(width: 8),
              Text(
                'Storage Hierarchy',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: warehouses.map((warehouse) => _buildWarehouseTile(warehouse)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseTile(StorageWarehouseModel warehouse) {
    return ExpansionTile(
      leading: const Icon(Icons.warehouse, color: Color(0xFF3B82F6), size: 20),
      title: Text(
        '🏭 ${warehouse.name} (${warehouse.totalBins} bins, ${warehouse.totalStock.toStringAsFixed(0)} item)',
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 16),
      children: warehouse.zones.map((zone) => _buildZoneTile(zone)).toList(),
    );
  }

  Widget _buildZoneTile(StorageZoneModel zone) {
    return ExpansionTile(
      leading: const Icon(Icons.grid_view, color: Color(0xFF10B981), size: 18),
      title: Text(
        '📦 ${zone.name} (${zone.totalBins} bins, ${zone.totalStock.toStringAsFixed(0)} item)',
        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
      ),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 16),
      children: zone.racks.map((rack) => _buildRackTile(rack)).toList(),
    );
  }

  Widget _buildRackTile(StorageRackModel rack) {
    return ExpansionTile(
      leading: const Icon(Icons.view_list, color: Color(0xFFF59E0B), size: 16),
      title: Text(
        '🗄️ ${rack.name} (${rack.totalBins} bins, ${rack.totalStock.toStringAsFixed(0)} item)',
        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w400),
      ),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 16),
      children: rack.shelves.map((shelf) => _buildShelfTile(shelf)).toList(),
    );
  }

  Widget _buildShelfTile(StorageShelfModel shelf) {
    if (shelf.bins.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Text(
          '📦 Tidak ada bin di shelf ini',
          style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
        ),
      );
    }

    return ExpansionTile(
      leading: const Icon(Icons.shelves, color: Color(0xFF8B5CF6), size: 14),
      title: Text(
        '📚 ${shelf.name} (${shelf.totalBins} bins, ${shelf.totalStock.toStringAsFixed(0)} item)',
        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w400),
      ),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 16),
      children: shelf.bins.map((bin) => _buildBinTile(bin)).toList(),
    );
  }

  Widget _buildBinTile(StorageBinNodeModel bin) {
    final color = bin.utilization >= 80 
        ? const Color(0xFFEF4444)
        : bin.utilization >= 60 
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981);
    
    final isSelected = selectedBinId == bin.id;
    
    return GestureDetector(
      onTap: () => onBinTap(bin, bin.id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: const Color(0xFF8B5CF6), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '📦 ${bin.code} - ${bin.currentQuantity.toStringAsFixed(0)} item',
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (bin.maxQuantity != null && bin.maxQuantity! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${bin.utilization.toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(color: color, fontSize: 9, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Decoration _glassDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white.withValues(alpha: 0.05),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.1),
        width: 0.5,
      ),
    );
  }
}