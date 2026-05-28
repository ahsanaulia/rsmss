import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
import '../models/todo_model.dart';
import 'todo_mobile_detail.dart';

class TodoMobileCard extends StatelessWidget {
  final TodoModel todo;
  final VoidCallback? onTap;
  final VoidCallback? onCompleted;

  const TodoMobileCard({
    super.key,
    required this.todo,
    this.onTap,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ?? () => _showDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Priority Chip + Mandatory Badge
                Row(
                  children: [
                    _buildPriorityChip(),
                    if (todo.isMandatory) ...[
                      const SizedBox(width: 8),
                      _buildMandatoryBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  todo.title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF01579B),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Description (if any)
                if (todo.description != null && todo.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    todo.description!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                // Footer: Duration + Target + Action
                Row(
                  children: [
                    if (todo.durationMinutes != null)
                      _buildInfoChip(
                        icon: Icons.timer_outlined,
                        label: '${todo.durationMinutes} menit',
                      ),
                    if (todo.durationMinutes != null) const SizedBox(width: 8),
                    _buildTargetChip(),
                    const Spacer(),
                    if (onCompleted != null)
                      _buildCompleteButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: todo.priorityColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: todo.priorityColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPriorityIcon(todo.priority),
            size: 12,
            color: todo.priorityColor,
          ),
          const SizedBox(width: 4),
          Text(
            todo.priorityLabel,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: todo.priorityColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMandatoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Text(
        'WAJIB',
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Colors.orange.shade700,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetChip() {
    List<String> targets = [];
    if (todo.targetUnitName != null) targets.add(todo.targetUnitName!);
    if (todo.targetPositionName != null) targets.add(todo.targetPositionName!);
    if (todo.targetShiftName != null) targets.add(todo.targetShiftName!);

    final label = targets.isNotEmpty ? targets.join(' • ') : 'Semua Pegawai';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF01579B).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 12, color: const Color(0xFF01579B)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: const Color(0xFF01579B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton() {
    return InkWell(
      onTap: onCompleted,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 14, color: Colors.green.shade600),
            const SizedBox(width: 4),
            Text(
              'Selesai',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Icons.priority_high;
      case 'high':
        return Icons.trending_up;
      case 'normal':
        return Icons.flag;
      case 'low':
        return Icons.flag_outlined;
      default:
        return Icons.flag;
    }
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TodoMobileDetailPage(todo: todo),
    );
  }
}

// ==================== LIST VIEW ====================

class TodoMobileListView extends StatelessWidget {
  final List<TodoModel> todos;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final Function(TodoModel)? onTodoCompleted;

  const TodoMobileListView({
    super.key,
    required this.todos,
    this.isLoading = false,
    this.onRefresh,
    this.onTodoCompleted,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: LinearProgressIndicator(color: Color(0xFF01579B)),
      );
    }

    if (todos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 15, 25, 8),
          child: Text(
            "TO DO HARI INI",
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF01579B),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          child: RefreshIndicator(
            onRefresh: () async {
              onRefresh?.call();
              return Future.value();
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return TodoMobileCard(
                  todo: todo,
                  onCompleted: onTodoCompleted != null
                      ? () => onTodoCompleted!(todo)
                      : null,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}