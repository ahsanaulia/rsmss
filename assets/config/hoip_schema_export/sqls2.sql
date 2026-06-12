-- ============================================================
-- RSMSS HOIP 5.0 - TENANT DATABASE TEMPLATE
-- ============================================================
-- File ini untuk membuat database tenant baru dari nol
-- Jalankan di Supabase SQL Editor project baru
-- ============================================================

-- ============================================================
-- 1. ENABLE EXTENSIONS
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "postgis_topology";

-- ============================================================
-- 2. CREATE TABLES (Urutan berdasarkan Foreign Key dependency)
-- ============================================================

-- 2.1 APPS CONFIG (Master konfigurasi tenant)
CREATE TABLE public.apps_config (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    client_name character varying NOT NULL,
    license_key character varying NOT NULL UNIQUE,
    supabase_url text NOT NULL,
    supabase_anon_key text NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT apps_config_pkey PRIMARY KEY (id)
);

-- 2.2 REFERENCE TABLES (Master data)
CREATE TABLE public.ref_building_functions (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    app_id uuid,
    function_name character varying NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    CONSTRAINT ref_building_functions_pkey PRIMARY KEY (id),
    CONSTRAINT ref_building_functions_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps_config(id)
);

CREATE TABLE public.ref_room_categories (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    app_id uuid,
    category_name character varying NOT NULL,
    color_code character varying,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    icon_name character varying,
    marker_color text,
    CONSTRAINT ref_room_categories_pkey PRIMARY KEY (id),
    CONSTRAINT ref_room_categories_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps_config(id)
);

CREATE TABLE public.hospital_profile (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    app_id uuid,
    name character varying NOT NULL,
    address text,
    logo_url text,
    contact_center character varying,
    total_buildings integer DEFAULT 1,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT hospital_profile_pkey PRIMARY KEY (id),
    CONSTRAINT hospital_profile_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps_config(id)
);

CREATE TABLE public.buildings (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    app_id uuid,
    hospital_id uuid,
    building_name character varying NOT NULL,
    function_id uuid,
    total_floors integer DEFAULT 1,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    latitude double precision,
    longitude double precision,
    CONSTRAINT buildings_pkey PRIMARY KEY (id),
    CONSTRAINT buildings_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps_config(id),
    CONSTRAINT buildings_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital_profile(id),
    CONSTRAINT buildings_function_id_fkey FOREIGN KEY (function_id) REFERENCES public.ref_building_functions(id)
);

CREATE TABLE public.floors (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    app_id uuid,
    building_id uuid,
    floor_number integer NOT NULL,
    floor_alias character varying,
    map_image_url text,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    CONSTRAINT floors_pkey PRIMARY KEY (id),
    CONSTRAINT floors_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps_config(id),
    CONSTRAINT floors_building_id_fkey FOREIGN KEY (building_id) REFERENCES public.buildings(id)
);

CREATE TABLE public.rooms (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    app_id uuid,
    floor_id uuid,
    room_name character varying NOT NULL,
    category_id uuid,
    is_entry_gate boolean DEFAULT false,
    x_pos double precision DEFAULT 0.0,
    y_pos double precision DEFAULT 0.0,
    created_at timestamp with time zone DEFAULT now(),
    x_pos_max integer,
    y_pos_max integer,
    created_by uuid,
    CONSTRAINT rooms_pkey PRIMARY KEY (id),
    CONSTRAINT rooms_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps_config(id),
    CONSTRAINT rooms_floor_id_fkey FOREIGN KEY (floor_id) REFERENCES public.floors(id),
    CONSTRAINT rooms_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.ref_room_categories(id)
);

CREATE TABLE public.detectors (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    app_id uuid,
    detector_code character varying NOT NULL UNIQUE,
    room_id uuid,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT detectors_pkey PRIMARY KEY (id),
    CONSTRAINT detectors_room_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id)
);

CREATE TABLE public.ref_people_categories (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    category_name character varying NOT NULL,
    marker_color character varying,
    created_at timestamp with time zone DEFAULT now(),
    is_insider boolean,
    CONSTRAINT ref_people_categories_pkey PRIMARY KEY (id)
);

CREATE TABLE public.ref_positions (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    position_name text NOT NULL,
    description text,
    level smallint,
    color text,
    icon_name text,
    level_name text,
    CONSTRAINT ref_positions_pkey PRIMARY KEY (id)
);

CREATE TABLE public.employee_units (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    unit_code character varying NOT NULL UNIQUE,
    unit_name character varying NOT NULL,
    parent_unit_id uuid,
    unit_level integer DEFAULT 1,
    head_of_unit_id uuid,
    shift_required boolean DEFAULT true,
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    level smallint,
    CONSTRAINT employee_units_pkey PRIMARY KEY (id),
    CONSTRAINT employee_units_parent_unit_id_fkey FOREIGN KEY (parent_unit_id) REFERENCES public.employee_units(id)
);

CREATE TABLE public.ref_shifts (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    shift_name character varying NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    app_id uuid,
    shift_code character varying,
    description text,
    is_cross_day boolean DEFAULT false,
    break_duration_minutes integer DEFAULT 60,
    tolerance_late_minutes integer DEFAULT 15,
    tolerance_early_leave_minutes integer DEFAULT 15,
    minimum_work_minutes integer DEFAULT 480,
    maximum_overtime_minutes integer DEFAULT 240,
    fatigue_weight numeric DEFAULT 1.00,
    risk_level text DEFAULT 'normal'::text,
    requires_medical_fit boolean DEFAULT false,
    requires_supervisor boolean DEFAULT false,
    requires_checkin_photo boolean DEFAULT false,
    requires_location_validation boolean DEFAULT true,
    ai_priority_weight numeric DEFAULT 1.00,
    wellbeing_monitoring_enabled boolean DEFAULT true,
    auto_assign_allowed boolean DEFAULT true,
    color_hex character varying DEFAULT '#2196F3'::character varying,
    icon_name character varying,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT ref_shifts_pkey PRIMARY KEY (id)
);

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    full_name text,
    role text,
    rfid_tag text UNIQUE,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
    address text,
    gender character,
    phone text,
    position_id uuid,
    avatar_url text,
    employee_id text,
    is_asset_initial boolean DEFAULT false,
    is_asset_inspection boolean DEFAULT false,
    is_stock_initial boolean DEFAULT false,
    is_stock_opname boolean DEFAULT false,
    is_flexible_roster boolean DEFAULT false,
    default_shift_id uuid,
    max_weekly_hours integer DEFAULT 40,
    max_daily_hours integer DEFAULT 8,
    preferred_shift_ids ARRAY DEFAULT '{}'::uuid[],
    wellbeing_risk_level text DEFAULT 'normal'::text,
    last_wellbeing_assessment timestamp with time zone,
    employee_nik character varying UNIQUE,
    unit_id uuid,
    unit_code character varying,
    join_date date,
    join_year integer,
    int_sequence integer DEFAULT 1,
    int_label character varying DEFAULT '1st'::character varying,
    current_situation character varying DEFAULT 'ACTIVE'::character varying,
    situation_notes text,
    situation_updated_at timestamp with time zone,
    rating_take_count integer DEFAULT 1,
    current_assignment text,
    assignment_destination text,
    assignment_started_at timestamp with time zone,
    assignment_eta timestamp with time zone,
    assignment_destination_lat double precision,
    assignment_destination_long double precision,
    is_stock_approval boolean DEFAULT false,
    is_approved boolean DEFAULT false,
    is_stock_admin boolean DEFAULT false,
    is_asset_admin boolean DEFAULT false,
    is_active boolean NOT NULL DEFAULT true,
    is_people_input boolean DEFAULT false,
    can_register_people boolean DEFAULT false,
    can_bed_assignment boolean DEFAULT false,
    can_bed_unassignment boolean DEFAULT false,
    can_checkout_people boolean DEFAULT false,
    can_asset_initial boolean DEFAULT false,
    can_asset_inspection boolean DEFAULT false,
    can_stock_initial boolean DEFAULT false,
    can_asset_request boolean DEFAULT false,
    can_return_asset boolean DEFAULT false,
    can_stock_opname boolean DEFAULT false,
    can_stock_in boolean DEFAULT false,
    can_stock_placement boolean DEFAULT false,
    can_stock_request boolean DEFAULT false,
    can_stock_request_approval boolean DEFAULT false,
    can_stock_fulfillment boolean DEFAULT false,
    can_stock_write_off boolean DEFAULT false,
    can_stock_write_off_approval boolean DEFAULT false,
    can_building_reference boolean DEFAULT false,
    can_bins_reference boolean DEFAULT false,
    CONSTRAINT profiles_pkey PRIMARY KEY (id),
    CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id),
    CONSTRAINT profiles_position_id_fkey FOREIGN KEY (position_id) REFERENCES public.ref_positions(id),
    CONSTRAINT profiles_default_shift_id_fkey FOREIGN KEY (default_shift_id) REFERENCES public.ref_shifts(id),
    CONSTRAINT profiles_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.employee_units(id)
);

CREATE TABLE public.people (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    app_id uuid,
    rfid_tag_id character varying NOT NULL UNIQUE,
    full_name character varying NOT NULL,
    category_id uuid,
    foto_url text,
    is_male boolean NOT NULL DEFAULT true,
    is_child boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    is_active boolean DEFAULT true,
    last_detector_id uuid,
    last_room_id uuid,
    last_detected_at timestamp with time zone,
    last_movement_status text,
    updated_at timestamp with time zone DEFAULT now(),
    level_contaminated text,
    CONSTRAINT people_pkey PRIMARY KEY (id),
    CONSTRAINT people_last_detector_id_fkey FOREIGN KEY (last_detector_id) REFERENCES public.detectors(id),
    CONSTRAINT people_last_room_id_fkey FOREIGN KEY (last_room_id) REFERENCES public.rooms(id),
    CONSTRAINT people_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.ref_people_categories(id)
);

CREATE TABLE public.people_movements (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    rfid_tag_id character varying NOT NULL,
    detector_id uuid NOT NULL,
    level_contaminated integer DEFAULT 0,
    movement_status character varying DEFAULT 'IN'::character varying,
    detected_at timestamp with time zone DEFAULT now(),
    CONSTRAINT people_movements_pkey PRIMARY KEY (id),
    CONSTRAINT pm_rfid_fkey FOREIGN KEY (rfid_tag_id) REFERENCES public.people(rfid_tag_id),
    CONSTRAINT pm_detector_fkey FOREIGN KEY (detector_id) REFERENCES public.detectors(id)
);

CREATE TABLE public.employee_shift_rosters (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    app_id uuid,
    profile_id uuid NOT NULL,
    shift_id uuid NOT NULL,
    roster_date date NOT NULL,
    scheduled_start timestamp with time zone,
    scheduled_end timestamp with time zone,
    is_day_off boolean DEFAULT false,
    is_overtime_planned boolean DEFAULT false,
    is_emergency_shift boolean DEFAULT false,
    is_on_call boolean DEFAULT false,
    ai_generated boolean DEFAULT false,
    ai_confidence_score numeric,
    ai_reason text,
    predicted_fatigue_score numeric,
    predicted_workload_score numeric,
    predicted_stress_score numeric,
    wellbeing_risk_level text,
    approval_status text DEFAULT 'pending'::text,
    approved_by uuid,
    approved_at timestamp with time zone,
    rejection_reason text,
    actual_check_in timestamp with time zone,
    actual_check_out timestamp with time zone,
    attendance_status text DEFAULT 'scheduled'::text,
    total_work_minutes integer,
    overtime_minutes integer DEFAULT 0,
    lateness_minutes integer DEFAULT 0,
    early_leave_minutes integer DEFAULT 0,
    notes text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    location_name character varying,
    location_room_id uuid,
    required_equipment ARRAY DEFAULT '{}'::text[],
    special_instructions text,
    leave_request_id uuid,
    qualification_required ARRAY DEFAULT '{}'::uuid[],
    min_score_required numeric,
    CONSTRAINT employee_shift_rosters_pkey PRIMARY KEY (id),
    CONSTRAINT fk_employee_shift_profile FOREIGN KEY (profile_id) REFERENCES public.profiles(id),
    CONSTRAINT fk_employee_shift_shift FOREIGN KEY (shift_id) REFERENCES public.ref_shifts(id),
    CONSTRAINT fk_employee_shift_approved_by FOREIGN KEY (approved_by) REFERENCES public.profiles(id),
    CONSTRAINT fk_employee_shift_created_by FOREIGN KEY (created_by) REFERENCES public.profiles(id),
    CONSTRAINT employee_shift_rosters_location_room_id_fkey FOREIGN KEY (location_room_id) REFERENCES public.rooms(id)
);

CREATE TABLE public.attendance (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    app_id uuid,
    profile_id uuid NOT NULL,
    shift_id uuid,
    check_in timestamp with time zone DEFAULT now(),
    check_out timestamp with time zone,
    location_check_in uuid,
    status text NOT NULL DEFAULT 'present'::text,
    is_overtime boolean DEFAULT false,
    is_available boolean DEFAULT true,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    lat double precision,
    long double precision,
    address_at_check_in text,
    roster_id uuid,
    session_id uuid DEFAULT gen_random_uuid(),
    is_tracking_active boolean DEFAULT false,
    last_tracking_lat double precision,
    last_tracking_long double precision,
    last_tracking_address text,
    last_tracking_at timestamp with time zone,
    CONSTRAINT attendance_pkey PRIMARY KEY (id),
    CONSTRAINT attendance_profile_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id),
    CONSTRAINT attendance_shift_fkey FOREIGN KEY (shift_id) REFERENCES public.ref_shifts(id),
    CONSTRAINT attendance_location_fkey FOREIGN KEY (location_check_in) REFERENCES public.rooms(id),
    CONSTRAINT attendance_roster_id_fkey FOREIGN KEY (roster_id) REFERENCES public.employee_shift_rosters(id)
);

