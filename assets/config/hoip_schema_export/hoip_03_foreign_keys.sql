[
  {
    "fk_ddl": "ALTER TABLE announcements ADD CONSTRAINT ann_building_fkey FOREIGN KEY (target_building_id) REFERENCES ref_building_functions(id);"
  },
  {
    "fk_ddl": "ALTER TABLE announcements ADD CONSTRAINT ann_sender_fkey FOREIGN KEY (sender_id) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE announcements ADD CONSTRAINT announcements_target_unit_id_fkey FOREIGN KEY (target_unit_id) REFERENCES employee_units(id);"
  },
  {
    "fk_ddl": "ALTER TABLE announcements ADD CONSTRAINT ann_profile_fkey FOREIGN KEY (target_profile_id) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE announcements ADD CONSTRAINT ann_position_fkey FOREIGN KEY (target_position_id) REFERENCES ref_positions(id);"
  },
  {
    "fk_ddl": "ALTER TABLE announcements ADD CONSTRAINT ann_room_fkey FOREIGN KEY (target_room_id) REFERENCES rooms(id);"
  },
  {
    "fk_ddl": "ALTER TABLE announcements ADD CONSTRAINT ann_floor_fkey FOREIGN KEY (target_floor_id) REFERENCES floors(id);"
  },
  {
    "fk_ddl": "ALTER TABLE asset_assignments ADD CONSTRAINT fk_assigned_by FOREIGN KEY (assigned_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE asset_assignments ADD CONSTRAINT fk_return_location FOREIGN KEY (return_location_id) REFERENCES rooms(id);"
  },
  {
    "fk_ddl": "ALTER TABLE asset_assignments ADD CONSTRAINT fk_asset FOREIGN KEY (asset_id) REFERENCES assets(id);"
  },
  {
    "fk_ddl": "ALTER TABLE asset_assignments ADD CONSTRAINT fk_profile FOREIGN KEY (profile_id) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE asset_assignments ADD CONSTRAINT fk_created_by FOREIGN KEY (created_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE asset_assignments ADD CONSTRAINT fk_handover_location FOREIGN KEY (handover_location_id) REFERENCES rooms(id);"
  },
  {
    "fk_ddl": "ALTER TABLE asset_inspections ADD CONSTRAINT fk_asset_inspection_task FOREIGN KEY (task_id) REFERENCES tasks(id);"
  },
  {
    "fk_ddl": "ALTER TABLE asset_inspections ADD CONSTRAINT fk_asset_inspection_profile FOREIGN KEY (inspected_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE asset_inspections ADD CONSTRAINT fk_asset_inspection_asset FOREIGN KEY (asset_id) REFERENCES assets(id);"
  },
  {
    "fk_ddl": "ALTER TABLE asset_movements ADD CONSTRAINT asset_movements_asset_fkey FOREIGN KEY (asset_id) REFERENCES assets(id);"
  },
  {
    "fk_ddl": "ALTER TABLE asset_movements ADD CONSTRAINT asset_movements_detector_fkey FOREIGN KEY (detector_id) REFERENCES detectors(id);"
  },
  {
    "fk_ddl": "ALTER TABLE assets ADD CONSTRAINT assets_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE assets ADD CONSTRAINT assets_last_detector_id_fkey FOREIGN KEY (last_detector_id) REFERENCES detectors(id);"
  },
  {
    "fk_ddl": "ALTER TABLE assets ADD CONSTRAINT assets_last_used_by_fkey FOREIGN KEY (last_used_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE assets ADD CONSTRAINT assets_last_inspection_id_fkey FOREIGN KEY (last_inspection_id) REFERENCES asset_inspections(id);"
  },
  {
    "fk_ddl": "ALTER TABLE assets ADD CONSTRAINT assets_type_fkey FOREIGN KEY (type_id) REFERENCES ref_asset_types(id);"
  },
  {
    "fk_ddl": "ALTER TABLE assets ADD CONSTRAINT assets_registered_by_fkey FOREIGN KEY (registered_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE assets ADD CONSTRAINT assets_last_room_id_fkey FOREIGN KEY (last_room_id) REFERENCES rooms(id);"
  },
  {
    "fk_ddl": "ALTER TABLE attendance ADD CONSTRAINT attendance_location_fkey FOREIGN KEY (location_check_in) REFERENCES rooms(id);"
  },
  {
    "fk_ddl": "ALTER TABLE attendance ADD CONSTRAINT attendance_profile_fkey FOREIGN KEY (profile_id) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE attendance ADD CONSTRAINT attendance_shift_fkey FOREIGN KEY (shift_id) REFERENCES ref_shifts(id);"
  },
  {
    "fk_ddl": "ALTER TABLE attendance ADD CONSTRAINT attendance_roster_id_fkey FOREIGN KEY (roster_id) REFERENCES employee_shift_rosters(id);"
  },
  {
    "fk_ddl": "ALTER TABLE buildings ADD CONSTRAINT buildings_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES hospital_profile(id);"
  },
  {
    "fk_ddl": "ALTER TABLE buildings ADD CONSTRAINT buildings_app_id_fkey FOREIGN KEY (app_id) REFERENCES apps_config(id);"
  },
  {
    "fk_ddl": "ALTER TABLE buildings ADD CONSTRAINT buildings_function_id_fkey FOREIGN KEY (function_id) REFERENCES ref_building_functions(id);"
  },
  {
    "fk_ddl": "ALTER TABLE detectors ADD CONSTRAINT detectors_room_fkey FOREIGN KEY (room_id) REFERENCES rooms(id);"
  },
  {
    "fk_ddl": "ALTER TABLE duty_notes ADD CONSTRAINT duty_notes_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE duty_notes ADD CONSTRAINT duty_notes_attendance_id_fkey FOREIGN KEY (attendance_id) REFERENCES attendance(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_leave_requests ADD CONSTRAINT employee_leave_requests_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_leave_requests ADD CONSTRAINT employee_leave_requests_created_by_fkey FOREIGN KEY (created_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_leave_requests ADD CONSTRAINT employee_leave_requests_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_leave_requests ADD CONSTRAINT employee_leave_requests_leave_type_id_fkey FOREIGN KEY (leave_type_id) REFERENCES leave_types(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_location_tracking ADD CONSTRAINT employee_location_tracking_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_location_tracking ADD CONSTRAINT fk_location_profile FOREIGN KEY (profile_id) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_qualification_assignments ADD CONSTRAINT employee_qualification_assignments_qualification_id_fkey FOREIGN KEY (qualification_id) REFERENCES employee_qualifications(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_qualification_assignments ADD CONSTRAINT employee_qualification_assignments_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_qualification_assignments ADD CONSTRAINT employee_qualification_assignments_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_scoring ADD CONSTRAINT employee_scoring_calculated_by_fkey FOREIGN KEY (calculated_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_scoring ADD CONSTRAINT employee_scoring_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_scoring ADD CONSTRAINT employee_scoring_scoring_category_id_fkey FOREIGN KEY (scoring_category_id) REFERENCES scoring_categories(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_shift_rosters ADD CONSTRAINT fk_employee_shift_profile FOREIGN KEY (profile_id) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_shift_rosters ADD CONSTRAINT employee_shift_rosters_location_room_id_fkey FOREIGN KEY (location_room_id) REFERENCES rooms(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_shift_rosters ADD CONSTRAINT fk_employee_shift_created_by FOREIGN KEY (created_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_shift_rosters ADD CONSTRAINT fk_employee_shift_approved_by FOREIGN KEY (approved_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_shift_rosters ADD CONSTRAINT fk_employee_shift_shift FOREIGN KEY (shift_id) REFERENCES ref_shifts(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_shift_rosters ADD CONSTRAINT employee_shift_rosters_leave_request_id_fkey FOREIGN KEY (leave_request_id) REFERENCES employee_leave_requests(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_units ADD CONSTRAINT employee_units_parent_unit_id_fkey FOREIGN KEY (parent_unit_id) REFERENCES employee_units(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_units ADD CONSTRAINT employee_units_head_of_unit_id_fkey FOREIGN KEY (head_of_unit_id) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE employee_wellbeing_logs ADD CONSTRAINT fk_wellbeing_profile FOREIGN KEY (profile_id) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE floors ADD CONSTRAINT floors_app_id_fkey FOREIGN KEY (app_id) REFERENCES apps_config(id);"
  },
  {
    "fk_ddl": "ALTER TABLE floors ADD CONSTRAINT floors_building_id_fkey FOREIGN KEY (building_id) REFERENCES buildings(id);"
  },
  {
    "fk_ddl": "ALTER TABLE hospital_profile ADD CONSTRAINT hospital_profile_app_id_fkey FOREIGN KEY (app_id) REFERENCES apps_config(id);"
  },
  {
    "fk_ddl": "ALTER TABLE incidents ADD CONSTRAINT incidents_action_taken_by_fkey FOREIGN KEY (action_taken_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE incidents ADD CONSTRAINT incidents_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE incidents ADD CONSTRAINT incidents_category_id_fkey FOREIGN KEY (category_id) REFERENCES ref_incident_categories(id);"
  },
  {
    "fk_ddl": "ALTER TABLE incidents ADD CONSTRAINT incidents_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE incidents ADD CONSTRAINT incidents_room_id_fkey FOREIGN KEY (room_id) REFERENCES rooms(id);"
  },
  {
    "fk_ddl": "ALTER TABLE people ADD CONSTRAINT people_category_id_fkey FOREIGN KEY (category_id) REFERENCES ref_people_categories(id);"
  },
  {
    "fk_ddl": "ALTER TABLE people ADD CONSTRAINT people_last_detector_id_fkey FOREIGN KEY (last_detector_id) REFERENCES detectors(id);"
  },
  {
    "fk_ddl": "ALTER TABLE people ADD CONSTRAINT people_last_room_id_fkey FOREIGN KEY (last_room_id) REFERENCES rooms(id);"
  },
  {
    "fk_ddl": "ALTER TABLE people_movements ADD CONSTRAINT pm_rfid_fkey FOREIGN KEY (rfid_tag_id) REFERENCES people(rfid_tag_id);"
  },
  {
    "fk_ddl": "ALTER TABLE people_movements ADD CONSTRAINT pm_detector_fkey FOREIGN KEY (detector_id) REFERENCES detectors(id);"
  },
  {
    "fk_ddl": "ALTER TABLE profiles ADD CONSTRAINT profiles_default_shift_id_fkey FOREIGN KEY (default_shift_id) REFERENCES ref_shifts(id);"
  },
  {
    "fk_ddl": "ALTER TABLE profiles ADD CONSTRAINT profiles_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES employee_units(id);"
  },
  {
    "fk_ddl": "ALTER TABLE profiles ADD CONSTRAINT profiles_position_id_fkey FOREIGN KEY (position_id) REFERENCES ref_positions(id);"
  },
  {
    "fk_ddl": "ALTER TABLE ref_asset_sub_categories ADD CONSTRAINT ref_asset_sub_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES ref_asset_categories(id);"
  },
  {
    "fk_ddl": "ALTER TABLE ref_asset_types ADD CONSTRAINT ref_asset_types_sub_category_id_fkey FOREIGN KEY (sub_category_id) REFERENCES ref_asset_sub_categories(id);"
  },
  {
    "fk_ddl": "ALTER TABLE ref_building_functions ADD CONSTRAINT ref_building_functions_app_id_fkey FOREIGN KEY (app_id) REFERENCES apps_config(id);"
  },
  {
    "fk_ddl": "ALTER TABLE ref_room_categories ADD CONSTRAINT ref_room_categories_app_id_fkey FOREIGN KEY (app_id) REFERENCES apps_config(id);"
  },
  {
    "fk_ddl": "ALTER TABLE ref_stock_sub_categories ADD CONSTRAINT ref_stock_sub_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES ref_stock_categories(id);"
  },
  {
    "fk_ddl": "ALTER TABLE ref_stock_types ADD CONSTRAINT ref_stock_types_sub_category_id_fkey FOREIGN KEY (sub_category_id) REFERENCES ref_stock_sub_categories(id);"
  },
  {
    "fk_ddl": "ALTER TABLE rooms ADD CONSTRAINT rooms_category_id_fkey FOREIGN KEY (category_id) REFERENCES ref_room_categories(id);"
  },
  {
    "fk_ddl": "ALTER TABLE rooms ADD CONSTRAINT rooms_floor_id_fkey FOREIGN KEY (floor_id) REFERENCES floors(id);"
  },
  {
    "fk_ddl": "ALTER TABLE rooms ADD CONSTRAINT rooms_app_id_fkey FOREIGN KEY (app_id) REFERENCES apps_config(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_bins ADD CONSTRAINT stock_bins_shelf_id_fkey FOREIGN KEY (shelf_id) REFERENCES stock_shelves(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_bins ADD CONSTRAINT stock_bins_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES assets(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_in ADD CONSTRAINT stock_in_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_in ADD CONSTRAINT stock_in_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES stocks(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_in ADD CONSTRAINT stock_in_received_by_fkey FOREIGN KEY (received_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_in_bins ADD CONSTRAINT stock_in_bins_bin_id_fkey FOREIGN KEY (bin_id) REFERENCES stock_bins(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_in_bins ADD CONSTRAINT stock_in_bins_put_away_by_fkey FOREIGN KEY (put_away_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_in_bins ADD CONSTRAINT stock_in_bins_stock_in_id_fkey FOREIGN KEY (stock_in_id) REFERENCES stock_in(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_in_bins ADD CONSTRAINT stock_in_bins_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES stocks(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_in_entries ADD CONSTRAINT stock_in_entries_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_in_entries ADD CONSTRAINT stock_in_entries_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES stocks(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_in_entries ADD CONSTRAINT stock_in_entries_received_bin_id_fkey FOREIGN KEY (received_bin_id) REFERENCES stock_bins(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_in_entries ADD CONSTRAINT stock_in_entries_current_bin_id_fkey FOREIGN KEY (current_bin_id) REFERENCES stock_bins(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_in_entries ADD CONSTRAINT stock_in_entries_received_by_fkey FOREIGN KEY (received_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_in_entries ADD CONSTRAINT stock_in_entries_returned_by_fkey FOREIGN KEY (returned_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_in_entries ADD CONSTRAINT stock_in_entries_put_away_by_fkey FOREIGN KEY (put_away_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_mutations ADD CONSTRAINT stock_mutations_bin_id_asal_fkey FOREIGN KEY (bin_id_asal) REFERENCES stock_bins(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_mutations ADD CONSTRAINT stock_mutations_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES stocks(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_mutations ADD CONSTRAINT stock_mutations_moved_by_fkey FOREIGN KEY (moved_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_mutations ADD CONSTRAINT stock_mutations_received_by_fkey FOREIGN KEY (received_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_mutations ADD CONSTRAINT stock_mutations_stock_in_bins_id_fkey FOREIGN KEY (stock_in_bins_id) REFERENCES stock_in_bins(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_mutations ADD CONSTRAINT stock_mutations_bin_id_tujuan_fkey FOREIGN KEY (bin_id_tujuan) REFERENCES stock_bins(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_racks ADD CONSTRAINT stock_racks_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES stock_zones(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_request_fulfillments ADD CONSTRAINT stock_request_fulfillments_bin_id_fkey FOREIGN KEY (bin_id) REFERENCES stock_bins(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_request_fulfillments ADD CONSTRAINT stock_request_fulfillments_stock_request_id_fkey FOREIGN KEY (stock_request_id) REFERENCES stock_requests(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_request_fulfillments ADD CONSTRAINT stock_request_fulfillments_stock_in_bins_id_fkey FOREIGN KEY (stock_in_bins_id) REFERENCES stock_in_bins(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_request_fulfillments ADD CONSTRAINT stock_request_fulfillments_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES stocks(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_request_fulfillments ADD CONSTRAINT stock_request_fulfillments_taken_by_fkey FOREIGN KEY (taken_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_requests ADD CONSTRAINT stock_requests_requested_stock_id_fkey FOREIGN KEY (requested_stock_id) REFERENCES stocks(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_requests ADD CONSTRAINT stock_requests_requester_id_fkey FOREIGN KEY (requester_id) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_requests ADD CONSTRAINT stock_requests_room_id_fkey FOREIGN KEY (room_id) REFERENCES rooms(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_requests ADD CONSTRAINT stock_requests_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_requests ADD CONSTRAINT stock_requests_approved_stock_id_fkey FOREIGN KEY (approved_stock_id) REFERENCES stocks(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_requests ADD CONSTRAINT stock_requests_rejected_by_fkey FOREIGN KEY (rejected_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_shelves ADD CONSTRAINT stock_shelves_rack_id_fkey FOREIGN KEY (rack_id) REFERENCES stock_racks(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_transactions ADD CONSTRAINT stock_transactions_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES stocks(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_transactions ADD CONSTRAINT stock_transactions_created_by_fkey FOREIGN KEY (created_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_warehouses ADD CONSTRAINT stock_warehouses_floor_id_fkey FOREIGN KEY (floor_id) REFERENCES floors(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_warehouses ADD CONSTRAINT stock_warehouses_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_write_offs ADD CONSTRAINT stock_write_offs_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_write_offs ADD CONSTRAINT stock_write_offs_stock_in_bins_id_fkey FOREIGN KEY (stock_in_bins_id) REFERENCES stock_in_bins(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_write_offs ADD CONSTRAINT stock_write_offs_bin_id_fkey FOREIGN KEY (bin_id) REFERENCES stock_bins(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_write_offs ADD CONSTRAINT stock_write_offs_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES stocks(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_zones ADD CONSTRAINT stock_zones_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES stock_warehouses(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stock_zones ADD CONSTRAINT stock_zones_room_id_fkey FOREIGN KEY (room_id) REFERENCES rooms(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stocks ADD CONSTRAINT stocks_storage_location_id_fkey FOREIGN KEY (storage_location_id) REFERENCES storage_locations(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stocks ADD CONSTRAINT stocks_stock_type_id_fkey FOREIGN KEY (stock_type_id) REFERENCES ref_stock_types(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stocks ADD CONSTRAINT stocks_created_by_fkey FOREIGN KEY (created_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stocks ADD CONSTRAINT stocks_last_usage_by_fkey FOREIGN KEY (last_usage_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stocks ADD CONSTRAINT stocks_last_purchase_by_fkey FOREIGN KEY (last_purchase_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stocks ADD CONSTRAINT stocks_last_opname_by_fkey FOREIGN KEY (last_opname_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stocks_opnames ADD CONSTRAINT stocks_opnames_bin_id_fkey FOREIGN KEY (bin_id) REFERENCES stock_bins(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stocks_opnames ADD CONSTRAINT stocks_opnames_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES stocks(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stocks_opnames ADD CONSTRAINT stocks_opnames_opname_by_fkey FOREIGN KEY (opname_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE stocks_opnames ADD CONSTRAINT stocks_opnames_stock_in_bins_id_fkey FOREIGN KEY (stock_in_bins_id) REFERENCES stock_in_bins(id);"
  },
  {
    "fk_ddl": "ALTER TABLE tasks ADD CONSTRAINT tasks_stock_fkey FOREIGN KEY (stock_id) REFERENCES stocks(id);"
  },
  {
    "fk_ddl": "ALTER TABLE tasks ADD CONSTRAINT tasks_to_room_fkey FOREIGN KEY (to_room_id) REFERENCES rooms(id);"
  },
  {
    "fk_ddl": "ALTER TABLE tasks ADD CONSTRAINT tasks_from_room_fkey FOREIGN KEY (from_room_id) REFERENCES rooms(id);"
  },
  {
    "fk_ddl": "ALTER TABLE tasks ADD CONSTRAINT tasks_type_fkey FOREIGN KEY (type_id) REFERENCES ref_task_types(id);"
  },
  {
    "fk_ddl": "ALTER TABLE tasks ADD CONSTRAINT tasks_assignee_fkey FOREIGN KEY (assignee_id) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE tasks ADD CONSTRAINT tasks_related_profile_fkey FOREIGN KEY (related_profile_id) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE tasks ADD CONSTRAINT tasks_asset_fkey FOREIGN KEY (asset_id) REFERENCES assets(id);"
  },
  {
    "fk_ddl": "ALTER TABLE tasks ADD CONSTRAINT tasks_created_by_fkey FOREIGN KEY (created_by) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE tasks_reports ADD CONSTRAINT tr_room_fkey FOREIGN KEY (at_room_id) REFERENCES rooms(id);"
  },
  {
    "fk_ddl": "ALTER TABLE tasks_reports ADD CONSTRAINT tr_reporter_fkey FOREIGN KEY (reporter_id) REFERENCES profiles(id);"
  },
  {
    "fk_ddl": "ALTER TABLE tasks_reports ADD CONSTRAINT tr_category_fkey FOREIGN KEY (category_id) REFERENCES ref_reports_category(id);"
  },
  {
    "fk_ddl": "ALTER TABLE tasks_reports ADD CONSTRAINT tr_task_fkey FOREIGN KEY (task_id) REFERENCES tasks(id);"
  }
]