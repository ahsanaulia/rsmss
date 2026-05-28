import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/todo_service.dart';
import '../models/todo_model.dart';
import 'todo_mobile_card.dart';

class TodoMobileStreamView extends StatefulWidget {
  final String profileId;
  final DateTime date;

  const TodoMobileStreamView({
    super.key,
    required this.profileId,
    required this.date,
  });

  @override
  State<TodoMobileStreamView> createState() => _TodoMobileStreamViewState();
}

class _TodoMobileStreamViewState extends State<TodoMobileStreamView> {
  late final TodoService _todoService;

  @override
  void initState() {
    super.initState();
    _todoService = TodoService();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TodoModel>>(
      stream: _todoService.streamTodosForEmployee(
        profileId: widget.profileId,
        date: widget.date,
      ),
      builder: (context, snapshot) {
        // Selalu tampilkan section, baik loading, error, kosong, atau ada data
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
            
            // Konten berdasarkan state
            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: LinearProgressIndicator(color: Color(0xFF01579B)),
              ),
              
            if (snapshot.hasError)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Gagal memuat To Do: ${snapshot.error}',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
                ),
              ),
              
            if (snapshot.hasData && snapshot.data!.isEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.checklist, size: 40, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'Tidak ada To Do untuk hari ini',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              
            if (snapshot.hasData && snapshot.data!.isNotEmpty)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final todo = snapshot.data![index];
                    return TodoMobileCard(
                      todo: todo,
                      onCompleted: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('To Do "${todo.title}" selesai'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}