CREATE TABLE public.employee_wellbeing_logs (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    app_id uuid,
    profile_id uuid NOT NULL,
    log_date date NOT NULL,
    fatigue_score numeric,
    stress_score numeric,
    mood_score numeric,
    energy_score numeric,
    sleep_hours numeric,
    self_report text,
    ai_burnout_risk numeric,
    ai_recommendation text,
    requires_attention boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT employee_wellbeing_logs_pkey PRIMARY KEY (id),
    CONSTRAINT fk_wellbeing_profile FOREIGN KEY (profile_id) REFERENCES public.profiles(id)
);

CREATE TABLE public.employee_qualifications (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    qualification_code character varying NOT NULL UNIQUE,
    qualification_name character varying NOT NULL,
    category character varying,
    validity_period_months integer,
    requires_renewal boolean DEFAULT true,
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT employee_qualifications_pkey PRIMARY KEY (id)
);

CREATE TABLE public.employee_qualification_assignments (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    profile_id uuid NOT NULL,
    qualification_id uuid NOT NULL,
    acquired_date date NOT NULL,
    expiry_date date,
    certificate_number character varying,
    score numeric,
    is_active boolean DEFAULT true,
    verified_by uuid,
    verified_at timestamp with time zone,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT employee_qualification_assignments_pkey PRIMARY KEY (id),
    CONSTRAINT employee_qualification_assignments_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id),
    CONSTRAINT employee_qualification_assignments_qualification_id_fkey FOREIGN KEY (qualification_id) REFERENCES public.employee_qualifications(id)
);

CREATE TABLE public.leave_types (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    leave_code character varying NOT NULL UNIQUE,
    leave_name character varying NOT NULL,
    max_days_per_year integer,
    paid_leave boolean DEFAULT true,
    requires_document boolean DEFAULT false,
    requires_medical_certificate boolean DEFAULT false,
    color character varying DEFAULT '#FF9800'::character varying,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT leave_types_pkey PRIMARY KEY (id)
);

CREATE TABLE public.employee_leave_requests (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    profile_id uuid NOT NULL,
    leave_type_id uuid NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    total_days integer NOT NULL,
    reason text,
    document_url text,
    approval_status character varying DEFAULT 'pending'::character varying,
    approved_by uuid,
    approved_at timestamp with time zone,
    rejection_reason text,
    notes text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT employee_leave_requests_pkey PRIMARY KEY (id),
    CONSTRAINT employee_leave_requests_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id),
    CONSTRAINT employee_leave_requests_leave_type_id_fkey FOREIGN KEY (leave_type_id) REFERENCES public.leave_types(id)
);

-- 2.3 ASSET MANAGEMENT TABLES
CREATE TABLE public.ref_asset_categories (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    category_name character varying NOT NULL UNIQUE,
    icon_name character varying,
    marker_color text,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    CONSTRAINT ref_asset_categories_pkey PRIMARY KEY (id)
);

CREATE TABLE public.ref_asset_sub_categories (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    category_id uuid NOT NULL,
    sub_category_name character varying NOT NULL,
    icon_name character varying,
    marker_color text,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    CONSTRAINT ref_asset_sub_categories_pkey PRIMARY KEY (id),
    CONSTRAINT ref_asset_sub_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.ref_asset_categories(id)
);

CREATE TABLE public.ref_asset_types (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    type_name character varying NOT NULL,
    icon_name character varying,
    created_at timestamp with time zone DEFAULT now(),
    marker_color text,
    sub_category_id uuid,
    created_by uuid,
    CONSTRAINT ref_asset_types_pkey PRIMARY KEY (id),
    CONSTRAINT ref_asset_types_sub_category_id_fkey FOREIGN KEY (sub_category_id) REFERENCES public.ref_asset_sub_categories(id)
);

CREATE TABLE public.ref_asset_danger_levels (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    level_code character varying NOT NULL UNIQUE,
    level_name character varying NOT NULL,
    risk_description text,
    protection_required text,
    handling_instruction text,
    color_hex character varying DEFAULT '#F59E0B'::character varying,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT ref_asset_danger_levels_pkey PRIMARY KEY (id)
);

CREATE TABLE public.assets (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    rfid_tag_id character varying NOT NULL UNIQUE,
    asset_name character varying NOT NULL,
    type_id uuid,
    foto_url text,
    status_condition character varying DEFAULT 'Good'::character varying,
    level_contaminated integer DEFAULT 0,
    is_dangerous boolean DEFAULT false,
    handling_instruction text,
    maintenance_pattern character varying,
    inspection_day_of_month integer,
    last_inspection_at timestamp with time zone,
    next_inspection_at timestamp with time zone,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_detector_id uuid,
    last_room_id uuid,
    last_detected_at timestamp with time zone,
    last_movement_status text,
    description text,
    registered_by uuid,
    updated_by uuid,
    registered_at timestamp with time zone DEFAULT now(),
    last_used_by uuid,
    last_assigned_at timestamp with time zone,
    last_inspection_id uuid,
    last_inspection_result text,
    last_inspection_notes text,
    last_action_taken text,
    last_recommendation text,
    qrcode_url text,
    danger_level_id uuid,
    CONSTRAINT assets_pkey PRIMARY KEY (id),
    CONSTRAINT assets_type_fkey FOREIGN KEY (type_id) REFERENCES public.ref_asset_types(id),
    CONSTRAINT assets_last_detector_id_fkey FOREIGN KEY (last_detector_id) REFERENCES public.detectors(id),
    CONSTRAINT assets_last_room_id_fkey FOREIGN KEY (last_room_id) REFERENCES public.rooms(id),
    CONSTRAINT assets_danger_level_id_fkey FOREIGN KEY (danger_level_id) REFERENCES public.ref_asset_danger_levels(id)
);

CREATE TABLE public.asset_movements (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    asset_id uuid NOT NULL,
    detector_id uuid NOT NULL,
    movement_status character varying DEFAULT 'IN'::character varying,
    level_contaminated integer DEFAULT 0,
    detected_at timestamp with time zone DEFAULT now(),
    CONSTRAINT asset_movements_pkey PRIMARY KEY (id),
    CONSTRAINT asset_movements_asset_fkey FOREIGN KEY (asset_id) REFERENCES public.assets(id),
    CONSTRAINT asset_movements_detector_fkey FOREIGN KEY (detector_id) REFERENCES public.detectors(id)
);

CREATE TABLE public.asset_assignments (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    asset_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    assigned_at timestamp with time zone DEFAULT now(),
    released_at timestamp with time zone,
    assignment_status text DEFAULT 'active'::text,
    notes text,
    created_by uuid,
    app_id uuid,
    assigned_by uuid,
    assignment_type text,
    handover_location_id uuid,
    return_location_id uuid,
    contamination_responsibility boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT asset_assignments_pkey PRIMARY KEY (id),
    CONSTRAINT fk_asset FOREIGN KEY (asset_id) REFERENCES public.assets(id),
    CONSTRAINT fk_profile FOREIGN KEY (profile_id) REFERENCES public.profiles(id),
    CONSTRAINT fk_handover_location FOREIGN KEY (handover_location_id) REFERENCES public.rooms(id),
    CONSTRAINT fk_return_location FOREIGN KEY (return_location_id) REFERENCES public.rooms(id)
);

CREATE TABLE public.asset_inspections (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    asset_id uuid NOT NULL,
    inspected_by uuid NOT NULL,
    inspection_type text,
    inspection_result text,
    condition_status text,
    contamination_level integer,
    notes text,
    action_taken text,
    recommendation text,
    inspected_at timestamp with time zone DEFAULT now(),
    next_inspection_at timestamp with time zone,
    photo_url text,
    app_id uuid,
    task_id uuid,
    risk_score numeric,
    inspection_duration_minutes integer,
    proof_video_url text,
    ai_detected_issue text,
    ai_prediction text,
    ai_health_score numeric,
    ai_failure_probability numeric,
    fatigue_level numeric,
    requires_followup boolean DEFAULT false,
    followup_priority text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT asset_inspections_pkey PRIMARY KEY (id),
    CONSTRAINT fk_asset_inspection_asset FOREIGN KEY (asset_id) REFERENCES public.assets(id),
    CONSTRAINT fk_asset_inspection_profile FOREIGN KEY (inspected_by) REFERENCES public.profiles(id)
);

-- 2.4 STOCK MANAGEMENT TABLES
CREATE TABLE public.storage_locations (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    location_code character varying NOT NULL UNIQUE,
    location_name character varying NOT NULL,
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT storage_locations_pkey PRIMARY KEY (id)
);

CREATE TABLE public.ref_stock_categories (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    category_name character varying NOT NULL UNIQUE,
    icon_name character varying,
    marker_color text,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    CONSTRAINT ref_stock_categories_pkey PRIMARY KEY (id)
);

CREATE TABLE public.ref_stock_sub_categories (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    category_id uuid NOT NULL,
    sub_category_name character varying NOT NULL,
    icon_name character varying,
    marker_color text,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    CONSTRAINT ref_stock_sub_categories_pkey PRIMARY KEY (id),
    CONSTRAINT ref_stock_sub_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.ref_stock_categories(id)
);

CREATE TABLE public.ref_stock_types (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    type_name character varying NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    sub_category_id uuid,
    icon_name character varying,
    marker_color text,
    CONSTRAINT ref_stock_types_pkey PRIMARY KEY (id),
    CONSTRAINT ref_stock_types_sub_category_id_fkey FOREIGN KEY (sub_category_id) REFERENCES public.ref_stock_sub_categories(id)
);

CREATE TABLE public.stocks (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    stock_code character varying UNIQUE,
    stock_name character varying NOT NULL,
    stock_type_id uuid,
    unit character varying NOT NULL,
    minimum_stock numeric DEFAULT 0,
    current_stock numeric DEFAULT 0,
    photo_url text,
    last_opname_at timestamp with time zone,
    last_opname_by uuid,
    last_opname_note text,
    updated_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now(),
    is_active boolean DEFAULT true,
    stock_condition character varying DEFAULT 'GOOD'::character varying,
    last_opname_stock numeric,
    last_purchase_at timestamp with time zone,
    last_purchase_by uuid,
    last_purchase_qty numeric,
    last_purchase_price numeric,
    last_usage_at timestamp with time zone,
    last_usage_by uuid,
    last_usage_qty numeric,
    storage_location_id uuid,
    batch_number character varying,
    description text,
    expiry_date timestamp without time zone,
    created_by uuid,
    stock_in_qty numeric DEFAULT 0,
    CONSTRAINT stocks_pkey PRIMARY KEY (id),
    CONSTRAINT stocks_stock_type_id_fkey FOREIGN KEY (stock_type_id) REFERENCES public.ref_stock_types(id),
    CONSTRAINT stocks_storage_location_id_fkey FOREIGN KEY (storage_location_id) REFERENCES public.storage_locations(id)
);

CREATE TABLE public.stock_warehouses (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    code character varying NOT NULL UNIQUE,
    name character varying NOT NULL,
    address text,
    manager_id uuid,
    is_active boolean DEFAULT true,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    floor_id uuid,
    created_by uuid,
    CONSTRAINT stock_warehouses_pkey PRIMARY KEY (id)
);

CREATE TABLE public.stock_zones (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    warehouse_id uuid NOT NULL,
    code character varying NOT NULL,
    name character varying NOT NULL,
    zone_type character varying DEFAULT 'NORMAL'::character varying,
    temperature_min numeric,
    temperature_max numeric,
    humidity_min numeric,
    humidity_max numeric,
    is_restricted boolean DEFAULT false,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    room_id uuid,
    created_by uuid,
    CONSTRAINT stock_zones_pkey PRIMARY KEY (id),
    CONSTRAINT stock_zones_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.stock_warehouses(id),
    CONSTRAINT stock_zones_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id)
);

CREATE TABLE public.stock_racks (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    zone_id uuid NOT NULL,
    code character varying NOT NULL,
    name character varying,
    capacity_kg numeric,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    CONSTRAINT stock_racks_pkey PRIMARY KEY (id),
    CONSTRAINT stock_racks_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.stock_zones(id)
);

CREATE TABLE public.stock_shelves (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    rack_id uuid NOT NULL,
    level_number integer NOT NULL,
    code character varying NOT NULL,
    max_height_cm numeric,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    CONSTRAINT stock_shelves_pkey PRIMARY KEY (id),
    CONSTRAINT stock_shelves_rack_id_fkey FOREIGN KEY (rack_id) REFERENCES public.stock_racks(id)
);

CREATE TABLE public.stock_bins (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    shelf_id uuid NOT NULL,
    code character varying NOT NULL,
    barcode character varying UNIQUE,
    position_x integer,
    position_y integer,
    max_quantity numeric,
    current_quantity numeric DEFAULT 0,
    current_product_id uuid,
    is_active boolean DEFAULT true,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    qrcode_url text,
    asset_id uuid,
    CONSTRAINT stock_bins_pkey PRIMARY KEY (id),
    CONSTRAINT stock_bins_shelf_id_fkey FOREIGN KEY (shelf_id) REFERENCES public.stock_shelves(id),
    CONSTRAINT stock_bins_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.assets(id)
);

CREATE TABLE public.stock_in (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    receipt_number character varying NOT NULL UNIQUE,
    stock_id uuid NOT NULL,
    quantity numeric NOT NULL,
    batch_number character varying NOT NULL,
    expiry_date date NOT NULL,
    source_type character varying NOT NULL DEFAULT 'PURCHASE'::character varying,
    source_reference character varying,
    returned_from_unit character varying,
    return_reason character varying,
    received_by uuid,
    received_at timestamp with time zone DEFAULT now(),
    status character varying DEFAULT 'RECEIVED'::character varying,
    verified_by uuid,
    verified_at timestamp with time zone,
    risk_level character varying DEFAULT 'NORMAL'::character varying,
    notes text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT stock_in_pkey PRIMARY KEY (id),
    CONSTRAINT stock_in_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES public.stocks(id)
);

