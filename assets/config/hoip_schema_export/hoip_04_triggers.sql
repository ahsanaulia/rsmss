-- ============================================
-- HOIP 5.0 TRIGGERS
-- Generated from existing database
-- ============================================

-- ASSET MANAGEMENT TRIGGERS
CREATE TRIGGER trg_update_asset_last_user
AFTER INSERT ON asset_assignments
FOR EACH ROW
EXECUTE FUNCTION fn_update_asset_last_user();

CREATE TRIGGER trg_update_asset_last_inspection
AFTER INSERT ON asset_inspections
FOR EACH ROW
EXECUTE FUNCTION fn_update_asset_last_inspection();

CREATE TRIGGER trg_after_asset_movement_insert
AFTER INSERT ON asset_movements
FOR EACH ROW
EXECUTE FUNCTION update_asset_last_pos();

-- BUILDING & FLOOR TRIGGERS
CREATE TRIGGER tr_buildings_created_by
BEFORE INSERT ON buildings
FOR EACH ROW
EXECUTE FUNCTION set_buildings_created_by();

CREATE TRIGGER tr_floors_created_by
BEFORE INSERT ON floors
FOR EACH ROW
EXECUTE FUNCTION set_floors_created_by();

-- EMPLOYEE MANAGEMENT TRIGGERS
CREATE TRIGGER trg_calc_leave_days
BEFORE INSERT OR UPDATE ON employee_leave_requests
FOR EACH ROW
EXECUTE FUNCTION fn_calc_leave_days();

CREATE TRIGGER trg_calc_qualification_expiry
BEFORE INSERT OR UPDATE ON employee_qualification_assignments
FOR EACH ROW
EXECUTE FUNCTION fn_calc_qualification_expiry();

CREATE TRIGGER trg_calculate_fatigue
BEFORE INSERT OR UPDATE ON employee_shift_rosters
FOR EACH ROW
EXECUTE FUNCTION fn_calculate_predicted_fatigue();

CREATE TRIGGER trg_wellbeing_alert
BEFORE INSERT OR UPDATE ON employee_wellbeing_logs
FOR EACH ROW
EXECUTE FUNCTION fn_check_wellbeing_alert();

-- PEOPLE & MOVEMENT TRIGGERS
CREATE TRIGGER trg_after_people_movement_insert
AFTER INSERT ON people_movements
FOR EACH ROW
EXECUTE FUNCTION update_people_last_pos();

CREATE TRIGGER trg_set_movement_status
BEFORE INSERT ON people_movements
FOR EACH ROW
EXECUTE FUNCTION fn_determine_movement_status();

-- PROFILE TRIGGERS
CREATE TRIGGER trg_set_join_year
BEFORE INSERT OR UPDATE ON profiles
FOR EACH ROW
EXECUTE FUNCTION fn_set_join_year();

-- REFERENCE TABLE TRIGGERS (created_by)
CREATE TRIGGER tr_ref_asset_categories_created_by
BEFORE INSERT ON ref_asset_categories
FOR EACH ROW
EXECUTE FUNCTION set_ref_asset_categories_created_by();

CREATE TRIGGER tr_ref_asset_sub_categories_created_by
BEFORE INSERT ON ref_asset_sub_categories
FOR EACH ROW
EXECUTE FUNCTION set_ref_asset_sub_categories_created_by();

CREATE TRIGGER tr_ref_asset_types_created_by
BEFORE INSERT ON ref_asset_types
FOR EACH ROW
EXECUTE FUNCTION set_ref_asset_types_created_by();

CREATE TRIGGER tr_ref_building_functions_created_by
BEFORE INSERT ON ref_building_functions
FOR EACH ROW
EXECUTE FUNCTION set_ref_building_functions_created_by();

CREATE TRIGGER tr_ref_room_categories_created_by
BEFORE INSERT ON ref_room_categories
FOR EACH ROW
EXECUTE FUNCTION set_ref_room_categories_created_by();

CREATE TRIGGER tr_ref_stock_categories_created_by
BEFORE INSERT ON ref_stock_categories
FOR EACH ROW
EXECUTE FUNCTION set_ref_stock_categories_created_by();

CREATE TRIGGER tr_ref_stock_sub_categories_created_by
BEFORE INSERT ON ref_stock_sub_categories
FOR EACH ROW
EXECUTE FUNCTION set_ref_stock_sub_categories_created_by();

CREATE TRIGGER tr_ref_stock_types_created_by
BEFORE INSERT ON ref_stock_types
FOR EACH ROW
EXECUTE FUNCTION set_ref_stock_types_created_by();

-- ROOM TRIGGERS
CREATE TRIGGER tr_rooms_created_by
BEFORE INSERT ON rooms
FOR EACH ROW
EXECUTE FUNCTION set_rooms_created_by();

-- STOCK MANAGEMENT TRIGGERS
CREATE TRIGGER tr_stock_bins_created_by
BEFORE INSERT ON stock_bins
FOR EACH ROW
EXECUTE FUNCTION set_stock_bins_created_by();

CREATE TRIGGER trigger_stock_in_qty
AFTER INSERT OR UPDATE OR DELETE ON stock_in
FOR EACH ROW
EXECUTE FUNCTION update_stock_in_qty();

CREATE TRIGGER trigger_current_stock_from_bins
AFTER INSERT OR UPDATE OR DELETE ON stock_in_bins
FOR EACH ROW
EXECUTE FUNCTION update_current_stock_from_bins();

CREATE TRIGGER trigger_update_stock_in_status
AFTER INSERT OR UPDATE OR DELETE ON stock_in_bins
FOR EACH ROW
EXECUTE FUNCTION update_stock_in_status();

CREATE TRIGGER tr_stock_racks_created_by
BEFORE INSERT ON stock_racks
FOR EACH ROW
EXECUTE FUNCTION set_stock_racks_created_by();

CREATE TRIGGER trigger_reduce_stock_in_bins
AFTER INSERT ON stock_request_fulfillments
FOR EACH ROW
EXECUTE FUNCTION reduce_stock_in_bins_quantity();

CREATE TRIGGER trigger_update_stock_request_fulfillment
AFTER INSERT OR UPDATE ON stock_request_fulfillments
FOR EACH ROW
EXECUTE FUNCTION update_stock_request_fulfillment();

CREATE TRIGGER trigger_update_status_on_approval
BEFORE UPDATE ON stock_requests
FOR EACH ROW
EXECUTE FUNCTION update_stock_request_status_on_approval();

CREATE TRIGGER tr_stock_shelves_created_by
BEFORE INSERT ON stock_shelves
FOR EACH ROW
EXECUTE FUNCTION set_stock_shelves_created_by();

CREATE TRIGGER tr_stock_warehouses_created_by
BEFORE INSERT ON stock_warehouses
FOR EACH ROW
EXECUTE FUNCTION set_stock_warehouses_created_by();

CREATE TRIGGER tr_stock_zones_created_by
BEFORE INSERT ON stock_zones
FOR EACH ROW
EXECUTE FUNCTION set_stock_zones_created_by();

CREATE TRIGGER trg_stock_opname_update
AFTER INSERT OR UPDATE ON stocks_opnames
FOR EACH ROW
EXECUTE FUNCTION fn_stock_opname_update();

-- AUTH TRIGGER (Supabase)
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION handle_new_user();