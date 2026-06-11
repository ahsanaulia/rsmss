// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'RSMSS IoT';

  @override
  String get emailHint => 'Email Operator';

  @override
  String get passwordHint => 'Kata Sandi';

  @override
  String get loginButton => 'MASUK';

  @override
  String get noAccount => 'Belum memiliki akun? ';

  @override
  String get register => 'Daftar';

  @override
  String get scanQrButton => 'SCAN QR TENANT';

  @override
  String get developedBy => 'Dikembangkan Oleh : PLATFORM PELAYANAN TERBAIK';

  @override
  String get distributedBy => 'Didistribusikan Oleh : PT. REKAMITRA';

  @override
  String get yearCountry => '2026 - Indonesia';

  @override
  String get qrScanTitle => 'Scan QR Tenant';

  @override
  String get qrScanInstruction => 'Arahkan kamera ke QR Code';

  @override
  String get qrScanProcessing => 'Memproses QR Code...';

  @override
  String get qrScanSuccess =>
      'Konfigurasi tenant berhasil disimpan. Aplikasi akan di-restart.';

  @override
  String get qrScanError => 'Gagal memproses QR: ';

  @override
  String get operationHospitalPlatform =>
      'Hospital Operational Intelligence Platform';

  @override
  String get operationOnDuty => 'BERTUGAS';

  @override
  String get operationOffDuty => 'TIDAK BERTUGAS';

  @override
  String get operationLatestAnnouncements => 'PENGUMUMAN TERBARU';

  @override
  String get operationOperational => 'Operasional';

  @override
  String get operationReports => 'Laporan';

  @override
  String get operationNotes => 'Catatan';

  @override
  String get operationInfo => 'INFO';

  @override
  String get operationUrgent => 'URGENT';

  @override
  String get operationNoAnnouncements =>
      'Belum ada pesan baru dari pusat kontrol.';

  @override
  String get operationJustNow => 'Baru saja';

  @override
  String get operationMinutesAgo => 'menit lalu';

  @override
  String get operationHourAgo => 'jam lalu';

  @override
  String get operationHoursAgo => 'jam lalu';

  @override
  String get operationYesterday => 'Kemarin';

  @override
  String get operationDaysAgo => 'hari lalu';

  @override
  String get operationWeeksAgo => 'minggu lalu';

  @override
  String get operationMonthsAgo => 'bulan lalu';

  @override
  String get operationYearsAgo => 'tahun lalu';

  @override
  String get operationMenuReportIncident => 'Lapor Insiden';

  @override
  String get operationMenuRegisterPeopleRfid => 'Registrasi Orang & RFID';

  @override
  String get operationMenuBedAssignment => 'Penentuan Tempat Tidur';

  @override
  String get operationMenuBedUnassignment => 'Tempat Tidur Dikosongkan';

  @override
  String get operationMenuCheckOutPeople => 'Check Out People';

  @override
  String get operationMenuInitialAsset => 'Inisialisasi Awal Asset';

  @override
  String get operationMenuRoutineAssetInspection => 'Inspeksi Rutin Asset';

  @override
  String get operationMenuInitialStock => 'Inisialisasi Awal Stock';

  @override
  String get operationMenuAssetRequest => 'Permintaan Aset';

  @override
  String get operationMenuReturnAsset => 'Kembalikan Aset';

  @override
  String get operationMenuStockOpname => 'Stock Opname';

  @override
  String get operationMenuStockIn => 'Stok Masuk';

  @override
  String get operationMenuStockPlacement => 'Penempatan Stok Pada Bin';

  @override
  String get operationMenuStockRequest => 'Permintaan Stok';

  @override
  String get operationMenuStockRequestApproval => 'Persetujuan Permintaan Stok';

  @override
  String get operationMenuStockFulfillment =>
      'Pengeluaran Stok Atas Permintaan';

  @override
  String get operationMenuStockWriteOff =>
      'Pengeluaran Stok Atas Kadaluarsa/Rusak';

  @override
  String get operationMenuStockWriteOffApproval =>
      'Persetujuan Pengeluaran Stok Atas Kadaluarsa/Rusak';

  @override
  String get operationMenuBuildingReference => 'Tabel Referensi Bangunan';

  @override
  String get operationMenuBinsReference => 'Tabel Referensi Bins';

  @override
  String get operationReportsMenuWorkHistory => 'Riwayat Pekerjaan';

  @override
  String get operationReportsMenuTaskHistory => 'Riwayat Tugas';

  @override
  String get operationReportsMenuTaskReportHistory => 'Riwayat Laporan Tugas';

  @override
  String get operationReportsMenuAttendanceHistory => 'Riwayat Absensi';

  @override
  String get operationBottomNavHome => 'Beranda';

  @override
  String get operationBottomNavAttendance => 'Absensi';

  @override
  String get operationBottomNavTasks => 'Tugas';

  @override
  String get operationBottomNavProfile => 'Profil';

  @override
  String get operationStatsNew => 'New';

  @override
  String get operationStatsOn => 'On';

  @override
  String get operationStatsUrg => 'Urg';

  @override
  String get minutesAgo => 'menit lalu';

  @override
  String get hoursAgo => 'jam lalu';

  @override
  String get yesterday => 'Kemarin';

  @override
  String get daysAgo => 'hari lalu';

  @override
  String get weeksAgo => 'minggu lalu';

  @override
  String get monthsAgo => 'bulan lalu';

  @override
  String get yearsAgo => 'tahun lalu';

  @override
  String get att_statusOnDuty => 'STATUS: DALAM SHIFT';

  @override
  String get att_statusSelfAttendance => 'ABSENSI MANDIRI';

  @override
  String get att_trackingInfo =>
      '📍 Lokasi akan tercatat untuk keperluan koordinasi tim';

  @override
  String get att_loading => 'Loading...';

  @override
  String get att_findingLocation => 'Mencari lokasi...';

  @override
  String get att_checkInSuccess => 'Check In Berhasil! Tracking dimulai.';

  @override
  String get att_checkOutSuccess =>
      'Selesai Shift Berhasil! Anda tidak dalam koordinasi lokasi dengan Tim. Selamat Beristirahat!';

  @override
  String get att_endShift => 'AKHIRI SHIFT';

  @override
  String get att_startShift => 'MULAI SHIFT';

  @override
  String get att_errorPrefix => 'Error: ';

  @override
  String get att_checkActiveFailed => 'Gagal cek status aktif: ';

  @override
  String get att_fetchShiftsError => 'Error fetching shifts: ';

  @override
  String get att_cameraError => 'Kamera Error: ';

  @override
  String get att_locationError => 'Lokasi Error: ';

  @override
  String get att_setupError => 'Setup Error: ';

  @override
  String get task_title => 'DAFTAR TUGAS';

  @override
  String get task_empty => 'Antrian Kosong 🚀';

  @override
  String get task_error => 'Error: ';

  @override
  String get task_from => 'DARI';

  @override
  String get task_to => 'KE';

  @override
  String get task_statusPending => 'PENDING';

  @override
  String get task_statusAccepted => 'DITERIMA';

  @override
  String get task_statusDone => 'SELESAI';

  @override
  String get task_defaultFromRoom => 'Lokasi A';

  @override
  String get task_defaultToRoom => 'Lokasi B';

  @override
  String get task_defaultTitle => 'Tugas';

  @override
  String get taskDetail_appBarTitle => 'Detail Eksekusi';

  @override
  String get taskDetail_acceptButton => 'TERIMA TUGAS';

  @override
  String get taskDetail_notAcceptedMessage =>
      'Tugas belum Anda terima. Klik tombol di bawah untuk mulai mengerjakan.';

  @override
  String get taskDetail_infoTitle => 'INFORMASI TUGAS';

  @override
  String get taskDetail_routeLabel => 'Rute: ';

  @override
  String get taskDetail_priorityLabel => 'Prioritas: ';

  @override
  String get taskDetail_requiresPhoto => 'Memerlukan bukti foto';

  @override
  String get taskDetail_locationTitle => 'LOKASI PENYELESAIAN';

  @override
  String get taskDetail_locationNotTaken => 'Belum ambil lokasi';

  @override
  String get taskDetail_takeLocationButton => 'AMBIL LOKASI SAAT INI';

  @override
  String get taskDetail_takingLocation => 'MENGAMBIL LOKASI...';

  @override
  String get taskDetail_completionTitle => 'PENYELESAIAN TUGAS';

  @override
  String get taskDetail_completionHint => 'Tulis catatan penyelesaian...';

  @override
  String get taskDetail_failButton => 'GAGAL';

  @override
  String get taskDetail_successButton => 'SELESAI';

  @override
  String get taskDetail_acceptSuccess => 'Tugas diterima, silakan kerjakan';

  @override
  String get taskDetail_acceptFailed => 'Gagal menerima tugas: ';

  @override
  String get taskDetail_locationPermissionRequired => 'Izin lokasi diperlukan';

  @override
  String get taskDetail_locationSuccess => 'Lokasi: ';

  @override
  String get taskDetail_locationFailed => 'Gagal mendapat lokasi: ';

  @override
  String get taskDetail_incompleteData =>
      'Lengkapi foto, kategori, dan deskripsi!';

  @override
  String get taskDetail_reportSent => 'Laporan kendala terkirim!';

  @override
  String get taskDetail_reportFailed => 'Gagal kirim laporan: ';

  @override
  String get taskDetail_photoRequired =>
      'Tugas ini memerlukan bukti foto! Silakan ambil foto terlebih dahulu.';

  @override
  String get taskDetail_taskSuccess => 'Tugas selesai! ✅';

  @override
  String get taskDetail_taskFailed => 'Tugas gagal ❌';

  @override
  String get taskDetail_clickToTakePhoto => 'Klik untuk Foto Bukti';

  @override
  String get taskDetail_reportIssueTitle => 'LAPORKAN KENDALA';

  @override
  String get taskDetail_reportIssueSubtext =>
      'Ditemukan masalah teknis/lapangan?';

  @override
  String get taskDetail_issueCategory => 'Kategori Masalah';

  @override
  String get taskDetail_issueDescriptionHint => 'Deskripsi kendala...';

  @override
  String get taskDetail_sendReportButton => 'KIRIM LAPORAN KENDALA';

  @override
  String get profile_title => 'PROFIL SAYA';

  @override
  String get profile_avatarSuccess => 'Foto diperbarui';

  @override
  String get profile_avatarFailed => 'Gagal upload foto';

  @override
  String get profile_saveSuccess => 'Profil berhasil disimpan';

  @override
  String get profile_saveFailed => 'Gagal menyimpan: ';

  @override
  String get profile_personalData => 'DATA PRIBADI';

  @override
  String get profile_fullName => 'Nama Lengkap';

  @override
  String get profile_nik => 'ID Pegawai';

  @override
  String get profile_gender => 'Jenis Kelamin';

  @override
  String get profile_phone => 'No. WhatsApp';

  @override
  String get profile_address => 'Alamat';

  @override
  String get profile_male => 'Laki-laki';

  @override
  String get profile_female => 'Perempuan';

  @override
  String get profile_workInfo => 'INFORMASI KERJA';

  @override
  String get profile_unit => 'Unit Kerja';

  @override
  String get profile_position => 'Jabatan';

  @override
  String get profile_shift => 'Shift Default';

  @override
  String get profile_logout => 'Keluar Aplikasi';

  @override
  String get profile_idPrefix => 'ID: ';

  @override
  String get dutyNote_title => 'Catatan Dinas';

  @override
  String get dutyNote_infoText =>
      'Catat aktivitas pekerjaan Anda hari ini. Setiap catatan akan mendapatkan +5 poin.';

  @override
  String get dutyNote_label => 'Catatan Pekerjaan';

  @override
  String get dutyNote_hint =>
      'Contoh:\n• Melakukan visit pasien di ruang VIP\n• Memindahkan pasien dari ruang A ke ruang B\n• Membersihkan dan sterilisasi alat';

  @override
  String get dutyNote_saveButton => 'Simpan Catatan';

  @override
  String get dutyNote_emptyError => 'Catatan tidak boleh kosong';

  @override
  String get dutyNote_sessionExpired => 'Session expired';

  @override
  String get dutyNote_notCheckedInError =>
      'Anda belum check-in hari ini. Silakan check-in terlebih dahulu.';

  @override
  String get dutyNote_saveSuccess => 'Catatan berhasil disimpan';

  @override
  String get todo_title => 'RUTINITAS (TO DO) HARI INI';

  @override
  String get todo_loadError => 'Gagal memuat Rutinitas';

  @override
  String get todo_empty => 'Tidak ada Rutinitas untuk hari ini';

  @override
  String get todo_completedMessage => 'Rutinitas selesai';

  @override
  String get stats_title => 'Kinerja Bulan Ini';

  @override
  String get stats_points => ' poin';

  @override
  String get stats_fatiguePrefix => 'Fatigue/Keletihan';

  @override
  String get stats_fatigueLow => 'Rendah';

  @override
  String get stats_fatigueMedium => 'Sedang';

  @override
  String get stats_fatigueHigh => 'Tinggi';

  @override
  String get stats_fatigueCritical => 'Kritis';

  @override
  String stats_remainingNeeded(Object remaining) {
    return 'Butuh $remaining poin lagi untuk mencapai target';
  }

  @override
  String get stats_targetAchieved => 'Target tercapai! 🎉';

  @override
  String get stats_catAttendance => 'Absensi';

  @override
  String get stats_catTask => 'Tugas';

  @override
  String get stats_catIncident => 'Insiden';

  @override
  String get stats_catInspection => 'Inspeksi';

  @override
  String get stats_catOpname => 'Opname';

  @override
  String get stats_catWellbeing => 'Wellbeing/Kesejahteraan';

  @override
  String get stats_catDutyNote => 'Catatan';

  @override
  String get stats_remainingNeededPrefix => 'Butuh';

  @override
  String get stats_remainingNeededSuffix => 'poin lagi untuk mencapai target';

  @override
  String get roster_dayOff => 'HARI LIBUR';

  @override
  String get roster_todaySchedule => 'JADWAL HARI INI';

  @override
  String get roster_fatiguePrefix => 'Fatigue';

  @override
  String get roster_locationNotSet => 'Lokasi belum ditentukan';

  @override
  String get roster_requiredEquipment => 'Perlengkapan Wajib:';

  @override
  String get roster_restMessage => 'Selamat beristirahat!';

  @override
  String get roster_nextSchedule => 'JADWAL BERIKUTNYA';

  @override
  String get roster_emptyMessage =>
      'Belum ada jadwal untuk hari ini. Silakan hubungi atasan.';

  @override
  String get opMenuReportIncident => 'Lapor Insiden';

  @override
  String get opMenuRegisterPeopleRfid => 'Registrasi Orang & RFID';

  @override
  String get opMenuBedAssignment => 'Penentuan Tempat Tidur';

  @override
  String get opMenuBedUnassignment => 'Tempat Tidur Dikosongkan';

  @override
  String get opMenuCheckOutPeople => 'Check Out People';

  @override
  String get opMenuInitialAsset => 'Inisialisasi Awal Asset';

  @override
  String get opMenuRoutineAssetInspection => 'Inspeksi Rutin Asset';

  @override
  String get opMenuInitialStock => 'Inisialisasi Awal Stock';

  @override
  String get opMenuAssetRequest => 'Permintaan Aset';

  @override
  String get opMenuReturnAsset => 'Kembalikan Aset';

  @override
  String get opMenuStockOpname => 'Stock Opname';

  @override
  String get opMenuStockIn => 'Stok Masuk';

  @override
  String get opMenuStockPlacement => 'Penempatan Stok Pada Bin';

  @override
  String get opMenuStockRequest => 'Permintaan Stok';

  @override
  String get opMenuStockRequestApproval => 'Persetujuan Permintaan Stok';

  @override
  String get opMenuStockFulfillment => 'Pengeluaran Stok Atas Permintaan';

  @override
  String get opMenuStockWriteOff => 'Pengeluaran Stok Atas Kadaluarsa/Rusak';

  @override
  String get opMenuStockWriteOffApproval =>
      'Persetujuan Pengeluaran Stok Atas Kadaluarsa/Rusak';

  @override
  String get opMenuBuildingReference => 'Tabel Referensi Bangunan';

  @override
  String get opMenuBinsReference => 'Tabel Referensi Bins';

  @override
  String get opMenuWorkHistory => 'Riwayat Pekerjaan';

  @override
  String get opMenuTaskHistory => 'Riwayat Tugas';

  @override
  String get opMenuTaskReportHistory => 'Riwayat Laporan Tugas';

  @override
  String get opMenuAttendanceHistory => 'Riwayat Absensi';

  @override
  String get admin_logoutConfirmTitle => 'Konfirmasi Logout';

  @override
  String get admin_logoutConfirmContent => 'Apakah Anda yakin ingin keluar?';

  @override
  String get admin_logoutCancel => 'Batal';

  @override
  String get admin_logoutConfirm => 'Logout';

  @override
  String get admin_sidebarMenuMasterData => 'DATA INDUK';

  @override
  String get admin_sidebarMenuAssetManagement => 'MANAJEMEN ASET';

  @override
  String get admin_sidebarMenuStockInventory => 'MANAJEMEN STOK/INVENTORI';

  @override
  String get admin_sidebarMenuOperational => 'OPERASIONAL';

  @override
  String get admin_sidebarMenuReferenceTables => 'TABEL REFERENSI';

  @override
  String get admin_sidebarMenuSystem => 'SISTEM';

  @override
  String get admin_sidebarSubMenuAssetRef => 'REFERENSI ASET';

  @override
  String get admin_sidebarSubMenuStockRef => 'REFERENSI STOK';

  @override
  String get admin_sidebarSubMenuLocationHierarchy => 'HIRARKI LOKASI';

  @override
  String get admin_sidebarSubMenuWarehouseHierarchy => 'HIRARKI GUDANG';

  @override
  String get admin_sidebarSubMenuGeneralRef => 'REFERENSI UMUM & KEPEGAWAIAN';

  @override
  String get admin_menuEmployees => 'Data Pegawai';

  @override
  String get admin_menuEmployeeQualifications => 'Kualifikasi Pegawai';

  @override
  String get admin_menuScoringCategories => 'Kategori Penilaian';

  @override
  String get admin_menuLeaveTypes => 'Jenis Cuti';

  @override
  String get admin_menuIncidentCategories => 'Kategori Insiden';

  @override
  String get admin_menuPeopleCategories => 'Klasifikasi Orang';

  @override
  String get admin_menuPositions => 'Posisi/Jabatan';

  @override
  String get admin_menuReportCategories => 'Kategori Laporan';

  @override
  String get admin_menuShifts => 'Shift Kerja';

  @override
  String get admin_menuAssets => 'Daftar Aset';

  @override
  String get admin_menuAssetVerification => 'Persetujuan Pemakaian Aset';

  @override
  String get admin_menuAssetReport => 'Laporan Aset';

  @override
  String get admin_menuBeds => 'Manajemen Ranjang';

  @override
  String get admin_menuStockList => 'Daftar Stok';

  @override
  String get admin_menuStockIn => 'Stok Masuk';

  @override
  String get admin_menuPendingPutAway => 'Stok Belum Ditempatkan';

  @override
  String get admin_menuStockWriteOffApproval => 'Persetujuan Penghapusan Stok';

  @override
  String get admin_menuStockMutation => 'Mutasi Stok';

  @override
  String get admin_menuPeopleRegistration => 'Registrasi Orang & RFID';

  @override
  String get admin_menuBedAssignment => 'Penentuan Tempat Tidur Pasien';

  @override
  String get admin_menuBedUnassignment => 'Tempat Tidur Dikosongkan';

  @override
  String get admin_menuPeopleCheckout => 'Unregister People (Check Out RFID)';

  @override
  String get admin_menuRoster => 'Penjadwalan Pegawai';

  @override
  String get admin_menuAnnouncements => 'Pengumuman Pegawai';

  @override
  String get admin_menuTaskAssignment => 'Penugasan Pegawai';

  @override
  String get admin_menuTodo => 'To Do';

  @override
  String get admin_menuAssetCategories => 'Kategori Aset';

  @override
  String get admin_menuAssetSubCategories => 'Sub-Kategori Aset';

  @override
  String get admin_menuAssetTypes => 'Tipe Aset';

  @override
  String get admin_menuAssetDangerLevels => 'Tingkat Bahaya Aset';

  @override
  String get admin_menuStockCategories => 'Kategori Stok';

  @override
  String get admin_menuStockSubCategories => 'Sub-Kategori Stok';

  @override
  String get admin_menuStockTypes => 'Tipe Stok';

  @override
  String get admin_menuBuildingFunctions => 'Fungsi Khusus Gedung';

  @override
  String get admin_menuRoomCategories => 'Kategori Ruangan';

  @override
  String get admin_menuBuildings => 'Gedung/Bangunan';

  @override
  String get admin_menuFloors => 'Lantai';

  @override
  String get admin_menuRooms => 'Ruangan';

  @override
  String get admin_menuWarehouses => 'Gudang';

  @override
  String get admin_menuZones => 'Zona Penyimpanan';

  @override
  String get admin_menuRacks => 'Lemari Rak';

  @override
  String get admin_menuShelves => 'Shelf/Rak Level';

  @override
  String get admin_menuBins => 'Bin/Box';

  @override
  String get admin_menuUnits => 'Unit/Departemen';

  @override
  String get admin_menuLogout => 'Logout';

  @override
  String get admin_selectMenuHint => 'Pilih menu dari sidebar';

  @override
  String get admin_footerDevelopedBy =>
      'Dikembangkan Oleh: PLATFORM PELAYANAN TERBAIK';

  @override
  String get admin_footerDistributedBy => 'Didistribusikan Oleh: PT. REKAMITRA';

  @override
  String get admin_footerYearCountry => '2026 - Indonesia';

  @override
  String get employee_searchHint => 'Cari nama, NIK, atau ID pegawai...';

  @override
  String get employee_addButton => 'Tambah Pegawai';

  @override
  String get employee_addNewTitle => 'TAMBAH PEGAWAI BARU';

  @override
  String get employee_editTitle => 'EDIT PEGAWAI';

  @override
  String get employee_closeButton => 'Tutup';

  @override
  String get employee_cancelButton => 'Batal';

  @override
  String get employee_saveButton => 'Simpan';

  @override
  String get employee_deleteConfirmTitle => 'Konfirmasi Hapus';

  @override
  String get employee_deleteConfirmContent =>
      'Apakah Anda yakin ingin menghapus pegawai ini?';

  @override
  String get employee_deleteButton => 'Hapus';

  @override
  String get employee_fullNameLabel => 'Nama Lengkap *';

  @override
  String get employee_fullNameHint => 'Nama lengkap pegawai';

  @override
  String get employee_roleLabel => 'Role *';

  @override
  String get employee_employeeIdLabel => 'ID Pegawai';

  @override
  String get employee_employeeIdHint => 'Nomor induk pegawai';

  @override
  String get employee_nikLabel => 'NIK';

  @override
  String get employee_nikHint => 'Nomor Induk Kependudukan';

  @override
  String get employee_phoneLabel => 'No Telepon';

  @override
  String get employee_phoneHint => 'Nomor HP aktif';

  @override
  String get employee_addressLabel => 'Alamat';

  @override
  String get employee_addressHint => 'Alamat lengkap';

  @override
  String get employee_unitLabel => 'Unit';

  @override
  String get employee_unitHint => 'Pilih unit (opsional)';

  @override
  String get employee_positionLabel => 'Posisi';

  @override
  String get employee_positionHint => 'Pilih posisi (opsional)';

  @override
  String get employee_shiftLabel => 'Shift Default';

  @override
  String get employee_shiftHint => 'Pilih shift default (opsional)';

  @override
  String get employee_statusLabel => 'Status';

  @override
  String get employee_joinDateLabel => 'Tanggal Bergabung';

  @override
  String get employee_joinDateHint => 'Pilih tanggal';

  @override
  String get employee_accessFeaturesTitle => 'Akses Fitur';

  @override
  String get employee_permissionAssetInitial => 'Inisialisasi Aset';

  @override
  String get employee_permissionAssetInspection => 'Inspeksi Aset';

  @override
  String get employee_permissionStockInitial => 'Inisialisasi Stok';

  @override
  String get employee_permissionStockOpname => 'Stock Opname';

  @override
  String get employee_permissionRegisterPeople => 'Registrasi Orang & RFID';

  @override
  String get employee_permissionBedAssignment => 'Penentuan Tempat Tidur';

  @override
  String get employee_permissionBedUnassignment => 'Tempat Tidur Dikosongkan';

  @override
  String get employee_permissionCheckoutPeople => 'Check Out People';

  @override
  String get employee_permissionAssetRequest => 'Permintaan Aset';

  @override
  String get employee_permissionReturnAsset => 'Kembalikan Aset';

  @override
  String get employee_permissionStockIn => 'Stok Masuk';

  @override
  String get employee_permissionStockPlacement => 'Penempatan Stok';

  @override
  String get employee_permissionStockRequest => 'Permintaan Stok';

  @override
  String get employee_permissionStockRequestApproval =>
      'Persetujuan Permintaan Stok';

  @override
  String get employee_permissionStockFulfillment =>
      'Pengeluaran Stok Atas Permintaan';

  @override
  String get employee_permissionStockWriteOff => 'Penghapusan Stok';

  @override
  String get employee_permissionStockWriteOffApproval =>
      'Persetujuan Penghapusan Stok';

  @override
  String get employee_permissionBuildingReference => 'Referensi Bangunan';

  @override
  String get employee_permissionBinsReference => 'Referensi Bins';

  @override
  String get employee_accountApproved => 'Akun Aktif (Approved)';

  @override
  String get employee_avatarInfo => 'Foto profil dari sistem';

  @override
  String get employee_nameRequired => 'Nama lengkap harus diisi';

  @override
  String get employee_saveSuccess => 'Pegawai berhasil disimpan';

  @override
  String get employee_saveError => 'Gagal menyimpan pegawai: ';

  @override
  String get employee_deleteSuccess => 'Pegawai berhasil dihapus';

  @override
  String get employee_deleteError => 'Gagal menghapus pegawai: ';

  @override
  String get employee_activeChip => 'Aktif';

  @override
  String get employee_idPrefix => 'ID: ';

  @override
  String get employee_optionalPrefix => 'Pilih (Opsional)';

  @override
  String get employee_selectDateHint => 'Pilih tanggal';

  @override
  String get employee_photoFromSystem => 'Foto profil dari sistem';

  @override
  String get employee_roleOperation => 'operation';

  @override
  String get employee_roleManagement => 'management';

  @override
  String get employee_roleAdmin => 'admin';

  @override
  String get employee_roleMonitor => 'monitor';

  @override
  String get employee_roleControlRoom => 'control_room';

  @override
  String get employee_statusActive => 'AKTIF';

  @override
  String get employee_statusInactive => 'TIDAK AKTIF';

  @override
  String get employee_statusOnLeave => 'CUTI';

  @override
  String get employee_statusSick => 'SAKIT';

  @override
  String get crud_eq_title => 'Kualifikasi Pegawai';

  @override
  String get crud_eq_delete_title => 'Hapus Kualifikasi';

  @override
  String get crud_eq_delete_confirm_content =>
      'Apakah Anda yakin ingin menghapus kualifikasi ini?';

  @override
  String get crud_eq_delete_cancel => 'Batal';

  @override
  String get crud_eq_delete_confirm => 'Hapus';

  @override
  String get crud_eq_delete_success => 'Kualifikasi berhasil dihapus';

  @override
  String get crud_eq_empty_data => 'Belum ada data kualifikasi';

  @override
  String get crud_eq_add_button => 'Tambah Kualifikasi';

  @override
  String get crud_eq_code_label => 'Kode: ';

  @override
  String get crud_eq_category_label => 'Kategori: ';

  @override
  String get crud_eq_validity_label => 'Masa Berlaku: ';

  @override
  String get crud_eq_months_suffix => ' bulan';

  @override
  String get crud_eq_status_active => 'Aktif';

  @override
  String get crud_eq_status_inactive => 'Nonaktif';

  @override
  String get crud_eq_requires_renewal => 'Perlu Perpanjangan';

  @override
  String get crud_eq_menu_detail => 'Detail';

  @override
  String get crud_eq_menu_edit => 'Edit';

  @override
  String get crud_eq_menu_delete => 'Hapus';

  @override
  String get crud_eq_refresh_tooltip => 'Refresh';

  @override
  String get crud_eq_detail_title => 'Detail';

  @override
  String get crud_eq_detail_id => 'ID';

  @override
  String get crud_eq_detail_code => 'Kode Kualifikasi';

  @override
  String get crud_eq_detail_name => 'Nama Kualifikasi';

  @override
  String get crud_eq_detail_category => 'Kategori';

  @override
  String get crud_eq_detail_validity => 'Masa Berlaku';

  @override
  String get crud_eq_detail_requires_renewal => 'Perlu Perpanjangan';

  @override
  String get crud_eq_detail_description => 'Deskripsi';

  @override
  String get crud_eq_detail_created_at => 'Dibuat Pada';

  @override
  String get crud_eq_yes => 'Ya';

  @override
  String get crud_eq_no => 'Tidak';

  @override
  String get crud_eq_form_code_hint => 'Contoh: STR, SIP, KLS, ACLS';

  @override
  String get crud_eq_form_name_hint =>
      'Contoh: Surat Tanda Registrasi, Sertifikasi ACLS';

  @override
  String get crud_eq_form_category_hint => 'Pilih kategori (opsional)';

  @override
  String get crud_eq_form_category_picker_title => 'Pilih Kategori';

  @override
  String get crud_eq_form_validity_hint => 'Contoh: 12 (opsional)';

  @override
  String get crud_eq_form_renewal_subtitle =>
      'Aktifkan jika kualifikasi ini perlu diperpanjang secara berkala';

  @override
  String get crud_eq_form_active_subtitle =>
      'Nonaktifkan jika kualifikasi ini tidak digunakan lagi';

  @override
  String get crud_eq_form_description_hint =>
      'Deskripsi singkat tentang kualifikasi ini (opsional)';

  @override
  String get crud_eq_form_preview_title => 'Preview';

  @override
  String get crud_eq_form_update_button => 'Update';

  @override
  String get crud_eq_form_save_button => 'Simpan';

  @override
  String get crud_eq_validation_code_required => 'Kode kualifikasi wajib diisi';

  @override
  String get crud_eq_validation_code_min => 'Kode minimal 2 karakter';

  @override
  String get crud_eq_validation_code_max => 'Kode maksimal 30 karakter';

  @override
  String get crud_eq_validation_name_required => 'Nama kualifikasi wajib diisi';

  @override
  String get crud_eq_validation_name_min => 'Nama minimal 2 karakter';

  @override
  String get crud_eq_validation_name_max => 'Nama maksimal 100 karakter';

  @override
  String get crud_eq_validation_validity_min => 'Masa berlaku minimal 1 bulan';

  @override
  String get crud_eq_validation_validity_max =>
      'Masa berlaku maksimal 120 bulan (10 tahun)';

  @override
  String get crud_eq_success_update => 'Kualifikasi berhasil diupdate';

  @override
  String get crud_eq_success_create => 'Kualifikasi berhasil ditambahkan';
}