CREATE TABLE public.stock_in_entries (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    entry_number character varying NOT NULL UNIQUE,
    stock_id uuid NOT NULL,
    quantity numeric NOT NULL,
    batch_number character varying NOT NULL,
    expiry_date date NOT NULL,
    source_type character varying NOT NULL,
    source_id character varying,
    entry_date timestamp with time zone DEFAULT now(),
    received_bin_id uuid,
    current_bin_id uuid,
    received_by uuid,
    returned_by uuid,
    returned_from_unit character varying,
    return_reason character varying,
    put_away_by uuid,
    verified_by uuid,
    verified_at timestamp with time zone,
    risk_level character varying DEFAULT 'NORMAL'::character varying,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT stock_in_entries_pkey PRIMARY KEY (id),
    CONSTRAINT stock_in_entries_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES public.stocks(id),
    CONSTRAINT stock_in_entries_received_bin_id_fkey FOREIGN KEY (received_bin_id) REFERENCES public.stock_bins(id),
    CONSTRAINT stock_in_entries_current_bin_id_fkey FOREIGN KEY (current_bin_id) REFERENCES public.stock_bins(id)
);

CREATE TABLE public.stock_in_bins (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    bin_id uuid NOT NULL,
    stock_id uuid NOT NULL,
    batch_number character varying NOT NULL,
    expiry_date date NOT NULL,
    quantity numeric NOT NULL,
    stock_in_id uuid,
    put_away_by uuid,
    put_away_at timestamp with time zone DEFAULT now(),
    scanned_bin_barcode character varying,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT stock_in_bins_pkey PRIMARY KEY (id),
    CONSTRAINT stock_in_bins_bin_id_fkey FOREIGN KEY (bin_id) REFERENCES public.stock_bins(id),
    CONSTRAINT stock_in_bins_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES public.stocks(id),
    CONSTRAINT stock_in_bins_stock_in_id_fkey FOREIGN KEY (stock_in_id) REFERENCES public.stock_in(id)
);

CREATE TABLE public.stock_requests (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    request_number character varying NOT NULL UNIQUE,
    requester_id uuid NOT NULL,
    requester_name character varying,
    room_id uuid,
    purpose character varying,
    request_date timestamp with time zone DEFAULT now(),
    notes text,
    requested_stock_id uuid NOT NULL,
    requested_stock_name character varying,
    requested_quantity numeric NOT NULL,
    requested_unit character varying,
    requested_batch character varying,
    approved_by uuid,
    approved_date timestamp with time zone,
    approved_quantity numeric,
    approved_stock_id uuid,
    approved_stock_name character varying,
    approval_notes text,
    status character varying DEFAULT 'PENDING'::character varying,
    fulfilled_quantity numeric DEFAULT 0,
    rejected_by uuid,
    rejected_at timestamp with time zone,
    rejection_reason text,
    rejection_type character varying,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT stock_requests_pkey PRIMARY KEY (id),
    CONSTRAINT stock_requests_requester_id_fkey FOREIGN KEY (requester_id) REFERENCES public.profiles(id),
    CONSTRAINT stock_requests_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id),
    CONSTRAINT stock_requests_requested_stock_id_fkey FOREIGN KEY (requested_stock_id) REFERENCES public.stocks(id)
);

CREATE TABLE public.stock_request_fulfillments (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    stock_request_id uuid NOT NULL,
    stock_in_bins_id uuid NOT NULL,
    bin_id uuid NOT NULL,
    stock_id uuid NOT NULL,
    batch_number character varying NOT NULL,
    expiry_date date NOT NULL,
    quantity numeric NOT NULL,
    taken_by uuid NOT NULL,
    taken_at timestamp with time zone DEFAULT now(),
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT stock_request_fulfillments_pkey PRIMARY KEY (id),
    CONSTRAINT stock_request_fulfillments_taken_by_fkey FOREIGN KEY (taken_by) REFERENCES public.profiles(id),
    CONSTRAINT stock_request_fulfillments_stock_request_id_fkey FOREIGN KEY (stock_request_id) REFERENCES public.stock_requests(id),
    CONSTRAINT stock_request_fulfillments_stock_in_bins_id_fkey FOREIGN KEY (stock_in_bins_id) REFERENCES public.stock_in_bins(id),
    CONSTRAINT stock_request_fulfillments_bin_id_fkey FOREIGN KEY (bin_id) REFERENCES public.stock_bins(id),
    CONSTRAINT stock_request_fulfillments_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES public.stocks(id)
);

CREATE TABLE public.stock_write_offs (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    write_off_number character varying NOT NULL UNIQUE,
    stock_in_bins_id uuid NOT NULL,
    bin_id uuid NOT NULL,
    stock_id uuid NOT NULL,
    batch_number character varying NOT NULL,
    expiry_date date NOT NULL,
    quantity numeric NOT NULL,
    unit character varying,
    reason character varying NOT NULL,
    reason_note text,
    requested_by uuid,
    requested_at timestamp with time zone DEFAULT now(),
    status character varying DEFAULT 'DRAFT'::character varying,
    photo_url text,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT stock_write_offs_pkey PRIMARY KEY (id),
    CONSTRAINT stock_write_offs_stock_in_bins_id_fkey FOREIGN KEY (stock_in_bins_id) REFERENCES public.stock_in_bins(id),
    CONSTRAINT stock_write_offs_bin_id_fkey FOREIGN KEY (bin_id) REFERENCES public.stock_bins(id),
    CONSTRAINT stock_write_offs_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES public.stocks(id)
);

CREATE TABLE public.stock_mutations (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    mutation_number character varying NOT NULL UNIQUE,
    stock_in_bins_id uuid NOT NULL,
    bin_id_asal uuid NOT NULL,
    bin_id_tujuan uuid NOT NULL,
    stock_id uuid NOT NULL,
    batch_number character varying NOT NULL,
    expiry_date date NOT NULL,
    quantity numeric NOT NULL,
    unit character varying,
    moved_by uuid NOT NULL,
    moved_at timestamp with time zone DEFAULT now(),
    received_by uuid,
    received_at timestamp with time zone,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT stock_mutations_pkey PRIMARY KEY (id),
    CONSTRAINT stock_mutations_stock_in_bins_id_fkey FOREIGN KEY (stock_in_bins_id) REFERENCES public.stock_in_bins(id),
    CONSTRAINT stock_mutations_bin_id_asal_fkey FOREIGN KEY (bin_id_asal) REFERENCES public.stock_bins(id),
    CONSTRAINT stock_mutations_bin_id_tujuan_fkey FOREIGN KEY (bin_id_tujuan) REFERENCES public.stock_bins(id),
    CONSTRAINT stock_mutations_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES public.stocks(id)
);

CREATE TABLE public.stock_transactions (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    stock_id uuid NOT NULL,
    transaction_type character varying NOT NULL,
    qty numeric NOT NULL,
    stock_before numeric NOT NULL,
    stock_after numeric NOT NULL,
    transaction_note text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT stock_transactions_pkey PRIMARY KEY (id),
    CONSTRAINT stock_transactions_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES public.stocks(id)
);

CREATE TABLE public.stocks_opnames (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    stock_id uuid NOT NULL,
    stock_before numeric DEFAULT 0,
    physical_stock numeric NOT NULL,
    adjustment_stock numeric DEFAULT 0,
    opname_note text,
    opname_by uuid,
    opname_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now(),
    bin_id uuid,
    stock_in_bins_id uuid,
    batch_number character varying,
    expiry_date date,
    system_quantity numeric,
    opname_type character varying DEFAULT 'PRODUCT'::character varying,
    CONSTRAINT stocks_opnames_pkey PRIMARY KEY (id),
    CONSTRAINT stocks_opnames_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES public.stocks(id),
    CONSTRAINT stocks_opnames_bin_id_fkey FOREIGN KEY (bin_id) REFERENCES public.stock_bins(id),
    CONSTRAINT stocks_opnames_stock_in_bins_id_fkey FOREIGN KEY (stock_in_bins_id) REFERENCES public.stock_in_bins(id)
);

-- 2.5 BEDS MANAGEMENT
CREATE TABLE public.beds (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    room_id uuid,
    bed_number character varying,
    asset_id uuid,
    status character varying DEFAULT 'EMPTY'::character varying,
    admitted_at timestamp with time zone,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    CONSTRAINT beds_pkey PRIMARY KEY (id),
    CONSTRAINT beds_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id),
    CONSTRAINT beds_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.assets(id)
);

CREATE TABLE public.beds_assignments (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    bed_id uuid NOT NULL,
    people_id uuid NOT NULL,
    assigned_at timestamp with time zone NOT NULL DEFAULT now(),
    predicted_until timestamp with time zone,
    discharged_at timestamp with time zone,
    notes text,
    created_by uuid,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT beds_assignments_pkey PRIMARY KEY (id),
    CONSTRAINT beds_assignments_bed_id_fkey FOREIGN KEY (bed_id) REFERENCES public.beds(id),
    CONSTRAINT beds_assignments_people_id_fkey FOREIGN KEY (people_id) REFERENCES public.people(id)
);

-- 2.6 INCIDENTS & TASKS
CREATE TABLE public.ref_incident_categories (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    code character varying NOT NULL UNIQUE,
    name character varying NOT NULL,
    description text,
    icon character varying,
    color character varying,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT ref_incident_categories_pkey PRIMARY KEY (id)
);

CREATE TABLE public.incidents (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    category_id uuid NOT NULL,
    reported_by uuid NOT NULL,
    room_id uuid,
    title character varying NOT NULL,
    description text NOT NULL,
    occurred_at timestamp with time zone NOT NULL,
    location_text text,
    status character varying NOT NULL DEFAULT 'reported'::character varying,
    photo_urls jsonb,
    voice_note_url text,
    ai_tags jsonb,
    ai_analysis jsonb,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    severity character varying DEFAULT 'MEDIUM'::character varying,
    assigned_to uuid,
    resolved_at timestamp with time zone,
    resolution_note text,
    lat double precision,
    long double precision,
    address text,
    action_taken text,
    action_taken_at timestamp with time zone,
    action_taken_by uuid,
    action_task_ids ARRAY,
    action_taken_model text,
    action_announcement_ids ARRAY,
    CONSTRAINT incidents_pkey PRIMARY KEY (id),
    CONSTRAINT incidents_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.ref_incident_categories(id),
    CONSTRAINT incidents_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES public.profiles(id),
    CONSTRAINT incidents_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id)
);

CREATE TABLE public.ref_task_types (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    task_type_name text NOT NULL,
    icon_name text,
    color_code text,
    description text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT ref_task_types_pkey PRIMARY KEY (id)
);

CREATE TABLE public.ref_reports_category (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    name character varying NOT NULL,
    description text,
    icon_name text,
    CONSTRAINT ref_reports_category_pkey PRIMARY KEY (id)
);

CREATE TABLE public.tasks (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    type_id uuid NOT NULL,
    assignee_id uuid NOT NULL,
    object_name text NOT NULL,
    from_room_id uuid NOT NULL,
    to_room_id uuid NOT NULL,
    status text NOT NULL DEFAULT 'pending'::text,
    priority text NOT NULL DEFAULT 'normal'::text,
    created_at timestamp with time zone DEFAULT now(),
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    created_by uuid,
    task_outcome text,
    completion_notes text,
    app_id uuid,
    asset_id uuid,
    stock_id uuid,
    related_profile_id uuid,
    accepted_at timestamp with time zone,
    rejected_at timestamp with time zone,
    cancelled_at timestamp with time zone,
    rejection_reason text,
    sla_minutes integer,
    estimated_duration_minutes integer,
    actual_duration_minutes integer,
    ai_generated boolean DEFAULT false,
    ai_priority_score numeric,
    ai_confidence_score numeric,
    ai_recommendation_reason text,
    fatigue_before numeric,
    fatigue_after numeric,
    wellbeing_impact_score numeric,
    workload_snapshot integer,
    requires_confirmation boolean DEFAULT false,
    requires_photo_proof boolean DEFAULT false,
    requires_qr_validation boolean DEFAULT false,
    proof_photo_url text,
    employee_feedback text,
    employee_rating integer,
    updated_at timestamp with time zone DEFAULT now(),
    completion_lat double precision,
    completion_long double precision,
    completion_address text,
    CONSTRAINT tasks_pkey PRIMARY KEY (id),
    CONSTRAINT tasks_type_fkey FOREIGN KEY (type_id) REFERENCES public.ref_task_types(id),
    CONSTRAINT tasks_assignee_fkey FOREIGN KEY (assignee_id) REFERENCES public.profiles(id),
    CONSTRAINT tasks_from_room_fkey FOREIGN KEY (from_room_id) REFERENCES public.rooms(id),
    CONSTRAINT tasks_to_room_fkey FOREIGN KEY (to_room_id) REFERENCES public.rooms(id),
    CONSTRAINT tasks_asset_fkey FOREIGN KEY (asset_id) REFERENCES public.assets(id),
    CONSTRAINT tasks_stock_fkey FOREIGN KEY (stock_id) REFERENCES public.stocks(id)
);

CREATE TABLE public.tasks_reports (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    task_id uuid NOT NULL,
    category_id uuid NOT NULL,
    reporter_id uuid NOT NULL,
    description text NOT NULL,
    urgency_level text NOT NULL DEFAULT 'normal'::text,
    at_room_id uuid,
    created_at timestamp with time zone DEFAULT now(),
    file_url text,
    file_type text,
    CONSTRAINT tasks_reports_pkey PRIMARY KEY (id),
    CONSTRAINT tr_task_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id),
    CONSTRAINT tr_category_fkey FOREIGN KEY (category_id) REFERENCES public.ref_reports_category(id),
    CONSTRAINT tr_reporter_fkey FOREIGN KEY (reporter_id) REFERENCES public.profiles(id)
);

-- 2.7 SUPPORT TICKETS
CREATE TABLE public.support_tickets (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    ticket_number text NOT NULL UNIQUE,
    session_id text,
    user_id uuid,
    user_name text NOT NULL,
    user_email text NOT NULL,
    subject text NOT NULL,
    message text NOT NULL,
    status text DEFAULT 'open'::text,
    is_read_admin boolean DEFAULT false,
    is_read_user boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT support_tickets_pkey PRIMARY KEY (id)
);

