// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../providers/employee_provider.dart';
// import '../../providers/employee_state.dart';
// import '../../models/employee_model.dart';

// class EmployeeTable extends ConsumerStatefulWidget {
//   const EmployeeTable({super.key});

//   @override
//   ConsumerState<EmployeeTable> createState() => _EmployeeTableState();
// }

// class _EmployeeTableState extends ConsumerState<EmployeeTable> {
//   final _searchController = TextEditingController();
//   String _searchQuery = '';

//   // Local state untuk edit
//   String _localSelectedRole = 'operation';
//   String? _localSelectedUnitId;
//   String? _localSelectedPositionId;
//   String? _localSelectedShiftId;
//   String _localSelectedSituation = 'ACTIVE';
//   bool _localIsAssetInitial = false;
//   bool _localIsAssetInspection = false;
//   bool _localIsStockInitial = false;
//   bool _localIsStockOpname = false;
//   bool _localIsApproved = false; // ← TAMBAHKAN INI
//   String? _localJoinDate;

//   // Controllers
//   final Map<String, TextEditingController> _controllers = {};

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       setState(() {
//         _searchQuery = _searchController.text.toLowerCase();
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     for (var controller in _controllers.values) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   void _initLocalState(EmployeeModel employee) {
//     _localSelectedRole = employee.role;
//     _localSelectedUnitId = employee.unitId;
//     _localSelectedPositionId = employee.positionId;
//     _localSelectedShiftId = employee.defaultShiftId;
//     _localSelectedSituation = employee.currentSituation;
//     _localIsAssetInitial = employee.isAssetInitial;
//     _localIsAssetInspection = employee.isAssetInspection;
//     _localIsStockInitial = employee.isStockInitial;
//     _localIsStockOpname = employee.isStockOpname;
//     _localIsApproved = employee.isApproved;
//      _localJoinDate = employee.joinDate;  // ← TAMBAHKAN

//     _controllers['name'] = TextEditingController(text: employee.fullName);
//     _controllers['employeeId'] = TextEditingController(
//       text: employee.employeeId ?? '',
//     );
//     _controllers['nik'] = TextEditingController(
//       text: employee.employeeNik ?? '',
//     );
//     _controllers['phone'] = TextEditingController(text: employee.phone ?? '');
//     _controllers['address'] = TextEditingController(
//       text: employee.address ?? '',
//     );
//   }

//   void _clearLocalState() {
//     for (var controller in _controllers.values) {
//       controller.dispose();
//     }
//     _controllers.clear();
//     _localIsApproved = false;
//     _localJoinDate = null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(employeeProvider);
//     final notifier = ref.read(employeeProvider.notifier);

//     // Handle messages
//     if (state.errorMessage != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(state.errorMessage!, style: GoogleFonts.poppins()),
//             backgroundColor: Colors.red.shade700,
//           ),
//         );
//         notifier.clearMessages();
//       });
//     }

//     if (state.successMessage != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(state.successMessage!, style: GoogleFonts.poppins()),
//             backgroundColor: Colors.green.shade700,
//           ),
//         );
//         notifier.clearMessages();
//       });
//     }

//     // Filter employees based on search
//     final filteredEmployees = _searchQuery.isEmpty
//         ? state.employees
//         : state.employees.where((e) {
//             return e.fullName.toLowerCase().contains(_searchQuery) ||
//                 (e.employeeId?.toLowerCase().contains(_searchQuery) ?? false) ||
//                 (e.employeeNik?.toLowerCase().contains(_searchQuery) ?? false);
//           }).toList();

//     return Column(
//       children: [
//         // Toolbar
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white.withValues(alpha: 0.7),
//             border: const Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                     hintText: 'Cari nama, NIK, atau ID pegawai...',
//                     prefixIcon: const Icon(Icons.search),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     isDense: true,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               ElevatedButton.icon(
//                 onPressed: state.isLoading
//                     ? null
//                     : () {
//                         _clearLocalState();
//                         notifier.startAddNew();
//                       },
//                 icon: const Icon(Icons.add, size: 18),
//                 label: const Text('Tambah Pegawai'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF01579B),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 12,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Loading indicator
//         if (state.isLoading)
//           const Expanded(
//             child: Center(
//               child: CircularProgressIndicator(color: Color(0xFF01579B)),
//             ),
//           ),

//         // Data Table
//         if (!state.isLoading)
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: filteredEmployees.length + (state.isAddingNew ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (state.isAddingNew && index == 0) {
//                   return _buildAddNewRow(state, notifier);
//                 }
//                 final employeeIndex = state.isAddingNew ? index - 1 : index;
//                 if (employeeIndex >= filteredEmployees.length)
//                   return const SizedBox();
//                 final employee = filteredEmployees[employeeIndex];
//                 final isEditing = state.editingId == employee.id;

//                 // Initialize local state when editing starts
//                 if (isEditing && _controllers.isEmpty) {
//                   _initLocalState(employee);
//                 }

//                 return _buildEmployeeRow(employee, isEditing, notifier, state);
//               },
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildEmployeeRow(
//     EmployeeModel employee,
//     bool isEditing,
//     EmployeeNotifier notifier,
//     EmployeeState state,
//   ) {
//     if (isEditing) {
//       return _buildEditRow(employee, notifier, state);
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: () {
//           _initLocalState(employee);
//           notifier.startEdit(employee.id);
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               // Avatar
//               CircleAvatar(
//                 radius: 24,
//                 backgroundColor: const Color(0xFF01579B).withValues(alpha: 0.1),
//                 backgroundImage:
//                     employee.avatarUrl != null && employee.avatarUrl!.isNotEmpty
//                     ? NetworkImage(employee.avatarUrl!)
//                     : null,
//                 child: employee.avatarUrl == null || employee.avatarUrl!.isEmpty
//                     ? Text(
//                         employee.fullName.isNotEmpty
//                             ? employee.fullName[0].toUpperCase()
//                             : '?',
//                         style: GoogleFonts.poppins(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                           color: const Color(0xFF01579B),
//                         ),
//                       )
//                     : null,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       employee.fullName,
//                       style: GoogleFonts.poppins(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 4,
//                       children: [
//                         _buildChip(
//                           'ID: ${employee.employeeId ?? '-'}',
//                           Colors.grey,
//                         ),
//                         if (employee.unitName != null)
//                           _buildChip(employee.unitName!, Colors.blue),
//                         _buildChip(employee.role, Colors.teal),
//                         if (employee.currentSituation == 'ACTIVE')
//                           _buildChip('Aktif', Colors.green)
//                         else
//                           _buildChip(employee.currentSituation, Colors.orange),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Row(
//                 children: [
//                   IconButton(
//                     onPressed: () => _confirmDelete(notifier, employee.id),
//                     icon: const Icon(
//                       Icons.delete_outline,
//                       size: 20,
//                       color: Colors.red,
//                     ),
//                     tooltip: 'Hapus',
//                   ),
//                   IconButton(
//                     onPressed: () {
//                       _initLocalState(employee);
//                       notifier.startEdit(employee.id);
//                     },
//                     icon: const Icon(
//                       Icons.edit_outlined,
//                       size: 20,
//                       color: Color(0xFF01579B),
//                     ),
//                     tooltip: 'Edit',
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEditRow(
//     EmployeeModel employee,
//     EmployeeNotifier notifier,
//     EmployeeState state,
//   ) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: const Color.fromARGB(255, 30, 74, 139), // Biru tua gelap
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFF42A5F5), width: 2),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Row(
//               children: [
//                 Icon(Icons.edit_note, size: 16, color: Colors.white),
//                 const SizedBox(width: 8),
//                 Text(
//                   'EDIT PEGAWAI',
//                   style: GoogleFonts.poppins(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const Spacer(),
//                 TextButton.icon(
//                   onPressed: () {

//                     _clearLocalState();
//                     notifier.cancelEdit();
//                   },
//                   icon: const Icon(
//                     Icons.close,
//                     size: 16,
//                     color: Colors.white70,
//                   ),
//                   label: const Text(
//                     'Tutup',
//                     style: TextStyle(color: Colors.white70),
//                   ),
//                   style: TextButton.styleFrom(foregroundColor: Colors.white70),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Foto Avatar
//             Container(
//               margin: const EdgeInsets.only(bottom: 16),
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 40,
//                     backgroundColor: Colors.blue.shade800,
//                     backgroundImage:
//                         employee.avatarUrl != null &&
//                             employee.avatarUrl!.isNotEmpty
//                         ? NetworkImage(employee.avatarUrl!)
//                         : null,
//                     child:
//                         (employee.avatarUrl == null ||
//                             employee.avatarUrl!.isEmpty)
//                         ? Icon(Icons.person, size: 40, color: Colors.white70)
//                         : null,
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Text(
//                       'Foto profil dari sistem',
//                       style: GoogleFonts.poppins(
//                         fontSize: 11,
//                         color: Colors.white70,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Form Fields dengan label putih
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildTextFieldDark(
//                     controller: _controllers['name']!,
//                     label: 'Nama Lengkap',
//                     hint: 'Nama lengkap pegawai',
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildTextFieldDark(
//                     controller: _controllers['employeeId']!,
//                     label: 'ID Pegawai',
//                     hint: 'Nomor induk pegawai',
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             Row(
//               children: [
//                 Expanded(
//                   child: _buildDropdownDark(
//                     label: 'Role',
//                     value: _localSelectedRole,
//                     items: const [
//                       'operation',
//                       'management',
//                       'admin',
//                       'monitor',
//                       'control_room',
//                     ],
//                     onChanged: (v) => setState(() => _localSelectedRole = v!),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildDropdownWithDataDark(
//                     label: 'Unit',
//                     value: _localSelectedUnitId,
//                     items: state.units,
//                     itemId: (e) => e['id'].toString(),
//                     itemLabel: (e) => e['unit_name'] ?? '-',
//                     onChanged: (v) => setState(() => _localSelectedUnitId = v),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             Row(
//               children: [
//                 Expanded(
//                   child: _buildDropdownWithDataDark(
//                     label: 'Posisi',
//                     value: _localSelectedPositionId,
//                     items: state.positions,
//                     itemId: (e) => e['id'].toString(),
//                     itemLabel: (e) => e['position_name'] ?? '-',
//                     onChanged: (v) =>
//                         setState(() => _localSelectedPositionId = v),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildDropdownWithDataDark(
//                     label: 'Shift Default',
//                     value: _localSelectedShiftId,
//                     items: state.shifts,
//                     itemId: (e) => e['id'].toString(),
//                     itemLabel: (e) =>
//                         '${e['shift_name']} (${e['shift_code'] ?? '-'})',
//                     onChanged: (v) => setState(() => _localSelectedShiftId = v),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             Row(
//               children: [
//                 Expanded(
//                   child: _buildTextFieldDark(
//                     controller: _controllers['nik']!,
//                     label: 'NIK',
//                     hint: 'Nomor Induk Kependudukan',
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildTextFieldDark(
//                     controller: _controllers['phone']!,
//                     label: 'No Telepon',
//                     hint: 'Nomor HP aktif',
//                     keyboardType: TextInputType.phone,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             _buildTextFieldDark(
//               controller: _controllers['address']!,
//               label: 'Alamat',
//               hint: 'Alamat lengkap',
//               maxLines: 2,
//             ),
//             const SizedBox(height: 12),

//             // Akses Fitur Card
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white.withValues(alpha: 0.15),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Akses Fitur',
//                     style: GoogleFonts.poppins(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 12,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Wrap(
//                     spacing: 16,
//                     runSpacing: 8,
//                     children: [
//                       _buildCheckboxDark(
//                         label: 'Asset Initial',
//                         value: _localIsAssetInitial,
//                         onChanged: (v) =>
//                             setState(() => _localIsAssetInitial = v),
//                       ),
//                       _buildCheckboxDark(
//                         label: 'Asset Inspection',
//                         value: _localIsAssetInspection,
//                         onChanged: (v) =>
//                             setState(() => _localIsAssetInspection = v),
//                       ),
//                       _buildCheckboxDark(
//                         label: 'Stock Initial',
//                         value: _localIsStockInitial,
//                         onChanged: (v) =>
//                             setState(() => _localIsStockInitial = v),
//                       ),
//                       _buildCheckboxDark(
//                         label: 'Stock Opname',
//                         value: _localIsStockOpname,
//                         onChanged: (v) =>
//                             setState(() => _localIsStockOpname = v),
//                       ),
//                       _buildCheckboxDark(
//                         label: 'Akun Aktif (Approved)',
//                         value: _localIsApproved, // ← BENAR! pakai local state
//                         onChanged: (v) => setState(() => _localIsApproved = v),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 12),

//             Row(
//               children: [
//                 Expanded(
//                   child: _buildDropdownDark(
//                     label: 'Status',
//                     value: _localSelectedSituation,
//                     items: const ['ACTIVE', 'INACTIVE', 'ON_LEAVE', 'SICK'],
//                     onChanged: (v) =>
//                         setState(() => _localSelectedSituation = v!),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildDateFieldDark(
//                     label: 'Tanggal Bergabung',
//                     value: _localJoinDate,
//                     onChanged: (date) => setState(() => _localJoinDate = date),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     _clearLocalState();
//                     notifier.cancelEdit();
//                   },
//                   style: TextButton.styleFrom(foregroundColor: Colors.white70),
//                   child: const Text('Batal'),
//                 ),
//                 const SizedBox(width: 12),
//                 ElevatedButton(
//                   onPressed: () async {
//                     final updatedEmployee = employee.copyWith(
//                       fullName: _controllers['name']!.text.trim(),
//                       role: _localSelectedRole,
//                       employeeId:
//                           _controllers['employeeId']!.text.trim().isEmpty
//                           ? null
//                           : _controllers['employeeId']!.text.trim(),
//                       employeeNik: _controllers['nik']!.text.trim().isEmpty
//                           ? null
//                           : _controllers['nik']!.text.trim(),
//                       phone: _controllers['phone']!.text.trim().isEmpty
//                           ? null
//                           : _controllers['phone']!.text.trim(),
//                       address: _controllers['address']!.text.trim().isEmpty
//                           ? null
//                           : _controllers['address']!.text.trim(),
//                       unitId: _localSelectedUnitId,
//                       positionId: _localSelectedPositionId,
//                       defaultShiftId: _localSelectedShiftId,
//                       currentSituation: _localSelectedSituation,
//                       isAssetInitial: _localIsAssetInitial,
//                       isAssetInspection: _localIsAssetInspection,
//                       isStockInitial: _localIsStockInitial,
//                       isStockOpname: _localIsStockOpname,
//                       isApproved: _localIsApproved,
//                       joinDate: _localJoinDate,
//                     );
//                     await notifier.saveEmployee(updatedEmployee);
//                     _clearLocalState();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF42A5F5),
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('Simpan'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper widgets untuk dark mode
//   Widget _buildTextFieldDark({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     int maxLines = 1,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//             color: Colors.white70,
//           ),
//         ),
//         const SizedBox(height: 4),
//         TextFormField(
//           controller: controller,
//           maxLines: maxLines,
//           keyboardType: keyboardType,
//           style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(color: Colors.white38),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 10,
//             ),
//             isDense: true,
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.white38),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Colors.white, width: 1.5),
//             ),
//             fillColor: Colors.white.withValues(alpha: 0.1),
//             filled: true,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdownDark({
//     required String label,
//     required String value,
//     required List<String> items,
//     required Function(String?) onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//             color: Colors.white70,
//           ),
//         ),
//         const SizedBox(height: 4),
//         DropdownButtonFormField<String>(
//           value: value,
//           dropdownColor: const Color(0xFF0D47A1),
//           style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
//           items: items.map((item) {
//             return DropdownMenuItem(value: item, child: Text(item));
//           }).toList(),
//           onChanged: onChanged,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 10,
//             ),
//             isDense: true,
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.white38),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Colors.white, width: 1.5),
//             ),
//             fillColor: Colors.white.withValues(alpha: 0.1),
//             filled: true,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdownWithDataDark({
//     required String label,
//     required String? value,
//     required List<Map<String, dynamic>> items,
//     required String Function(Map<String, dynamic>) itemId,
//     required String Function(Map<String, dynamic>) itemLabel,
//     required Function(String?) onChanged,
//     bool optional = true,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//             color: Colors.white70,
//           ),
//         ),
//         const SizedBox(height: 4),
//         DropdownButtonFormField<String>(
//           value: value,
//           hint: Text(
//             optional ? 'Pilih (Opsional)' : 'Pilih',
//             style: TextStyle(color: Colors.white54),
//           ),
//           dropdownColor: const Color(0xFF0D47A1),
//           style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
//           items: [
//             if (optional)
//               const DropdownMenuItem(
//                 value: null,
//                 child: Text('-', style: TextStyle(color: Colors.white70)),
//               ),
//             ...items.map((item) {
//               return DropdownMenuItem(
//                 value: itemId(item),
//                 child: Text(
//                   itemLabel(item),
//                   style: TextStyle(color: Colors.white),
//                 ),
//               );
//             }),
//           ],
//           onChanged: onChanged,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 10,
//             ),
//             isDense: true,
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.white38),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Colors.white, width: 1.5),
//             ),
//             fillColor: Colors.white.withValues(alpha: 0.1),
//             filled: true,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDateFieldDark({
//     required String label,
//     required String? value,
//     required Function(String?) onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//             color: Colors.white70,
//           ),
//         ),
//         const SizedBox(height: 4),
//         InkWell(
//           onTap: () async {
//             final date = await showDatePicker(
//               context: context,
//               initialDate: DateTime.now(),
//               firstDate: DateTime(2000),
//               lastDate: DateTime(2030),
//             );
//             if (date != null) {
//               onChanged(date.toIso8601String().split('T')[0]);
//             }
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.white38),
//               borderRadius: BorderRadius.circular(8),
//               color: Colors.white.withValues(alpha: 0.1),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     value ?? 'Pilih tanggal',
//                     style: GoogleFonts.poppins(
//                       fontSize: 13,
//                       color: value == null ? Colors.white54 : Colors.white,
//                     ),
//                   ),
//                 ),
//                 Icon(Icons.calendar_today, size: 18, color: Colors.white70),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCheckboxDark({
//     required String label,
//     required bool value,
//     required Function(bool) onChanged,
//   }) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         SizedBox(
//           width: 18,
//           height: 18,
//           child: Checkbox(
//             value: value,
//             onChanged: (v) => onChanged(v ?? false),
//             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//             activeColor: Colors.white,
//             checkColor: const Color(0xFF0D47A1),
//           ),
//         ),
//         const SizedBox(width: 6),
//         Text(
//           label,
//           style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
//         ),
//       ],
//     );
//   }

//   Widget _buildAddNewRow(EmployeeState state, EmployeeNotifier notifier) {
//     final nameController = TextEditingController();
//     String selectedRole = 'operation';
//     String? selectedUnitId;
//     String? selectedPositionId;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE8F5E9),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.green.shade400, width: 1.5),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.add_circle, size: 16, color: Colors.green.shade700),
//                 const SizedBox(width: 8),
//                 Text(
//                   'TAMBAH PEGAWAI BARU',
//                   style: GoogleFonts.poppins(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                     color: Colors.green.shade700,
//                   ),
//                 ),
//                 const Spacer(),
//                 TextButton.icon(
//                   onPressed: () {
//                     nameController.dispose();
//                     notifier.cancelEdit();
//                   },
//                   icon: const Icon(Icons.close, size: 16),
//                   label: const Text('Batal'),
//                   style: TextButton.styleFrom(foregroundColor: Colors.red),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildTextField(
//                     controller: nameController,
//                     label: 'Nama Lengkap *',
//                     hint: 'Nama lengkap pegawai',
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildDropdown(
//                     label: 'Role *',
//                     value: selectedRole,
//                     items: const [
//                       'operation',
//                       'management',
//                       'admin',
//                       'monitor',
//                       'control_room',
//                     ],
//                     onChanged: (v) => setState(() => selectedRole = v!),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildDropdownWithData(
//                     label: 'Unit',
//                     value: selectedUnitId,
//                     items: state.units,
//                     itemId: (e) => e['id'].toString(),
//                     itemLabel: (e) => e['unit_name'] ?? '-',
//                     onChanged: (v) => setState(() => selectedUnitId = v),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildDropdownWithData(
//                     label: 'Posisi',
//                     value: selectedPositionId,
//                     items: state.positions,
//                     itemId: (e) => e['id'].toString(),
//                     itemLabel: (e) => e['position_name'] ?? '-',
//                     onChanged: (v) => setState(() => selectedPositionId = v),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (nameController.text.trim().isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Nama lengkap harus diisi'),
//                         ),
//                       );
//                       return;
//                     }
//                     final newEmployee = EmployeeModel(
//                       id: 'new',
//                       fullName: nameController.text.trim(),
//                       role: selectedRole,
//                       unitId: selectedUnitId,
//                       positionId: selectedPositionId,
//                     );
//                     await notifier.saveEmployee(newEmployee);
//                     nameController.dispose();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('Simpan'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper widgets (sama seperti sebelumnya)
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     int maxLines = 1,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//             color: Colors.grey.shade700,
//           ),
//         ),
//         const SizedBox(height: 4),
//         TextFormField(
//           controller: controller,
//           maxLines: maxLines,
//           keyboardType: keyboardType,
//           decoration: InputDecoration(
//             hintText: hint,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 10,
//             ),
//             isDense: true,
//           ),
//           style: GoogleFonts.poppins(fontSize: 13),
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdown({
//     required String label,
//     required String value,
//     required List<String> items,
//     required Function(String?) onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//             color: Colors.grey.shade700,
//           ),
//         ),
//         const SizedBox(height: 4),
//         DropdownButtonFormField<String>(
//           value: value,
//           items: items.map((item) {
//             return DropdownMenuItem(value: item, child: Text(item));
//           }).toList(),
//           onChanged: onChanged,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 10,
//             ),
//             isDense: true,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdownWithData({
//     required String label,
//     required String? value,
//     required List<Map<String, dynamic>> items,
//     required String Function(Map<String, dynamic>) itemId,
//     required String Function(Map<String, dynamic>) itemLabel,
//     required Function(String?) onChanged,
//     bool optional = true,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//             color: Colors.grey.shade700,
//           ),
//         ),
//         const SizedBox(height: 4),
//         DropdownButtonFormField<String>(
//           value: value,
//           hint: Text(optional ? 'Pilih (Opsional)' : 'Pilih'),
//           items: [
//             if (optional) const DropdownMenuItem(value: null, child: Text('-')),
//             ...items.map((item) {
//               return DropdownMenuItem(
//                 value: itemId(item),
//                 child: Text(
//                   itemLabel(item),
//                   style: GoogleFonts.poppins(fontSize: 13),
//                 ),
//               );
//             }),
//           ],
//           onChanged: onChanged,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 10,
//             ),
//             isDense: true,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDateField({
//     required String label,
//     required String? value,
//     required Function(String?) onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//             color: Colors.grey.shade700,
//           ),
//         ),
//         const SizedBox(height: 4),
//         InkWell(
//           onTap: () async {
//             final date = await showDatePicker(
//               context: context,
//               initialDate: DateTime.now(),
//               firstDate: DateTime(2000),
//               lastDate: DateTime(2030),
//             );
//             if (date != null) {
//               onChanged(date.toIso8601String().split('T')[0]);
//             }
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade400),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     value ?? 'Pilih tanggal',
//                     style: GoogleFonts.poppins(
//                       fontSize: 13,
//                       color: value == null ? Colors.grey : Colors.black,
//                     ),
//                   ),
//                 ),
//                 const Icon(
//                   Icons.calendar_today,
//                   size: 18,
//                   color: Color(0xFF01579B),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildChip(String label, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         label,
//         style: GoogleFonts.poppins(fontSize: 10, color: color),
//       ),
//     );
//   }

//   Widget _buildCheckbox({
//     required String label,
//     required bool value,
//     required Function(bool) onChanged,
//   }) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         SizedBox(
//           width: 18,
//           height: 18,
//           child: Checkbox(
//             value: value,
//             onChanged: (v) => onChanged(v ?? false),
//             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           ),
//         ),
//         const SizedBox(width: 6),
//         Text(label, style: GoogleFonts.poppins(fontSize: 11)),
//       ],
//     );
//   }

//   void _confirmDelete(EmployeeNotifier notifier, String id) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Konfirmasi Hapus'),
//         content: const Text('Apakah Anda yakin ingin menghapus pegawai ini?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Batal'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               notifier.deleteEmployee(id);
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Hapus'),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/employee_provider.dart';
import '../../providers/employee_state.dart';
import '../../models/employee_model.dart';
import 'package:rsmss/l10n/app_localizations.dart';

class EmployeeTable extends ConsumerStatefulWidget {
  const EmployeeTable({super.key});

  @override
  ConsumerState<EmployeeTable> createState() => _EmployeeTableState();
}

class _EmployeeTableState extends ConsumerState<EmployeeTable> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Local state untuk edit
  String _localSelectedRole = 'operation';
  String? _localSelectedUnitId;
  String? _localSelectedPositionId;
  String? _localSelectedShiftId;
  String _localSelectedSituation = 'ACTIVE';
  
  // Old permission fields (masih dipertahankan untuk backward compatibility)
  bool _localIsAssetInitial = false;
  bool _localIsAssetInspection = false;
  bool _localIsStockInitial = false;
  bool _localIsStockOpname = false;
  bool _localIsApproved = false;
  String? _localJoinDate;
  
  // ============ NEW PERMISSION FIELDS (can_) ============
  bool _localCanRegisterPeople = false;
  bool _localCanBedAssignment = false;
  bool _localCanBedUnassignment = false;
  bool _localCanCheckoutPeople = false;
  bool _localCanAssetInitial = false;
  bool _localCanAssetInspection = false;
  bool _localCanStockInitial = false;
  bool _localCanAssetRequest = false;
  bool _localCanReturnAsset = false;
  bool _localCanStockOpname = false;
  bool _localCanStockIn = false;
  bool _localCanStockPlacement = false;
  bool _localCanStockRequest = false;
  bool _localCanStockRequestApproval = false;
  bool _localCanStockFulfillment = false;
  bool _localCanStockWriteOff = false;
  bool _localCanStockWriteOffApproval = false;
  bool _localCanBuildingReference = false;
  bool _localCanBinsReference = false;

  // Controllers
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initLocalState(EmployeeModel employee) {
    _localSelectedRole = employee.role;
    _localSelectedUnitId = employee.unitId;
    _localSelectedPositionId = employee.positionId;
    _localSelectedShiftId = employee.defaultShiftId;
    _localSelectedSituation = employee.currentSituation;
    
    // Old fields
    _localIsAssetInitial = employee.isAssetInitial;
    _localIsAssetInspection = employee.isAssetInspection;
    _localIsStockInitial = employee.isStockInitial;
    _localIsStockOpname = employee.isStockOpname;
    _localIsApproved = employee.isApproved;
    _localJoinDate = employee.joinDate;
    
    // New permission fields
    _localCanRegisterPeople = employee.canRegisterPeople;
    _localCanBedAssignment = employee.canBedAssignment;
    _localCanBedUnassignment = employee.canBedUnassignment;
    _localCanCheckoutPeople = employee.canCheckoutPeople;
    _localCanAssetInitial = employee.canAssetInitial;
    _localCanAssetInspection = employee.canAssetInspection;
    _localCanStockInitial = employee.canStockInitial;
    _localCanAssetRequest = employee.canAssetRequest;
    _localCanReturnAsset = employee.canReturnAsset;
    _localCanStockOpname = employee.canStockOpname;
    _localCanStockIn = employee.canStockIn;
    _localCanStockPlacement = employee.canStockPlacement;
    _localCanStockRequest = employee.canStockRequest;
    _localCanStockRequestApproval = employee.canStockRequestApproval;
    _localCanStockFulfillment = employee.canStockFulfillment;
    _localCanStockWriteOff = employee.canStockWriteOff;
    _localCanStockWriteOffApproval = employee.canStockWriteOffApproval;
    _localCanBuildingReference = employee.canBuildingReference;
    _localCanBinsReference = employee.canBinsReference;

    _controllers['name'] = TextEditingController(text: employee.fullName);
    _controllers['employeeId'] = TextEditingController(
      text: employee.employeeId ?? '',
    );
    _controllers['nik'] = TextEditingController(
      text: employee.employeeNik ?? '',
    );
    _controllers['phone'] = TextEditingController(text: employee.phone ?? '');
    _controllers['address'] = TextEditingController(
      text: employee.address ?? '',
    );
  }

  void _clearLocalState() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _localIsApproved = false;
    _localJoinDate = null;
    // Reset new permissions
    _localCanRegisterPeople = false;
    _localCanBedAssignment = false;
    _localCanBedUnassignment = false;
    _localCanCheckoutPeople = false;
    _localCanAssetInitial = false;
    _localCanAssetInspection = false;
    _localCanStockInitial = false;
    _localCanAssetRequest = false;
    _localCanReturnAsset = false;
    _localCanStockOpname = false;
    _localCanStockIn = false;
    _localCanStockPlacement = false;
    _localCanStockRequest = false;
    _localCanStockRequestApproval = false;
    _localCanStockFulfillment = false;
    _localCanStockWriteOff = false;
    _localCanStockWriteOffApproval = false;
    _localCanBuildingReference = false;
    _localCanBinsReference = false;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final state = ref.watch(employeeProvider);
    final notifier = ref.read(employeeProvider.notifier);

    // Handle messages
    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!, style: GoogleFonts.poppins()),
            backgroundColor: Colors.red.shade700,
          ),
        );
        notifier.clearMessages();
      });
    }

    if (state.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.successMessage!, style: GoogleFonts.poppins()),
            backgroundColor: Colors.green.shade700,
          ),
        );
        notifier.clearMessages();
      });
    }

    // Filter employees based on search
    final filteredEmployees = _searchQuery.isEmpty
        ? state.employees
        : state.employees.where((e) {
            return e.fullName.toLowerCase().contains(_searchQuery) ||
                (e.employeeId?.toLowerCase().contains(_searchQuery) ?? false) ||
                (e.employeeNik?.toLowerCase().contains(_searchQuery) ?? false);
          }).toList();

    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            border: const Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: localizations?.employee_searchHint ?? 'Cari nama, NIK, atau ID pegawai...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: state.isLoading
                    ? null
                    : () {
                        _clearLocalState();
                        notifier.startAddNew();
                      },
                icon: const Icon(Icons.add, size: 18),
                label: Text(localizations?.employee_addButton ?? 'Tambah Pegawai'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01579B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Loading indicator
        if (state.isLoading)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF01579B)),
            ),
          ),

        // Data Table
        if (!state.isLoading)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredEmployees.length + (state.isAddingNew ? 1 : 0),
              itemBuilder: (context, index) {
                if (state.isAddingNew && index == 0) {
                  return _buildAddNewRow(state, notifier);
                }
                final employeeIndex = state.isAddingNew ? index - 1 : index;
                if (employeeIndex >= filteredEmployees.length)
                  return const SizedBox();
                final employee = filteredEmployees[employeeIndex];
                final isEditing = state.editingId == employee.id;

                // Initialize local state when editing starts
                if (isEditing && _controllers.isEmpty) {
                  _initLocalState(employee);
                }

                return _buildEmployeeRow(employee, isEditing, notifier, state);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEmployeeRow(
    EmployeeModel employee,
    bool isEditing,
    EmployeeNotifier notifier,
    EmployeeState state,
  ) {
    final localizations = AppLocalizations.of(context);
    
    if (isEditing) {
      return _buildEditRow(employee, notifier, state);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          _initLocalState(employee);
          notifier.startEdit(employee.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF01579B).withValues(alpha: 0.1),
                backgroundImage:
                    employee.avatarUrl != null && employee.avatarUrl!.isNotEmpty
                    ? NetworkImage(employee.avatarUrl!)
                    : null,
                child: employee.avatarUrl == null || employee.avatarUrl!.isEmpty
                    ? Text(
                        employee.fullName.isNotEmpty
                            ? employee.fullName[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xFF01579B),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.fullName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildChip(
                          '${localizations?.employee_idPrefix ?? "ID: "}${employee.employeeId ?? '-'}',
                          Colors.grey,
                        ),
                        if (employee.unitName != null)
                          _buildChip(employee.unitName!, Colors.blue),
                        _buildChip(employee.role, Colors.teal),
                        if (employee.currentSituation == 'ACTIVE')
                          _buildChip(localizations?.employee_activeChip ?? 'Aktif', Colors.green)
                        else
                          _buildChip(employee.currentSituation, Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _confirmDelete(notifier, employee.id),
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                    tooltip: localizations?.employee_deleteButton ?? 'Hapus',
                  ),
                  IconButton(
                    onPressed: () {
                      _initLocalState(employee);
                      notifier.startEdit(employee.id);
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: Color(0xFF01579B),
                    ),
                    tooltip: localizations?.employee_saveButton ?? 'Edit',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditRow(
    EmployeeModel employee,
    EmployeeNotifier notifier,
    EmployeeState state,
  ) {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 30, 74, 139),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF42A5F5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.edit_note, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  localizations?.employee_editTitle ?? 'EDIT PEGAWAI',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    _clearLocalState();
                    notifier.cancelEdit();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white70,
                  ),
                  label: Text(
                    localizations?.employee_closeButton ?? 'Tutup',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Foto Avatar
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.shade800,
                    backgroundImage:
                        employee.avatarUrl != null &&
                            employee.avatarUrl!.isNotEmpty
                        ? NetworkImage(employee.avatarUrl!)
                        : null,
                    child:
                        (employee.avatarUrl == null ||
                            employee.avatarUrl!.isEmpty)
                        ? Icon(Icons.person, size: 40, color: Colors.white70)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      localizations?.employee_photoFromSystem ?? 'Foto profil dari sistem',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form Fields dengan label putih
            Row(
              children: [
                Expanded(
                  child: _buildTextFieldDark(
                    controller: _controllers['name']!,
                    label: localizations?.employee_fullNameLabel ?? 'Nama Lengkap',
                    hint: localizations?.employee_fullNameHint ?? 'Nama lengkap pegawai',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextFieldDark(
                    controller: _controllers['employeeId']!,
                    label: localizations?.employee_employeeIdLabel ?? 'ID Pegawai',
                    hint: localizations?.employee_employeeIdHint ?? 'Nomor induk pegawai',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildDropdownDark(
                    label: localizations?.employee_roleLabel ?? 'Role',
                    value: _localSelectedRole,
                    items: const [
                      'operation',
                      'management',
                      'admin',
                      'monitor',
                      'control_room',
                    ],
                    onChanged: (v) => setState(() => _localSelectedRole = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownWithDataDark(
                    label: localizations?.employee_unitLabel ?? 'Unit',
                    value: _localSelectedUnitId,
                    items: state.units,
                    itemId: (e) => e['id'].toString(),
                    itemLabel: (e) => e['unit_name'] ?? '-',
                    onChanged: (v) => setState(() => _localSelectedUnitId = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildDropdownWithDataDark(
                    label: localizations?.employee_positionLabel ?? 'Posisi',
                    value: _localSelectedPositionId,
                    items: state.positions,
                    itemId: (e) => e['id'].toString(),
                    itemLabel: (e) => e['position_name'] ?? '-',
                    onChanged: (v) =>
                        setState(() => _localSelectedPositionId = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownWithDataDark(
                    label: localizations?.employee_shiftLabel ?? 'Shift Default',
                    value: _localSelectedShiftId,
                    items: state.shifts,
                    itemId: (e) => e['id'].toString(),
                    itemLabel: (e) =>
                        '${e['shift_name']} (${e['shift_code'] ?? '-'})',
                    onChanged: (v) => setState(() => _localSelectedShiftId = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildTextFieldDark(
                    controller: _controllers['nik']!,
                    label: localizations?.employee_nikLabel ?? 'NIK',
                    hint: localizations?.employee_nikHint ?? 'Nomor Induk Kependudukan',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextFieldDark(
                    controller: _controllers['phone']!,
                    label: localizations?.employee_phoneLabel ?? 'No Telepon',
                    hint: localizations?.employee_phoneHint ?? 'Nomor HP aktif',
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildTextFieldDark(
              controller: _controllers['address']!,
              label: localizations?.employee_addressLabel ?? 'Alamat',
              hint: localizations?.employee_addressHint ?? 'Alamat lengkap',
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            // Akses Fitur Card - OLD PERMISSIONS (backward compatibility)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations?.employee_accessFeaturesTitle ?? 'Akses Fitur',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionAssetInitial ?? 'Asset Initial',
                        value: _localIsAssetInitial,
                        onChanged: (v) => setState(() => _localIsAssetInitial = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionAssetInspection ?? 'Asset Inspection',
                        value: _localIsAssetInspection,
                        onChanged: (v) => setState(() => _localIsAssetInspection = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionStockInitial ?? 'Stock Initial',
                        value: _localIsStockInitial,
                        onChanged: (v) => setState(() => _localIsStockInitial = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionStockOpname ?? 'Stock Opname',
                        value: _localIsStockOpname,
                        onChanged: (v) => setState(() => _localIsStockOpname = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // NEW PERMISSIONS CARD (19 permissions)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Permissions (can_)',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionRegisterPeople ?? 'Register People & RFID',
                        value: _localCanRegisterPeople,
                        onChanged: (v) => setState(() => _localCanRegisterPeople = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionBedAssignment ?? 'Bed Assignment',
                        value: _localCanBedAssignment,
                        onChanged: (v) => setState(() => _localCanBedAssignment = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionBedUnassignment ?? 'Bed Unassignment',
                        value: _localCanBedUnassignment,
                        onChanged: (v) => setState(() => _localCanBedUnassignment = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionCheckoutPeople ?? 'Check Out People',
                        value: _localCanCheckoutPeople,
                        onChanged: (v) => setState(() => _localCanCheckoutPeople = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionAssetInitial ?? 'Asset Initial',
                        value: _localCanAssetInitial,
                        onChanged: (v) => setState(() => _localCanAssetInitial = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionAssetInspection ?? 'Asset Inspection',
                        value: _localCanAssetInspection,
                        onChanged: (v) => setState(() => _localCanAssetInspection = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionStockInitial ?? 'Stock Initial',
                        value: _localCanStockInitial,
                        onChanged: (v) => setState(() => _localCanStockInitial = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionAssetRequest ?? 'Asset Request',
                        value: _localCanAssetRequest,
                        onChanged: (v) => setState(() => _localCanAssetRequest = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionReturnAsset ?? 'Return Asset',
                        value: _localCanReturnAsset,
                        onChanged: (v) => setState(() => _localCanReturnAsset = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionStockOpname ?? 'Stock Opname',
                        value: _localCanStockOpname,
                        onChanged: (v) => setState(() => _localCanStockOpname = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionStockIn ?? 'Stock In',
                        value: _localCanStockIn,
                        onChanged: (v) => setState(() => _localCanStockIn = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionStockPlacement ?? 'Stock Placement',
                        value: _localCanStockPlacement,
                        onChanged: (v) => setState(() => _localCanStockPlacement = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionStockRequest ?? 'Stock Request',
                        value: _localCanStockRequest,
                        onChanged: (v) => setState(() => _localCanStockRequest = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionStockRequestApproval ?? 'Stock Request Approval',
                        value: _localCanStockRequestApproval,
                        onChanged: (v) => setState(() => _localCanStockRequestApproval = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionStockFulfillment ?? 'Stock Fulfillment',
                        value: _localCanStockFulfillment,
                        onChanged: (v) => setState(() => _localCanStockFulfillment = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionStockWriteOff ?? 'Stock Write Off',
                        value: _localCanStockWriteOff,
                        onChanged: (v) => setState(() => _localCanStockWriteOff = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionStockWriteOffApproval ?? 'Stock Write Off Approval',
                        value: _localCanStockWriteOffApproval,
                        onChanged: (v) => setState(() => _localCanStockWriteOffApproval = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionBuildingReference ?? 'Building Reference',
                        value: _localCanBuildingReference,
                        onChanged: (v) => setState(() => _localCanBuildingReference = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_permissionBinsReference ?? 'Bins Reference',
                        value: _localCanBinsReference,
                        onChanged: (v) => setState(() => _localCanBinsReference = v),
                      ),
                      _buildCheckboxDark(
                        label: localizations?.employee_accountApproved ?? 'Account Active (Approved)',
                        value: _localIsApproved,
                        onChanged: (v) => setState(() => _localIsApproved = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildDropdownDark(
                    label: localizations?.employee_statusLabel ?? 'Status',
                    value: _localSelectedSituation,
                    items: const ['ACTIVE', 'INACTIVE', 'ON_LEAVE', 'SICK'],
                    onChanged: (v) =>
                        setState(() => _localSelectedSituation = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateFieldDark(
                    label: localizations?.employee_joinDateLabel ?? 'Tanggal Bergabung',
                    value: _localJoinDate,
                    onChanged: (date) => setState(() => _localJoinDate = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _clearLocalState();
                    notifier.cancelEdit();
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                  child: Text(localizations?.employee_cancelButton ?? 'Batal'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    final updatedEmployee = employee.copyWith(
                      fullName: _controllers['name']!.text.trim(),
                      role: _localSelectedRole,
                      employeeId:
                          _controllers['employeeId']!.text.trim().isEmpty
                          ? null
                          : _controllers['employeeId']!.text.trim(),
                      employeeNik: _controllers['nik']!.text.trim().isEmpty
                          ? null
                          : _controllers['nik']!.text.trim(),
                      phone: _controllers['phone']!.text.trim().isEmpty
                          ? null
                          : _controllers['phone']!.text.trim(),
                      address: _controllers['address']!.text.trim().isEmpty
                          ? null
                          : _controllers['address']!.text.trim(),
                      unitId: _localSelectedUnitId,
                      positionId: _localSelectedPositionId,
                      defaultShiftId: _localSelectedShiftId,
                      currentSituation: _localSelectedSituation,
                      // Old fields
                      isAssetInitial: _localIsAssetInitial,
                      isAssetInspection: _localIsAssetInspection,
                      isStockInitial: _localIsStockInitial,
                      isStockOpname: _localIsStockOpname,
                      isApproved: _localIsApproved,
                      joinDate: _localJoinDate,
                      // New permission fields
                      canRegisterPeople: _localCanRegisterPeople,
                      canBedAssignment: _localCanBedAssignment,
                      canBedUnassignment: _localCanBedUnassignment,
                      canCheckoutPeople: _localCanCheckoutPeople,
                      canAssetInitial: _localCanAssetInitial,
                      canAssetInspection: _localCanAssetInspection,
                      canStockInitial: _localCanStockInitial,
                      canAssetRequest: _localCanAssetRequest,
                      canReturnAsset: _localCanReturnAsset,
                      canStockOpname: _localCanStockOpname,
                      canStockIn: _localCanStockIn,
                      canStockPlacement: _localCanStockPlacement,
                      canStockRequest: _localCanStockRequest,
                      canStockRequestApproval: _localCanStockRequestApproval,
                      canStockFulfillment: _localCanStockFulfillment,
                      canStockWriteOff: _localCanStockWriteOff,
                      canStockWriteOffApproval: _localCanStockWriteOffApproval,
                      canBuildingReference: _localCanBuildingReference,
                      canBinsReference: _localCanBinsReference,
                    );
                    await notifier.saveEmployee(updatedEmployee);
                    _clearLocalState();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF42A5F5),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(localizations?.employee_saveButton ?? 'Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widgets untuk dark mode
  Widget _buildTextFieldDark({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white38),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            isDense: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white38),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white, width: 1.5),
            ),
            fillColor: Colors.white.withValues(alpha: 0.1),
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownDark({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: const Color(0xFF0D47A1),
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            isDense: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white38),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white, width: 1.5),
            ),
            fillColor: Colors.white.withValues(alpha: 0.1),
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownWithDataDark({
    required String label,
    required String? value,
    required List<Map<String, dynamic>> items,
    required String Function(Map<String, dynamic>) itemId,
    required String Function(Map<String, dynamic>) itemLabel,
    required Function(String?) onChanged,
    bool optional = true,
  }) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(
            optional ? (localizations?.employee_optionalPrefix ?? 'Pilih (Opsional)') : 'Pilih',
            style: TextStyle(color: Colors.white54),
          ),
          dropdownColor: const Color(0xFF0D47A1),
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          items: [
            if (optional)
              const DropdownMenuItem(
                value: null,
                child: Text('-', style: TextStyle(color: Colors.white70)),
              ),
            ...items.map((item) {
              return DropdownMenuItem(
                value: itemId(item),
                child: Text(
                  itemLabel(item),
                  style: TextStyle(color: Colors.white),
                ),
              );
            }),
          ],
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            isDense: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white38),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white, width: 1.5),
            ),
            fillColor: Colors.white.withValues(alpha: 0.1),
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDateFieldDark({
    required String label,
    required String? value,
    required Function(String?) onChanged,
  }) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              onChanged(date.toIso8601String().split('T')[0]);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white38),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withValues(alpha: 0.1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? (localizations?.employee_selectDateHint ?? 'Pilih tanggal'),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: value == null ? Colors.white54 : Colors.white,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today, size: 18, color: Colors.white70),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxDark({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            activeColor: Colors.white,
            checkColor: const Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildAddNewRow(EmployeeState state, EmployeeNotifier notifier) {
    final localizations = AppLocalizations.of(context);
    final nameController = TextEditingController();
    String selectedRole = 'operation';
    String? selectedUnitId;
    String? selectedPositionId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade400, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_circle, size: 16, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  localizations?.employee_addNewTitle ?? 'TAMBAH PEGAWAI BARU',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.green.shade700,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    nameController.dispose();
                    notifier.cancelEdit();
                  },
                  icon: const Icon(Icons.close, size: 16),
                  label: Text(localizations?.employee_cancelButton ?? 'Batal'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: nameController,
                    label: localizations?.employee_fullNameLabel ?? 'Nama Lengkap *',
                    hint: localizations?.employee_fullNameHint ?? 'Nama lengkap pegawai',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    label: localizations?.employee_roleLabel ?? 'Role *',
                    value: selectedRole,
                    items: const [
                      'operation',
                      'management',
                      'admin',
                      'monitor',
                      'control_room',
                    ],
                    onChanged: (v) => setState(() => selectedRole = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownWithData(
                    label: localizations?.employee_unitLabel ?? 'Unit',
                    value: selectedUnitId,
                    items: state.units,
                    itemId: (e) => e['id'].toString(),
                    itemLabel: (e) => e['unit_name'] ?? '-',
                    onChanged: (v) => setState(() => selectedUnitId = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownWithData(
                    label: localizations?.employee_positionLabel ?? 'Posisi',
                    value: selectedPositionId,
                    items: state.positions,
                    itemId: (e) => e['id'].toString(),
                    itemLabel: (e) => e['position_name'] ?? '-',
                    onChanged: (v) => setState(() => selectedPositionId = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations?.employee_nameRequired ?? 'Nama lengkap harus diisi'),
                        ),
                      );
                      return;
                    }
                    final newEmployee = EmployeeModel(
                      id: 'new',
                      fullName: nameController.text.trim(),
                      role: selectedRole,
                      unitId: selectedUnitId,
                      positionId: selectedPositionId,
                    );
                    await notifier.saveEmployee(newEmployee);
                    nameController.dispose();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(localizations?.employee_saveButton ?? 'Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widgets (light mode untuk add new row)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            isDense: true,
          ),
          style: GoogleFonts.poppins(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownWithData({
    required String label,
    required String? value,
    required List<Map<String, dynamic>> items,
    required String Function(Map<String, dynamic>) itemId,
    required String Function(Map<String, dynamic>) itemLabel,
    required Function(String?) onChanged,
    bool optional = true,
  }) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(optional ? (localizations?.employee_optionalPrefix ?? 'Pilih (Opsional)') : 'Pilih'),
          items: [
            if (optional) const DropdownMenuItem(value: null, child: Text('-')),
            ...items.map((item) {
              return DropdownMenuItem(
                value: itemId(item),
                child: Text(
                  itemLabel(item),
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              );
            }),
          ],
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 10, color: color),
      ),
    );
  }

  void _confirmDelete(EmployeeNotifier notifier, String id) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations?.employee_deleteConfirmTitle ?? 'Konfirmasi Hapus'),
        content: Text(localizations?.employee_deleteConfirmContent ?? 'Apakah Anda yakin ingin menghapus pegawai ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations?.employee_cancelButton ?? 'Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.deleteEmployee(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(localizations?.employee_deleteButton ?? 'Hapus'),
          ),
        ],
      ),
    );
  }
}