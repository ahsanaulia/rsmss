import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../models/hospital_profile_model.dart';
import 'tables/employee_table.dart';
import 'tables/tasks_table.dart';
import 'tables/announcements_table.dart';
import '../../crud/roster/presentation/pages/roster_page.dart';
import '../../crud/assets/presentation/pages/asset_list_page.dart';
import '../../crud/stocks/presentation/pages/stock_list_page.dart';
import '../../crud/ref_asset_categories/views/ref_asset_category_list.dart';
import '../../crud/ref_asset_sub_categories/views/ref_asset_sub_category_list.dart';
import '../../crud/ref_asset_types/views/ref_asset_type_list.dart';
import '../../crud/ref_stock_categories/views/ref_stock_category_list.dart';
import '../../crud/ref_stock_sub_categories/views/ref_stock_sub_category_list.dart';
import '../../crud/ref_stock_types/views/ref_stock_type_list.dart';
import '../../crud/ref_building_functions/views/ref_building_function_list.dart';
import '../../crud/buildings/views/building_list.dart';
import '../../crud/floors/views/floor_list.dart';
import '../../crud/rooms/views/room_list.dart';
import '../../crud/ref_room_categories/views/ref_room_category_list.dart';
import '../../features/asset_assignment/views/admin/admin_asset_verification_page.dart';
import '../../features/asset_report/views/asset_report_page.dart';
import '../../features/stock/views/stock_write_off_approval_page.dart';
import '../../features/stock/views/stock_mutation_view.dart';
import '../../features/stock_in/presentations/stock_in_list_screen.dart';
import '../../features/stock_in_bins/presentations/pending_put_away_admin_list.dart';

import '../../crud/stock_warehouses/views/stock_warehouse_list.dart';
import '../../crud/stock_zones/views/stock_zone_list.dart';
import '../../crud/stock_racks/views/stock_rack_list.dart';
import '../../crud/stock_shelves/views/stock_shelf_list.dart';
import '../../crud/stock_bins/views/stock_bin_list.dart';