CREATE TABLE public.support_replies (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    ticket_id uuid,
    user_name text NOT NULL,
    user_role text DEFAULT 'user'::text,
    message text NOT NULL,
    is_read boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT support_replies_pkey PRIMARY KEY (id),
    CONSTRAINT support_replies_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.support_tickets(id)
);

-- 2.8 ANNOUNCEMENTS & DUTY NOTES
CREATE TABLE public.announcements (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    sender_id uuid NOT NULL,
    title text NOT NULL,
    content text NOT NULL,
    priority text NOT NULL DEFAULT 'normal'::text,
    target_building_id uuid,
    target_floor_id uuid,
    target_room_id uuid,
    target_position_id uuid,
    target_profile_id uuid,
    created_at timestamp with time zone DEFAULT now(),
    expires_at timestamp with time zone,
    target_role text,
    target_unit_id uuid,
    target_permission_asset text,
    target_permission_stock text,
    target_flexible_roster boolean,
    target_wellbeing_risk text,
    target_join_year_start integer,
    target_join_year_end integer,
    target_situation text,
    target_gender character,
    target_rating_take_count_min integer,
    target_rating_take_count_max integer,
    target_int_sequence_min integer,
    target_int_sequence_max integer,
    target_fatigue_score_min numeric,
    target_fatigue_score_max numeric,
    CONSTRAINT announcements_pkey PRIMARY KEY (id),
    CONSTRAINT ann_sender_fkey FOREIGN KEY (sender_id) REFERENCES public.profiles(id),
    CONSTRAINT ann_building_fkey FOREIGN KEY (target_building_id) REFERENCES public.ref_building_functions(id),
    CONSTRAINT ann_floor_fkey FOREIGN KEY (target_floor_id) REFERENCES public.floors(id),
    CONSTRAINT ann_room_fkey FOREIGN KEY (target_room_id) REFERENCES public.rooms(id),
    CONSTRAINT ann_position_fkey FOREIGN KEY (target_position_id) REFERENCES public.ref_positions(id),
    CONSTRAINT ann_profile_fkey FOREIGN KEY (target_profile_id) REFERENCES public.profiles(id),
    CONSTRAINT announcements_target_unit_id_fkey FOREIGN KEY (target_unit_id) REFERENCES public.employee_units(id)
);

CREATE TABLE public.duty_notes (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    attendance_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    note_text text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT duty_notes_pkey PRIMARY KEY (id),
    CONSTRAINT duty_notes_attendance_id_fkey FOREIGN KEY (attendance_id) REFERENCES public.attendance(id),
    CONSTRAINT duty_notes_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id)
);

-- 2.9 SCORING
CREATE TABLE public.scoring_categories (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    category_code character varying NOT NULL UNIQUE,
    category_name character varying NOT NULL,
    weight numeric DEFAULT 1.00,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT scoring_categories_pkey PRIMARY KEY (id)
);

CREATE TABLE public.employee_scoring (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    profile_id uuid NOT NULL,
    scoring_category_id uuid NOT NULL,
    score numeric NOT NULL DEFAULT 0,
    max_score numeric NOT NULL DEFAULT 100,
    period_start date NOT NULL,
    period_end date NOT NULL,
    notes text,
    calculated_at timestamp with time zone DEFAULT now(),
    calculated_by uuid,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT employee_scoring_pkey PRIMARY KEY (id),
    CONSTRAINT employee_scoring_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id),
    CONSTRAINT employee_scoring_scoring_category_id_fkey FOREIGN KEY (scoring_category_id) REFERENCES public.scoring_categories(id)
);

-- 2.10 EMPLOYEE LOCATION TRACKING
CREATE TABLE public.employee_location_tracking (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    profile_id uuid NOT NULL,
    session_id uuid NOT NULL,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    accuracy double precision,
    speed double precision,
    altitude double precision,
    is_moving boolean DEFAULT false,
    recorded_at timestamp with time zone DEFAULT now(),
    device_info jsonb,
    CONSTRAINT employee_location_tracking_pkey PRIMARY KEY (id),
    CONSTRAINT employee_location_tracking_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id)
);

-- 2.11 TODOS
CREATE TABLE public.todos (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    title text NOT NULL,
    description text,
    duration_minutes integer,
    target_unit_id uuid,
    target_position_id uuid,
    target_shift_id uuid,
    todo_date date NOT NULL,
    start_time time without time zone,
    end_time time without time zone,
    source_type text DEFAULT 'admin_input'::text,
    source_id text,
    source_table text,
    source_data jsonb,
    is_active boolean DEFAULT true,
    expired_at timestamp with time zone,
    display_order integer DEFAULT 0,
    is_mandatory boolean DEFAULT true,
    priority text DEFAULT 'normal'::text,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT todos_pkey PRIMARY KEY (id),
    CONSTRAINT fk_todos_target_unit FOREIGN KEY (target_unit_id) REFERENCES public.employee_units(id),
    CONSTRAINT fk_todos_target_position FOREIGN KEY (target_position_id) REFERENCES public.ref_positions(id),
    CONSTRAINT fk_todos_target_shift FOREIGN KEY (target_shift_id) REFERENCES public.ref_shifts(id),
    CONSTRAINT fk_todos_created_by FOREIGN KEY (created_by) REFERENCES public.profiles(id)
);

-- 2.12 SYSTEM & MARKETING TABLES
CREATE TABLE public.licenses (
    license_key character varying NOT NULL,
    is_active boolean DEFAULT true,
    client_name character varying,
    production_supabase_url text NOT NULL,
    production_anon_key text NOT NULL,
    gemini_api_key text,
    expiry_date date,
    created_at timestamp with time zone DEFAULT now(),
    package character varying DEFAULT 'basic'::character varying,
    CONSTRAINT licenses_pkey PRIMARY KEY (license_key)
);

CREATE TABLE public.packages (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    name text NOT NULL,
    slug text NOT NULL UNIQUE,
    description text,
    price_monthly numeric,
    price_yearly numeric,
    is_popular boolean DEFAULT false,
    features ARRAY DEFAULT '{}'::text[],
    display_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    price_monthly_idr bigint,
    price_yearly_idr bigint,
    currency text DEFAULT 'IDR'::text,
    CONSTRAINT packages_pkey PRIMARY KEY (id)
);

CREATE TABLE public.modules (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    package_id uuid,
    name text NOT NULL,
    slug text NOT NULL UNIQUE,
    description text,
    icon_name text,
    display_order integer DEFAULT 0,
    is_coming boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT modules_pkey PRIMARY KEY (id),
    CONSTRAINT modules_package_id_fkey FOREIGN KEY (package_id) REFERENCES public.packages(id)
);

CREATE TABLE public.features (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    menu_name text NOT NULL,
    description text NOT NULL,
    picture_url text,
    level integer DEFAULT 1,
    details jsonb,
    package_uuids ARRAY,
    icon_name text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    module_id uuid,
    display_order integer DEFAULT 0,
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT features_pkey PRIMARY KEY (id),
    CONSTRAINT features_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.modules(id)
);

CREATE TABLE public.pricing_plans (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    name text NOT NULL,
    price_monthly integer,
    price_yearly integer,
    features jsonb,
    cta_text text,
    icon_name text,
    color_hex text,
    is_popular boolean DEFAULT false,
    is_active boolean DEFAULT true,
    CONSTRAINT pricing_plans_pkey PRIMARY KEY (id)
);

CREATE TABLE public.testimonials (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    hospital_name text NOT NULL,
    user_name text,
    content text NOT NULL,
    rating integer DEFAULT 5,
    picture_url text,
    avatar_url text,
    is_published boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT testimonials_pkey PRIMARY KEY (id)
);

CREATE TABLE public.trusted_hospitals (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    name text NOT NULL,
    logo_url text NOT NULL,
    display_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT trusted_hospitals_pkey PRIMARY KEY (id)
);

CREATE TABLE public.contact_info (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    category text NOT NULL,
    title text NOT NULL,
    description text,
    address text,
    whatsapp text,
    email text,
    contact_for text,
    logo_url text,
    is_active boolean DEFAULT true,
    display_order integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT contact_info_pkey PRIMARY KEY (id)
);

CREATE TABLE public.head_office (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    title text NOT NULL,
    address text NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT head_office_pkey PRIMARY KEY (id)
);

CREATE TABLE public.contact_note (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    content text NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT contact_note_pkey PRIMARY KEY (id)
);

CREATE TABLE public.downloads (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    title text NOT NULL,
    title_id text NOT NULL,
    description text,
    description_id text,
    icon_name text NOT NULL,
    file_url text NOT NULL,
    file_size text,
    version text,
    platform text,
    allowed_roles ARRAY DEFAULT '{}'::text[],
    download_count integer DEFAULT 0,
    display_order integer DEFAULT 0 UNIQUE,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT downloads_pkey PRIMARY KEY (id)
);

-- ============================================================
-- 2. VIEWS
-- ============================================================
-- ============================================================
-- 5. CREATE VIEWS
-- ============================================================

-- 5.1 Employee Last Location View
CREATE OR REPLACE VIEW public.employee_last_location_view AS
 SELECT DISTINCT ON (elt.profile_id) elt.profile_id,
    p.full_name,
    p.employee_id,
    p.unit_code,
    p.current_situation,
    p.current_assignment,
    elt.latitude,
    elt.longitude,
    elt.accuracy,
    elt.speed,
    elt.recorded_at AS last_updated,
    a.check_in,
    a.shift_id,
    COALESCE(rs.shift_name, 'No Shift'::character varying) AS shift_name
   FROM (((employee_location_tracking elt
     JOIN profiles p ON ((p.id = elt.profile_id)))
     LEFT JOIN attendance a ON ((a.session_id = elt.session_id)))
     LEFT JOIN ref_shifts rs ON ((rs.id = a.shift_id)))
  WHERE (a.check_out IS NULL)
  ORDER BY elt.profile_id, elt.recorded_at DESC;

-- 5.2 Employee Score Summary View
CREATE OR REPLACE VIEW public.employee_score_summary AS
 SELECT p.id AS profile_id,
    p.full_name,
    p.employee_id,
    p.unit_code,
    ((sum((es.score * sc.weight)) / sum((es.max_score * sc.weight))) * (100)::numeric) AS total_percentage,
    sum(es.score) AS total_score,
    sum(es.max_score) AS total_max_score,
    es.period_start,
    es.period_end
   FROM ((employee_scoring es
     JOIN profiles p ON ((p.id = es.profile_id)))
     JOIN scoring_categories sc ON ((sc.id = es.scoring_category_id)))
  GROUP BY p.id, p.full_name, p.employee_id, p.unit_code, es.period_start, es.period_end;

-- 5.3 Employee Tracking View
CREATE OR REPLACE VIEW public.employee_tracking_view AS
 SELECT elt.id,
    elt.profile_id,
    p.full_name,
    p.employee_id,
    p.unit_code,
    p.current_situation,
    p.current_assignment,
    elt.session_id,
    a.shift_id,
    COALESCE(rs.shift_name, 'No Shift'::character varying) AS shift_name,
    COALESCE(rs.shift_code, 'N/A'::character varying) AS shift_code,
    elt.latitude,
    elt.longitude,
    elt.accuracy,
    elt.speed,
    elt.altitude,
    elt.is_moving,
    elt.recorded_at,
    elt.device_info,
    a.check_in,
    a.check_out,
    a.is_tracking_active,
    lag(elt.latitude) OVER (PARTITION BY elt.session_id ORDER BY elt.recorded_at) AS prev_lat,
    lag(elt.longitude) OVER (PARTITION BY elt.session_id ORDER BY elt.recorded_at) AS prev_lng,
    lag(elt.recorded_at) OVER (PARTITION BY elt.session_id ORDER BY elt.recorded_at) AS prev_recorded_at,
        CASE
            WHEN (a.check_out IS NULL) THEN 'ON_DUTY'::text
            ELSE 'OFF_DUTY'::text
        END AS duty_status
   FROM (((employee_location_tracking elt
     JOIN profiles p ON ((p.id = elt.profile_id)))
     LEFT JOIN attendance a ON ((a.session_id = elt.session_id)))
     LEFT JOIN ref_shifts rs ON ((rs.id = a.shift_id)));

-- 5.4 Personil Last Position View
CREATE OR REPLACE VIEW public.personil_last_position AS
 SELECT DISTINCT ON (rfid_tag_id) id,
    rfid_tag_id,
    detector_id,
    level_contaminated,
    movement_status,
    detected_at
   FROM people_movements
  ORDER BY rfid_tag_id, detected_at DESC;

-- 5.5 Roster Dashboard View
CREATE OR REPLACE VIEW public.roster_dashboard_view AS
 SELECT r.roster_date,
    r.profile_id,
    p.full_name,
    p.employee_id,
    s.shift_name,
    s.shift_code,
    s.start_time,
    s.end_time,
    r.predicted_fatigue_score,
    r.wellbeing_risk_level,
    r.attendance_status,
        CASE
            WHEN (r.actual_check_in IS NULL) THEN 'Not Started'::text
            WHEN (r.actual_check_in > (r.scheduled_start + ((r.lateness_minutes || ' minutes'::text))::interval)) THEN 'Late'::text
            WHEN (r.actual_check_out IS NULL) THEN 'In Progress'::text
            ELSE 'Completed'::text
        END AS current_status,
    w.fatigue_score AS actual_fatigue_score,
    w.stress_score,
    w.mood_score
   FROM (((employee_shift_rosters r
     JOIN profiles p ON ((p.id = r.profile_id)))
     JOIN ref_shifts s ON ((s.id = r.shift_id)))
     LEFT JOIN employee_wellbeing_logs w ON (((w.profile_id = r.profile_id) AND (w.log_date = r.roster_date))));

