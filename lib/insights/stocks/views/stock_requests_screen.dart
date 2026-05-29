// File: lib/insights/stocks/views/stock_requests_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/stock_requests_providers.dart';
import '../models/stock_request_model.dart';
import '../models/stock_request_summary_model.dart';
import '../models/stock_requester_model.dart';
import '../../profiles/widgets/shared/donut_chart.dart';

class StockRequestsScreen extends ConsumerStatefulWidget {
  const StockRequestsScreen({super.key});

  @override
  ConsumerState<StockRequestsScreen> createState() => _StockRequestsScreenState();
}

class _StockRequestsScreenState extends ConsumerState<StockRequestsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final horizontalMargin = isMobile ? 12.0 : (isTablet ? 20.0 : 32.0);
    final useTwoColumns = screenWidth >= 900;

    // 🔥 PAKAI REALTIME STATE
    final state = ref.watch(stockRequestsRealtimeStateProvider);
    final summary = state.summary;
    final trend = state.trend;
    final pendingRequests = state.pendingRequests;
    final perUnit = state.perUnit;
    final perRoom = state.perRoom;
    final topRequesters = state.topRequesters;
    final perPosition = state.perPosition;
    final isLoading = state.isLoading;
    final errorMessage = state.errorMessage;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xFF052D9C),
            Color(0xFF1E3A8A),
          ],
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),

                if (isLoading && summary.totalRequests == 0)
                  _buildLoadingShimmer()
                else if (errorMessage != null && summary.totalRequests == 0)
                  _buildErrorWidget(errorMessage)
                else ...[
                  _buildKPICards(summary, isMobile, isTablet),
                  const SizedBox(height: 20),

                  if (useTwoColumns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildStatusDonut(summary)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTrendChart(trend)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildStatusDonut(summary),
                        const SizedBox(height: 16),
                        _buildTrendChart(trend),
                      ],
                    ),
                  const SizedBox(height: 20),

                  if (useTwoColumns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildPerUnitChart(perUnit)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildPerRoomChart(perRoom)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildPerUnitChart(perUnit),
                        const SizedBox(height: 16),
                        _buildPerRoomChart(perRoom),
                      ],
                    ),
                  const SizedBox(height: 20),

                  if (useTwoColumns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildTopRequesterChart(topRequesters)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildPerPositionChart(perPosition)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildTopRequesterChart(topRequesters),
                        const SizedBox(height: 16),
                        _buildPerPositionChart(perPosition),
                      ],
                    ),
                  const SizedBox(height: 20),

                  _buildPendingRequestsTable(pendingRequests),
                  const SizedBox(height: 20),

                  _buildApprovalEffectiveness(summary),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.request_page, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STOCK REQUESTS',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              Text(
                'Permintaan Stok & Persetujuan (Realtime)',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKPICards(StockRequestSummaryModel summary, bool isMobile, bool isTablet) {
    final List<Widget> activeCards = [];
    
    if (summary.totalRequests > 0) {
      activeCards.add(_kpiCard('Total Request', summary.totalRequests.toString(), Icons.request_page, const Color(0xFF3B82F6)));
    }
    if (summary.pending > 0) {
      activeCards.add(_kpiCard('Pending', summary.pending.toString(), Icons.pending, const Color(0xFFF59E0B)));
    }
    if (summary.approved > 0) {
      activeCards.add(_kpiCard('Approved', summary.approved.toString(), Icons.check_circle, const Color(0xFF10B981)));
    }
    if (summary.rejected > 0) {
      activeCards.add(_kpiCard('Rejected', summary.rejected.toString(), Icons.cancel, const Color(0xFFEF4444)));
    }
    if (summary.fulfilled > 0) {
      activeCards.add(_kpiCard('Completed', summary.fulfilled.toString(), Icons.done_all, const Color(0xFF8B5CF6)));
    }
    if (summary.totalRequests > 0) {
      activeCards.add(_kpiCard('Approval Rate', '${summary.approvalRate.toStringAsFixed(1)}%', Icons.percent, const Color(0xFF06B6D4)));
    }
    
    if (activeCards.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Belum ada data request',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ),
      );
    }
    
    int crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 6);
    if (activeCards.length < crossAxisCount) {
      crossAxisCount = activeCards.length;
    }
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: activeCards,
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _glassDecoration(),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DONUT CHART - DIAMKAN (TIDAK DIUBAH)
  // ============================================================
  Widget _buildStatusDonut(StockRequestSummaryModel summary) {
    final Map<String, int> statusData = {};

    if (summary.pending > 0) {
      statusData['PENDING'] = summary.pending;
    }
    if (summary.approved > 0) {
      statusData['APPROVED'] = summary.approved;
    }
    if (summary.rejected > 0) {
      statusData['REJECTED'] = summary.rejected;
    }
    if (summary.fulfilled > 0) {
      statusData['COMPLETED'] = summary.fulfilled;
    }

    if (statusData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data status request',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    final total = summary.totalRequests.toDouble();

    return Container(
      decoration: _glassDecoration(),
      padding: const EdgeInsets.all(8),
      child: DonutChart(
        data: statusData,
        title: 'Status Distribution',
        total: total,
      ),
    );
  }

  // ============================================================
  // TREND CHART - TETAP SCROLLABLE HORIZONTAL
  // ============================================================
  Widget _buildTrendChart(List<StockRequestTrendModel> trend) {
    if (trend.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data request 30 hari terakhir',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    final maxRequests = trend.fold<int>(0, (max, d) => d.totalRequests > max ? d.totalRequests : max);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trend Request per Hari (30 hari)',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: trend.length,
              itemBuilder: (context, index) {
                final data = trend[index];
                final barHeight = maxRequests > 0 ? (data.totalRequests / maxRequests) * 100 : 0.0;

                return SizedBox(
                  width: 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 24,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd').format(data.date),
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PER UNIT CHART - BATASI 5 ITEM + SCROLLABLE
  // ============================================================
  Widget _buildPerUnitChart(List<StockRequestPerUnitModel> perUnit) {
    if (perUnit.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data request per unit',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    final maxRequests = perUnit.first.totalRequests;
    final displayItems = perUnit.take(5).toList();
    final hasMore = perUnit.length > 5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request per Unit',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: displayItems.map((unit) {
              final percent = maxRequests > 0 ? (unit.totalRequests / maxRequests) * 100 : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            unit.unitName,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${unit.totalRequests} req',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF10B981),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: percent / 100,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        color: const Color(0xFF10B981),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          if (hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '📋 +${perUnit.length - 5} unit lainnya',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // PER ROOM CHART - BATASI 5 ITEM + SCROLLABLE
  // ============================================================
  Widget _buildPerRoomChart(List<StockRequestPerRoomModel> perRoom) {
    if (perRoom.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data request per ruangan',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    final maxRequests = perRoom.first.totalRequests;
    final displayItems = perRoom.take(5).toList();
    final hasMore = perRoom.length > 5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request per Ruangan',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: displayItems.map((room) {
              final percent = maxRequests > 0 ? (room.totalRequests / maxRequests) * 100 : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            room.roomName,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${room.totalRequests} req',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF8B5CF6),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: percent / 100,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        color: const Color(0xFF8B5CF6),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          if (hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '📋 +${perRoom.length - 5} ruangan lainnya',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP REQUESTER - BATASI 5 ITEM + SCROLLABLE
  // ============================================================
  Widget _buildTopRequesterChart(List<StockRequesterModel> requesters) {
    if (requesters.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data requester',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    final maxRequests = requesters.first.totalRequests;
    final displayItems = requesters.take(5).toList();
    final hasMore = requesters.length > 5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Requester',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: displayItems.map((requester) {
              final percent = maxRequests > 0 ? (requester.totalRequests / maxRequests) * 100 : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            requester.requesterName,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${requester.totalRequests} req',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFF59E0B),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: percent / 100,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        color: const Color(0xFFF59E0B),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          if (hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '📋 +${requesters.length - 5} requester lainnya',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // PER POSITION CHART - BATASI 5 ITEM + SCROLLABLE
  // ============================================================
  Widget _buildPerPositionChart(List<StockRequestPerPositionModel> positions) {
    if (positions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data request per posisi',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    final maxRequests = positions.first.totalRequests;
    final displayItems = positions.take(5).toList();
    final hasMore = positions.length > 5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request per Posisi',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: displayItems.map((position) {
              final percent = maxRequests > 0 ? (position.totalRequests / maxRequests) * 100 : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            position.positionName,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${position.totalRequests} req',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF3B82F6),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: percent / 100,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        color: const Color(0xFF3B82F6),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          if (hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '📋 +${positions.length - 5} posisi lainnya',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // PENDING REQUESTS TABLE - SCROLLABLE HORIZONTAL & VERTICAL
  // ============================================================
  Widget _buildPendingRequestsTable(List<StockRequestModel> pendingRequests) {
    if (pendingRequests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada pending request',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
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
              Icon(Icons.pending, color: const Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 8),
              Text(
                'Pending Requests (${pendingRequests.length})',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // BATASI TINGGI MAKSIMAL 300px, SCROLL VERTICAL
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.05)),
                  dataRowColor: WidgetStateProperty.all(Colors.transparent),
                  dividerThickness: 0,
                  columnSpacing: 16,
                  columns: const [
                    DataColumn(label: Text('Tanggal', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Pemohon', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Item', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Qty', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Unit', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600))),
                  ],
                  rows: pendingRequests.map((request) {
                    return DataRow(
                      cells: [
                        DataCell(Text(DateFormat('dd/MM/yyyy').format(request.requestDate), style: const TextStyle(color: Colors.white, fontSize: 11))),
                        DataCell(Text(request.requesterName, style: const TextStyle(color: Colors.white, fontSize: 11))),
                        DataCell(Text(request.requestedStockName, style: const TextStyle(color: Colors.white, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        DataCell(Text(request.requestedQuantity.toInt().toString(), style: const TextStyle(color: Colors.white, fontSize: 11))),
                        DataCell(Text(request.unit, style: const TextStyle(color: Colors.white, fontSize: 11))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // APPROVAL EFFECTIVENESS - DIAMKAN
  // ============================================================
  Widget _buildApprovalEffectiveness(StockRequestSummaryModel summary) {
    if (summary.totalRequests == 0) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.speed, color: Color(0xFF10B981), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Approval Effectiveness',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Rata-rata waktu approval: ',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '${summary.averageProcessingHours.toStringAsFixed(1)} jam',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING SHIMMER
  // ============================================================
  Widget _buildLoadingShimmer() {
    return Column(
      children: List.generate(5, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: _glassDecoration(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ============================================================
  // ERROR WIDGET
  // ============================================================
  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _glassDecoration(),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: const Color(0xFFEF4444).withValues(alpha: 0.8),
          ),
          const SizedBox(height: 12),
          Text(
            'Gagal memuat data',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(stockRequestsRealtimeStateProvider);
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPER
  // ============================================================
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