import '../../crud/employee_qualifications/views/employee_qualification_list.dart';
import '../../crud/scoring_categories/views/scoring_category_list.dart';
import '../../crud/leave_types/views/leave_type_list.dart';
import '../../crud/ref_incident_categories/views/ref_incident_category_list.dart';
import '../../crud/employee_units/views/employee_unit_list.dart';
import '../../crud/ref_people_categories/views/ref_people_category_list.dart';
import '../../crud/ref_positions/views/ref_position_list.dart';
import '../../crud/ref_reports_category/views/ref_reports_category_list.dart';
// import '../../crud/admin_accidents/views/accident_list.dart';
import '../../crud/ref_shifts/views/ref_shift_list.dart';
// import '../../crud/admin_incidents/views/incident_list_admin.dart';
import '../../crud/todos/views/todo_list.dart';
import '../../crud/ref_asset_danger_levels/views/ref_asset_danger_level_list.dart';
import '../../crud/beds/views/bed_list_page.dart';
import '../../features/people/views/people_input_screen.dart';
import '../../features/bed_assignments/views/bed_assignment_screen.dart';
import '../../features/bed_unassignment/views/bed_unassignment_screen.dart';
import '../../features/people_checkout/views/people_checkout_screen.dart';
import '../../providers/locale_provider.dart';
import 'package:rsmss/l10n/app_localizations.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  final VoidCallback onLogout;

  const AdminDashboard({super.key, required this.onLogout});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  final _supabase = Supabase.instance.client;
  HospitalProfileModel? _hospitalProfile;
  bool _isSidebarVisible = true;
  final Color deepBlue = const Color(0xFF01579B);

  String _selectedMenu = "Data Pegawai";

  // Track expanded state untuk sub-menu
  final Set<String> _expandedSubMenus = {};

  late final List<MenuGroup> _menuGroups;

  final Set<String> _expandedGroups = {
    "MASTER DATA",
    "OPERASIONAL",
    "MANAJEMEN ASSET",
    "TABEL REFERENSI",
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _fetchHospitalProfile();
    _initMenuGroups();
  }

  void _initMenuGroups() {
    _menuGroups = [
      MenuGroup(
        title: "admin_sidebarMenuMasterData",
        icon: Icons.storage,
        menus: [
          MenuItem("admin_menuEmployees", Icons.people, EmployeeTable()),
          MenuItem(
            "admin_menuEmployeeQualifications",
            Icons.badge,
            const EmployeeQualificationListPage(),
          ),
          MenuItem(
            "admin_menuScoringCategories",
            Icons.score,
            const ScoringCategoryListPage(),
          ),
          MenuItem(
            "admin_menuLeaveTypes",
            Icons.calendar_today,
            const LeaveTypeListPage(),
          ),
          MenuItem(
            "admin_menuIncidentCategories",
            Icons.warning,
            const RefIncidentCategoryListPage(),
          ),
          MenuItem(
            "admin_menuPeopleCategories",
            Icons.people,
            const RefPeopleCategoryListPage(),
          ),
          MenuItem("admin_menuPositions", Icons.work, const RefPositionListPage()),
          MenuItem(
            "admin_menuReportCategories",
            Icons.description,
            const RefReportsCategoryListPage(),
          ),
          MenuItem(
            "admin_menuShifts",
            Icons.schedule,
            const RefShiftListPage(),
          ),
        ],
      ),
      MenuGroup(
        title: "admin_sidebarMenuAssetManagement",
        icon: Icons.inventory,
        menus: [
          MenuItem("admin_menuAssets", Icons.inventory_2, const AssetListPage()),
          MenuItem(
            "admin_menuAssetVerification",
            Icons.verified,
            const AdminAssetVerificationPage(),
          ),
          MenuItem("admin_menuAssetReport", Icons.receipt_long, const AssetReportPage()),
          MenuItem(
            "admin_menuBeds",
            Icons.bed,
            const BedListPage(),
          ),
        ],
      ),
      MenuGroup(
        title: "admin_sidebarMenuStockInventory",
        icon: Icons.inventory,
        menus: [
          MenuItem("admin_menuStockList", Icons.inventory_2, const StockListPage()),
          MenuItem("admin_menuStockIn", Icons.input, const StockInListScreen()),
          MenuItem(
            "admin_menuPendingPutAway",
            Icons.pending,
            const PendingPutAwayAdminList(),
          ),
          MenuItem(
            "admin_menuStockWriteOffApproval",
            Icons.check_circle,
            const StockWriteOffApprovalPage(),
          ),
          MenuItem(
            "admin_menuStockMutation",
            Icons.assignment_turned_in,
            const StockMutationView(),
          ),
        ],
      ),
      MenuGroup(
        title: "admin_sidebarMenuOperational",
        icon: Icons.work,
        menus: [
          MenuItem(
            "admin_menuPeopleRegistration",
            Icons.person_add_alt_1,
            const PeopleInputScreen(),
          ),
          MenuItem(
            "admin_menuBedAssignment",
            Icons.bed,
            const BedAssignmentScreen(),
          ),
          MenuItem(
            "admin_menuBedUnassignment",
            Icons.bed,
            const BedUnassignmentScreen(),
          ),
          MenuItem(
            "admin_menuPeopleCheckout",
            Icons.exit_to_app,
            const PeopleCheckoutScreen(),
          ),
          MenuItem("admin_menuRoster", Icons.calendar_today, const RosterPage()),
          MenuItem("admin_menuAnnouncements", Icons.assignment, AnnouncementsTable()),
          MenuItem("admin_menuTaskAssignment", Icons.assignment, TasksTable()),
          MenuItem("admin_menuTodo", Icons.checklist, const TodoListPage()),
        ],
      ),
      MenuGroup(
        title: "admin_sidebarMenuReferenceTables",
        icon: Icons.table_chart,
        subMenus: [
          SubMenuGroup(
            title: "admin_sidebarSubMenuAssetRef",
            icon: Icons.category,
            menus: [
              MenuItem(
                "admin_menuAssetCategories",
                Icons.category,
                const RefAssetCategoryListPage(),
              ),
              MenuItem(
                "admin_menuAssetSubCategories",
                Icons.subdirectory_arrow_right,
                const RefAssetSubCategoryListPage(),
              ),
              MenuItem("admin_menuAssetTypes", Icons.devices, const RefAssetTypeListPage()),
              MenuItem(
                "admin_menuAssetDangerLevels",
                Icons.warning_amber,
                const RefAssetDangerLevelListPage(),
              ),
            ],
          ),
          SubMenuGroup(
            title: "admin_sidebarSubMenuStockRef",
            icon: Icons.inventory_2,
            menus: [
              MenuItem(
                "admin_menuStockCategories",
                Icons.inventory_2,
                const RefStockCategoryListPage(),
              ),
              MenuItem(
                "admin_menuStockSubCategories",
                Icons.subdirectory_arrow_right,
                const RefStockSubCategoryListPage(),
              ),
              MenuItem("admin_menuStockTypes", Icons.label, const RefStockTypeListPage()),
            ],
          ),
          SubMenuGroup(
            title: "admin_sidebarSubMenuLocationHierarchy",
            icon: Icons.broadcast_on_personal_sharp,
            menus: [
              MenuItem(
                "admin_menuBuildingFunctions",
                Icons.functions_rounded,
                const RefBuildingFunctionListPage(),
              ),
              MenuItem(
                "admin_menuRoomCategories",
                Icons.room_preferences,
                const RefRoomCategoryListPage(),
              ),
              MenuItem(
                "admin_menuBuildings",
                Icons.business,
                const BuildingListPage(),
              ),
              MenuItem(
                "admin_menuFloors",
                Icons.format_list_numbered_rounded,
                const FloorListPage(),
              ),
              MenuItem("admin_menuRooms", Icons.room, const RoomListPage()),
            ],
          ),
          SubMenuGroup(
            title: "admin_sidebarSubMenuWarehouseHierarchy",
            icon: Icons.broadcast_on_personal_sharp,
            menus: [
              MenuItem("admin_menuWarehouses", Icons.warehouse, const StockWarehouseListPage()),
              MenuItem(
                "admin_menuZones",
                Icons.zoom_out_map_rounded,
                const StockZoneListPage(),
              ),
              MenuItem("admin_menuRooms", Icons.room, const RoomListPage()),
              MenuItem(
                "admin_menuRacks",
                Icons.archive_outlined,
                const StockRackListPage(),
              ),
              MenuItem(
                "admin_menuShelves",
                Icons.border_top_sharp,
                const StockShelfListPage(),
              ),
              MenuItem("admin_menuBins", Icons.inbox, const StockBinListPage()),
            ],
          ),
          SubMenuGroup(
            title: "admin_sidebarSubMenuGeneralRef",
            icon: Icons.location_on,
            menus: [
              MenuItem(
                "admin_menuUnits",
                Icons.business_center,
                const EmployeeUnitListPage(),
              ),
              MenuItem(
                "admin_menuEmployeeQualifications",
                Icons.badge,
                const EmployeeQualificationListPage(),
              ),
              MenuItem(
                "admin_menuScoringCategories",
                Icons.score,
                const ScoringCategoryListPage(),
              ),
              MenuItem(
                "admin_menuLeaveTypes",
                Icons.calendar_today,
                const LeaveTypeListPage(),
              ),
              MenuItem(
                "admin_menuIncidentCategories",
                Icons.warning,
                const RefIncidentCategoryListPage(),
              ),
              MenuItem(
                "admin_menuPeopleCategories",
                Icons.people,
                const RefPeopleCategoryListPage(),
              ),
              MenuItem("admin_menuPositions", Icons.work, const RefPositionListPage()),
              MenuItem(
                "admin_menuReportCategories",
                Icons.description,
                const RefReportsCategoryListPage(),
              ),
              MenuItem(
                "admin_menuShifts",
                Icons.schedule,
                const RefShiftListPage(),
              ),
            ],
          ),
        ],
      ),
      MenuGroup(
        title: "admin_sidebarMenuSystem",
        icon: Icons.settings,
        menus: [MenuItem("admin_menuLogout", Icons.logout, null, true)],
      ),
    ];
  }

  Future<void> _fetchHospitalProfile() async {
    try {
      final data = await _supabase
          .from('hospital_profile')
          .select()
          .maybeSingle();
      if (data != null && mounted) {
        setState(() {
          _hospitalProfile = HospitalProfileModel.fromJson(data);
        });
      }
    } catch (_) {}
  }

  void _handleLogout() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(localizations?.admin_logoutConfirmTitle ?? 'Confirm Logout'),
        content: Text(localizations?.admin_logoutConfirmContent ?? 'Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(localizations?.admin_logoutCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
              ]);
              widget.onLogout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(localizations?.admin_logoutConfirm ?? 'Logout'),
          ),
        ],
      ),
    );
  }

  void _toggleGroup(String groupTitle) {
    setState(() {
      if (_expandedGroups.contains(groupTitle)) {
        _expandedGroups.remove(groupTitle);
      } else {
        _expandedGroups.add(groupTitle);
      }
    });
  }

  void _toggleSubMenu(String subMenuTitle) {
    setState(() {
      if (_expandedSubMenus.contains(subMenuTitle)) {
        _expandedSubMenus.remove(subMenuTitle);
      } else {
        _expandedSubMenus.add(subMenuTitle);
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isSidebarVisible ? 260 : 0,
            child: _isSidebarVisible
                ? _buildSidebar()
                : const SizedBox.shrink(),
          ),
          Expanded(child: _buildMainCanvas()),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 260,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.95),
                Colors.white.withOpacity(0.85),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: deepBlue.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(4, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildSidebarHeader(),
              _buildHospitalBrand(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._menuGroups.map((group) => _buildMenuGroup(group)),
                      const SizedBox(height: 16),
                      _buildLanguageToggle(),
                      const SizedBox(height: 8),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    final currentLocale = ref.watch(localeProvider);
    final isEnglish = currentLocale.languageCode == 'en';
    final localizations = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: deepBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLangButton(
            langCode: 'en',
            label: 'EN',
            isActive: isEnglish,
            onTap: () => _changeLocale(const Locale('en')),
          ),
          const SizedBox(width: 4),
          _buildLangButton(
            langCode: 'id',
            label: 'ID',
            isActive: !isEnglish,
            onTap: () => _changeLocale(const Locale('id')),
          ),
        ],
      ),
    );
  }

  Widget _buildLangButton({
    required String langCode,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? deepBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : deepBlue,
          ),
        ),
      ),
    );
  }

  void _changeLocale(Locale locale) {
    ref.read(localeProvider.notifier).setLocale(locale);
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: deepBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.menu, size: 18, color: deepBlue),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isSidebarVisible = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.chevron_left, size: 24, color: deepBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGroup(MenuGroup group) {
    final isExpanded = _expandedGroups.contains(group.title);
    final localizations = AppLocalizations.of(context);
    
    final String displayTitle;
    switch (group.title) {
      case "admin_sidebarMenuMasterData":
        displayTitle = localizations?.admin_sidebarMenuMasterData ?? "MASTER DATA";
        break;
      case "admin_sidebarMenuAssetManagement":
        displayTitle = localizations?.admin_sidebarMenuAssetManagement ?? "ASSET MANAGEMENT";
        break;
      case "admin_sidebarMenuStockInventory":
        displayTitle = localizations?.admin_sidebarMenuStockInventory ?? "STOCK/INVENTORY MANAGEMENT";
        break;
      case "admin_sidebarMenuOperational":
        displayTitle = localizations?.admin_sidebarMenuOperational ?? "OPERATIONAL";
        break;
      case "admin_sidebarMenuReferenceTables":
        displayTitle = localizations?.admin_sidebarMenuReferenceTables ?? "REFERENCE TABLES";
        break;
      case "admin_sidebarMenuSystem":
        displayTitle = localizations?.admin_sidebarMenuSystem ?? "SYSTEM";
        break;
      default:
        displayTitle = group.title;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _toggleGroup(group.title),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: isExpanded
                  ? deepBlue.withOpacity(0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(group.icon, size: 18, color: deepBlue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    displayTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: deepBlue,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: deepBlue,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          if (group.subMenus.isNotEmpty)
            ...group.subMenus.map((subMenu) => _buildSubMenuGroup(subMenu)),
          if (group.menus.isNotEmpty)
            ...group.menus.map((menu) => _buildMenuItem(menu)),
        ],
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildSubMenuGroup(SubMenuGroup subMenu) {
    final isExpanded = _expandedSubMenus.contains(subMenu.title);
    final localizations = AppLocalizations.of(context);
    
    final String displayTitle;
    switch (subMenu.title) {
      case "admin_sidebarSubMenuAssetRef":
        displayTitle = localizations?.admin_sidebarSubMenuAssetRef ?? "ASSET REF";
        break;
      case "admin_sidebarSubMenuStockRef":
        displayTitle = localizations?.admin_sidebarSubMenuStockRef ?? "STOCK REF";
        break;
      case "admin_sidebarSubMenuLocationHierarchy":
        displayTitle = localizations?.admin_sidebarSubMenuLocationHierarchy ?? "LOCATION HIERARCHY";
        break;
      case "admin_sidebarSubMenuWarehouseHierarchy":
        displayTitle = localizations?.admin_sidebarSubMenuWarehouseHierarchy ?? "WAREHOUSE HIERARCHY";
        break;
      case "admin_sidebarSubMenuGeneralRef":
        displayTitle = localizations?.admin_sidebarSubMenuGeneralRef ?? "GENERAL & EMPLOYEE REF";
        break;
      default:
        displayTitle = subMenu.title;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _toggleSubMenu(subMenu.title),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: isExpanded
                  ? deepBlue.withOpacity(0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(subMenu.icon, size: 16, color: deepBlue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    displayTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: deepBlue,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: deepBlue,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Column(
            children: subMenu.menus
                .map((menu) => _buildMenuItem(menu, indent: 48))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildMenuItem(MenuItem menu, {double indent = 30}) {
    final isSelected = _selectedMenu == menu.title;
    final isLogout = menu.isLogout;
    final localizations = AppLocalizations.of(context);
    
    String displayTitle;
    switch (menu.title) {
      case "admin_menuEmployees":
        displayTitle = localizations?.admin_menuEmployees ?? "Employees Data";
        break;
      case "admin_menuEmployeeQualifications":
        displayTitle = localizations?.admin_menuEmployeeQualifications ?? "Employee Qualifications";
        break;
      case "admin_menuScoringCategories":
        displayTitle = localizations?.admin_menuScoringCategories ?? "Scoring Categories";
        break;
      case "admin_menuLeaveTypes":
        displayTitle = localizations?.admin_menuLeaveTypes ?? "Leave Types";
        break;
      case "admin_menuIncidentCategories":
        displayTitle = localizations?.admin_menuIncidentCategories ?? "Incident Categories";
        break;
      case "admin_menuPeopleCategories":
        displayTitle = localizations?.admin_menuPeopleCategories ?? "People Categories";
        break;
      case "admin_menuPositions":
        displayTitle = localizations?.admin_menuPositions ?? "Positions";
        break;
      case "admin_menuReportCategories":
        displayTitle = localizations?.admin_menuReportCategories ?? "Report Categories";
        break;
      case "admin_menuShifts":
        displayTitle = localizations?.admin_menuShifts ?? "Shifts";
        break;
      case "admin_menuAssets":
        displayTitle = localizations?.admin_menuAssets ?? "Assets";
        break;
      case "admin_menuAssetVerification":
        displayTitle = localizations?.admin_menuAssetVerification ?? "Asset Usage Verification";
        break;
      case "admin_menuAssetReport":
        displayTitle = localizations?.admin_menuAssetReport ?? "Asset Report";
        break;
      case "admin_menuBeds":
        displayTitle = localizations?.admin_menuBeds ?? "Bed Management";
        break;
      case "admin_menuStockList":
        displayTitle = localizations?.admin_menuStockList ?? "Stock List";
        break;
      case "admin_menuStockIn":
        displayTitle = localizations?.admin_menuStockIn ?? "Stock In";
        break;
      case "admin_menuPendingPutAway":
        displayTitle = localizations?.admin_menuPendingPutAway ?? "Pending Put Away";
        break;
      case "admin_menuStockWriteOffApproval":
        displayTitle = localizations?.admin_menuStockWriteOffApproval ?? "Stock Write Off Approval";
        break;
      case "admin_menuStockMutation":
        displayTitle = localizations?.admin_menuStockMutation ?? "Stock Mutation";
        break;
      case "admin_menuPeopleRegistration":
        displayTitle = localizations?.admin_menuPeopleRegistration ?? "People & RFID Registration";
        break;
      case "admin_menuBedAssignment":
        displayTitle = localizations?.admin_menuBedAssignment ?? "Patient Bed Assignment";
        break;
      case "admin_menuBedUnassignment":
        displayTitle = localizations?.admin_menuBedUnassignment ?? "Bed Unassignment";
        break;
      case "admin_menuPeopleCheckout":
        displayTitle = localizations?.admin_menuPeopleCheckout ?? "People Checkout (RFID)";
        break;
      case "admin_menuRoster":
        displayTitle = localizations?.admin_menuRoster ?? "Employee Scheduling";
        break;
      case "admin_menuAnnouncements":
        displayTitle = localizations?.admin_menuAnnouncements ?? "Employee Announcements";
        break;
      case "admin_menuTaskAssignment":
        displayTitle = localizations?.admin_menuTaskAssignment ?? "Task Assignment";
        break;
      case "admin_menuTodo":
        displayTitle = localizations?.admin_menuTodo ?? "To Do";
        break;
      case "admin_menuAssetCategories":
        displayTitle = localizations?.admin_menuAssetCategories ?? "Asset Categories";
        break;
      case "admin_menuAssetSubCategories":
        displayTitle = localizations?.admin_menuAssetSubCategories ?? "Asset Sub-Categories";
        break;
      case "admin_menuAssetTypes":
        displayTitle = localizations?.admin_menuAssetTypes ?? "Asset Types";
        break;
      case "admin_menuAssetDangerLevels":
        displayTitle = localizations?.admin_menuAssetDangerLevels ?? "Asset Danger Levels";
        break;
      case "admin_menuStockCategories":
        displayTitle = localizations?.admin_menuStockCategories ?? "Stock Categories";
        break;
      case "admin_menuStockSubCategories":
        displayTitle = localizations?.admin_menuStockSubCategories ?? "Stock Sub-Categories";
        break;
      case "admin_menuStockTypes":
        displayTitle = localizations?.admin_menuStockTypes ?? "Stock Types";
        break;
      case "admin_menuBuildingFunctions":
        displayTitle = localizations?.admin_menuBuildingFunctions ?? "Building Functions";
        break;
      case "admin_menuRoomCategories":
        displayTitle = localizations?.admin_menuRoomCategories ?? "Room Categories";
        break;
      case "admin_menuBuildings":
        displayTitle = localizations?.admin_menuBuildings ?? "Buildings";
        break;
      case "admin_menuFloors":
        displayTitle = localizations?.admin_menuFloors ?? "Floors";
        break;
      case "admin_menuRooms":
        displayTitle = localizations?.admin_menuRooms ?? "Rooms";
        break;
      case "admin_menuWarehouses":
        displayTitle = localizations?.admin_menuWarehouses ?? "Warehouses";
        break;
      case "admin_menuZones":
        displayTitle = localizations?.admin_menuZones ?? "Storage Zones";
        break;
      case "admin_menuRacks":
        displayTitle = localizations?.admin_menuRacks ?? "Racks";
        break;
      case "admin_menuShelves":
        displayTitle = localizations?.admin_menuShelves ?? "Shelves";
        break;
      case "admin_menuBins":
        displayTitle = localizations?.admin_menuBins ?? "Bins";
        break;
      case "admin_menuUnits":
        displayTitle = localizations?.admin_menuUnits ?? "Units/Departments";
        break;
      case "admin_menuLogout":
        displayTitle = localizations?.admin_menuLogout ?? "Logout";
        break;
      default:
        displayTitle = menu.title;
    }

    return GestureDetector(
      onTap: () {
        if (isLogout) {
          _handleLogout();
        } else {
          setState(() {
            _selectedMenu = menu.title;
          });
        }
      },
      child: Container(
        margin: EdgeInsets.only(left: indent, bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? deepBlue.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              menu.icon,
              size: 16,
              color: isLogout
                  ? Colors.red
                  : (isSelected ? deepBlue : Colors.grey.shade600),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                displayTitle,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isLogout
                      ? Colors.red
                      : (isSelected ? deepBlue : Colors.grey.shade800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalBrand() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: deepBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                _hospitalProfile?.logoUrl != null &&
                    _hospitalProfile!.logoUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _hospitalProfile!.logoUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.local_hospital,
                          color: deepBlue,
                          size: 32,
                        );
                      },
                    ),
                  )
                : Icon(Icons.local_hospital, color: deepBlue, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            _hospitalProfile?.name ?? 'HOSPITAL SYSTEM',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: deepBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final localizations = AppLocalizations.of(context);
    return Center(
      child: Column(
        children: [
          Text(
            localizations?.admin_footerDevelopedBy ?? "Developed By: PLATFORM PELAYANAN TERBAIK",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 7,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            localizations?.admin_footerDistributedBy ?? "Distributed By: PT. REKAMITRA",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 7,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            localizations?.admin_footerYearCountry ?? "2026 - Indonesia",
            style: GoogleFonts.poppins(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMainCanvas() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0F2F1), Color(0xFFB3E5FC), Color(0xFF81D4FA)],
        ),
      ),
      child: Stack(
        children: [
          Padding(padding: const EdgeInsets.all(16), child: _getBody()),
          if (!_isSidebarVisible)
            Positioned(
              top: 20,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isSidebarVisible = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: deepBlue,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.menu, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _getBody() {
    final localizations = AppLocalizations.of(context);
    // Cari menu yang dipilih dari semua group dan subMenu
    for (var group in _menuGroups) {
      for (var menu in group.menus) {
        if (menu.title == _selectedMenu && menu.widget != null) {
          return _buildContentContainer(menu.widget!);
        }
      }
      for (var subMenu in group.subMenus) {
        for (var menu in subMenu.menus) {
          if (menu.title == _selectedMenu && menu.widget != null) {
            return _buildContentContainer(menu.widget!);
          }
        }
      }
    }
    return Center(
      child: Text(localizations?.admin_selectMenuHint ?? "Pilih menu dari sidebar"),
    );
  }

  Widget _buildContentContainer(Widget widget) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(20), child: widget),
    );
  }
}

// ======================
// MODEL CLASSES
// ======================

class MenuGroup {
  final String title;
  final IconData icon;
  final List<MenuItem> menus;
  final List<SubMenuGroup> subMenus;

  MenuGroup({
    required this.title,
    required this.icon,
    this.menus = const [],
    this.subMenus = const [],
  });
}

class SubMenuGroup {
  final String title;
  final IconData icon;
  final List<MenuItem> menus;

  SubMenuGroup({required this.title, required this.icon, required this.menus});
}

class MenuItem {
  final String title;
  final IconData icon;
  final Widget? widget;
  final bool isLogout;

  MenuItem(this.title, this.icon, this.widget, [this.isLogout = false]);
}