-- 5.6 Roster Monthly Matrix View
CREATE OR REPLACE VIEW public.roster_monthly_matrix AS
 SELECT p.id AS profile_id,
    p.full_name AS nama,
    p.employee_nik AS nik,
    p.unit_code AS unit,
    COALESCE(p.int_label, '1st'::character varying) AS "int",
    p.current_situation AS ket,
    esr.roster_date,
    rs.shift_code,
    rs.shift_name
   FROM ((employee_shift_rosters esr
     JOIN profiles p ON ((p.id = esr.profile_id)))
     JOIN ref_shifts rs ON ((rs.id = esr.shift_id)))
  WHERE (esr.is_day_off = false)
  ORDER BY p.unit_code, p.full_name, esr.roster_date;

-- 5.7 Stock Bins Full View
CREATE OR REPLACE VIEW public.stock_bins_full AS
 SELECT b.id AS bin_id,
    b.code AS bin_code,
    b.barcode,
    b.position_x,
    b.position_y,
    b.max_quantity,
    b.current_quantity,
    b.current_product_id,
    b.is_active AS bin_is_active,
    s.id AS shelf_id,
    s.code AS shelf_code,
    s.level_number AS shelf_level,
    r.id AS rack_id,
    r.code AS rack_code,
    z.id AS zone_id,
    z.code AS zone_code,
    z.zone_type,
    z.is_restricted AS zone_is_restricted,
    rm.id AS room_id,
    rm.room_name,
    w.id AS warehouse_id,
    w.code AS warehouse_code,
    w.name AS warehouse_name,
    f.id AS floor_id,
    f.floor_number,
    f.floor_alias,
    concat(COALESCE(w.code, ''::character varying), '-', COALESCE(z.code, ''::character varying), '-', COALESCE(r.code, ''::character varying), '-', COALESCE(s.code, ''::character varying), '-', COALESCE(b.code, ''::character varying)) AS full_location_code,
    concat(COALESCE(w.name, 'Gudang'::character varying), ' / ', COALESCE(rm.room_name, 'Ruangan'::character varying), ' / ', COALESCE(r.code, 'Rak'::character varying), ' / ', COALESCE(s.code, 'Shelf'::character varying), ' / ', COALESCE(b.code, 'Bin'::character varying)) AS full_location_name
   FROM ((((((stock_bins b
     LEFT JOIN stock_shelves s ON ((b.shelf_id = s.id)))
     LEFT JOIN stock_racks r ON ((s.rack_id = r.id)))
     LEFT JOIN stock_zones z ON ((r.zone_id = z.id)))
     LEFT JOIN rooms rm ON ((z.room_id = rm.id)))
     LEFT JOIN stock_warehouses w ON ((z.warehouse_id = w.id)))
     LEFT JOIN floors f ON ((w.floor_id = f.id)));

-- 5.8 Asset Available View
CREATE OR REPLACE VIEW public.v_asset_available AS
 SELECT a.id,
    a.rfid_tag_id,
    a.asset_name,
    a.type_id,
    t.type_name,
    a.foto_url,
    a.status_condition,
    a.level_contaminated,
    a.is_dangerous,
    a.handling_instruction,
    a.description,
    a.last_room_id,
    r.room_name AS last_room_name,
    aa.assignment_status AS last_assignment_status,
    aa.profile_id AS last_user_id,
    p.full_name AS last_user_name,
    'available'::text AS availability_status
   FROM ((((assets a
     LEFT JOIN ref_asset_types t ON ((t.id = a.type_id)))
     LEFT JOIN rooms r ON ((r.id = a.last_room_id)))
     LEFT JOIN LATERAL ( SELECT asset_assignments.id,
            asset_assignments.asset_id,
            asset_assignments.profile_id,
            asset_assignments.assigned_at,
            asset_assignments.released_at,
            asset_assignments.assignment_status,
            asset_assignments.notes,
            asset_assignments.created_by,
            asset_assignments.app_id,
            asset_assignments.assigned_by,
            asset_assignments.assignment_type,
            asset_assignments.handover_location_id,
            asset_assignments.return_location_id,
            asset_assignments.contamination_responsibility,
            asset_assignments.created_at,
            asset_assignments.updated_at
           FROM asset_assignments
          WHERE (asset_assignments.asset_id = a.id)
          ORDER BY asset_assignments.created_at DESC
         LIMIT 1) aa ON (true))
     LEFT JOIN profiles p ON ((p.id = aa.profile_id)))
  WHERE ((a.is_active = true) AND ((aa.assignment_status IS NULL) OR (aa.assignment_status = 'released'::text) OR (aa.assignment_status = 'rejected'::text)) AND ((a.status_condition)::text <> 'Damage'::text) AND ((a.status_condition)::text <> 'Critical'::text))
  ORDER BY a.asset_name;

-- 5.9 Asset Dashboard Summary View
CREATE OR REPLACE VIEW public.v_asset_dashboard_summary AS
 SELECT count(*) AS total_assets,
    count(*) FILTER (WHERE ((status_condition)::text = 'Good'::text)) AS total_good,
    count(*) FILTER (WHERE ((status_condition)::text = 'Maintenance'::text)) AS total_maintenance,
    count(*) FILTER (WHERE ((status_condition)::text = 'Critical'::text)) AS total_critical,
    count(*) FILTER (WHERE ((status_condition)::text = 'Damaged'::text)) AS total_damaged,
    count(*) FILTER (WHERE (is_dangerous = true)) AS total_dangerous,
    count(*) FILTER (WHERE (level_contaminated >= 4)) AS high_contamination,
    count(*) FILTER (WHERE (next_inspection_at <= now())) AS overdue_inspection
   FROM assets;

-- 5.10 Asset Details View
CREATE OR REPLACE VIEW public.v_asset_details AS
 SELECT a.id,
    a.rfid_tag_id,
    a.asset_name,
    a.type_id,
    a.foto_url,
    a.status_condition,
    a.level_contaminated,
    a.is_dangerous,
    a.handling_instruction,
    a.maintenance_pattern,
    a.inspection_day_of_month,
    a.last_inspection_at,
    a.next_inspection_at,
    a.is_active,
    a.created_at,
    a.updated_at,
    a.last_detector_id,
    a.last_room_id,
    a.last_detected_at,
    a.last_movement_status,
    a.description,
    a.registered_by,
    a.updated_by,
    a.registered_at,
    a.last_used_by,
    a.last_assigned_at,
    a.last_inspection_id,
    a.last_inspection_result,
    a.last_inspection_notes,
    a.last_action_taken,
    a.last_recommendation,
    a.qrcode_url,
    a.danger_level_id,
    radl.level_code AS danger_level_code,
    radl.level_name AS danger_level_name,
    radl.color_hex AS danger_color
   FROM (assets a
     LEFT JOIN ref_asset_danger_levels radl ON ((a.danger_level_id = radl.id)));

-- 5.11 Asset Group By Category View
CREATE OR REPLACE VIEW public.v_asset_group_by_category AS
 SELECT c.id AS category_id,
    c.category_name,
    count(a.id) AS total_assets
   FROM (((assets a
     LEFT JOIN ref_asset_types t ON ((t.id = a.type_id)))
     LEFT JOIN ref_asset_sub_categories sc ON ((sc.id = t.sub_category_id)))
     LEFT JOIN ref_asset_categories c ON ((c.id = sc.category_id)))
  GROUP BY c.id, c.category_name;

-- 5.12 Asset Group By Condition View
CREATE OR REPLACE VIEW public.v_asset_group_by_condition AS
 SELECT status_condition,
    count(*) AS total_assets
   FROM assets
  GROUP BY status_condition;

-- 5.13 Asset Group By Sub Category View
CREATE OR REPLACE VIEW public.v_asset_group_by_sub_category AS
 SELECT sc.id AS sub_category_id,
    sc.sub_category_name,
    count(a.id) AS total_assets
   FROM ((assets a
     LEFT JOIN ref_asset_types t ON ((t.id = a.type_id)))
     LEFT JOIN ref_asset_sub_categories sc ON ((sc.id = t.sub_category_id)))
  GROUP BY sc.id, sc.sub_category_name;

-- 5.14 Asset Group By Type View
CREATE OR REPLACE VIEW public.v_asset_group_by_type AS
 SELECT t.id AS type_id,
    t.type_name,
    count(a.id) AS total_assets
   FROM (assets a
     LEFT JOIN ref_asset_types t ON ((t.id = a.type_id)))
  GROUP BY t.id, t.type_name;

-- 5.15 Asset Master Complete View
CREATE OR REPLACE VIEW public.v_asset_master_complete AS
 SELECT a.id,
    a.rfid_tag_id,
    a.asset_name,
    a.description,
    a.foto_url,
    rac.id AS category_id,
    rac.category_name,
    rac.icon_name AS category_icon,
    rac.marker_color AS category_color,
    rasc.id AS sub_category_id,
    rasc.sub_category_name,
    rasc.icon_name AS sub_category_icon,
    rasc.marker_color AS sub_category_color,
    rat.id AS type_id,
    rat.type_name,
    rat.icon_name AS type_icon,
    rat.marker_color AS type_color,
    a.status_condition,
    a.level_contaminated,
    a.is_dangerous,
    a.handling_instruction,
    a.maintenance_pattern,
    a.is_active,
    a.inspection_day_of_month,
    a.last_inspection_at,
    a.next_inspection_at,
    a.last_inspection_result,
    a.last_inspection_notes,
    a.last_action_taken,
    a.last_recommendation,
    a.last_inspection_id,
    ai.id AS inspection_id,
    ai.inspection_type,
    ai.inspection_result,
    ai.condition_status AS inspection_condition_status,
    ai.contamination_level AS inspection_contamination_level,
    ai.notes AS inspection_notes,
    ai.action_taken AS inspection_action_taken,
    ai.recommendation AS inspection_recommendation,
    ai.inspected_at,
    ai.next_inspection_at AS inspection_next_schedule,
    ai.photo_url AS inspection_photo_url,
    ai.inspected_by AS inspector_id,
    ip.full_name AS inspector_name,
    ip.role AS inspector_role,
    ip.employee_id AS inspector_employee_id,
    ip.phone AS inspector_phone,
    ip.avatar_url AS inspector_avatar_url,
    a.last_room_id,
    r.room_name,
    a.last_detector_id,
    d.detector_code,
    a.last_detected_at,
    a.last_movement_status,
    a.last_used_by AS last_used_by_id,
    lup.full_name AS last_used_by_name,
    lup.role AS last_used_by_role,
    lup.employee_id AS last_used_by_employee_id,
    lup.phone AS last_used_by_phone,
    lup.avatar_url AS last_used_by_avatar,
    a.registered_by AS registered_by_id,
    rbp.full_name AS registered_by_name,
    rbp.role AS registered_by_role,
    rbp.employee_id AS registered_by_employee_id,
    a.updated_by AS updated_by_id,
    ubp.full_name AS updated_by_name,
    ubp.role AS updated_by_role,
    ubp.employee_id AS updated_by_employee_id,
    aa.id AS assignment_id,
    aa.assigned_at,
    aa.released_at,
    aa.assignment_status,
    aa.notes AS assignment_notes,
    aa.profile_id AS assigned_profile_id,
    app.full_name AS assigned_profile_name,
    app.role AS assigned_profile_role,
    app.employee_id AS assigned_profile_employee_id,
    app.phone AS assigned_profile_phone,
    app.avatar_url AS assigned_profile_avatar,
    aa.created_by AS assignment_created_by_id,
    acbp.full_name AS assignment_created_by_name,
    a.created_at,
    a.updated_at,
    a.registered_at,
    radl.id AS danger_level_id,
    radl.level_code AS danger_level_code,
    radl.level_name AS danger_level_name,
    radl.risk_description AS danger_risk,
    radl.protection_required AS danger_protection,
    radl.handling_instruction AS danger_instruction,
    radl.color_hex AS danger_color
   FROM ((((((((((((((assets a
     LEFT JOIN ref_asset_types rat ON ((a.type_id = rat.id)))
     LEFT JOIN ref_asset_sub_categories rasc ON ((rat.sub_category_id = rasc.id)))
     LEFT JOIN ref_asset_categories rac ON ((rasc.category_id = rac.id)))
     LEFT JOIN asset_inspections ai ON ((a.last_inspection_id = ai.id)))
     LEFT JOIN profiles ip ON ((ai.inspected_by = ip.id)))
     LEFT JOIN rooms r ON ((a.last_room_id = r.id)))
     LEFT JOIN detectors d ON ((a.last_detector_id = d.id)))
     LEFT JOIN profiles lup ON ((a.last_used_by = lup.id)))
     LEFT JOIN profiles rbp ON ((a.registered_by = rbp.id)))
     LEFT JOIN profiles ubp ON ((a.updated_by = ubp.id)))
     LEFT JOIN asset_assignments aa ON (((a.id = aa.asset_id) AND (aa.released_at IS NULL))))
     LEFT JOIN profiles app ON ((aa.profile_id = app.id)))
     LEFT JOIN profiles acbp ON ((aa.created_by = acbp.id)))
     LEFT JOIN ref_asset_danger_levels radl ON ((a.danger_level_id = radl.id)));

