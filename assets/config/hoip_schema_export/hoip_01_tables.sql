[
  {
    "ddl": "-- Table: announcements\nCREATE TABLE IF NOT EXISTS announcements (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  sender_id uuid NOT NULL,\n  title text NOT NULL,\n  content text NOT NULL,\n  priority text NOT NULL DEFAULT 'normal'::text,\n  target_building_id uuid,\n  target_floor_id uuid,\n  target_room_id uuid,\n  target_position_id uuid,\n  target_profile_id uuid,\n  created_at timestamptz DEFAULT now(),\n  expires_at timestamptz,\n  target_role text,\n  target_unit_id uuid,\n  target_permission_asset text,\n  target_permission_stock text,\n  target_flexible_roster boolean,\n  target_wellbeing_risk text,\n  target_join_year_start integer,\n  target_join_year_end integer,\n  target_situation text,\n  target_gender character,\n  target_rating_take_count_min integer,\n  target_rating_take_count_max integer,\n  target_int_sequence_min integer,\n  target_int_sequence_max integer,\n  target_fatigue_score_min numeric,\n  target_fatigue_score_max numeric\n);\n"
  },
  {
    "ddl": "-- Table: apps_config\nCREATE TABLE IF NOT EXISTS apps_config (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  client_name varchar NOT NULL,\n  license_key varchar NOT NULL,\n  supabase_url text NOT NULL,\n  supabase_anon_key text NOT NULL,\n  is_active boolean DEFAULT true,\n  created_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: asset_assignments\nCREATE TABLE IF NOT EXISTS asset_assignments (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  asset_id uuid NOT NULL,\n  profile_id uuid NOT NULL,\n  assigned_at timestamptz DEFAULT now(),\n  released_at timestamptz,\n  assignment_status text DEFAULT 'active'::text,\n  notes text,\n  created_by uuid,\n  app_id uuid,\n  assigned_by uuid,\n  assignment_type text,\n  handover_location_id uuid,\n  return_location_id uuid,\n  contamination_responsibility boolean DEFAULT false,\n  created_at timestamptz DEFAULT now(),\n  updated_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: asset_inspections\nCREATE TABLE IF NOT EXISTS asset_inspections (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  asset_id uuid NOT NULL,\n  inspected_by uuid NOT NULL,\n  inspection_type text,\n  inspection_result text,\n  condition_status text,\n  contamination_level integer,\n  notes text,\n  action_taken text,\n  recommendation text,\n  inspected_at timestamptz DEFAULT now(),\n  next_inspection_at timestamptz,\n  photo_url text,\n  app_id uuid,\n  task_id uuid,\n  risk_score numeric,\n  inspection_duration_minutes integer,\n  proof_video_url text,\n  ai_detected_issue text,\n  ai_prediction text,\n  ai_health_score numeric,\n  ai_failure_probability numeric,\n  fatigue_level numeric,\n  requires_followup boolean DEFAULT false,\n  followup_priority text,\n  created_at timestamptz DEFAULT now(),\n  updated_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: asset_movements\nCREATE TABLE IF NOT EXISTS asset_movements (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  asset_id uuid NOT NULL,\n  detector_id uuid NOT NULL,\n  movement_status varchar DEFAULT 'IN',\n  level_contaminated integer DEFAULT 0,\n  detected_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: assets\nCREATE TABLE IF NOT EXISTS assets (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  rfid_tag_id varchar NOT NULL,\n  asset_name varchar NOT NULL,\n  type_id uuid,\n  foto_url text,\n  status_condition varchar DEFAULT 'Good',\n  level_contaminated integer DEFAULT 0,\n  is_dangerous boolean DEFAULT false,\n  handling_instruction text,\n  maintenance_pattern varchar,\n  inspection_day_of_month integer,\n  last_inspection_at timestamptz,\n  next_inspection_at timestamptz,\n  is_active boolean DEFAULT true,\n  created_at timestamptz DEFAULT now(),\n  updated_at timestamptz DEFAULT now(),\n  last_detector_id uuid,\n  last_room_id uuid,\n  last_detected_at timestamptz,\n  last_movement_status text,\n  description text,\n  registered_by uuid,\n  updated_by uuid,\n  registered_at timestamptz DEFAULT now(),\n  last_used_by uuid,\n  last_assigned_at timestamptz,\n  last_inspection_id uuid,\n  last_inspection_result text,\n  last_inspection_notes text,\n  last_action_taken text,\n  last_recommendation text,\n  qrcode_url text\n);\n"
  },
  {
    "ddl": "-- Table: attendance\nCREATE TABLE IF NOT EXISTS attendance (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  app_id uuid,\n  profile_id uuid NOT NULL,\n  shift_id uuid,\n  check_in timestamptz DEFAULT now(),\n  check_out timestamptz,\n  location_check_in uuid,\n  status text NOT NULL DEFAULT 'present'::text,\n  is_overtime boolean DEFAULT false,\n  is_available boolean DEFAULT true,\n  notes text,\n  created_at timestamptz DEFAULT now(),\n  lat float8,\n  long float8,\n  address_at_check_in text,\n  roster_id uuid,\n  session_id uuid DEFAULT gen_random_uuid(),\n  is_tracking_active boolean DEFAULT false,\n  last_tracking_lat float8,\n  last_tracking_long float8,\n  last_tracking_address text,\n  last_tracking_at timestamptz\n);\n"
  },
  {
    "ddl": "-- Table: buildings\nCREATE TABLE IF NOT EXISTS buildings (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  app_id uuid,\n  hospital_id uuid,\n  building_name varchar NOT NULL,\n  function_id uuid,\n  total_floors integer DEFAULT 1,\n  created_at timestamptz DEFAULT now(),\n  created_by uuid,\n  latitude float8,\n  longitude float8\n);\n"
  },
  {
    "ddl": "-- Table: detectors\nCREATE TABLE IF NOT EXISTS detectors (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  app_id uuid,\n  detector_code varchar NOT NULL,\n  room_id uuid,\n  is_active boolean DEFAULT true,\n  created_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: duty_notes\nCREATE TABLE IF NOT EXISTS duty_notes (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  attendance_id uuid NOT NULL,\n  profile_id uuid NOT NULL,\n  note_text text NOT NULL,\n  created_at timestamptz DEFAULT now(),\n  updated_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: employee_last_location_view\nCREATE TABLE IF NOT EXISTS employee_last_location_view (  profile_id uuid,\n  full_name text,\n  employee_id text,\n  unit_code varchar,\n  current_situation varchar,\n  current_assignment text,\n  latitude float8,\n  longitude float8,\n  accuracy float8,\n  speed float8,\n  last_updated timestamptz,\n  check_in timestamptz,\n  shift_id uuid,\n  shift_name varchar\n);\n"
  },
  {
    "ddl": "-- Table: employee_leave_requests\nCREATE TABLE IF NOT EXISTS employee_leave_requests (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  profile_id uuid NOT NULL,\n  leave_type_id uuid NOT NULL,\n  start_date date NOT NULL,\n  end_date date NOT NULL,\n  total_days integer NOT NULL,\n  reason text,\n  document_url text,\n  approval_status varchar DEFAULT 'pending',\n  approved_by uuid,\n  approved_at timestamptz,\n  rejection_reason text,\n  notes text,\n  created_by uuid,\n  created_at timestamptz DEFAULT now(),\n  updated_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: employee_location_tracking\nCREATE TABLE IF NOT EXISTS employee_location_tracking (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  profile_id uuid NOT NULL,\n  session_id uuid NOT NULL,\n  latitude float8 NOT NULL,\n  longitude float8 NOT NULL,\n  accuracy float8,\n  speed float8,\n  altitude float8,\n  is_moving boolean DEFAULT false,\n  recorded_at timestamptz DEFAULT now(),\n  device_info jsonb\n);\n"
  },
  {
    "ddl": "-- Table: employee_qualification_assignments\nCREATE TABLE IF NOT EXISTS employee_qualification_assignments (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  profile_id uuid NOT NULL,\n  qualification_id uuid NOT NULL,\n  acquired_date date NOT NULL,\n  expiry_date date,\n  certificate_number varchar,\n  score numeric,\n  is_active boolean DEFAULT true,\n  verified_by uuid,\n  verified_at timestamptz,\n  notes text,\n  created_at timestamptz DEFAULT now(),\n  updated_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: employee_qualifications\nCREATE TABLE IF NOT EXISTS employee_qualifications (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  qualification_code varchar NOT NULL,\n  qualification_name varchar NOT NULL,\n  category varchar,\n  validity_period_months integer,\n  requires_renewal boolean DEFAULT true,\n  description text,\n  is_active boolean DEFAULT true,\n  created_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: employee_score_summary\nCREATE TABLE IF NOT EXISTS employee_score_summary (  profile_id uuid,\n  full_name text,\n  employee_id text,\n  unit_code varchar,\n  total_percentage numeric,\n  total_score numeric,\n  total_max_score numeric,\n  period_start date,\n  period_end date\n);\n"
  },
  {
    "ddl": "-- Table: employee_scoring\nCREATE TABLE IF NOT EXISTS employee_scoring (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  profile_id uuid NOT NULL,\n  scoring_category_id uuid NOT NULL,\n  score numeric NOT NULL DEFAULT 0,\n  max_score numeric NOT NULL DEFAULT 100,\n  period_start date NOT NULL,\n  period_end date NOT NULL,\n  notes text,\n  calculated_at timestamptz DEFAULT now(),\n  calculated_by uuid,\n  created_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: employee_shift_rosters\nCREATE TABLE IF NOT EXISTS employee_shift_rosters (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  app_id uuid,\n  profile_id uuid NOT NULL,\n  shift_id uuid NOT NULL,\n  roster_date date NOT NULL,\n  scheduled_start timestamptz,\n  scheduled_end timestamptz,\n  is_day_off boolean DEFAULT false,\n  is_overtime_planned boolean DEFAULT false,\n  is_emergency_shift boolean DEFAULT false,\n  is_on_call boolean DEFAULT false,\n  ai_generated boolean DEFAULT false,\n  ai_confidence_score numeric,\n  ai_reason text,\n  predicted_fatigue_score numeric,\n  predicted_workload_score numeric,\n  predicted_stress_score numeric,\n  wellbeing_risk_level text,\n  approval_status text DEFAULT 'pending'::text,\n  approved_by uuid,\n  approved_at timestamptz,\n  rejection_reason text,\n  actual_check_in timestamptz,\n  actual_check_out timestamptz,\n  attendance_status text DEFAULT 'scheduled'::text,\n  total_work_minutes integer,\n  overtime_minutes integer DEFAULT 0,\n  lateness_minutes integer DEFAULT 0,\n  early_leave_minutes integer DEFAULT 0,\n  notes text,\n  created_by uuid,\n  created_at timestamptz DEFAULT now(),\n  updated_at timestamptz DEFAULT now(),\n  location_name varchar,\n  location_room_id uuid,\n  required_equipment _text[] DEFAULT '{}'::text[],\n  special_instructions text,\n  leave_request_id uuid,\n  qualification_required _uuid[] DEFAULT '{}'::uuid[],\n  min_score_required numeric\n);\n"
  },
  {
    "ddl": "-- Table: employee_tracking_view\nCREATE TABLE IF NOT EXISTS employee_tracking_view (  id uuid,\n  profile_id uuid,\n  full_name text,\n  employee_id text,\n  unit_code varchar,\n  current_situation varchar,\n  current_assignment text,\n  session_id uuid,\n  shift_id uuid,\n  shift_name varchar,\n  shift_code varchar,\n  latitude float8,\n  longitude float8,\n  accuracy float8,\n  speed float8,\n  altitude float8,\n  is_moving boolean,\n  recorded_at timestamptz,\n  device_info jsonb,\n  check_in timestamptz,\n  check_out timestamptz,\n  is_tracking_active boolean,\n  prev_lat float8,\n  prev_lng float8,\n  prev_recorded_at timestamptz,\n  duty_status text\n);\n"
  },
  {
    "ddl": "-- Table: employee_units\nCREATE TABLE IF NOT EXISTS employee_units (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  unit_code varchar NOT NULL,\n  unit_name varchar NOT NULL,\n  parent_unit_id uuid,\n  unit_level integer DEFAULT 1,\n  head_of_unit_id uuid,\n  shift_required boolean DEFAULT true,\n  description text,\n  is_active boolean DEFAULT true,\n  created_at timestamptz DEFAULT now(),\n  updated_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: employee_wellbeing_logs\nCREATE TABLE IF NOT EXISTS employee_wellbeing_logs (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  app_id uuid,\n  profile_id uuid NOT NULL,\n  log_date date NOT NULL,\n  fatigue_score numeric,\n  stress_score numeric,\n  mood_score numeric,\n  energy_score numeric,\n  sleep_hours numeric,\n  self_report text,\n  ai_burnout_risk numeric,\n  ai_recommendation text,\n  requires_attention boolean DEFAULT false,\n  created_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: floors\nCREATE TABLE IF NOT EXISTS floors (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  app_id uuid,\n  building_id uuid,\n  floor_number integer NOT NULL,\n  floor_alias varchar,\n  map_image_url text,\n  created_at timestamptz DEFAULT now(),\n  created_by uuid\n);\n"
  },
  {
    "ddl": "-- Table: hospital_profile\nCREATE TABLE IF NOT EXISTS hospital_profile (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  app_id uuid,\n  name varchar NOT NULL,\n  address text,\n  logo_url text,\n  contact_center varchar,\n  total_buildings integer DEFAULT 1,\n  created_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: incidents\nCREATE TABLE IF NOT EXISTS incidents (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  category_id uuid NOT NULL,\n  reported_by uuid NOT NULL,\n  room_id uuid,\n  title varchar NOT NULL,\n  description text NOT NULL,\n  occurred_at timestamptz NOT NULL,\n  location_text text,\n  status varchar NOT NULL DEFAULT 'reported',\n  photo_urls jsonb,\n  voice_note_url text,\n  ai_tags jsonb,\n  ai_analysis jsonb,\n  created_at timestamptz NOT NULL DEFAULT now(),\n  updated_at timestamptz NOT NULL DEFAULT now(),\n  severity varchar DEFAULT 'MEDIUM',\n  assigned_to uuid,\n  resolved_at timestamptz,\n  resolution_note text,\n  lat float8,\n  long float8,\n  address text,\n  action_taken text,\n  action_taken_at timestamptz,\n  action_taken_by uuid,\n  action_task_ids _uuid[],\n  action_taken_model text,\n  action_announcement_ids _uuid[]\n);\n"
  },
  {
    "ddl": "-- Table: leave_types\nCREATE TABLE IF NOT EXISTS leave_types (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  leave_code varchar NOT NULL,\n  leave_name varchar NOT NULL,\n  max_days_per_year integer,\n  paid_leave boolean DEFAULT true,\n  requires_document boolean DEFAULT false,\n  requires_medical_certificate boolean DEFAULT false,\n  color varchar DEFAULT '#FF9800',\n  is_active boolean DEFAULT true,\n  created_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: people\nCREATE TABLE IF NOT EXISTS people (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  app_id uuid,\n  rfid_tag_id varchar NOT NULL,\n  full_name varchar NOT NULL,\n  category_id uuid,\n  foto_url text,\n  is_male boolean NOT NULL DEFAULT true,\n  is_child boolean DEFAULT false,\n  created_at timestamptz DEFAULT now(),\n  is_active boolean DEFAULT true,\n  last_detector_id uuid,\n  last_room_id uuid,\n  last_detected_at timestamptz,\n  last_movement_status text,\n  updated_at timestamptz DEFAULT now(),\n  level_contaminated text\n);\n"
  },
  {
    "ddl": "-- Table: people_movements\nCREATE TABLE IF NOT EXISTS people_movements (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  rfid_tag_id varchar NOT NULL,\n  detector_id uuid NOT NULL,\n  level_contaminated integer DEFAULT 0,\n  movement_status varchar DEFAULT 'IN',\n  detected_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: personil_last_position\nCREATE TABLE IF NOT EXISTS personil_last_position (  id uuid,\n  rfid_tag_id varchar,\n  detector_id uuid,\n  level_contaminated integer,\n  movement_status varchar,\n  detected_at timestamptz\n);\n"
  },
  {
    "ddl": "-- Table: profiles\nCREATE TABLE IF NOT EXISTS profiles (  id uuid NOT NULL,\n  full_name text,\n  role text,\n  rfid_tag text,\n  updated_at timestamptz DEFAULT timezone('utc'::text, now()),\n  address text,\n  gender character,\n  phone text,\n  position_id uuid,\n  avatar_url text,\n  employee_id text,\n  is_asset_initial boolean DEFAULT false,\n  is_asset_inspection boolean DEFAULT false,\n  is_stock_initial boolean DEFAULT false,\n  is_stock_opname boolean DEFAULT false,\n  is_flexible_roster boolean DEFAULT false,\n  default_shift_id uuid,\n  max_weekly_hours integer DEFAULT 40,\n  max_daily_hours integer DEFAULT 8,\n  preferred_shift_ids _uuid[] DEFAULT '{}'::uuid[],\n  wellbeing_risk_level text DEFAULT 'normal'::text,\n  last_wellbeing_assessment timestamptz,\n  employee_nik varchar,\n  unit_id uuid,\n  unit_code varchar,\n  join_date date,\n  join_year integer,\n  int_sequence integer DEFAULT 1,\n  int_label varchar DEFAULT '1st',\n  current_situation varchar DEFAULT 'ACTIVE',\n  situation_notes text,\n  situation_updated_at timestamptz,\n  rating_take_count integer DEFAULT 1,\n  current_assignment text,\n  assignment_destination text,\n  assignment_started_at timestamptz,\n  assignment_eta timestamptz,\n  assignment_destination_lat float8,\n  assignment_destination_long float8,\n  is_stock_approval boolean DEFAULT false,\n  is_approved boolean DEFAULT false,\n  is_stock_admin boolean DEFAULT false,\n  is_asset_admin boolean DEFAULT false\n);\n"
  },
  {
    "ddl": "-- Table: ref_asset_categories\nCREATE TABLE IF NOT EXISTS ref_asset_categories (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  category_name varchar NOT NULL,\n  icon_name varchar,\n  marker_color text,\n  created_at timestamptz DEFAULT now(),\n  created_by uuid\n);\n"
  },
  {
    "ddl": "-- Table: ref_asset_sub_categories\nCREATE TABLE IF NOT EXISTS ref_asset_sub_categories (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  category_id uuid NOT NULL,\n  sub_category_name varchar NOT NULL,\n  icon_name varchar,\n  marker_color text,\n  created_at timestamptz DEFAULT now(),\n  created_by uuid\n);\n"
  },
  {
    "ddl": "-- Table: ref_asset_types\nCREATE TABLE IF NOT EXISTS ref_asset_types (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  type_name varchar NOT NULL,\n  icon_name varchar,\n  created_at timestamptz DEFAULT now(),\n  marker_color text,\n  sub_category_id uuid,\n  created_by uuid\n);\n"
  },
  {
    "ddl": "-- Table: ref_building_functions\nCREATE TABLE IF NOT EXISTS ref_building_functions (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  app_id uuid,\n  function_name varchar NOT NULL,\n  description text,\n  created_at timestamptz DEFAULT now(),\n  created_by uuid\n);\n"
  },
  {
    "ddl": "-- Table: ref_incident_categories\nCREATE TABLE IF NOT EXISTS ref_incident_categories (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  code varchar NOT NULL,\n  name varchar NOT NULL,\n  description text,\n  icon varchar,\n  color varchar,\n  is_active boolean NOT NULL DEFAULT true,\n  created_at timestamptz NOT NULL DEFAULT now(),\n  updated_at timestamptz NOT NULL DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: ref_people_categories\nCREATE TABLE IF NOT EXISTS ref_people_categories (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  category_name varchar NOT NULL,\n  marker_color varchar,\n  created_at timestamptz DEFAULT now(),\n  is_insider boolean\n);\n"
  },
  {
    "ddl": "-- Table: ref_positions\nCREATE TABLE IF NOT EXISTS ref_positions (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  position_name text NOT NULL,\n  description text\n);\n"
  },
  {
    "ddl": "-- Table: ref_reports_category\nCREATE TABLE IF NOT EXISTS ref_reports_category (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  name varchar NOT NULL,\n  description text,\n  icon_name text\n);\n"
  },
  {
    "ddl": "-- Table: ref_room_categories\nCREATE TABLE IF NOT EXISTS ref_room_categories (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  app_id uuid,\n  category_name varchar NOT NULL,\n  color_code varchar,\n  created_at timestamptz DEFAULT now(),\n  created_by uuid,\n  icon_name varchar,\n  marker_color text\n);\n"
  },
  {
    "ddl": "-- Table: ref_shifts\nCREATE TABLE IF NOT EXISTS ref_shifts (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  shift_name varchar NOT NULL,\n  start_time time without time zone NOT NULL,\n  end_time time without time zone NOT NULL,\n  app_id uuid,\n  shift_code varchar,\n  description text,\n  is_cross_day boolean DEFAULT false,\n  break_duration_minutes integer DEFAULT 60,\n  tolerance_late_minutes integer DEFAULT 15,\n  tolerance_early_leave_minutes integer DEFAULT 15,\n  minimum_work_minutes integer DEFAULT 480,\n  maximum_overtime_minutes integer DEFAULT 240,\n  fatigue_weight numeric DEFAULT 1.00,\n  risk_level text DEFAULT 'normal'::text,\n  requires_medical_fit boolean DEFAULT false,\n  requires_supervisor boolean DEFAULT false,\n  requires_checkin_photo boolean DEFAULT false,\n  requires_location_validation boolean DEFAULT true,\n  ai_priority_weight numeric DEFAULT 1.00,\n  wellbeing_monitoring_enabled boolean DEFAULT true,\n  auto_assign_allowed boolean DEFAULT true,\n  color_hex varchar DEFAULT '#2196F3',\n  icon_name varchar,\n  is_active boolean DEFAULT true,\n  created_at timestamptz DEFAULT now(),\n  updated_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: ref_stock_categories\nCREATE TABLE IF NOT EXISTS ref_stock_categories (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  category_name varchar NOT NULL,\n  icon_name varchar,\n  marker_color text,\n  created_at timestamptz DEFAULT now(),\n  created_by uuid\n);\n"
  },
  {
    "ddl": "-- Table: ref_stock_sub_categories\nCREATE TABLE IF NOT EXISTS ref_stock_sub_categories (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  category_id uuid NOT NULL,\n  sub_category_name varchar NOT NULL,\n  icon_name varchar,\n  marker_color text,\n  created_at timestamptz DEFAULT now(),\n  created_by uuid\n);\n"
  },
  {
    "ddl": "-- Table: ref_stock_types\nCREATE TABLE IF NOT EXISTS ref_stock_types (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  type_name varchar NOT NULL,\n  description text,\n  created_at timestamptz DEFAULT now(),\n  created_by uuid,\n  sub_category_id uuid,\n  icon_name varchar,\n  marker_color text\n);\n"
  },
  {
    "ddl": "-- Table: ref_task_types\nCREATE TABLE IF NOT EXISTS ref_task_types (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  task_type_name text NOT NULL,\n  icon_name text,\n  color_code text,\n  description text,\n  created_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: rooms\nCREATE TABLE IF NOT EXISTS rooms (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  app_id uuid,\n  floor_id uuid,\n  room_name varchar NOT NULL,\n  category_id uuid,\n  is_entry_gate boolean DEFAULT false,\n  x_pos float8 DEFAULT 0.0,\n  y_pos float8 DEFAULT 0.0,\n  created_at timestamptz DEFAULT now(),\n  x_pos_max integer,\n  y_pos_max integer,\n  created_by uuid\n);\n"
  },
  {
    "ddl": "-- Table: roster_dashboard_view\nCREATE TABLE IF NOT EXISTS roster_dashboard_view (  roster_date date,\n  profile_id uuid,\n  full_name text,\n  employee_id text,\n  shift_name varchar,\n  shift_code varchar,\n  start_time time without time zone,\n  end_time time without time zone,\n  predicted_fatigue_score numeric,\n  wellbeing_risk_level text,\n  attendance_status text,\n  current_status text,\n  actual_fatigue_score numeric,\n  stress_score numeric,\n  mood_score numeric\n);\n"
  },
  {
    "ddl": "-- Table: roster_monthly_matrix\nCREATE TABLE IF NOT EXISTS roster_monthly_matrix (  profile_id uuid,\n  nama text,\n  nik varchar,\n  unit varchar,\n  int varchar,\n  ket varchar,\n  roster_date date,\n  shift_code varchar,\n  shift_name varchar\n);\n"
  },
  {
    "ddl": "-- Table: scoring_categories\nCREATE TABLE IF NOT EXISTS scoring_categories (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  category_code varchar NOT NULL,\n  category_name varchar NOT NULL,\n  weight numeric DEFAULT 1.00,\n  is_active boolean DEFAULT true,\n  created_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: stock_bins\nCREATE TABLE IF NOT EXISTS stock_bins (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  shelf_id uuid NOT NULL,\n  code varchar NOT NULL,\n  barcode varchar,\n  position_x integer,\n  position_y integer,\n  max_quantity numeric,\n  current_quantity numeric DEFAULT 0,\n  current_product_id uuid,\n  is_active boolean DEFAULT true,\n  metadata jsonb,\n  created_at timestamptz DEFAULT now(),\n  updated_at timestamptz DEFAULT now(),\n  created_by uuid,\n  qrcode_url text,\n  asset_id uuid\n);\n"
  },
  {
    "ddl": "-- Table: stock_bins_full\nCREATE TABLE IF NOT EXISTS stock_bins_full (  bin_id uuid,\n  bin_code varchar,\n  barcode varchar,\n  position_x integer,\n  position_y integer,\n  max_quantity numeric,\n  current_quantity numeric,\n  current_product_id uuid,\n  bin_is_active boolean,\n  shelf_id uuid,\n  shelf_code varchar,\n  shelf_level integer,\n  rack_id uuid,\n  rack_code varchar,\n  zone_id uuid,\n  zone_code varchar,\n  zone_type varchar,\n  zone_is_restricted boolean,\n  room_id uuid,\n  room_name varchar,\n  warehouse_id uuid,\n  warehouse_code varchar,\n  warehouse_name varchar,\n  floor_id uuid,\n  floor_number integer,\n  floor_alias varchar,\n  full_location_code text,\n  full_location_name text\n);\n"
  },
  {
    "ddl": "-- Table: stock_in\nCREATE TABLE IF NOT EXISTS stock_in (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  receipt_number varchar NOT NULL,\n  stock_id uuid NOT NULL,\n  quantity numeric NOT NULL,\n  batch_number varchar NOT NULL,\n  expiry_date date NOT NULL,\n  source_type varchar NOT NULL DEFAULT 'PURCHASE',\n  source_reference varchar,\n  returned_from_unit varchar,\n  return_reason varchar,\n  received_by uuid,\n  received_at timestamptz DEFAULT now(),\n  status varchar DEFAULT 'RECEIVED',\n  verified_by uuid,\n  verified_at timestamptz,\n  risk_level varchar DEFAULT 'NORMAL',\n  notes text,\n  metadata jsonb,\n  created_at timestamptz DEFAULT now(),\n  updated_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: stock_in_bins\nCREATE TABLE IF NOT EXISTS stock_in_bins (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  bin_id uuid NOT NULL,\n  stock_id uuid NOT NULL,\n  batch_number varchar NOT NULL,\n  expiry_date date NOT NULL,\n  quantity numeric NOT NULL,\n  stock_in_id uuid,\n  put_away_by uuid,\n  put_away_at timestamptz DEFAULT now(),\n  scanned_bin_barcode varchar,\n  notes text,\n  created_at timestamptz DEFAULT now(),\n  updated_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: stock_in_entries\nCREATE TABLE IF NOT EXISTS stock_in_entries (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  entry_number varchar NOT NULL,\n  stock_id uuid NOT NULL,\n  quantity numeric NOT NULL,\n  batch_number varchar NOT NULL,\n  expiry_date date NOT NULL,\n  source_type varchar NOT NULL,\n  source_id varchar,\n  entry_date timestamptz DEFAULT now(),\n  received_bin_id uuid,\n  current_bin_id uuid,\n  received_by uuid,\n  returned_by uuid,\n  returned_from_unit varchar,\n  return_reason varchar,\n  put_away_by uuid,\n  verified_by uuid,\n  verified_at timestamptz,\n  risk_level varchar DEFAULT 'NORMAL',\n  metadata jsonb,\n  created_at timestamptz DEFAULT now(),\n  updated_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: stock_mutations\nCREATE TABLE IF NOT EXISTS stock_mutations (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  mutation_number varchar NOT NULL,\n  stock_in_bins_id uuid NOT NULL,\n  bin_id_asal uuid NOT NULL,\n  bin_id_tujuan uuid NOT NULL,\n  stock_id uuid NOT NULL,\n  batch_number varchar NOT NULL,\n  expiry_date date NOT NULL,\n  quantity numeric NOT NULL,\n  unit varchar,\n  moved_by uuid NOT NULL,\n  moved_at timestamptz DEFAULT now(),\n  received_by uuid,\n  received_at timestamptz,\n  notes text,\n  created_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: stock_racks\nCREATE TABLE IF NOT EXISTS stock_racks (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  zone_id uuid NOT NULL,\n  code varchar NOT NULL,\n  name varchar,\n  capacity_kg numeric,\n  metadata jsonb,\n  created_at timestamptz DEFAULT now(),\n  updated_at timestamptz DEFAULT now(),\n  created_by uuid\n);\n"
  },
  {
    "ddl": "-- Table: stock_request_fulfillments\nCREATE TABLE IF NOT EXISTS stock_request_fulfillments (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  stock_request_id uuid NOT NULL,\n  stock_in_bins_id uuid NOT NULL,\n  bin_id uuid NOT NULL,\n  stock_id uuid NOT NULL,\n  batch_number varchar NOT NULL,\n  expiry_date date NOT NULL,\n  quantity numeric NOT NULL,\n  taken_by uuid NOT NULL,\n  taken_at timestamptz DEFAULT now(),\n  notes text,\n  created_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: stock_requests\nCREATE TABLE IF NOT EXISTS stock_requests (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  request_number varchar NOT NULL,\n  requester_id uuid NOT NULL,\n  requester_name varchar,\n  room_id uuid,\n  purpose varchar,\n  request_date timestamptz DEFAULT now(),\n  notes text,\n  requested_stock_id uuid NOT NULL,\n  requested_stock_name varchar,\n  requested_quantity numeric NOT NULL,\n  requested_unit varchar,\n  requested_batch varchar,\n  approved_by uuid,\n  approved_date timestamptz,\n  approved_quantity numeric,\n  approved_stock_id uuid,\n  approved_stock_name varchar,\n  approval_notes text,\n  status varchar DEFAULT 'PENDING',\n  fulfilled_quantity numeric DEFAULT 0,\n  rejected_by uuid,\n  rejected_at timestamptz,\n  rejection_reason text,\n  rejection_type varchar,\n  created_at timestamptz DEFAULT now(),\n  updated_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: stock_shelves\nCREATE TABLE IF NOT EXISTS stock_shelves (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  rack_id uuid NOT NULL,\n  level_number integer NOT NULL,\n  code varchar NOT NULL,\n  max_height_cm numeric,\n  metadata jsonb,\n  created_at timestamptz DEFAULT now(),\n  updated_at timestamptz DEFAULT now(),\n  created_by uuid\n);\n"
  },
  {
    "ddl": "-- Table: stock_transactions\nCREATE TABLE IF NOT EXISTS stock_transactions (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  stock_id uuid NOT NULL,\n  transaction_type varchar NOT NULL,\n  qty numeric NOT NULL,\n  stock_before numeric NOT NULL,\n  stock_after numeric NOT NULL,\n  transaction_note text,\n  created_by uuid,\n  created_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: stock_warehouses\nCREATE TABLE IF NOT EXISTS stock_warehouses (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  code varchar NOT NULL,\n  name varchar NOT NULL,\n  address text,\n  manager_id uuid,\n  is_active boolean DEFAULT true,\n  metadata jsonb,\n  created_at timestamptz DEFAULT now(),\n  updated_at timestamptz DEFAULT now(),\n  floor_id uuid,\n  created_by uuid\n);\n"
  },
  {
    "ddl": "-- Table: stock_write_offs\nCREATE TABLE IF NOT EXISTS stock_write_offs (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  write_off_number varchar NOT NULL,\n  stock_in_bins_id uuid NOT NULL,\n  bin_id uuid NOT NULL,\n  stock_id uuid NOT NULL,\n  batch_number varchar NOT NULL,\n  expiry_date date NOT NULL,\n  quantity numeric NOT NULL,\n  unit varchar,\n  reason varchar NOT NULL,\n  reason_note text,\n  requested_by uuid,\n  requested_at timestamptz DEFAULT now(),\n  status varchar DEFAULT 'DRAFT',\n  photo_url text,\n  notes text,\n  created_at timestamptz DEFAULT now(),\n  updated_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: stock_zones\nCREATE TABLE IF NOT EXISTS stock_zones (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  warehouse_id uuid NOT NULL,\n  code varchar NOT NULL,\n  name varchar NOT NULL,\n  zone_type varchar DEFAULT 'NORMAL',\n  temperature_min numeric,\n  temperature_max numeric,\n  humidity_min numeric,\n  humidity_max numeric,\n  is_restricted boolean DEFAULT false,\n  metadata jsonb,\n  created_at timestamptz DEFAULT now(),\n  updated_at timestamptz DEFAULT now(),\n  room_id uuid,\n  created_by uuid\n);\n"
  },
  {
    "ddl": "-- Table: stocks\nCREATE TABLE IF NOT EXISTS stocks (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  stock_code varchar,\n  stock_name varchar NOT NULL,\n  stock_type_id uuid,\n  unit varchar NOT NULL,\n  minimum_stock numeric DEFAULT 0,\n  current_stock numeric DEFAULT 0,\n  photo_url text,\n  last_opname_at timestamptz,\n  last_opname_by uuid,\n  last_opname_note text,\n  updated_at timestamptz DEFAULT now(),\n  created_at timestamptz DEFAULT now(),\n  is_active boolean DEFAULT true,\n  stock_condition varchar DEFAULT 'GOOD',\n  last_opname_stock numeric,\n  last_purchase_at timestamptz,\n  last_purchase_by uuid,\n  last_purchase_qty numeric,\n  last_purchase_price numeric,\n  last_usage_at timestamptz,\n  last_usage_by uuid,\n  last_usage_qty numeric,\n  storage_location_id uuid,\n  batch_number varchar,\n  description text,\n  expiry_date timestamp without time zone,\n  created_by uuid,\n  stock_in_qty numeric DEFAULT 0\n);\n"
  },
  {
    "ddl": "-- Table: stocks_opnames\nCREATE TABLE IF NOT EXISTS stocks_opnames (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  stock_id uuid NOT NULL,\n  stock_before numeric DEFAULT 0,\n  physical_stock numeric NOT NULL,\n  adjustment_stock numeric DEFAULT 0,\n  opname_note text,\n  opname_by uuid,\n  opname_at timestamptz DEFAULT now(),\n  created_at timestamptz DEFAULT now(),\n  bin_id uuid,\n  stock_in_bins_id uuid,\n  batch_number varchar,\n  expiry_date date,\n  system_quantity numeric,\n  opname_type varchar DEFAULT 'PRODUCT'\n);\n"
  },
  {
    "ddl": "-- Table: storage_locations\nCREATE TABLE IF NOT EXISTS storage_locations (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  location_code varchar NOT NULL,\n  location_name varchar NOT NULL,\n  description text,\n  is_active boolean DEFAULT true,\n  created_at timestamptz DEFAULT now()\n);\n"
  },
  {
    "ddl": "-- Table: tasks\nCREATE TABLE IF NOT EXISTS tasks (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  type_id uuid NOT NULL,\n  assignee_id uuid NOT NULL,\n  object_name text NOT NULL,\n  from_room_id uuid NOT NULL,\n  to_room_id uuid NOT NULL,\n  status text NOT NULL DEFAULT 'pending'::text,\n  priority text NOT NULL DEFAULT 'normal'::text,\n  created_at timestamptz DEFAULT now(),\n  started_at timestamptz,\n  completed_at timestamptz,\n  created_by uuid,\n  task_outcome text,\n  completion_notes text,\n  app_id uuid,\n  asset_id uuid,\n  stock_id uuid,\n  related_profile_id uuid,\n  accepted_at timestamptz,\n  rejected_at timestamptz,\n  cancelled_at timestamptz,\n  rejection_reason text,\n  sla_minutes integer,\n  estimated_duration_minutes integer,\n  actual_duration_minutes integer,\n  ai_generated boolean DEFAULT false,\n  ai_priority_score numeric,\n  ai_confidence_score numeric,\n  ai_recommendation_reason text,\n  fatigue_before numeric,\n  fatigue_after numeric,\n  wellbeing_impact_score numeric,\n  workload_snapshot integer,\n  requires_confirmation boolean DEFAULT false,\n  requires_photo_proof boolean DEFAULT false,\n  requires_qr_validation boolean DEFAULT false,\n  proof_photo_url text,\n  employee_feedback text,\n  employee_rating integer,\n  updated_at timestamptz DEFAULT now(),\n  completion_lat float8,\n  completion_long float8,\n  completion_address text\n);\n"
  },
  {
    "ddl": "-- Table: tasks_reports\nCREATE TABLE IF NOT EXISTS tasks_reports (  id uuid NOT NULL DEFAULT gen_random_uuid(),\n  task_id uuid NOT NULL,\n  category_id uuid NOT NULL,\n  reporter_id uuid NOT NULL,\n  description text NOT NULL,\n  urgency_level text NOT NULL DEFAULT 'normal'::text,\n  at_room_id uuid,\n  created_at timestamptz DEFAULT now(),\n  file_url text,\n  file_type text\n);\n"
  },
  {
    "ddl": "-- Table: v_asset_available\nCREATE TABLE IF NOT EXISTS v_asset_available (  id uuid,\n  rfid_tag_id varchar,\n  asset_name varchar,\n  type_id uuid,\n  type_name varchar,\n  foto_url text,\n  status_condition varchar,\n  level_contaminated integer,\n  is_dangerous boolean,\n  handling_instruction text,\n  description text,\n  last_room_id uuid,\n  last_room_name varchar,\n  last_assignment_status text,\n  last_user_id uuid,\n  last_user_name text,\n  availability_status text\n);\n"
  },
  {
    "ddl": "-- Table: v_asset_dashboard_summary\nCREATE TABLE IF NOT EXISTS v_asset_dashboard_summary (  total_assets bigint,\n  total_good bigint,\n  total_maintenance bigint,\n  total_critical bigint,\n  total_damaged bigint,\n  total_dangerous bigint,\n  high_contamination bigint,\n  overdue_inspection bigint\n);\n"
  },
  {
    "ddl": "-- Table: v_asset_details\nCREATE TABLE IF NOT EXISTS v_asset_details (  id uuid,\n  rfid_tag_id varchar,\n  asset_name varchar,\n  type_id uuid,\n  foto_url text,\n  status_condition varchar,\n  level_contaminated integer,\n  is_dangerous boolean,\n  handling_instruction text,\n  maintenance_pattern varchar,\n  inspection_day_of_month integer,\n  last_inspection_at timestamptz,\n  next_inspection_at timestamptz,\n  is_active boolean,\n  created_at timestamptz,\n  updated_at timestamptz,\n  last_detector_id uuid,\n  last_room_id uuid,\n  last_detected_at timestamptz,\n  last_movement_status text,\n  description text,\n  registered_by uuid,\n  updated_by uuid,\n  registered_at timestamptz,\n  last_used_by uuid,\n  last_assigned_at timestamptz,\n  last_inspection_id uuid,\n  last_inspection_result text,\n  last_inspection_notes text,\n  last_action_taken text,\n  last_recommendation text,\n  qrcode_url text,\n  type_name varchar,\n  sub_category_name varchar,\n  category_name varchar,\n  room_name varchar,\n  registered_by_name text,\n  updated_by_name text,\n  last_used_by_name text\n);\n"
  },
  {
    "ddl": "-- Table: v_asset_group_by_category\nCREATE TABLE IF NOT EXISTS v_asset_group_by_category (  category_id uuid,\n  category_name varchar,\n  total_assets bigint\n);\n"
  },
  {
    "ddl": "-- Table: v_asset_group_by_condition\nCREATE TABLE IF NOT EXISTS v_asset_group_by_condition (  status_condition varchar,\n  total_assets bigint\n);\n"
  },
  {
    "ddl": "-- Table: v_asset_group_by_sub_category\nCREATE TABLE IF NOT EXISTS v_asset_group_by_sub_category (  sub_category_id uuid,\n  sub_category_name varchar,\n  total_assets bigint\n);\n"
  },
  {
    "ddl": "-- Table: v_asset_group_by_type\nCREATE TABLE IF NOT EXISTS v_asset_group_by_type (  type_id uuid,\n  type_name varchar,\n  total_assets bigint\n);\n"
  },
  {
    "ddl": "-- Table: v_asset_master_complete\nCREATE TABLE IF NOT EXISTS v_asset_master_complete (  id uuid,\n  rfid_tag_id varchar,\n  asset_name varchar,\n  description text,\n  foto_url text,\n  category_id uuid,\n  category_name varchar,\n  category_icon varchar,\n  category_color text,\n  sub_category_id uuid,\n  sub_category_name varchar,\n  sub_category_icon varchar,\n  sub_category_color text,\n  type_id uuid,\n  type_name varchar,\n  type_icon varchar,\n  type_color text,\n  status_condition varchar,\n  level_contaminated integer,\n  is_dangerous boolean,\n  handling_instruction text,\n  maintenance_pattern varchar,\n  is_active boolean,\n  inspection_day_of_month integer,\n  last_inspection_at timestamptz,\n  next_inspection_at timestamptz,\n  last_inspection_result text,\n  last_inspection_notes text,\n  last_action_taken text,\n  last_recommendation text,\n  last_inspection_id uuid,\n  inspection_id uuid,\n  inspection_type text,\n  inspection_result text,\n  inspection_condition_status text,\n  inspection_contamination_level integer,\n  inspection_notes text,\n  inspection_action_taken text,\n  inspection_recommendation text,\n  inspected_at timestamptz,\n  inspection_next_schedule timestamptz,\n  inspection_photo_url text,\n  inspector_id uuid,\n  inspector_name text,\n  inspector_role text,\n  inspector_employee_id text,\n  inspector_phone text,\n  inspector_avatar_url text,\n  room_id uuid,\n  room_name varchar,\n  detector_id uuid,\n  detector_code varchar,\n  last_detected_at timestamptz,\n  last_movement_status text,\n  last_used_by_id uuid,\n  last_used_by_name text,\n  last_used_by_role text,\n  last_used_by_employee_id text,\n  last_used_by_phone text,\n  last_used_by_avatar text,\n  registered_by_id uuid,\n  registered_by_name text,\n  registered_by_role text,\n  registered_by_employee_id text,\n  updated_by_id uuid,\n  updated_by_name text,\n  updated_by_role text,\n  updated_by_employee_id text,\n  assignment_id uuid,\n  assigned_at timestamptz,\n  released_at timestamptz,\n  assignment_status text,\n  assignment_notes text,\n  assigned_profile_id uuid,\n  assigned_profile_name text,\n  assigned_profile_role text,\n  assigned_profile_employee_id text,\n  assigned_profile_phone text,\n  assigned_profile_avatar text,\n  assignment_created_by_id uuid,\n  assignment_created_by_name text,\n  created_at timestamptz,\n  updated_at timestamptz,\n  registered_at timestamptz\n);\n"
  },
  {
    "ddl": "-- Table: v_asset_report\nCREATE TABLE IF NOT EXISTS v_asset_report (  id uuid,\n  rfid_tag_id varchar,\n  asset_name varchar,\n  status_condition varchar,\n  level_contaminated integer,\n  is_dangerous boolean,\n  last_room_id uuid,\n  last_room_name varchar,\n  maintenance_pattern varchar,\n  is_active boolean,\n  registered_at timestamptz,\n  last_inspection_at timestamptz,\n  last_inspection_result text,\n  next_inspection_at timestamptz,\n  type_id uuid,\n  type_name varchar,\n  registered_by uuid,\n  registered_by_name text,\n  current_user_id uuid,\n  current_user_name text,\n  last_assignment_status text,\n  last_inspector_id uuid,\n  last_inspector_name text,\n  inspection_status text,\n  availability_status text\n);\n"
  },
  {
    "ddl": "-- Table: v_assets_with_status\nCREATE TABLE IF NOT EXISTS v_assets_with_status (  id uuid,\n  rfid_tag_id varchar,\n  asset_name varchar,\n  type_id uuid,\n  type_name varchar,\n  foto_url text,\n  status_condition varchar,\n  level_contaminated integer,\n  is_dangerous boolean,\n  handling_instruction text,\n  is_active boolean,\n  description text,\n  last_room_id uuid,\n  last_room_name varchar,\n  current_assignment_status text,\n  current_user_id uuid,\n  current_user_name text,\n  current_assigned_at timestamptz,\n  current_assigned_by uuid,\n  current_assigned_by_name text,\n  handover_location_id uuid,\n  handover_location_name varchar,\n  availability_status text\n);\n"
  },
  {
    "ddl": "-- Table: v_crud_stocks\nCREATE TABLE IF NOT EXISTS v_crud_stocks (  id uuid,\n  stock_code varchar,\n  stock_name varchar,\n  stock_type_id uuid,\n  stock_type_name varchar,\n  stock_type_description text,\n  unit varchar,\n  minimum_stock numeric,\n  current_stock numeric,\n  stock_condition varchar,\n  photo_url text,\n  is_active boolean,\n  last_opname_at timestamptz,\n  last_opname_by uuid,\n  last_opname_by_name text,\n  last_opname_by_employee_id text,\n  last_opname_note text,\n  last_opname_stock numeric,\n  last_purchase_at timestamptz,\n  last_purchase_by uuid,\n  last_purchase_by_name text,\n  last_purchase_by_employee_id text,\n  last_purchase_qty numeric,\n  last_purchase_price numeric,\n  last_usage_at timestamptz,\n  last_usage_by uuid,\n  last_usage_by_name text,\n  last_usage_by_employee_id text,\n  last_usage_qty numeric,\n  storage_location_id uuid,\n  storage_location_name varchar,\n  storage_location_code varchar,\n  batch_number varchar,\n  description text,\n  expiry_date timestamp without time zone,\n  updated_at timestamptz,\n  created_at timestamptz,\n  created_by uuid,\n  created_by_name text,\n  created_by_employee_id text,\n  is_empty boolean,\n  is_low_stock boolean,\n  is_stock_safe boolean,\n  sort_type_name text,\n  sort_stock_name text\n);\n"
  },
  {
    "ddl": "-- Table: v_my_asset_requests\nCREATE TABLE IF NOT EXISTS v_my_asset_requests (  id uuid,\n  asset_id uuid,\n  asset_name varchar,\n  foto_url text,\n  profile_id uuid,\n  assignment_status text,\n  requested_at timestamptz,\n  assigned_at timestamptz,\n  assigned_by uuid,\n  assigned_by_name text,\n  notes text,\n  handover_location_id uuid,\n  handover_location_name varchar\n);\n"
  },
  {
    "ddl": "-- Table: v_pending_assignments\nCREATE TABLE IF NOT EXISTS v_pending_assignments (  id uuid,\n  asset_id uuid,\n  asset_name varchar,\n  foto_url text,\n  profile_id uuid,\n  requester_name text,\n  requester_employee_id text,\n  notes text,\n  assignment_status text,\n  requested_at timestamptz,\n  handover_location_id uuid,\n  handover_location_name varchar\n);\n"
  },
  {
    "ddl": "-- Table: v_sla_violations\nCREATE TABLE IF NOT EXISTS v_sla_violations (  task_id uuid,\n  object_name text,\n  assignee_id uuid,\n  assignee_name text,\n  unit_code varchar,\n  priority text,\n  sla_minutes integer,\n  status text,\n  created_at timestamptz,\n  minutes_elapsed numeric,\n  sla_status text\n);\n"
  },
  {
    "ddl": "-- Table: v_stocks\nCREATE TABLE IF NOT EXISTS v_stocks (  id uuid,\n  stock_code varchar,\n  stock_name varchar,\n  stock_type_id uuid,\n  stock_type_name varchar,\n  stock_type_description text,\n  unit varchar,\n  minimum_stock numeric,\n  current_stock numeric,\n  stock_condition varchar,\n  photo_url text,\n  is_active boolean,\n  last_opname_at timestamptz,\n  last_opname_by uuid,\n  last_opname_by_name text,\n  last_opname_by_employee_id text,\n  last_opname_note text,\n  last_opname_stock numeric,\n  last_purchase_at timestamptz,\n  last_purchase_by uuid,\n  last_purchase_by_name text,\n  last_purchase_by_employee_id text,\n  last_purchase_qty numeric,\n  last_purchase_price numeric,\n  last_usage_at timestamptz,\n  last_usage_by uuid,\n  last_usage_by_name text,\n  last_usage_by_employee_id text,\n  last_usage_qty numeric,\n  updated_at timestamptz,\n  created_at timestamptz,\n  is_empty boolean,\n  is_low_stock boolean,\n  is_stock_safe boolean,\n  sort_type_name text,\n  sort_stock_name text\n);\n"
  },
  {
    "ddl": "-- Table: v_unresolved_incidents\nCREATE TABLE IF NOT EXISTS v_unresolved_incidents (  id uuid,\n  title varchar,\n  severity varchar,\n  status varchar,\n  occurred_at timestamptz,\n  minutes_elapsed numeric,\n  category_id uuid,\n  category_name varchar,\n  reported_by uuid,\n  reported_by_name text,\n  room_id uuid,\n  room_name varchar,\n  action_task_ids _uuid[],\n  action_announcement_ids _uuid[]\n);\n"
  },
  {
    "ddl": "-- Table: view_asset_live\nCREATE TABLE IF NOT EXISTS view_asset_live (  asset_id uuid,\n  entity_id uuid,\n  entity_type text,\n  rfid_tag_id varchar,\n  asset_name varchar,\n  foto_url text,\n  category_name varchar,\n  marker_color text,\n  status_condition varchar,\n  level_contaminated integer,\n  is_dangerous boolean,\n  handling_instruction text,\n  last_detected_at timestamptz,\n  last_movement_status text,\n  updated_at timestamptz,\n  tracking_status text,\n  detector_code varchar,\n  room_id uuid,\n  room_name varchar,\n  x_pos float8,\n  y_pos float8,\n  floor_id uuid,\n  floor_number integer,\n  floor_alias varchar,\n  map_image_url text,\n  building_id uuid,\n  room_x_min float8,\n  room_y_min float8,\n  room_x_max integer,\n  room_y_max integer\n);\n"
  },
  {
    "ddl": "-- Table: view_people_live\nCREATE TABLE IF NOT EXISTS view_people_live (  person_id uuid,\n  entity_id uuid,\n  entity_type text,\n  rfid_tag_id varchar,\n  full_name varchar,\n  is_male boolean,\n  is_child boolean,\n  foto_url text,\n  category_name varchar,\n  level_contaminated integer,\n  last_detected_at timestamptz,\n  last_movement_status text,\n  updated_at timestamptz,\n  tracking_status text,\n  detector_code varchar,\n  room_id uuid,\n  room_name varchar,\n  x_pos float8,\n  y_pos float8,\n  floor_id uuid,\n  floor_number integer,\n  floor_alias varchar,\n  map_image_url text,\n  building_id uuid,\n  marker_color varchar,\n  room_x_min float8,\n  room_y_min float8,\n  room_x_max integer,\n  room_y_max integer\n);\n"
  },
  {
    "ddl": "-- Table: vw_asset_alert_summary\nCREATE TABLE IF NOT EXISTS vw_asset_alert_summary (  dangerous_assets bigint,\n  critical_contamination_assets bigint,\n  critical_condition_assets bigint,\n  overdue_inspection_assets bigint,\n  damaged_assets bigint,\n  generated_at timestamptz\n);\n"
  },
  {
    "ddl": "-- Table: vw_asset_category_summary\nCREATE TABLE IF NOT EXISTS vw_asset_category_summary (  category_id uuid,\n  category_name varchar,\n  icon_name varchar,\n  marker_color text,\n  total_assets bigint,\n  active_assets bigint,\n  good_assets bigint,\n  maintenance_assets bigint,\n  damaged_assets bigint,\n  critical_assets bigint,\n  dangerous_assets bigint,\n  high_contamination_assets bigint\n);\n"
  },
  {
    "ddl": "-- Table: vw_asset_health_summary\nCREATE TABLE IF NOT EXISTS vw_asset_health_summary (  status_condition varchar,\n  total_assets bigint,\n  active_assets bigint,\n  dangerous_assets bigint,\n  high_contamination_assets bigint\n);\n"
  },
  {
    "ddl": "-- Table: vw_asset_inspection_summary\nCREATE TABLE IF NOT EXISTS vw_asset_inspection_summary (  overdue_inspection_assets bigint,\n  inspection_due_today bigint,\n  inspection_due_this_week bigint,\n  never_inspected_assets bigint,\n  generated_at timestamptz\n);\n"
  },
  {
    "ddl": "-- Table: vw_asset_overview_kpi\nCREATE TABLE IF NOT EXISTS vw_asset_overview_kpi (  total_assets bigint,\n  active_assets bigint,\n  inactive_assets bigint,\n  good_assets bigint,\n  maintenance_assets bigint,\n  damaged_assets bigint,\n  critical_assets bigint,\n  dangerous_assets bigint,\n  high_contamination_assets bigint,\n  generated_at timestamptz\n);\n"
  },
  {
    "ddl": "-- Table: vw_asset_subcategory_summary\nCREATE TABLE IF NOT EXISTS vw_asset_subcategory_summary (  sub_category_id uuid,\n  sub_category_name varchar,\n  icon_name varchar,\n  marker_color text,\n  category_id uuid,\n  category_name varchar,\n  total_assets bigint,\n  active_assets bigint,\n  good_assets bigint,\n  maintenance_assets bigint,\n  damaged_assets bigint,\n  critical_assets bigint\n);\n"
  },
  {
    "ddl": "-- Table: vw_asset_taxonomy\nCREATE TABLE IF NOT EXISTS vw_asset_taxonomy (  id uuid,\n  asset_name varchar,\n  foto_url text,\n  status_condition varchar,\n  level_contaminated integer,\n  is_dangerous boolean,\n  is_active boolean,\n  maintenance_pattern varchar,\n  inspection_day_of_month integer,\n  last_inspection_at timestamptz,\n  next_inspection_at timestamptz,\n  last_inspection_result text,\n  last_action_taken text,\n  last_recommendation text,\n  created_at timestamptz,\n  updated_at timestamptz,\n  type_id uuid,\n  type_name varchar,\n  type_icon varchar,\n  type_color text,\n  sub_category_id uuid,\n  sub_category_name varchar,\n  sub_category_icon varchar,\n  sub_category_color text,\n  category_id uuid,\n  category_name varchar,\n  category_icon varchar,\n  category_color text\n);\n"
  },
  {
    "ddl": "-- Table: vw_asset_type_summary\nCREATE TABLE IF NOT EXISTS vw_asset_type_summary (  type_id uuid,\n  type_name varchar,\n  icon_name varchar,\n  marker_color text,\n  sub_category_id uuid,\n  sub_category_name varchar,\n  category_id uuid,\n  category_name varchar,\n  total_assets bigint,\n  active_assets bigint,\n  good_assets bigint,\n  maintenance_assets bigint,\n  damaged_assets bigint,\n  critical_assets bigint,\n  dangerous_assets bigint,\n  high_contamination_assets bigint\n);\n"
  }
]