-- 5.16 Asset Report View
CREATE OR REPLACE VIEW public.v_asset_report AS
 SELECT a.id,
    a.rfid_tag_id,
    a.asset_name,
    a.status_condition,
    a.level_contaminated,
    a.is_dangerous,
    a.last_room_id,
    r.room_name AS last_room_name,
    a.maintenance_pattern,
    a.is_active,
    a.registered_at,
    a.last_inspection_at,
    a.last_inspection_result,
    a.next_inspection_at,
    a.type_id,
    t.type_name,
    a.registered_by,
    reg.full_name AS registered_by_name,
    aa.profile_id AS current_user_id,
        CASE
            WHEN (aa.assignment_status = 'active'::text) THEN pu.full_name
            ELSE NULL::text
        END AS current_user_name,
    aa.assignment_status AS last_assignment_status,
    ins.inspected_by AS last_inspector_id,
    insp.full_name AS last_inspector_name,
        CASE
            WHEN (a.next_inspection_at IS NULL) THEN 'Tidak Ditentukan'::text
            WHEN (a.next_inspection_at < now()) THEN 'Terlewat'::text
            ELSE 'Sesuai Jadwal'::text
        END AS inspection_status,
        CASE
            WHEN (a.is_active = false) THEN 'Tidak Aktif'::text
            WHEN (aa.assignment_status = 'active'::text) THEN 'Digunakan'::text
            WHEN ((a.status_condition)::text = ANY ((ARRAY['Damage'::character varying, 'Critical'::character varying])::text[])) THEN 'Rusak'::text
            WHEN ((a.status_condition)::text = 'Under Maintenance'::text) THEN 'Perawatan'::text
            ELSE 'Tersedia'::text
        END AS availability_status
   FROM (((((((assets a
     LEFT JOIN ref_asset_types t ON ((t.id = a.type_id)))
     LEFT JOIN rooms r ON ((r.id = a.last_room_id)))
     LEFT JOIN profiles reg ON ((reg.id = a.registered_by)))
     LEFT JOIN LATERAL ( SELECT asset_assignments.id,
            asset_assignments.asset_id,
            asset_assignments.profile_id,
            asset_assignments.assigned_at,
            asset_assignments.released_at,
            asset_assignments.assignment_status,
            asset_assignments.notes,
            asset_assignments.created_by,
            asset_assignments.app_id,
            asset_assignments.assigned_by,
            asset_assignments.assignment_type,
            asset_assignments.handover_location_id,
            asset_assignments.return_location_id,
            asset_assignments.contamination_responsibility,
            asset_assignments.created_at,
            asset_assignments.updated_at
           FROM asset_assignments
          WHERE (asset_assignments.asset_id = a.id)
          ORDER BY asset_assignments.created_at DESC
         LIMIT 1) aa ON (true))
     LEFT JOIN profiles pu ON (((pu.id = aa.profile_id) AND (aa.assignment_status = 'active'::text))))
     LEFT JOIN asset_inspections ins ON ((ins.id = a.last_inspection_id)))
     LEFT JOIN profiles insp ON ((insp.id = ins.inspected_by)));

-- 5.17 Assets With Status View
CREATE OR REPLACE VIEW public.v_assets_with_status AS
 SELECT a.id,
    a.rfid_tag_id,
    a.asset_name,
    a.type_id,
    t.type_name,
    a.foto_url,
    a.status_condition,
    a.level_contaminated,
    a.is_dangerous,
    a.handling_instruction,
    a.is_active,
    a.description,
    a.last_room_id,
    r.room_name AS last_room_name,
    aa.assignment_status AS current_assignment_status,
    aa.profile_id AS current_user_id,
    p.full_name AS current_user_name,
    aa.assigned_at AS current_assigned_at,
    aa.assigned_by AS current_assigned_by,
    admin.full_name AS current_assigned_by_name,
    aa.handover_location_id,
    hr.room_name AS handover_location_name,
        CASE
            WHEN (aa.assignment_status IS NULL) THEN 'available'::text
            WHEN (aa.assignment_status = 'pending'::text) THEN 'pending'::text
            WHEN (aa.assignment_status = 'active'::text) THEN 'in_use'::text
            WHEN (aa.assignment_status = 'released'::text) THEN 'available'::text
            WHEN (aa.assignment_status = 'transferred'::text) THEN 'in_use'::text
            WHEN (aa.assignment_status = 'lost'::text) THEN 'lost'::text
            WHEN (aa.assignment_status = 'maintenance'::text) THEN 'maintenance'::text
            ELSE 'available'::text
        END AS availability_status
   FROM ((((((assets a
     LEFT JOIN ref_asset_types t ON ((t.id = a.type_id)))
     LEFT JOIN rooms r ON ((r.id = a.last_room_id)))
     LEFT JOIN LATERAL ( SELECT asset_assignments.id,
            asset_assignments.asset_id,
            asset_assignments.profile_id,
            asset_assignments.assigned_at,
            asset_assignments.released_at,
            asset_assignments.assignment_status,
            asset_assignments.notes,
            asset_assignments.created_by,
            asset_assignments.app_id,
            asset_assignments.assigned_by,
            asset_assignments.assignment_type,
            asset_assignments.handover_location_id,
            asset_assignments.return_location_id,
            asset_assignments.contamination_responsibility,
            asset_assignments.created_at,
            asset_assignments.updated_at
           FROM asset_assignments
          WHERE (asset_assignments.asset_id = a.id)
          ORDER BY asset_assignments.assigned_at DESC NULLS LAST, asset_assignments.created_at DESC
         LIMIT 1) aa ON (true))
     LEFT JOIN profiles p ON ((p.id = aa.profile_id)))
     LEFT JOIN profiles admin ON ((admin.id = aa.assigned_by)))
     LEFT JOIN rooms hr ON ((hr.id = aa.handover_location_id)));

-- 5.18 CRUD Stocks View
CREATE OR REPLACE VIEW public.v_crud_stocks AS
 SELECT s.id,
    s.stock_code,
    s.stock_name,
    s.stock_type_id,
    rst.type_name AS stock_type_name,
    rst.description AS stock_type_description,
    s.unit,
    s.minimum_stock,
    s.current_stock,
    s.stock_condition,
    s.photo_url,
    s.is_active,
    s.last_opname_at,
    s.last_opname_by,
    p_opname.full_name AS last_opname_by_name,
    p_opname.employee_id AS last_opname_by_employee_id,
    s.last_opname_note,
    s.last_opname_stock,
    s.last_purchase_at,
    s.last_purchase_by,
    p_purchase.full_name AS last_purchase_by_name,
    p_purchase.employee_id AS last_purchase_by_employee_id,
    s.last_purchase_qty,
    s.last_purchase_price,
    s.last_usage_at,
    s.last_usage_by,
    p_usage.full_name AS last_usage_by_name,
    p_usage.employee_id AS last_usage_by_employee_id,
    s.last_usage_qty,
    s.storage_location_id,
    sl.location_name AS storage_location_name,
    sl.location_code AS storage_location_code,
    s.batch_number,
    s.description,
    s.expiry_date,
    s.updated_at,
    s.created_at,
    s.created_by,
    p_created.full_name AS created_by_name,
    p_created.employee_id AS created_by_employee_id,
        CASE
            WHEN (s.current_stock <= (0)::numeric) THEN true
            ELSE false
        END AS is_empty,
        CASE
            WHEN (s.current_stock <= s.minimum_stock) THEN true
            ELSE false
        END AS is_low_stock,
        CASE
            WHEN (s.current_stock > s.minimum_stock) THEN true
            ELSE false
        END AS is_stock_safe,
    lower((rst.type_name)::text) AS sort_type_name,
    lower((s.stock_name)::text) AS sort_stock_name
   FROM ((((((stocks s
     LEFT JOIN ref_stock_types rst ON ((rst.id = s.stock_type_id)))
     LEFT JOIN storage_locations sl ON ((sl.id = s.storage_location_id)))
     LEFT JOIN profiles p_opname ON ((p_opname.id = s.last_opname_by)))
     LEFT JOIN profiles p_purchase ON ((p_purchase.id = s.last_purchase_by)))
     LEFT JOIN profiles p_usage ON ((p_usage.id = s.last_usage_by)))
     LEFT JOIN profiles p_created ON ((p_created.id = s.created_by)));

-- 5.19 My Asset Requests View
CREATE OR REPLACE VIEW public.v_my_asset_requests AS
 SELECT aa.id,
    aa.asset_id,
    a.asset_name,
    a.foto_url,
    aa.profile_id,
    aa.assignment_status,
    aa.created_at AS requested_at,
    aa.assigned_at,
    aa.assigned_by,
    admin.full_name AS assigned_by_name,
    aa.notes,
    aa.handover_location_id,
    r.room_name AS handover_location_name
   FROM (((asset_assignments aa
     LEFT JOIN assets a ON ((a.id = aa.asset_id)))
     LEFT JOIN profiles admin ON ((admin.id = aa.assigned_by)))
     LEFT JOIN rooms r ON ((r.id = aa.handover_location_id)));

-- 5.20 Pending Assignments View
CREATE OR REPLACE VIEW public.v_pending_assignments AS
 SELECT aa.id,
    aa.asset_id,
    a.asset_name,
    a.foto_url,
    aa.profile_id,
    p.full_name AS requester_name,
    p.employee_id AS requester_employee_id,
    aa.notes,
    aa.assignment_status,
    aa.created_at AS requested_at,
    aa.handover_location_id,
    r.room_name AS handover_location_name
   FROM (((asset_assignments aa
     LEFT JOIN assets a ON ((a.id = aa.asset_id)))
     LEFT JOIN profiles p ON ((p.id = aa.profile_id)))
     LEFT JOIN rooms r ON ((r.id = aa.handover_location_id)))
  WHERE (aa.assignment_status = 'pending'::text)
  ORDER BY aa.created_at;

-- 5.21 SLA Violations View
CREATE OR REPLACE VIEW public.v_sla_violations AS
 SELECT t.id AS task_id,
    t.object_name,
    t.assignee_id,
    p.full_name AS assignee_name,
    p.unit_code,
    t.priority,
    t.sla_minutes,
    t.status,
    t.created_at,
    (EXTRACT(epoch FROM (now() - t.created_at)) / (60)::numeric) AS minutes_elapsed,
        CASE
            WHEN ((t.status = ANY (ARRAY['pending'::text, 'in_progress'::text])) AND (now() > (t.created_at + ((t.sla_minutes || ' minutes'::text))::interval))) THEN 'BREACHED'::text
            ELSE 'OK'::text
        END AS sla_status
   FROM (tasks t
     LEFT JOIN profiles p ON ((p.id = t.assignee_id)))
  WHERE ((t.status = ANY (ARRAY['pending'::text, 'in_progress'::text])) AND (t.sla_minutes IS NOT NULL));

-- 5.22 Stocks View
CREATE OR REPLACE VIEW public.v_stocks AS
 SELECT s.id,
    s.stock_code,
    s.stock_name,
    s.stock_type_id,
    rst.type_name AS stock_type_name,
    rst.description AS stock_type_description,
    s.unit,
    s.minimum_stock,
    s.current_stock,
    s.stock_condition,
    s.photo_url,
    s.is_active,
    s.last_opname_at,
    s.last_opname_by,
    p_opname.full_name AS last_opname_by_name,
    p_opname.employee_id AS last_opname_by_employee_id,
    s.last_opname_note,
    s.last_opname_stock,
    s.last_purchase_at,
    s.last_purchase_by,
    p_purchase.full_name AS last_purchase_by_name,
    p_purchase.employee_id AS last_purchase_by_employee_id,
    s.last_purchase_qty,
    s.last_purchase_price,
    s.last_usage_at,
    s.last_usage_by,
    p_usage.full_name AS last_usage_by_name,
    p_usage.employee_id AS last_usage_by_employee_id,
    s.last_usage_qty,
    s.updated_at,
    s.created_at,
        CASE
            WHEN (s.current_stock <= (0)::numeric) THEN true
            ELSE false
        END AS is_empty,
        CASE
            WHEN (s.current_stock <= s.minimum_stock) THEN true
            ELSE false
        END AS is_low_stock,
        CASE
            WHEN (s.current_stock > s.minimum_stock) THEN true
            ELSE false
        END AS is_stock_safe,
    lower((rst.type_name)::text) AS sort_type_name,
    lower((s.stock_name)::text) AS sort_stock_name
   FROM ((((stocks s
     LEFT JOIN ref_stock_types rst ON ((rst.id = s.stock_type_id)))
     LEFT JOIN profiles p_opname ON ((p_opname.id = s.last_opname_by)))
     LEFT JOIN profiles p_purchase ON ((p_purchase.id = s.last_purchase_by)))
     LEFT JOIN profiles p_usage ON ((p_usage.id = s.last_usage_by)));

-- 5.23 Unresolved Incidents View
CREATE OR REPLACE VIEW public.v_unresolved_incidents AS
 SELECT i.id,
    i.title,
    i.severity,
    i.status,
    i.occurred_at,
    (EXTRACT(epoch FROM (now() - i.occurred_at)) / (60)::numeric) AS minutes_elapsed,
    i.category_id,
    ic.name AS category_name,
    i.reported_by,
    p.full_name AS reported_by_name,
    i.room_id,
    r.room_name,
    i.action_task_ids,
    i.action_announcement_ids
   FROM (((incidents i
     LEFT JOIN ref_incident_categories ic ON ((ic.id = i.category_id)))
     LEFT JOIN profiles p ON ((p.id = i.reported_by)))
     LEFT JOIN rooms r ON ((r.id = i.room_id)))
  WHERE ((i.status)::text <> ALL ((ARRAY['resolved'::character varying, 'closed'::character varying])::text[]))
  ORDER BY
        CASE i.severity
            WHEN 'CRITICAL'::text THEN 1
            WHEN 'HIGH'::text THEN 2
            WHEN 'MEDIUM'::text THEN 3
            WHEN 'LOW'::text THEN 4
            ELSE NULL::integer
        END, i.occurred_at;

-- 5.24 View Asset Live (Tracking)
CREATE OR REPLACE VIEW public.view_asset_live AS
 SELECT a.id AS asset_id,
    a.id AS entity_id,
    'asset'::text AS entity_type,
    a.rfid_tag_id,
    a.asset_name,
    a.foto_url,
    rat.type_name AS category_name,
    rat.marker_color,
    a.status_condition,
    COALESCE(a.level_contaminated, 0) AS level_contaminated,
    a.is_dangerous,
    a.handling_instruction,
    a.last_detected_at,
    a.last_movement_status,
    a.updated_at,
        CASE
            WHEN (a.last_detected_at IS NULL) THEN 'UNKNOWN'::text
            WHEN ((now() - a.last_detected_at) > '00:10:00'::interval) THEN 'OFFLINE'::text
            ELSE 'ONLINE'::text
        END AS tracking_status,
    d.detector_code,
    r.id AS room_id,
    COALESCE(r.room_name, 'UNKNOWN'::character varying) AS room_name,
    r.x_pos,
    r.y_pos,
    f.id AS floor_id,
    f.floor_number,
    f.floor_alias,
    f.map_image_url,
    b.id AS building_id,
    r.x_pos AS room_x_min,
    r.y_pos AS room_y_min,
    r.x_pos_max AS room_x_max,
    r.y_pos_max AS room_y_max
   FROM (((((assets a
     LEFT JOIN detectors d ON ((a.last_detector_id = d.id)))
     LEFT JOIN rooms r ON ((a.last_room_id = r.id)))
     LEFT JOIN floors f ON ((r.floor_id = f.id)))
     LEFT JOIN buildings b ON ((f.building_id = b.id)))
     LEFT JOIN ref_asset_types rat ON ((a.type_id = rat.id)))
  WHERE (a.is_active = true);

-- 5.25 View People Live (Tracking)
CREATE OR REPLACE VIEW public.view_people_live AS
 SELECT p.id AS person_id,
    p.id AS entity_id,
    'person'::text AS entity_type,
    p.rfid_tag_id,
    p.full_name,
    p.is_male,
    p.is_child,
    p.foto_url,
    pc.category_name,
    COALESCE((p.level_contaminated)::integer, 0) AS level_contaminated,
    p.last_detected_at,
    p.last_movement_status,
    p.updated_at,
        CASE
            WHEN (p.last_detected_at IS NULL) THEN 'UNKNOWN'::text
            WHEN ((now() - p.last_detected_at) > '00:10:00'::interval) THEN 'OFFLINE'::text
            ELSE 'ONLINE'::text
        END AS tracking_status,
    d.detector_code,
    r.id AS room_id,
    COALESCE(r.room_name, 'UNKNOWN'::character varying) AS room_name,
    r.x_pos,
    r.y_pos,
    f.id AS floor_id,
    f.floor_number,
    f.floor_alias,
    f.map_image_url,
    b.id AS building_id,
    pc.marker_color,
    r.x_pos AS room_x_min,
    r.y_pos AS room_y_min,
    r.x_pos_max AS room_x_max,
    r.y_pos_max AS room_y_max
   FROM (((((people p
     LEFT JOIN detectors d ON ((p.last_detector_id = d.id)))
     LEFT JOIN rooms r ON ((p.last_room_id = r.id)))
     LEFT JOIN floors f ON ((r.floor_id = f.id)))
     LEFT JOIN buildings b ON ((f.building_id = b.id)))
     LEFT JOIN ref_people_categories pc ON ((p.category_id = pc.id)))
  WHERE (p.is_active = true);

-- 5.26 Asset Alert Summary View
CREATE OR REPLACE VIEW public.vw_asset_alert_summary AS
 SELECT count(*) FILTER (WHERE (is_dangerous = true)) AS dangerous_assets,
    count(*) FILTER (WHERE (level_contaminated >= 4)) AS critical_contamination_assets,
    count(*) FILTER (WHERE ((status_condition)::text = 'Critical'::text)) AS critical_condition_assets,
    count(*) FILTER (WHERE ((next_inspection_at IS NOT NULL) AND (next_inspection_at < now()))) AS overdue_inspection_assets,
    count(*) FILTER (WHERE ((status_condition)::text = 'Damaged'::text)) AS damaged_assets,
    now() AS generated_at
   FROM assets;

-- 5.27 Asset Category Summary View
CREATE OR REPLACE VIEW public.vw_asset_category_summary AS
 SELECT c.id AS category_id,
    c.category_name,
    c.icon_name,
    c.marker_color,
    count(a.id) AS total_assets,
    count(a.id) FILTER (WHERE (a.is_active = true)) AS active_assets,
    count(a.id) FILTER (WHERE ((a.status_condition)::text = 'Good'::text)) AS good_assets,
    count(a.id) FILTER (WHERE ((a.status_condition)::text = 'Maintenance'::text)) AS maintenance_assets,
    count(a.id) FILTER (WHERE ((a.status_condition)::text = 'Damaged'::text)) AS damaged_assets,
    count(a.id) FILTER (WHERE ((a.status_condition)::text = 'Critical'::text)) AS critical_assets,
    count(a.id) FILTER (WHERE (a.is_dangerous = true)) AS dangerous_assets,
    count(a.id) FILTER (WHERE (a.level_contaminated >= 3)) AS high_contamination_assets
   FROM (((ref_asset_categories c
     LEFT JOIN ref_asset_sub_categories sc ON ((sc.category_id = c.id)))
     LEFT JOIN ref_asset_types t ON ((t.sub_category_id = sc.id)))
     LEFT JOIN assets a ON ((a.type_id = t.id)))
  GROUP BY c.id, c.category_name, c.icon_name, c.marker_color
  ORDER BY (count(a.id)) DESC;

-- 5.28 Asset Health Summary View
CREATE OR REPLACE VIEW public.vw_asset_health_summary AS
 SELECT status_condition,
    count(*) AS total_assets,
    count(*) FILTER (WHERE (is_active = true)) AS active_assets,
    count(*) FILTER (WHERE (is_dangerous = true)) AS dangerous_assets,
    count(*) FILTER (WHERE (level_contaminated >= 3)) AS high_contamination_assets
   FROM assets
  GROUP BY status_condition
  ORDER BY (count(*)) DESC;

-- 5.29 Asset Inspection Summary View
CREATE OR REPLACE VIEW public.vw_asset_inspection_summary AS
 SELECT count(*) FILTER (WHERE ((next_inspection_at IS NOT NULL) AND (next_inspection_at < now()))) AS overdue_inspection_assets,
    count(*) FILTER (WHERE ((next_inspection_at IS NOT NULL) AND (date(next_inspection_at) = CURRENT_DATE))) AS inspection_due_today,
    count(*) FILTER (WHERE ((next_inspection_at IS NOT NULL) AND (next_inspection_at >= CURRENT_DATE) AND (next_inspection_at < (CURRENT_DATE + '7 days'::interval)))) AS inspection_due_this_week,
    count(*) FILTER (WHERE (last_inspection_at IS NULL)) AS never_inspected_assets,
    now() AS generated_at
   FROM assets;

-- 5.30 Asset Overview KPI View
CREATE OR REPLACE VIEW public.vw_asset_overview_kpi AS
 SELECT count(*) AS total_assets,
    count(*) FILTER (WHERE (is_active = true)) AS active_assets,
    count(*) FILTER (WHERE (is_active = false)) AS inactive_assets,
    count(*) FILTER (WHERE ((status_condition)::text = 'Good'::text)) AS good_assets,
    count(*) FILTER (WHERE ((status_condition)::text = 'Maintenance'::text)) AS maintenance_assets,
    count(*) FILTER (WHERE ((status_condition)::text = 'Damaged'::text)) AS damaged_assets,
    count(*) FILTER (WHERE ((status_condition)::text = 'Critical'::text)) AS critical_assets,
    count(*) FILTER (WHERE (is_dangerous = true)) AS dangerous_assets,
    count(*) FILTER (WHERE (level_contaminated >= 3)) AS high_contamination_assets,
    now() AS generated_at
   FROM assets;

-- 5.31 Asset Subcategory Summary View
CREATE OR REPLACE VIEW public.vw_asset_subcategory_summary AS
 SELECT sc.id AS sub_category_id,
    sc.sub_category_name,
    sc.icon_name,
    sc.marker_color,
    c.id AS category_id,
    c.category_name,
    count(a.id) AS total_assets,
    count(a.id) FILTER (WHERE (a.is_active = true)) AS active_assets,
    count(a.id) FILTER (WHERE ((a.status_condition)::text = 'Good'::text)) AS good_assets,
    count(a.id) FILTER (WHERE ((a.status_condition)::text = 'Maintenance'::text)) AS maintenance_assets,
    count(a.id) FILTER (WHERE ((a.status_condition)::text = 'Damaged'::text)) AS damaged_assets,
    count(a.id) FILTER (WHERE ((a.status_condition)::text = 'Critical'::text)) AS critical_assets
   FROM (((ref_asset_sub_categories sc
     LEFT JOIN ref_asset_categories c ON ((sc.category_id = c.id)))
     LEFT JOIN ref_asset_types t ON ((t.sub_category_id = sc.id)))
     LEFT JOIN assets a ON ((a.type_id = t.id)))
  GROUP BY sc.id, sc.sub_category_name, sc.icon_name, sc.marker_color, c.id, c.category_name
  ORDER BY (count(a.id)) DESC;

-- 5.32 Asset Taxonomy View
CREATE OR REPLACE VIEW public.vw_asset_taxonomy AS
 SELECT a.id,
    a.asset_name,
    a.foto_url,
    a.status_condition,
    a.level_contaminated,
    a.is_dangerous,
    a.is_active,
    a.maintenance_pattern,
    a.inspection_day_of_month,
    a.last_inspection_at,
    a.next_inspection_at,
    a.last_inspection_result,
    a.last_action_taken,
    a.last_recommendation,
    a.created_at,
    a.updated_at,
    t.id AS type_id,
    t.type_name,
    t.icon_name AS type_icon,
    t.marker_color AS type_color,
    sc.id AS sub_category_id,
    sc.sub_category_name,
    sc.icon_name AS sub_category_icon,
    sc.marker_color AS sub_category_color,
    c.id AS category_id,
    c.category_name,
    c.icon_name AS category_icon,
    c.marker_color AS category_color
   FROM (((assets a
     LEFT JOIN ref_asset_types t ON ((a.type_id = t.id)))
     LEFT JOIN ref_asset_sub_categories sc ON ((t.sub_category_id = sc.id)))
     LEFT JOIN ref_asset_categories c ON ((sc.category_id = c.id)));

-- 5.33 Asset Type Summary View
CREATE OR REPLACE VIEW public.vw_asset_type_summary AS
 SELECT t.id AS type_id,
    t.type_name,
    t.icon_name,
    t.marker_color,
    sc.id AS sub_category_id,
    sc.sub_category_name,
    c.id AS category_id,
    c.category_name,
    count(a.id) AS total_assets,
    count(a.id) FILTER (WHERE (a.is_active = true)) AS active_assets,
    count(a.id) FILTER (WHERE ((a.status_condition)::text = 'Good'::text)) AS good_assets,
    count(a.id) FILTER (WHERE ((a.status_condition)::text = 'Maintenance'::text)) AS maintenance_assets,
    count(a.id) FILTER (WHERE ((a.status_condition)::text = 'Damaged'::text)) AS damaged_assets,
    count(a.id) FILTER (WHERE ((a.status_condition)::text = 'Critical'::text)) AS critical_assets,
    count(a.id) FILTER (WHERE (a.is_dangerous = true)) AS dangerous_assets,
    count(a.id) FILTER (WHERE (a.level_contaminated >= 3)) AS high_contamination_assets
   FROM (((ref_asset_types t
     LEFT JOIN ref_asset_sub_categories sc ON ((t.sub_category_id = sc.id)))
     LEFT JOIN ref_asset_categories c ON ((sc.category_id = c.id)))
     LEFT JOIN assets a ON ((a.type_id = t.id)))
  GROUP BY t.id, t.type_name, t.icon_name, t.marker_color, sc.id, sc.sub_category_name, c.id, c.category_name
  ORDER BY (count(a.id)) DESC;
-- ============================================================
-- 3. CREATE FUNCTIONS
-- ============================================================

-- 3.1 Wellbeing & Fatigue Functions
CREATE OR REPLACE FUNCTION public.fn_calculate_predicted_fatigue()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
  v_consecutive_days INTEGER;
  v_shift_hours INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_consecutive_days
  FROM employee_shift_rosters
  WHERE profile_id = NEW.profile_id
    AND roster_date >= (NEW.roster_date - INTERVAL '7 days')
    AND roster_date <= NEW.roster_date
    AND is_day_off = false;
  
  SELECT EXTRACT(HOUR FROM (end_time - start_time)) INTO v_shift_hours
  FROM ref_shifts WHERE id = NEW.shift_id;
  
  NEW.predicted_fatigue_score := LEAST(10, 
    (v_consecutive_days * 0.5) + 
    (v_shift_hours / 8.0) * 2 +
    (CASE WHEN NEW.is_overtime_planned THEN 2 ELSE 0 END)
  );
  
  NEW.wellbeing_risk_level := CASE
    WHEN NEW.predicted_fatigue_score <= 3 THEN 'low'
    WHEN NEW.predicted_fatigue_score <= 6 THEN 'medium'
    WHEN NEW.predicted_fatigue_score <= 8 THEN 'high'
    ELSE 'critical'
  END;
  
  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.fn_check_wellbeing_alert()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.requires_attention := 
    NEW.fatigue_score > 7 OR 
    NEW.stress_score > 7 OR 
    NEW.mood_score < 3 OR
    NEW.energy_score < 3 OR
    NEW.sleep_hours < 5;
  
  RETURN NEW;
END;
$function$;

-- 3.2 Leave & Qualification Functions
CREATE OR REPLACE FUNCTION public.fn_calc_leave_days()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.total_days = (NEW.end_date - NEW.start_date) + 1;
  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.fn_calc_qualification_expiry()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
  v_validity_months INTEGER;
BEGIN
  SELECT validity_period_months INTO v_validity_months
  FROM employee_qualifications WHERE id = NEW.qualification_id;
  
  IF v_validity_months IS NOT NULL AND v_validity_months > 0 THEN
    NEW.expiry_date = NEW.acquired_date + (v_validity_months || ' months')::INTERVAL;
  END IF;
  
  RETURN NEW;
END;
$function$;

-- 3.3 Profile Functions
CREATE OR REPLACE FUNCTION public.fn_set_join_year()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.join_date IS NOT NULL THEN
    NEW.join_year = EXTRACT(YEAR FROM NEW.join_date);
    NEW.int_sequence = EXTRACT(YEAR FROM NOW()) - NEW.join_year + 1;
    NEW.int_label = CASE
      WHEN NEW.int_sequence = 1 THEN '1st'
      WHEN NEW.int_sequence = 2 THEN '2nd'
      WHEN NEW.int_sequence = 3 THEN '3rd'
      WHEN NEW.int_sequence = 4 THEN '4th'
      WHEN NEW.int_sequence = 5 THEN '5th'
      ELSE NEW.int_sequence::text || 'th'
    END;
  END IF;
  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.fn_sync_profile_to_people()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_category_id UUID;
    v_rfid_tag_id VARCHAR(100);
BEGIN
    IF (TG_OP = 'DELETE') THEN
        UPDATE public.people
        SET is_active = false, updated_at = NOW()
        WHERE app_id = OLD.id;
        RETURN OLD;
    END IF;
    
    IF NEW.rfid_tag IS NOT NULL AND NEW.rfid_tag != '' THEN
        v_rfid_tag_id := NEW.rfid_tag;
    ELSE
        v_rfid_tag_id := NEW.employee_id;
    END IF;
    
    IF v_rfid_tag_id IS NULL OR v_rfid_tag_id = '' THEN
        v_rfid_tag_id := NEW.id::VARCHAR(100);
    END IF;
    
    SELECT id INTO v_category_id
    FROM public.ref_people_categories
    WHERE LOWER(category_name) = LOWER(NEW.role)
    LIMIT 1;
    
    IF v_category_id IS NULL THEN
        SELECT id INTO v_category_id
        FROM public.ref_people_categories
        WHERE LOWER(category_name) = 'employee'
        LIMIT 1;
    END IF;
    
    INSERT INTO public.people (
        app_id, rfid_tag_id, full_name, category_id, foto_url,
        is_male, is_child, is_active, updated_at
    ) VALUES (
        NEW.id, v_rfid_tag_id, COALESCE(NEW.full_name, 'Unknown'),
        v_category_id, NEW.avatar_url,
        CASE WHEN NEW.gender = 'M' OR NEW.gender = 'm' THEN true ELSE false END,
        false, NEW.is_approved, NOW()
    ) ON CONFLICT (rfid_tag_id) DO UPDATE SET
        app_id = EXCLUDED.app_id,
        full_name = EXCLUDED.full_name,
        category_id = EXCLUDED.category_id,
        foto_url = EXCLUDED.foto_url,
        is_active = EXCLUDED.is_active,
        updated_at = EXCLUDED.updated_at;
    
    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Error in fn_sync_profile_to_people: %', SQLERRM;
    RETURN NEW;
END;
$function$;

-- 3.4 Movement & Tracking Functions
CREATE OR REPLACE FUNCTION public.fn_determine_movement_status()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
    is_registered boolean;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM public.people WHERE rfid_tag_id = NEW.rfid_tag_id
    ) INTO is_registered;

    IF NOT is_registered THEN
        RAISE EXCEPTION 'RFID Tag % tidak terdaftar di sistem!', NEW.rfid_tag_id;
        RETURN NULL; 
    END IF;

    RETURN NEW;
END;
$function$;

-- 3.5 Asset Functions
CREATE OR REPLACE FUNCTION public.fn_update_asset_last_inspection()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE public.assets
    SET
        last_inspection_id = NEW.id,
        last_inspection_at = NEW.inspected_at,
        next_inspection_at = NEW.next_inspection_at,
        status_condition = COALESCE(NEW.condition_status, status_condition),
        level_contaminated = COALESCE(NEW.contamination_level, level_contaminated),
        last_inspection_result = NEW.inspection_result,
        last_inspection_notes = NEW.notes,
        last_action_taken = NEW.action_taken,
        last_recommendation = NEW.recommendation,
        updated_at = now(),
        updated_by = NEW.inspected_by
    WHERE id = NEW.asset_id;
    RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.fn_update_asset_last_user()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE public.assets
    SET
        last_used_by = NEW.profile_id,
        last_assigned_at = NEW.assigned_at,
        updated_at = now()
    WHERE id = NEW.asset_id;
    RETURN NEW;
END;
$function$;

-- 3.6 Stock Functions
CREATE OR REPLACE FUNCTION public.fn_stock_opname_update()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
    IF NEW.bin_id IS NOT NULL AND NEW.stock_in_bins_id IS NOT NULL THEN
        UPDATE stock_in_bins
        SET quantity = NEW.physical_stock, updated_at = NOW()
        WHERE id = NEW.stock_in_bins_id;
    ELSE
        UPDATE stocks
        SET current_stock = NEW.physical_stock,
            last_opname_at = NEW.opname_at,
            last_opname_by = NEW.opname_by,
            last_opname_note = NEW.opname_note,
            last_opname_stock = NEW.stock_before,
            updated_at = NOW()
        WHERE id = NEW.stock_id;
    END IF;
    RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.fn_stock_purchase_update()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
declare
    v_stock_before numeric;
    v_stock_after numeric;
    v_condition varchar;
begin
    select current_stock into v_stock_before
    from public.stocks where id = new.stock_id;

    if v_stock_before is null then
        raise exception 'Stock tidak ditemukan';
    end if;

    v_stock_after := coalesce(v_stock_before,0) + coalesce(new.qty,0);

    select case
        when v_stock_after <= 0 then 'EMPTY'
        when v_stock_after <= minimum_stock then 'LOW'
        else 'GOOD'
    end into v_condition
    from public.stocks where id = new.stock_id;

    update public.stocks set
        current_stock = v_stock_after,
        stock_condition = v_condition,
        last_purchase_at = new.purchased_at,
        last_purchase_by = new.purchased_by,
        last_purchase_qty = new.qty,
        last_purchase_price = new.purchase_price,
        updated_at = now()
    where id = new.stock_id;

    insert into public.stock_transactions (
        stock_id, transaction_type, qty, stock_before, stock_after,
        transaction_note, created_by
    ) values (
        new.stock_id, 'PURCHASE', new.qty, v_stock_before, v_stock_after,
        new.purchase_note, new.purchased_by
    );

    return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.fn_stock_usage_update()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
declare
    v_stock_before numeric;
    v_stock_after numeric;
    v_condition varchar;
begin
    select current_stock into v_stock_before
    from public.stocks where id = new.stock_id;

    if v_stock_before is null then
        raise exception 'Stock tidak ditemukan';
    end if;

    v_stock_after := coalesce(v_stock_before,0) - coalesce(new.qty_used,0);

    if v_stock_after < 0 then
        raise exception 'Stock tidak mencukupi';
    end if;

    select case
        when v_stock_after <= 0 then 'EMPTY'
        when v_stock_after <= minimum_stock then 'LOW'
        else 'GOOD'
    end into v_condition
    from public.stocks where id = new.stock_id;

    update public.stocks set
        current_stock = v_stock_after,
        stock_condition = v_condition,
        last_usage_at = new.used_at,
        last_usage_by = new.used_by,
        last_usage_qty = new.qty_used,
        updated_at = now()
    where id = new.stock_id;

    insert into public.stock_transactions (
        stock_id, transaction_type, qty, stock_before, stock_after,
        transaction_note, created_by
    ) values (
        new.stock_id, 'USAGE', new.qty_used, v_stock_before, v_stock_after,
        new.usage_note, new.used_by
    );

    return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.add_stock_to_bin(
    p_bin_id uuid, p_stock_id uuid, p_batch_number character varying,
    p_expiry_date date, p_quantity numeric, p_unit character varying,
    p_notes text DEFAULT NULL::text
)
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
    v_existing_id UUID;
    v_existing_quantity NUMERIC;
BEGIN
    SELECT id, quantity INTO v_existing_id, v_existing_quantity
    FROM stock_in_bins
    WHERE bin_id = p_bin_id 
      AND stock_id = p_stock_id 
      AND batch_number = p_batch_number;
    
    IF FOUND THEN
        UPDATE stock_in_bins
        SET quantity = v_existing_quantity + p_quantity,
            updated_at = NOW(),
            notes = COALESCE(notes, '') || E'\n' || COALESCE(p_notes, 'Mutasi stok')
        WHERE id = v_existing_id;
    ELSE
        INSERT INTO stock_in_bins (
            id, bin_id, stock_id, batch_number, expiry_date, 
            quantity, notes, created_at, updated_at
        ) VALUES (
            gen_random_uuid(), p_bin_id, p_stock_id, p_batch_number, 
            p_expiry_date, p_quantity, p_notes, NOW(), NOW()
        );
    END IF;
END;
$function$;

CREATE OR REPLACE FUNCTION public.create_stock_mutation(
    p_mutation_number character varying, p_stock_in_bins_id uuid,
    p_bin_id_asal uuid, p_bin_id_tujuan uuid, p_stock_id uuid,
    p_batch_number character varying, p_expiry_date date,
    p_quantity numeric, p_unit character varying, p_moved_by uuid,
    p_received_by uuid, p_notes text DEFAULT NULL::text
)
RETURNS void
LANGUAGE plpgsql
AS $function$
BEGIN
    PERFORM reduce_stock_in_bins_quantity(p_stock_in_bins_id, p_quantity);
    
    PERFORM add_stock_to_bin(
        p_bin_id_tujuan, p_stock_id, p_batch_number, p_expiry_date,
        p_quantity, p_unit, p_notes
    );
    
    INSERT INTO stock_mutations (
        id, mutation_number, stock_in_bins_id, bin_id_asal, bin_id_tujuan,
        stock_id, batch_number, expiry_date, quantity, unit,
        moved_by, moved_at, received_by, received_at, notes
    ) VALUES (
        gen_random_uuid(), p_mutation_number, p_stock_in_bins_id, p_bin_id_asal, p_bin_id_tujuan,
        p_stock_id, p_batch_number, p_expiry_date, p_quantity, p_unit,
        p_moved_by, NOW(), p_received_by, NOW(), p_notes
    );
END;
$function$;

CREATE OR REPLACE FUNCTION public.reduce_stock_in_bins_quantity(p_stock_in_bins_id uuid, p_quantity numeric)
RETURNS void
LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE stock_in_bins
    SET quantity = quantity - p_quantity, updated_at = NOW()
    WHERE id = p_stock_in_bins_id;
END;
$function$;

-- 3.7 Generator Functions
CREATE OR REPLACE FUNCTION public.generate_request_number()
RETURNS character varying
LANGUAGE plpgsql
AS $function$
DECLARE
    today DATE := CURRENT_DATE;
    date_part VARCHAR(8);
    seq INT;
    seq_text VARCHAR(4);
BEGIN
    date_part := to_char(today, 'YYYYMMDD');
    SELECT COALESCE(COUNT(*), 0) INTO seq
    FROM stock_requests
    WHERE DATE(created_at) = today;
    seq_text := LPAD((seq + 1)::TEXT, 4, '0');
    RETURN 'SR-' || date_part || '-' || seq_text;
END;
$function$;

CREATE OR REPLACE FUNCTION public.generate_ticket_number()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
  seq_num INT;
  year_part TEXT;
  month_part TEXT;
BEGIN
  year_part := TO_CHAR(NOW(), 'YYYY');
  month_part := TO_CHAR(NOW(), 'MM');
  
  SELECT COALESCE(MAX(SUBSTRING(ticket_number FROM '[0-9]+$')::INT), 0) + 1 INTO seq_num
  FROM support_tickets
  WHERE ticket_number LIKE 'HOIP-' || year_part || month_part || '-%';
  
  NEW.ticket_number := 'HOIP-' || year_part || month_part || '-' || LPAD(seq_num::TEXT, 4, '0');
  RETURN NEW;
END;
$function$;

-- ============================================================
-- 4. CREATE TRIGGERS
-- ============================================================

CREATE TRIGGER trg_calc_leave_days
    BEFORE INSERT OR UPDATE OF start_date, end_date
    ON public.employee_leave_requests
    FOR EACH ROW
    EXECUTE FUNCTION public.fn_calc_leave_days();

CREATE TRIGGER trg_calc_qualification_expiry
    BEFORE INSERT OR UPDATE OF acquired_date
    ON public.employee_qualification_assignments
    FOR EACH ROW
    EXECUTE FUNCTION public.fn_calc_qualification_expiry();

CREATE TRIGGER trg_calculate_fatigue
    BEFORE INSERT OR UPDATE
    ON public.employee_shift_rosters
    FOR EACH ROW
    EXECUTE FUNCTION public.fn_calculate_predicted_fatigue();

CREATE TRIGGER trg_wellbeing_alert
    BEFORE INSERT
    ON public.employee_wellbeing_logs
    FOR EACH ROW
    EXECUTE FUNCTION public.fn_check_wellbeing_alert();

CREATE TRIGGER trg_set_movement_status
    BEFORE INSERT
    ON public.people_movements
    FOR EACH ROW
    EXECUTE FUNCTION public.fn_determine_movement_status();

CREATE TRIGGER trg_set_join_year
    BEFORE INSERT OR UPDATE OF join_date
    ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.fn_set_join_year();

CREATE TRIGGER trg_sync_profile_to_people
    AFTER INSERT OR DELETE OR UPDATE
    ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.fn_sync_profile_to_people();

CREATE TRIGGER trg_stock_opname_update
    AFTER INSERT
    ON public.stocks_opnames
    FOR EACH ROW
    EXECUTE FUNCTION public.fn_stock_opname_update();

CREATE TRIGGER trg_update_asset_last_inspection
    AFTER INSERT
    ON public.asset_inspections
    FOR EACH ROW
    EXECUTE FUNCTION public.fn_update_asset_last_inspection();

CREATE TRIGGER trg_update_asset_last_user
    AFTER INSERT
    ON public.asset_assignments
    FOR EACH ROW
    EXECUTE FUNCTION public.fn_update_asset_last_user();

CREATE TRIGGER trigger_generate_ticket_number
    BEFORE INSERT
    ON public.support_tickets
    FOR EACH ROW
    EXECUTE FUNCTION public.generate_ticket_number();

-- ============================================================
-- 5. SCRIPT SELESAI
-- ============================================================