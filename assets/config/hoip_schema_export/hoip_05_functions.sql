[
  {
    "function_name": "_postgis_deprecate",
    "argument_count": 3,
    "source_code": "\nDECLARE\n  curver_text text;\nBEGIN\n  --\n  -- Raises a NOTICE if it was deprecated in this version,\n  -- a WARNING if in a previous version (only up to minor version checked)\n  --\n\tcurver_text := '3.3.7';\n\tIF pg_catalog.split_part(curver_text,'.',1)::int > pg_catalog.split_part(version,'.',1)::int OR\n\t   ( pg_catalog.split_part(curver_text,'.',1) = pg_catalog.split_part(version,'.',1) AND\n\t\t pg_catalog.split_part(curver_text,'.',2) != split_part(version,'.',2) )\n\tTHEN\n\t  RAISE WARNING '% signature was deprecated in %. Please use %', oldname, version, newname;\n\tELSE\n\t  RAISE DEBUG '% signature was deprecated in %. Please use %', oldname, version, newname;\n\tEND IF;\nEND;\n"
  },
  {
    "function_name": "_postgis_index_extent",
    "argument_count": 2,
    "source_code": "_postgis_gserialized_index_extent"
  },
  {
    "function_name": "_postgis_join_selectivity",
    "argument_count": 5,
    "source_code": "_postgis_gserialized_joinsel"
  },
  {
    "function_name": "_postgis_pgsql_version",
    "argument_count": 0,
    "source_code": "\n\tSELECT CASE WHEN pg_catalog.split_part(s,'.',1)::integer > 9 THEN pg_catalog.split_part(s,'.',1) || '0'\n\tELSE pg_catalog.split_part(s,'.', 1) || pg_catalog.split_part(s,'.', 2) END AS v\n\tFROM pg_catalog.substring(version(), E'PostgreSQL ([0-9\\\\.]+)') AS s;\n"
  },
  {
    "function_name": "_postgis_scripts_pgsql_version",
    "argument_count": 0,
    "source_code": "SELECT '170'::text AS version"
  },
  {
    "function_name": "_postgis_selectivity",
    "argument_count": 4,
    "source_code": "_postgis_gserialized_sel"
  },
  {
    "function_name": "_postgis_stats",
    "argument_count": 3,
    "source_code": "_postgis_gserialized_stats"
  },
  {
    "function_name": "_st_3ddfullywithin",
    "argument_count": 3,
    "source_code": "LWGEOM_dfullywithin3d"
  },
  {
    "function_name": "_st_3ddwithin",
    "argument_count": 3,
    "source_code": "LWGEOM_dwithin3d"
  },
  {
    "function_name": "_st_3dintersects",
    "argument_count": 2,
    "source_code": "ST_3DIntersects"
  },
  {
    "function_name": "_st_asgml",
    "argument_count": 6,
    "source_code": "LWGEOM_asGML"
  },
  {
    "function_name": "_st_asx3d",
    "argument_count": 5,
    "source_code": "LWGEOM_asX3D"
  },
  {
    "function_name": "_st_bestsrid",
    "argument_count": 2,
    "source_code": "geography_bestsrid"
  },
  {
    "function_name": "_st_bestsrid",
    "argument_count": 1,
    "source_code": "geography_bestsrid"
  },
  {
    "function_name": "_st_contains",
    "argument_count": 2,
    "source_code": "contains"
  },
  {
    "function_name": "_st_containsproperly",
    "argument_count": 2,
    "source_code": "containsproperly"
  },
  {
    "function_name": "_st_coveredby",
    "argument_count": 2,
    "source_code": "coveredby"
  },
  {
    "function_name": "_st_coveredby",
    "argument_count": 2,
    "source_code": "geography_coveredby"
  },
  {
    "function_name": "_st_covers",
    "argument_count": 2,
    "source_code": "geography_covers"
  },
  {
    "function_name": "_st_covers",
    "argument_count": 2,
    "source_code": "covers"
  },
  {
    "function_name": "_st_crosses",
    "argument_count": 2,
    "source_code": "crosses"
  },
  {
    "function_name": "_st_dfullywithin",
    "argument_count": 3,
    "source_code": "LWGEOM_dfullywithin"
  },
  {
    "function_name": "_st_distancetree",
    "argument_count": 4,
    "source_code": "geography_distance_tree"
  },
  {
    "function_name": "_st_distancetree",
    "argument_count": 2,
    "source_code": "SELECT public._ST_DistanceTree($1, $2, 0.0, true)"
  },
  {
    "function_name": "_st_distanceuncached",
    "argument_count": 4,
    "source_code": "geography_distance_uncached"
  },
  {
    "function_name": "_st_distanceuncached",
    "argument_count": 3,
    "source_code": "SELECT public._ST_DistanceUnCached($1, $2, 0.0, $3)"
  },
  {
    "function_name": "_st_distanceuncached",
    "argument_count": 2,
    "source_code": "SELECT public._ST_DistanceUnCached($1, $2, 0.0, true)"
  },
  {
    "function_name": "_st_dwithin",
    "argument_count": 4,
    "source_code": "geography_dwithin"
  },
  {
    "function_name": "_st_dwithin",
    "argument_count": 3,
    "source_code": "LWGEOM_dwithin"
  },
  {
    "function_name": "_st_dwithinuncached",
    "argument_count": 4,
    "source_code": "geography_dwithin_uncached"
  },
  {
    "function_name": "_st_dwithinuncached",
    "argument_count": 3,
    "source_code": "SELECT $1 OPERATOR(public.&&) public._ST_Expand($2,$3) AND $2 OPERATOR(public.&&) public._ST_Expand($1,$3) AND public._ST_DWithinUnCached($1, $2, $3, true)"
  },
  {
    "function_name": "_st_equals",
    "argument_count": 2,
    "source_code": "ST_Equals"
  },
  {
    "function_name": "_st_expand",
    "argument_count": 2,
    "source_code": "geography_expand"
  },
  {
    "function_name": "_st_geomfromgml",
    "argument_count": 2,
    "source_code": "geom_from_gml"
  },
  {
    "function_name": "_st_intersects",
    "argument_count": 2,
    "source_code": "ST_Intersects"
  },
  {
    "function_name": "_st_linecrossingdirection",
    "argument_count": 2,
    "source_code": "ST_LineCrossingDirection"
  },
  {
    "function_name": "_st_longestline",
    "argument_count": 2,
    "source_code": "LWGEOM_longestline2d"
  },
  {
    "function_name": "_st_maxdistance",
    "argument_count": 2,
    "source_code": "LWGEOM_maxdistance2d_linestring"
  },
  {
    "function_name": "_st_orderingequals",
    "argument_count": 2,
    "source_code": "LWGEOM_same"
  },
  {
    "function_name": "_st_overlaps",
    "argument_count": 2,
    "source_code": "overlaps"
  },
  {
    "function_name": "_st_pointoutside",
    "argument_count": 1,
    "source_code": "geography_point_outside"
  },
  {
    "function_name": "_st_sortablehash",
    "argument_count": 1,
    "source_code": "_ST_SortableHash"
  },
  {
    "function_name": "_st_touches",
    "argument_count": 2,
    "source_code": "touches"
  },
  {
    "function_name": "_st_voronoi",
    "argument_count": 4,
    "source_code": "ST_Voronoi"
  },
  {
    "function_name": "_st_within",
    "argument_count": 2,
    "source_code": "SELECT public._ST_Contains($2,$1)"
  },
  {
    "function_name": "add_stock_to_bin",
    "argument_count": 7,
    "source_code": "\r\nDECLARE\r\n    v_existing_id UUID;\r\n    v_existing_quantity NUMERIC;\r\nBEGIN\r\n    -- Cek apakah sudah ada kombinasi yang sama di bin tujuan\r\n    SELECT id, quantity INTO v_existing_id, v_existing_quantity\r\n    FROM stock_in_bins\r\n    WHERE bin_id = p_bin_id \r\n      AND stock_id = p_stock_id \r\n      AND batch_number = p_batch_number;\r\n    \r\n    IF FOUND THEN\r\n        -- UPDATE quantity (tambah stok ke bin yang sama)\r\n        UPDATE stock_in_bins\r\n        SET quantity = v_existing_quantity + p_quantity,\r\n            updated_at = NOW(),\r\n            notes = COALESCE(notes, '') || E'\\n' || COALESCE(p_notes, 'Mutasi stok')\r\n        WHERE id = v_existing_id;\r\n    ELSE\r\n        -- INSERT baru\r\n        INSERT INTO stock_in_bins (\r\n            id, bin_id, stock_id, batch_number, expiry_date, \r\n            quantity, notes, created_at, updated_at\r\n        ) VALUES (\r\n            gen_random_uuid(), p_bin_id, p_stock_id, p_batch_number, \r\n            p_expiry_date, p_quantity, p_notes, NOW(), NOW()\r\n        );\r\n    END IF;\r\nEND;\r\n"
  },
  {
    "function_name": "addauth",
    "argument_count": 1,
    "source_code": "\nDECLARE\n\tlockid alias for $1;\n\tokay boolean;\n\tmyrec record;\nBEGIN\n\t-- check to see if table exists\n\t--  if not, CREATE TEMP TABLE mylock (transid xid, lockcode text)\n\tokay := 'f';\n\tFOR myrec IN SELECT * FROM pg_class WHERE relname = 'temp_lock_have_table' LOOP\n\t\tokay := 't';\n\tEND LOOP;\n\tIF (okay <> 't') THEN\n\t\tCREATE TEMP TABLE temp_lock_have_table (transid xid, lockcode text);\n\t\t\t-- this will only work from pgsql7.4 up\n\t\t\t-- ON COMMIT DELETE ROWS;\n\tEND IF;\n\n\t--  INSERT INTO mylock VALUES ( $1)\n--\tEXECUTE 'INSERT INTO temp_lock_have_table VALUES ( '||\n--\t\tquote_literal(getTransactionID()) || ',' ||\n--\t\tquote_literal(lockid) ||')';\n\n\tINSERT INTO temp_lock_have_table VALUES (getTransactionID(), lockid);\n\n\tRETURN true::boolean;\nEND;\n"
  },
  {
    "function_name": "addgeometrycolumn",
    "argument_count": 6,
    "source_code": "\nDECLARE\n\tret  text;\nBEGIN\n\tSELECT public.AddGeometryColumn('','',$1,$2,$3,$4,$5, $6) into ret;\n\tRETURN ret;\nEND;\n"
  },
  {
    "function_name": "addgeometrycolumn",
    "argument_count": 7,
    "source_code": "\nDECLARE\n\tret  text;\nBEGIN\n\tSELECT public.AddGeometryColumn('',$1,$2,$3,$4,$5,$6,$7) into ret;\n\tRETURN ret;\nEND;\n"
  },
  {
    "function_name": "addgeometrycolumn",
    "argument_count": 8,
    "source_code": "\nDECLARE\n\trec RECORD;\n\tsr varchar;\n\treal_schema name;\n\tsql text;\n\tnew_srid integer;\n\nBEGIN\n\n\t-- Verify geometry type\n\tIF (postgis_type_name(new_type,new_dim) IS NULL )\n\tTHEN\n\t\tRAISE EXCEPTION 'Invalid type name \"%(%)\" - valid ones are:\n\tPOINT, MULTIPOINT,\n\tLINESTRING, MULTILINESTRING,\n\tPOLYGON, MULTIPOLYGON,\n\tCIRCULARSTRING, COMPOUNDCURVE, MULTICURVE,\n\tCURVEPOLYGON, MULTISURFACE,\n\tGEOMETRY, GEOMETRYCOLLECTION,\n\tPOINTM, MULTIPOINTM,\n\tLINESTRINGM, MULTILINESTRINGM,\n\tPOLYGONM, MULTIPOLYGONM,\n\tCIRCULARSTRINGM, COMPOUNDCURVEM, MULTICURVEM\n\tCURVEPOLYGONM, MULTISURFACEM, TRIANGLE, TRIANGLEM,\n\tPOLYHEDRALSURFACE, POLYHEDRALSURFACEM, TIN, TINM\n\tor GEOMETRYCOLLECTIONM', new_type, new_dim;\n\t\tRETURN 'fail';\n\tEND IF;\n\n\t-- Verify dimension\n\tIF ( (new_dim >4) OR (new_dim <2) ) THEN\n\t\tRAISE EXCEPTION 'invalid dimension';\n\t\tRETURN 'fail';\n\tEND IF;\n\n\tIF ( (new_type LIKE '%M') AND (new_dim!=3) ) THEN\n\t\tRAISE EXCEPTION 'TypeM needs 3 dimensions';\n\t\tRETURN 'fail';\n\tEND IF;\n\n\t-- Verify SRID\n\tIF ( new_srid_in > 0 ) THEN\n\t\tIF new_srid_in > 998999 THEN\n\t\t\tRAISE EXCEPTION 'AddGeometryColumn() - SRID must be <= %', 998999;\n\t\tEND IF;\n\t\tnew_srid := new_srid_in;\n\t\tSELECT SRID INTO sr FROM spatial_ref_sys WHERE SRID = new_srid;\n\t\tIF NOT FOUND THEN\n\t\t\tRAISE EXCEPTION 'AddGeometryColumn() - invalid SRID';\n\t\t\tRETURN 'fail';\n\t\tEND IF;\n\tELSE\n\t\tnew_srid := public.ST_SRID('POINT EMPTY'::public.geometry);\n\t\tIF ( new_srid_in != new_srid ) THEN\n\t\t\tRAISE NOTICE 'SRID value % converted to the officially unknown SRID value %', new_srid_in, new_srid;\n\t\tEND IF;\n\tEND IF;\n\n\t-- Verify schema\n\tIF ( schema_name IS NOT NULL AND schema_name != '' ) THEN\n\t\tsql := 'SELECT nspname FROM pg_namespace ' ||\n\t\t\t'WHERE text(nspname) = ' || quote_literal(schema_name) ||\n\t\t\t'LIMIT 1';\n\t\tRAISE DEBUG '%', sql;\n\t\tEXECUTE sql INTO real_schema;\n\n\t\tIF ( real_schema IS NULL ) THEN\n\t\t\tRAISE EXCEPTION 'Schema % is not a valid schemaname', quote_literal(schema_name);\n\t\t\tRETURN 'fail';\n\t\tEND IF;\n\tEND IF;\n\n\tIF ( real_schema IS NULL ) THEN\n\t\tRAISE DEBUG 'Detecting schema';\n\t\tsql := 'SELECT n.nspname AS schemaname ' ||\n\t\t\t'FROM pg_catalog.pg_class c ' ||\n\t\t\t  'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace ' ||\n\t\t\t'WHERE c.relkind = ' || quote_literal('r') ||\n\t\t\t' AND n.nspname NOT IN (' || quote_literal('pg_catalog') || ', ' || quote_literal('pg_toast') || ')' ||\n\t\t\t' AND pg_catalog.pg_table_is_visible(c.oid)' ||\n\t\t\t' AND c.relname = ' || quote_literal(table_name);\n\t\tRAISE DEBUG '%', sql;\n\t\tEXECUTE sql INTO real_schema;\n\n\t\tIF ( real_schema IS NULL ) THEN\n\t\t\tRAISE EXCEPTION 'Table % does not occur in the search_path', quote_literal(table_name);\n\t\t\tRETURN 'fail';\n\t\tEND IF;\n\tEND IF;\n\n\t-- Add geometry column to table\n\tIF use_typmod THEN\n\t\t sql := 'ALTER TABLE ' ||\n\t\t\tquote_ident(real_schema) || '.' || quote_ident(table_name)\n\t\t\t|| ' ADD COLUMN ' || quote_ident(column_name) ||\n\t\t\t' geometry(' || public.postgis_type_name(new_type, new_dim) || ', ' || new_srid::text || ')';\n\t\tRAISE DEBUG '%', sql;\n\tELSE\n\t\tsql := 'ALTER TABLE ' ||\n\t\t\tquote_ident(real_schema) || '.' || quote_ident(table_name)\n\t\t\t|| ' ADD COLUMN ' || quote_ident(column_name) ||\n\t\t\t' geometry ';\n\t\tRAISE DEBUG '%', sql;\n\tEND IF;\n\tEXECUTE sql;\n\n\tIF NOT use_typmod THEN\n\t\t-- Add table CHECKs\n\t\tsql := 'ALTER TABLE ' ||\n\t\t\tquote_ident(real_schema) || '.' || quote_ident(table_name)\n\t\t\t|| ' ADD CONSTRAINT '\n\t\t\t|| quote_ident('enforce_srid_' || column_name)\n\t\t\t|| ' CHECK (st_srid(' || quote_ident(column_name) ||\n\t\t\t') = ' || new_srid::text || ')' ;\n\t\tRAISE DEBUG '%', sql;\n\t\tEXECUTE sql;\n\n\t\tsql := 'ALTER TABLE ' ||\n\t\t\tquote_ident(real_schema) || '.' || quote_ident(table_name)\n\t\t\t|| ' ADD CONSTRAINT '\n\t\t\t|| quote_ident('enforce_dims_' || column_name)\n\t\t\t|| ' CHECK (st_ndims(' || quote_ident(column_name) ||\n\t\t\t') = ' || new_dim::text || ')' ;\n\t\tRAISE DEBUG '%', sql;\n\t\tEXECUTE sql;\n\n\t\tIF ( NOT (new_type = 'GEOMETRY')) THEN\n\t\t\tsql := 'ALTER TABLE ' ||\n\t\t\t\tquote_ident(real_schema) || '.' || quote_ident(table_name) || ' ADD CONSTRAINT ' ||\n\t\t\t\tquote_ident('enforce_geotype_' || column_name) ||\n\t\t\t\t' CHECK (GeometryType(' ||\n\t\t\t\tquote_ident(column_name) || ')=' ||\n\t\t\t\tquote_literal(new_type) || ' OR (' ||\n\t\t\t\tquote_ident(column_name) || ') is null)';\n\t\t\tRAISE DEBUG '%', sql;\n\t\t\tEXECUTE sql;\n\t\tEND IF;\n\tEND IF;\n\n\tRETURN\n\t\treal_schema || '.' ||\n\t\ttable_name || '.' || column_name ||\n\t\t' SRID:' || new_srid::text ||\n\t\t' TYPE:' || new_type ||\n\t\t' DIMS:' || new_dim::text || ' ';\nEND;\n"
  },
  {
    "function_name": "box",
    "argument_count": 1,
    "source_code": "LWGEOM_to_BOX"
  },
  {
    "function_name": "box",
    "argument_count": 1,
    "source_code": "BOX3D_to_BOX"
  },
  {
    "function_name": "box2d",
    "argument_count": 1,
    "source_code": "LWGEOM_to_BOX2D"
  },
  {
    "function_name": "box2d",
    "argument_count": 1,
    "source_code": "BOX3D_to_BOX2D"
  },
  {
    "function_name": "box2d_in",
    "argument_count": 1,
    "source_code": "BOX2D_in"
  },
  {
    "function_name": "box2d_out",
    "argument_count": 1,
    "source_code": "BOX2D_out"
  },
  {
    "function_name": "box2df_in",
    "argument_count": 1,
    "source_code": "box2df_in"
  },
  {
    "function_name": "box2df_out",
    "argument_count": 1,
    "source_code": "box2df_out"
  },
  {
    "function_name": "box3d",
    "argument_count": 1,
    "source_code": "BOX2D_to_BOX3D"
  },
  {
    "function_name": "box3d",
    "argument_count": 1,
    "source_code": "LWGEOM_to_BOX3D"
  },
  {
    "function_name": "box3d_in",
    "argument_count": 1,
    "source_code": "BOX3D_in"
  },
  {
    "function_name": "box3d_out",
    "argument_count": 1,
    "source_code": "BOX3D_out"
  },
  {
    "function_name": "box3dtobox",
    "argument_count": 1,
    "source_code": "BOX3D_to_BOX"
  },
  {
    "function_name": "bytea",
    "argument_count": 1,
    "source_code": "LWGEOM_to_bytea"
  },
  {
    "function_name": "bytea",
    "argument_count": 1,
    "source_code": "LWGEOM_to_bytea"
  },
  {
    "function_name": "checkauth",
    "argument_count": 2,
    "source_code": " SELECT CheckAuth('', $1, $2) "
  },
  {
    "function_name": "checkauth",
    "argument_count": 3,
    "source_code": "\nDECLARE\n\tschema text;\nBEGIN\n\tIF NOT LongTransactionsEnabled() THEN\n\t\tRAISE EXCEPTION 'Long transaction support disabled, use EnableLongTransaction() to enable.';\n\tEND IF;\n\n\tif ( $1 != '' ) THEN\n\t\tschema = $1;\n\tELSE\n\t\tSELECT current_schema() into schema;\n\tEND IF;\n\n\t-- TODO: check for an already existing trigger ?\n\n\tEXECUTE 'CREATE TRIGGER check_auth BEFORE UPDATE OR DELETE ON '\n\t\t|| quote_ident(schema) || '.' || quote_ident($2)\n\t\t||' FOR EACH ROW EXECUTE PROCEDURE CheckAuthTrigger('\n\t\t|| quote_literal($3) || ')';\n\n\tRETURN 0;\nEND;\n"
  },
  {
    "function_name": "checkauthtrigger",
    "argument_count": 0,
    "source_code": "check_authorization"
  },
  {
    "function_name": "contains_2d",
    "argument_count": 2,
    "source_code": "gserialized_contains_box2df_geom_2d"
  },
  {
    "function_name": "contains_2d",
    "argument_count": 2,
    "source_code": "SELECT $2 OPERATOR(public.@) $1;"
  },
  {
    "function_name": "contains_2d",
    "argument_count": 2,
    "source_code": "gserialized_contains_box2df_box2df_2d"
  },
  {
    "function_name": "create_stock_mutation",
    "argument_count": 12,
    "source_code": "\r\nBEGIN\r\n    -- 1. Kurangi stok di bin asal\r\n    PERFORM reduce_stock_in_bins_quantity(p_stock_in_bins_id, p_quantity);\r\n    \r\n    -- 2. Tambah stok ke bin tujuan\r\n    PERFORM add_stock_to_bin(\r\n        p_bin_id_tujuan, \r\n        p_stock_id, \r\n        p_batch_number, \r\n        p_expiry_date, \r\n        p_quantity, \r\n        p_unit, \r\n        p_notes\r\n    );\r\n    \r\n    -- 3. Catat mutasi\r\n    INSERT INTO stock_mutations (\r\n        id, mutation_number, stock_in_bins_id, bin_id_asal, bin_id_tujuan,\r\n        stock_id, batch_number, expiry_date, quantity, unit,\r\n        moved_by, moved_at, received_by, received_at, notes\r\n    ) VALUES (\r\n        gen_random_uuid(), p_mutation_number, p_stock_in_bins_id, p_bin_id_asal, p_bin_id_tujuan,\r\n        p_stock_id, p_batch_number, p_expiry_date, p_quantity, p_unit,\r\n        p_moved_by, NOW(), p_received_by, NOW(), p_notes\r\n    );\r\nEND;\r\n"
  },
  {
    "function_name": "disablelongtransactions",
    "argument_count": 0,
    "source_code": "\nDECLARE\n\trec RECORD;\n\nBEGIN\n\n\t--\n\t-- Drop all triggers applied by CheckAuth()\n\t--\n\tFOR rec IN\n\t\tSELECT c.relname, t.tgname, t.tgargs FROM pg_trigger t, pg_class c, pg_proc p\n\t\tWHERE p.proname = 'checkauthtrigger' and t.tgfoid = p.oid and t.tgrelid = c.oid\n\tLOOP\n\t\tEXECUTE 'DROP TRIGGER ' || quote_ident(rec.tgname) ||\n\t\t\t' ON ' || quote_ident(rec.relname);\n\tEND LOOP;\n\n\t--\n\t-- Drop the authorization_table table\n\t--\n\tFOR rec IN SELECT * FROM pg_class WHERE relname = 'authorization_table' LOOP\n\t\tDROP TABLE authorization_table;\n\tEND LOOP;\n\n\t--\n\t-- Drop the authorized_tables view\n\t--\n\tFOR rec IN SELECT * FROM pg_class WHERE relname = 'authorized_tables' LOOP\n\t\tDROP VIEW authorized_tables;\n\tEND LOOP;\n\n\tRETURN 'Long transactions support disabled';\nEND;\n"
  },
  {
    "function_name": "dropgeometrycolumn",
    "argument_count": 4,
    "source_code": "\nDECLARE\n\tmyrec RECORD;\n\tokay boolean;\n\treal_schema name;\n\nBEGIN\n\n\t-- Find, check or fix schema_name\n\tIF ( schema_name != '' ) THEN\n\t\tokay = false;\n\n\t\tFOR myrec IN SELECT nspname FROM pg_namespace WHERE text(nspname) = schema_name LOOP\n\t\t\tokay := true;\n\t\tEND LOOP;\n\n\t\tIF ( okay <>  true ) THEN\n\t\t\tRAISE NOTICE 'Invalid schema name - using current_schema()';\n\t\t\tSELECT current_schema() into real_schema;\n\t\tELSE\n\t\t\treal_schema = schema_name;\n\t\tEND IF;\n\tELSE\n\t\tSELECT current_schema() into real_schema;\n\tEND IF;\n\n\t-- Find out if the column is in the geometry_columns table\n\tokay = false;\n\tFOR myrec IN SELECT * from public.geometry_columns where f_table_schema = text(real_schema) and f_table_name = table_name and f_geometry_column = column_name LOOP\n\t\tokay := true;\n\tEND LOOP;\n\tIF (okay <> true) THEN\n\t\tRAISE EXCEPTION 'column not found in geometry_columns table';\n\t\tRETURN false;\n\tEND IF;\n\n\t-- Remove table column\n\tEXECUTE 'ALTER TABLE ' || quote_ident(real_schema) || '.' ||\n\t\tquote_ident(table_name) || ' DROP COLUMN ' ||\n\t\tquote_ident(column_name);\n\n\tRETURN real_schema || '.' || table_name || '.' || column_name ||' effectively removed.';\n\nEND;\n"
  },
  {
    "function_name": "dropgeometrycolumn",
    "argument_count": 2,
    "source_code": "\nDECLARE\n\tret text;\nBEGIN\n\tSELECT public.DropGeometryColumn('','',$1,$2) into ret;\n\tRETURN ret;\nEND;\n"
  },
  {
    "function_name": "dropgeometrycolumn",
    "argument_count": 3,
    "source_code": "\nDECLARE\n\tret text;\nBEGIN\n\tSELECT public.DropGeometryColumn('',$1,$2,$3) into ret;\n\tRETURN ret;\nEND;\n"
  },
  {
    "function_name": "dropgeometrytable",
    "argument_count": 1,
    "source_code": " SELECT public.DropGeometryTable('','',$1) "
  },
  {
    "function_name": "dropgeometrytable",
    "argument_count": 2,
    "source_code": " SELECT public.DropGeometryTable('',$1,$2) "
  },
  {
    "function_name": "dropgeometrytable",
    "argument_count": 3,
    "source_code": "\nDECLARE\n\treal_schema name;\n\nBEGIN\n\n\tIF ( schema_name = '' ) THEN\n\t\tSELECT current_schema() into real_schema;\n\tELSE\n\t\treal_schema = schema_name;\n\tEND IF;\n\n\t-- TODO: Should we warn if table doesn't exist probably instead just saying dropped\n\t-- Remove table\n\tEXECUTE 'DROP TABLE IF EXISTS '\n\t\t|| quote_ident(real_schema) || '.' ||\n\t\tquote_ident(table_name) || ' RESTRICT';\n\n\tRETURN\n\t\treal_schema || '.' ||\n\t\ttable_name ||' dropped.';\n\nEND;\n"
  },
  {
    "function_name": "enablelongtransactions",
    "argument_count": 0,
    "source_code": "\nDECLARE\n\t\"query\" text;\n\texists bool;\n\trec RECORD;\n\nBEGIN\n\n\texists = 'f';\n\tFOR rec IN SELECT * FROM pg_class WHERE relname = 'authorization_table'\n\tLOOP\n\t\texists = 't';\n\tEND LOOP;\n\n\tIF NOT exists\n\tTHEN\n\t\t\"query\" = 'CREATE TABLE authorization_table (\n\t\t\ttoid oid, -- table oid\n\t\t\trid text, -- row id\n\t\t\texpires timestamp,\n\t\t\tauthid text\n\t\t)';\n\t\tEXECUTE \"query\";\n\tEND IF;\n\n\texists = 'f';\n\tFOR rec IN SELECT * FROM pg_class WHERE relname = 'authorized_tables'\n\tLOOP\n\t\texists = 't';\n\tEND LOOP;\n\n\tIF NOT exists THEN\n\t\t\"query\" = 'CREATE VIEW authorized_tables AS ' ||\n\t\t\t'SELECT ' ||\n\t\t\t'n.nspname as schema, ' ||\n\t\t\t'c.relname as table, trim(' ||\n\t\t\tquote_literal(chr(92) || '000') ||\n\t\t\t' from t.tgargs) as id_column ' ||\n\t\t\t'FROM pg_trigger t, pg_class c, pg_proc p ' ||\n\t\t\t', pg_namespace n ' ||\n\t\t\t'WHERE p.proname = ' || quote_literal('checkauthtrigger') ||\n\t\t\t' AND c.relnamespace = n.oid' ||\n\t\t\t' AND t.tgfoid = p.oid and t.tgrelid = c.oid';\n\t\tEXECUTE \"query\";\n\tEND IF;\n\n\tRETURN 'Long transactions support enabled';\nEND;\n"
  },
  {
    "function_name": "equals",
    "argument_count": 2,
    "source_code": "ST_Equals"
  },
  {
    "function_name": "find_srid",
    "argument_count": 3,
    "source_code": "\nDECLARE\n\tschem varchar =  $1;\n\ttabl varchar = $2;\n\tsr int4;\nBEGIN\n-- if the table contains a . and the schema is empty\n-- split the table into a schema and a table\n-- otherwise drop through to default behavior\n\tIF ( schem = '' and strpos(tabl,'.') > 0 ) THEN\n\t schem = substr(tabl,1,strpos(tabl,'.')-1);\n\t tabl = substr(tabl,length(schem)+2);\n\tEND IF;\n\n\tselect SRID into sr from public.geometry_columns where (f_table_schema = schem or schem = '') and f_table_name = tabl and f_geometry_column = $3;\n\tIF NOT FOUND THEN\n\t   RAISE EXCEPTION 'find_srid() - could not find the corresponding SRID - is the geometry registered in the GEOMETRY_COLUMNS table?  Is there an uppercase/lowercase mismatch?';\n\tEND IF;\n\treturn sr;\nEND;\n"
  },
  {
    "function_name": "fn_calc_leave_days",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n  NEW.total_days = (NEW.end_date - NEW.start_date) + 1;\r\n  RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "fn_calc_qualification_expiry",
    "argument_count": 0,
    "source_code": "\r\nDECLARE\r\n  v_validity_months INTEGER;\r\nBEGIN\r\n  SELECT validity_period_months INTO v_validity_months\r\n  FROM employee_qualifications WHERE id = NEW.qualification_id;\r\n  \r\n  IF v_validity_months IS NOT NULL AND v_validity_months > 0 THEN\r\n    NEW.expiry_date = NEW.acquired_date + (v_validity_months || ' months')::INTERVAL;\r\n  END IF;\r\n  \r\n  RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "fn_calculate_predicted_fatigue",
    "argument_count": 0,
    "source_code": "\r\nDECLARE\r\n  v_consecutive_days INTEGER;\r\n  v_shift_hours INTEGER;\r\nBEGIN\r\n  -- Hitung hari kerja berturut-turut\r\n  SELECT COUNT(*) INTO v_consecutive_days\r\n  FROM employee_shift_rosters\r\n  WHERE profile_id = NEW.profile_id\r\n    AND roster_date >= (NEW.roster_date - INTERVAL '7 days')\r\n    AND roster_date <= NEW.roster_date\r\n    AND is_day_off = false;\r\n  \r\n  -- Ambil durasi shift\r\n  SELECT EXTRACT(HOUR FROM (end_time - start_time)) INTO v_shift_hours\r\n  FROM ref_shifts WHERE id = NEW.shift_id;\r\n  \r\n  -- Hitung predicted fatigue score (0-10, semakin tinggi semakin lelah)\r\n  NEW.predicted_fatigue_score := LEAST(10, \r\n    (v_consecutive_days * 0.5) + \r\n    (v_shift_hours / 8.0) * 2 +\r\n    (CASE WHEN NEW.is_overtime_planned THEN 2 ELSE 0 END)\r\n  );\r\n  \r\n  -- Set wellbeing risk level berdasarkan fatigue score\r\n  NEW.wellbeing_risk_level := CASE\r\n    WHEN NEW.predicted_fatigue_score <= 3 THEN 'low'\r\n    WHEN NEW.predicted_fatigue_score <= 6 THEN 'medium'\r\n    WHEN NEW.predicted_fatigue_score <= 8 THEN 'high'\r\n    ELSE 'critical'\r\n  END;\r\n  \r\n  RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "fn_check_wellbeing_alert",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n  NEW.requires_attention := \r\n    NEW.fatigue_score > 7 OR \r\n    NEW.stress_score > 7 OR \r\n    NEW.mood_score < 3 OR\r\n    NEW.energy_score < 3 OR\r\n    NEW.sleep_hours < 5;\r\n  \r\n  RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "fn_determine_movement_status",
    "argument_count": 0,
    "source_code": "DECLARE\r\n    last_status varchar;\r\n    is_registered boolean;\r\nBEGIN\r\n    -- 1. Validasi: Cek apakah RFID terdaftar di master tabel 'people'\r\n    SELECT EXISTS (\r\n        SELECT 1 FROM public.people WHERE rfid_tag_id = NEW.rfid_tag_id\r\n    ) INTO is_registered;\r\n\r\n    -- Jika tidak terdaftar, batalkan proses insert (Mencegah data unknown)\r\n    IF NOT is_registered THEN\r\n        RAISE EXCEPTION 'RFID Tag % tidak terdaftar di sistem!', NEW.rfid_tag_id;\r\n        RETURN NULL; \r\n    END IF;\r\n\r\n    -- 2. Ambil status terakhir dari RFID ini pada DETEKTOR YANG SAMA\r\n    SELECT movement_status INTO last_status\r\n    FROM public.people_movements\r\n    WHERE rfid_tag_id = NEW.rfid_tag_id \r\n      AND detector_id = NEW.detector_id\r\n    ORDER BY detected_at DESC\r\n    LIMIT 1;\r\n\r\n\r\n    RETURN NEW;\r\nEND;"
  },
  {
    "function_name": "fn_set_join_year",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n  IF NEW.join_date IS NOT NULL THEN\r\n    NEW.join_year = EXTRACT(YEAR FROM NEW.join_date);\r\n    -- Auto calculate int_sequence based on join_year\r\n    NEW.int_sequence = EXTRACT(YEAR FROM NOW()) - NEW.join_year + 1;\r\n    NEW.int_label = CASE\r\n      WHEN NEW.int_sequence = 1 THEN '1st'\r\n      WHEN NEW.int_sequence = 2 THEN '2nd'\r\n      WHEN NEW.int_sequence = 3 THEN '3rd'\r\n      WHEN NEW.int_sequence = 4 THEN '4th'\r\n      WHEN NEW.int_sequence = 5 THEN '5th'\r\n      ELSE NEW.int_sequence::text || 'th'\r\n    END;\r\n  END IF;\r\n  RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "fn_stock_opname_update",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    -- Jika opname per BIN (ada bin_id)\r\n    IF NEW.bin_id IS NOT NULL AND NEW.stock_in_bins_id IS NOT NULL THEN\r\n        -- 1. Update stock_in_bins.quantity\r\n        UPDATE stock_in_bins\r\n        SET quantity = NEW.physical_stock,\r\n            updated_at = NOW()\r\n        WHERE id = NEW.stock_in_bins_id;\r\n        \r\n        -- 2. stocks.current_stock akan otomatis update via trigger_current_stock_from_bins\r\n        -- Jadi tidak perlu update langsung di sini\r\n    ELSE\r\n        -- Opname per produk (cara lama)\r\n        UPDATE stocks\r\n        SET current_stock = NEW.physical_stock,\r\n            last_opname_at = NEW.opname_at,\r\n            last_opname_by = NEW.opname_by,\r\n            last_opname_note = NEW.opname_note,\r\n            last_opname_stock = NEW.stock_before,\r\n            updated_at = NOW()\r\n        WHERE id = NEW.stock_id;\r\n    END IF;\r\n    \r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "fn_stock_purchase_update",
    "argument_count": 0,
    "source_code": "\r\ndeclare\r\n    v_stock_before numeric;\r\n    v_stock_after numeric;\r\n    v_condition varchar;\r\nbegin\r\n\r\n    select current_stock\r\n    into v_stock_before\r\n    from public.stocks\r\n    where id = new.stock_id;\r\n\r\n    if v_stock_before is null then\r\n        raise exception 'Stock tidak ditemukan';\r\n    end if;\r\n\r\n    v_stock_after :=\r\n        coalesce(v_stock_before,0) + coalesce(new.qty,0);\r\n\r\n    select\r\n        case\r\n            when v_stock_after <= 0 then 'EMPTY'\r\n            when v_stock_after <= minimum_stock then 'LOW'\r\n            else 'GOOD'\r\n        end\r\n    into v_condition\r\n    from public.stocks\r\n    where id = new.stock_id;\r\n\r\n    update public.stocks\r\n    set\r\n        current_stock = v_stock_after,\r\n\r\n        stock_condition = v_condition,\r\n\r\n        last_purchase_at = new.purchased_at,\r\n        last_purchase_by = new.purchased_by,\r\n        last_purchase_qty = new.qty,\r\n        last_purchase_price = new.purchase_price,\r\n\r\n        updated_at = now()\r\n\r\n    where id = new.stock_id;\r\n\r\n    insert into public.stock_transactions (\r\n        stock_id,\r\n        transaction_type,\r\n        qty,\r\n        stock_before,\r\n        stock_after,\r\n        transaction_note,\r\n        created_by\r\n    )\r\n    values (\r\n        new.stock_id,\r\n        'PURCHASE',\r\n        new.qty,\r\n        v_stock_before,\r\n        v_stock_after,\r\n        new.purchase_note,\r\n        new.purchased_by\r\n    );\r\n\r\n    return new;\r\nend;\r\n"
  },
  {
    "function_name": "fn_stock_usage_update",
    "argument_count": 0,
    "source_code": "\r\ndeclare\r\n    v_stock_before numeric;\r\n    v_stock_after numeric;\r\n    v_condition varchar;\r\nbegin\r\n\r\n    select current_stock\r\n    into v_stock_before\r\n    from public.stocks\r\n    where id = new.stock_id;\r\n\r\n    if v_stock_before is null then\r\n        raise exception 'Stock tidak ditemukan';\r\n    end if;\r\n\r\n    v_stock_after :=\r\n        coalesce(v_stock_before,0)\r\n        - coalesce(new.qty_used,0);\r\n\r\n    if v_stock_after < 0 then\r\n        raise exception 'Stock tidak mencukupi';\r\n    end if;\r\n\r\n    select\r\n        case\r\n            when v_stock_after <= 0 then 'EMPTY'\r\n            when v_stock_after <= minimum_stock then 'LOW'\r\n            else 'GOOD'\r\n        end\r\n    into v_condition\r\n    from public.stocks\r\n    where id = new.stock_id;\r\n\r\n    update public.stocks\r\n    set\r\n        current_stock = v_stock_after,\r\n\r\n        stock_condition = v_condition,\r\n\r\n        last_usage_at = new.used_at,\r\n        last_usage_by = new.used_by,\r\n        last_usage_qty = new.qty_used,\r\n\r\n        updated_at = now()\r\n\r\n    where id = new.stock_id;\r\n\r\n    insert into public.stock_transactions (\r\n        stock_id,\r\n        transaction_type,\r\n        qty,\r\n        stock_before,\r\n        stock_after,\r\n        transaction_note,\r\n        created_by\r\n    )\r\n    values (\r\n        new.stock_id,\r\n        'USAGE',\r\n        new.qty_used,\r\n        v_stock_before,\r\n        v_stock_after,\r\n        new.usage_note,\r\n        new.used_by\r\n    );\r\n\r\n    return new;\r\nend;\r\n"
  },
  {
    "function_name": "fn_update_asset_last_inspection",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n\r\n    UPDATE public.assets\r\n    SET\r\n\r\n        -- relasi inspeksi terakhir\r\n        last_inspection_id = NEW.id,\r\n\r\n        -- waktu inspeksi\r\n        last_inspection_at = NEW.inspected_at,\r\n        next_inspection_at = NEW.next_inspection_at,\r\n\r\n        -- snapshot kondisi asset terbaru\r\n        status_condition = COALESCE(\r\n            NEW.condition_status,\r\n            status_condition\r\n        ),\r\n\r\n        level_contaminated = COALESCE(\r\n            NEW.contamination_level,\r\n            level_contaminated\r\n        ),\r\n\r\n        -- snapshot hasil inspeksi terakhir\r\n        last_inspection_result = NEW.inspection_result,\r\n        last_inspection_notes = NEW.notes,\r\n        last_action_taken = NEW.action_taken,\r\n        last_recommendation = NEW.recommendation,\r\n\r\n        -- audit update\r\n        updated_at = now(),\r\n        updated_by = NEW.inspected_by\r\n\r\n    WHERE id = NEW.asset_id;\r\n\r\n    RETURN NEW;\r\n\r\nEND;\r\n"
  },
  {
    "function_name": "fn_update_asset_last_user",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n\r\n    UPDATE public.assets\r\n    SET\r\n        last_used_by = NEW.profile_id,\r\n        last_assigned_at = NEW.assigned_at,\r\n        updated_at = now()\r\n    WHERE id = NEW.asset_id;\r\n\r\n    RETURN NEW;\r\n\r\nEND;\r\n"
  },
  {
    "function_name": "generate_request_number",
    "argument_count": 0,
    "source_code": "\r\nDECLARE\r\n    today DATE := CURRENT_DATE;\r\n    date_part VARCHAR(8);\r\n    seq INT;\r\n    seq_text VARCHAR(4);\r\nBEGIN\r\n    date_part := to_char(today, 'YYYYMMDD');\r\n    \r\n    -- Hitung jumlah request hari ini\r\n    SELECT COALESCE(COUNT(*), 0) INTO seq\r\n    FROM stock_requests\r\n    WHERE DATE(created_at) = today;\r\n    \r\n    seq_text := LPAD((seq + 1)::TEXT, 4, '0');\r\n    \r\n    RETURN 'SR-' || date_part || '-' || seq_text;\r\nEND;\r\n"
  },
  {
    "function_name": "geog_brin_inclusion_add_value",
    "argument_count": 4,
    "source_code": "geog_brin_inclusion_add_value"
  },
  {
    "function_name": "geography",
    "argument_count": 1,
    "source_code": "geography_from_binary"
  },
  {
    "function_name": "geography",
    "argument_count": 3,
    "source_code": "geography_enforce_typmod"
  },
  {
    "function_name": "geography",
    "argument_count": 1,
    "source_code": "geography_from_geometry"
  },
  {
    "function_name": "geography_analyze",
    "argument_count": 1,
    "source_code": "gserialized_analyze_nd"
  },
  {
    "function_name": "geography_cmp",
    "argument_count": 2,
    "source_code": "geography_cmp"
  },
  {
    "function_name": "geography_distance_knn",
    "argument_count": 2,
    "source_code": "geography_distance_knn"
  },
  {
    "function_name": "geography_eq",
    "argument_count": 2,
    "source_code": "geography_eq"
  },
  {
    "function_name": "geography_ge",
    "argument_count": 2,
    "source_code": "geography_ge"
  },
  {
    "function_name": "geography_gist_compress",
    "argument_count": 1,
    "source_code": "gserialized_gist_compress"
  },
  {
    "function_name": "geography_gist_consistent",
    "argument_count": 3,
    "source_code": "gserialized_gist_consistent"
  },
  {
    "function_name": "geography_gist_decompress",
    "argument_count": 1,
    "source_code": "gserialized_gist_decompress"
  },
  {
    "function_name": "geography_gist_distance",
    "argument_count": 3,
    "source_code": "gserialized_gist_geog_distance"
  },
  {
    "function_name": "geography_gist_penalty",
    "argument_count": 3,
    "source_code": "gserialized_gist_penalty"
  },
  {
    "function_name": "geography_gist_picksplit",
    "argument_count": 2,
    "source_code": "gserialized_gist_picksplit"
  },
  {
    "function_name": "geography_gist_same",
    "argument_count": 3,
    "source_code": "gserialized_gist_same"
  },
  {
    "function_name": "geography_gist_union",
    "argument_count": 2,
    "source_code": "gserialized_gist_union"
  },
  {
    "function_name": "geography_gt",
    "argument_count": 2,
    "source_code": "geography_gt"
  },
  {
    "function_name": "geography_in",
    "argument_count": 3,
    "source_code": "geography_in"
  },
  {
    "function_name": "geography_le",
    "argument_count": 2,
    "source_code": "geography_le"
  },
  {
    "function_name": "geography_lt",
    "argument_count": 2,
    "source_code": "geography_lt"
  },
  {
    "function_name": "geography_out",
    "argument_count": 1,
    "source_code": "geography_out"
  },
  {
    "function_name": "geography_overlaps",
    "argument_count": 2,
    "source_code": "gserialized_overlaps"
  },
  {
    "function_name": "geography_recv",
    "argument_count": 3,
    "source_code": "geography_recv"
  },
  {
    "function_name": "geography_send",
    "argument_count": 1,
    "source_code": "geography_send"
  },
  {
    "function_name": "geography_spgist_choose_nd",
    "argument_count": 2,
    "source_code": "gserialized_spgist_choose_nd"
  },
  {
    "function_name": "geography_spgist_compress_nd",
    "argument_count": 1,
    "source_code": "gserialized_spgist_compress_nd"
  },
  {
    "function_name": "geography_spgist_config_nd",
    "argument_count": 2,
    "source_code": "gserialized_spgist_config_nd"
  },
  {
    "function_name": "geography_spgist_inner_consistent_nd",
    "argument_count": 2,
    "source_code": "gserialized_spgist_inner_consistent_nd"
  },
  {
    "function_name": "geography_spgist_leaf_consistent_nd",
    "argument_count": 2,
    "source_code": "gserialized_spgist_leaf_consistent_nd"
  },
  {
    "function_name": "geography_spgist_picksplit_nd",
    "argument_count": 2,
    "source_code": "gserialized_spgist_picksplit_nd"
  },
  {
    "function_name": "geography_typmod_in",
    "argument_count": 1,
    "source_code": "geography_typmod_in"
  },
  {
    "function_name": "geography_typmod_out",
    "argument_count": 1,
    "source_code": "postgis_typmod_out"
  },
  {
    "function_name": "geom2d_brin_inclusion_add_value",
    "argument_count": 4,
    "source_code": "geom2d_brin_inclusion_add_value"
  },
  {
    "function_name": "geom3d_brin_inclusion_add_value",
    "argument_count": 4,
    "source_code": "geom3d_brin_inclusion_add_value"
  },
  {
    "function_name": "geom4d_brin_inclusion_add_value",
    "argument_count": 4,
    "source_code": "geom4d_brin_inclusion_add_value"
  },
  {
    "function_name": "geometry",
    "argument_count": 1,
    "source_code": "point_to_geometry"
  },
  {
    "function_name": "geometry",
    "argument_count": 1,
    "source_code": "LWGEOM_from_bytea"
  },
  {
    "function_name": "geometry",
    "argument_count": 1,
    "source_code": "parse_WKT_lwgeom"
  },
  {
    "function_name": "geometry",
    "argument_count": 1,
    "source_code": "BOX3D_to_LWGEOM"
  },
  {
    "function_name": "geometry",
    "argument_count": 1,
    "source_code": "BOX2D_to_LWGEOM"
  },
  {
    "function_name": "geometry",
    "argument_count": 3,
    "source_code": "geometry_enforce_typmod"
  },
  {
    "function_name": "geometry",
    "argument_count": 1,
    "source_code": "path_to_geometry"
  },
  {
    "function_name": "geometry",
    "argument_count": 1,
    "source_code": "polygon_to_geometry"
  },
  {
    "function_name": "geometry",
    "argument_count": 1,
    "source_code": "geometry_from_geography"
  },
  {
    "function_name": "geometry_above",
    "argument_count": 2,
    "source_code": "gserialized_above_2d"
  },
  {
    "function_name": "geometry_analyze",
    "argument_count": 1,
    "source_code": "gserialized_analyze_nd"
  },
  {
    "function_name": "geometry_below",
    "argument_count": 2,
    "source_code": "gserialized_below_2d"
  },
  {
    "function_name": "geometry_cmp",
    "argument_count": 2,
    "source_code": "lwgeom_cmp"
  },
  {
    "function_name": "geometry_contained_3d",
    "argument_count": 2,
    "source_code": "gserialized_contained_3d"
  },
  {
    "function_name": "geometry_contains",
    "argument_count": 2,
    "source_code": "gserialized_contains_2d"
  },
  {
    "function_name": "geometry_contains_3d",
    "argument_count": 2,
    "source_code": "gserialized_contains_3d"
  },
  {
    "function_name": "geometry_contains_nd",
    "argument_count": 2,
    "source_code": "gserialized_contains"
  },
  {
    "function_name": "geometry_distance_box",
    "argument_count": 2,
    "source_code": "gserialized_distance_box_2d"
  },
  {
    "function_name": "geometry_distance_centroid",
    "argument_count": 2,
    "source_code": "ST_Distance"
  },
  {
    "function_name": "geometry_distance_centroid_nd",
    "argument_count": 2,
    "source_code": "gserialized_distance_nd"
  },
  {
    "function_name": "geometry_distance_cpa",
    "argument_count": 2,
    "source_code": "ST_DistanceCPA"
  },
  {
    "function_name": "geometry_eq",
    "argument_count": 2,
    "source_code": "lwgeom_eq"
  },
  {
    "function_name": "geometry_ge",
    "argument_count": 2,
    "source_code": "lwgeom_ge"
  },
  {
    "function_name": "geometry_gist_compress_2d",
    "argument_count": 1,
    "source_code": "gserialized_gist_compress_2d"
  },
  {
    "function_name": "geometry_gist_compress_nd",
    "argument_count": 1,
    "source_code": "gserialized_gist_compress"
  },
  {
    "function_name": "geometry_gist_consistent_2d",
    "argument_count": 3,
    "source_code": "gserialized_gist_consistent_2d"
  },
  {
    "function_name": "geometry_gist_consistent_nd",
    "argument_count": 3,
    "source_code": "gserialized_gist_consistent"
  },
  {
    "function_name": "geometry_gist_decompress_2d",
    "argument_count": 1,
    "source_code": "gserialized_gist_decompress_2d"
  },
  {
    "function_name": "geometry_gist_decompress_nd",
    "argument_count": 1,
    "source_code": "gserialized_gist_decompress"
  },
  {
    "function_name": "geometry_gist_distance_2d",
    "argument_count": 3,
    "source_code": "gserialized_gist_distance_2d"
  },
  {
    "function_name": "geometry_gist_distance_nd",
    "argument_count": 3,
    "source_code": "gserialized_gist_distance"
  },
  {
    "function_name": "geometry_gist_penalty_2d",
    "argument_count": 3,
    "source_code": "gserialized_gist_penalty_2d"
  },
  {
    "function_name": "geometry_gist_penalty_nd",
    "argument_count": 3,
    "source_code": "gserialized_gist_penalty"
  },
  {
    "function_name": "geometry_gist_picksplit_2d",
    "argument_count": 2,
    "source_code": "gserialized_gist_picksplit_2d"
  },
  {
    "function_name": "geometry_gist_picksplit_nd",
    "argument_count": 2,
    "source_code": "gserialized_gist_picksplit"
  },
  {
    "function_name": "geometry_gist_same_2d",
    "argument_count": 3,
    "source_code": "gserialized_gist_same_2d"
  },
  {
    "function_name": "geometry_gist_same_nd",
    "argument_count": 3,
    "source_code": "gserialized_gist_same"
  },
  {
    "function_name": "geometry_gist_sortsupport_2d",
    "argument_count": 1,
    "source_code": "gserialized_gist_sortsupport_2d"
  },
  {
    "function_name": "geometry_gist_union_2d",
    "argument_count": 2,
    "source_code": "gserialized_gist_union_2d"
  },
  {
    "function_name": "geometry_gist_union_nd",
    "argument_count": 2,
    "source_code": "gserialized_gist_union"
  },
  {
    "function_name": "geometry_gt",
    "argument_count": 2,
    "source_code": "lwgeom_gt"
  },
  {
    "function_name": "geometry_hash",
    "argument_count": 1,
    "source_code": "lwgeom_hash"
  },
  {
    "function_name": "geometry_in",
    "argument_count": 1,
    "source_code": "LWGEOM_in"
  },
  {
    "function_name": "geometry_le",
    "argument_count": 2,
    "source_code": "lwgeom_le"
  },
  {
    "function_name": "geometry_left",
    "argument_count": 2,
    "source_code": "gserialized_left_2d"
  },
  {
    "function_name": "geometry_lt",
    "argument_count": 2,
    "source_code": "lwgeom_lt"
  },
  {
    "function_name": "geometry_out",
    "argument_count": 1,
    "source_code": "LWGEOM_out"
  },
  {
    "function_name": "geometry_overabove",
    "argument_count": 2,
    "source_code": "gserialized_overabove_2d"
  },
  {
    "function_name": "geometry_overbelow",
    "argument_count": 2,
    "source_code": "gserialized_overbelow_2d"
  },
  {
    "function_name": "geometry_overlaps",
    "argument_count": 2,
    "source_code": "gserialized_overlaps_2d"
  },
  {
    "function_name": "geometry_overlaps_3d",
    "argument_count": 2,
    "source_code": "gserialized_overlaps_3d"
  },
  {
    "function_name": "geometry_overlaps_nd",
    "argument_count": 2,
    "source_code": "gserialized_overlaps"
  },
  {
    "function_name": "geometry_overleft",
    "argument_count": 2,
    "source_code": "gserialized_overleft_2d"
  },
  {
    "function_name": "geometry_overright",
    "argument_count": 2,
    "source_code": "gserialized_overright_2d"
  },
  {
    "function_name": "geometry_recv",
    "argument_count": 1,
    "source_code": "LWGEOM_recv"
  },
  {
    "function_name": "geometry_right",
    "argument_count": 2,
    "source_code": "gserialized_right_2d"
  },
  {
    "function_name": "geometry_same",
    "argument_count": 2,
    "source_code": "gserialized_same_2d"
  },
  {
    "function_name": "geometry_same_3d",
    "argument_count": 2,
    "source_code": "gserialized_same_3d"
  },
  {
    "function_name": "geometry_same_nd",
    "argument_count": 2,
    "source_code": "gserialized_same"
  },
  {
    "function_name": "geometry_send",
    "argument_count": 1,
    "source_code": "LWGEOM_send"
  },
  {
    "function_name": "geometry_sortsupport",
    "argument_count": 1,
    "source_code": "lwgeom_sortsupport"
  },
  {
    "function_name": "geometry_spgist_choose_2d",
    "argument_count": 2,
    "source_code": "gserialized_spgist_choose_2d"
  },
  {
    "function_name": "geometry_spgist_choose_3d",
    "argument_count": 2,
    "source_code": "gserialized_spgist_choose_3d"
  },
  {
    "function_name": "geometry_spgist_choose_nd",
    "argument_count": 2,
    "source_code": "gserialized_spgist_choose_nd"
  },
  {
    "function_name": "geometry_spgist_compress_2d",
    "argument_count": 1,
    "source_code": "gserialized_spgist_compress_2d"
  },
  {
    "function_name": "geometry_spgist_compress_3d",
    "argument_count": 1,
    "source_code": "gserialized_spgist_compress_3d"
  },
  {
    "function_name": "geometry_spgist_compress_nd",
    "argument_count": 1,
    "source_code": "gserialized_spgist_compress_nd"
  },
  {
    "function_name": "geometry_spgist_config_2d",
    "argument_count": 2,
    "source_code": "gserialized_spgist_config_2d"
  },
  {
    "function_name": "geometry_spgist_config_3d",
    "argument_count": 2,
    "source_code": "gserialized_spgist_config_3d"
  },
  {
    "function_name": "geometry_spgist_config_nd",
    "argument_count": 2,
    "source_code": "gserialized_spgist_config_nd"
  },
  {
    "function_name": "geometry_spgist_inner_consistent_2d",
    "argument_count": 2,
    "source_code": "gserialized_spgist_inner_consistent_2d"
  },
  {
    "function_name": "geometry_spgist_inner_consistent_3d",
    "argument_count": 2,
    "source_code": "gserialized_spgist_inner_consistent_3d"
  },
  {
    "function_name": "geometry_spgist_inner_consistent_nd",
    "argument_count": 2,
    "source_code": "gserialized_spgist_inner_consistent_nd"
  },
  {
    "function_name": "geometry_spgist_leaf_consistent_2d",
    "argument_count": 2,
    "source_code": "gserialized_spgist_leaf_consistent_2d"
  },
  {
    "function_name": "geometry_spgist_leaf_consistent_3d",
    "argument_count": 2,
    "source_code": "gserialized_spgist_leaf_consistent_3d"
  },
  {
    "function_name": "geometry_spgist_leaf_consistent_nd",
    "argument_count": 2,
    "source_code": "gserialized_spgist_leaf_consistent_nd"
  },
  {
    "function_name": "geometry_spgist_picksplit_2d",
    "argument_count": 2,
    "source_code": "gserialized_spgist_picksplit_2d"
  },
  {
    "function_name": "geometry_spgist_picksplit_3d",
    "argument_count": 2,
    "source_code": "gserialized_spgist_picksplit_3d"
  },
  {
    "function_name": "geometry_spgist_picksplit_nd",
    "argument_count": 2,
    "source_code": "gserialized_spgist_picksplit_nd"
  },
  {
    "function_name": "geometry_typmod_in",
    "argument_count": 1,
    "source_code": "geometry_typmod_in"
  },
  {
    "function_name": "geometry_typmod_out",
    "argument_count": 1,
    "source_code": "postgis_typmod_out"
  },
  {
    "function_name": "geometry_within",
    "argument_count": 2,
    "source_code": "gserialized_within_2d"
  },
  {
    "function_name": "geometry_within_nd",
    "argument_count": 2,
    "source_code": "gserialized_within"
  },
  {
    "function_name": "geometrytype",
    "argument_count": 1,
    "source_code": "LWGEOM_getTYPE"
  },
  {
    "function_name": "geometrytype",
    "argument_count": 1,
    "source_code": "LWGEOM_getTYPE"
  },
  {
    "function_name": "geomfromewkb",
    "argument_count": 1,
    "source_code": "LWGEOMFromEWKB"
  },
  {
    "function_name": "geomfromewkt",
    "argument_count": 1,
    "source_code": "parse_WKT_lwgeom"
  },
  {
    "function_name": "get_proj4_from_srid",
    "argument_count": 1,
    "source_code": "\n\tBEGIN\n\tRETURN proj4text::text FROM public.spatial_ref_sys WHERE srid= $1;\n\tEND;\n\t"
  },
  {
    "function_name": "get_tracking_by_date_range",
    "argument_count": 3,
    "source_code": "\r\nBEGIN\r\n  RETURN QUERY\r\n  SELECT \r\n    elt.recorded_at,\r\n    elt.latitude,\r\n    elt.longitude,\r\n    elt.speed,\r\n    (SELECT address_at_check_in FROM attendance WHERE session_id = elt.session_id LIMIT 1) as address,\r\n    COALESCE(rs.shift_name, 'No Shift')\r\n  FROM employee_location_tracking elt\r\n  LEFT JOIN attendance a ON a.session_id = elt.session_id\r\n  LEFT JOIN ref_shifts rs ON rs.id = a.shift_id\r\n  WHERE elt.profile_id = p_profile_id\r\n    AND elt.recorded_at BETWEEN p_start_date AND p_end_date\r\n  ORDER BY elt.recorded_at ASC;\r\nEND;\r\n"
  },
  {
    "function_name": "gettransactionid",
    "argument_count": 0,
    "source_code": "getTransactionID"
  },
  {
    "function_name": "gidx_in",
    "argument_count": 1,
    "source_code": "gidx_in"
  },
  {
    "function_name": "gidx_out",
    "argument_count": 1,
    "source_code": "gidx_out"
  },
  {
    "function_name": "gserialized_gist_joinsel_2d",
    "argument_count": 4,
    "source_code": "gserialized_gist_joinsel_2d"
  },
  {
    "function_name": "gserialized_gist_joinsel_nd",
    "argument_count": 4,
    "source_code": "gserialized_gist_joinsel_nd"
  },
  {
    "function_name": "gserialized_gist_sel_2d",
    "argument_count": 4,
    "source_code": "gserialized_gist_sel_2d"
  },
  {
    "function_name": "gserialized_gist_sel_nd",
    "argument_count": 4,
    "source_code": "gserialized_gist_sel_nd"
  },
  {
    "function_name": "handle_new_user",
    "argument_count": 0,
    "source_code": "\r\nbegin\r\n  insert into public.profiles (id, full_name, role)\r\n  values (\r\n    new.id, \r\n    new.raw_user_meta_data->>'full_name', -- Mengambil nama dari metadata registrasi\r\n    'operation' -- Default role bagi pendaftar baru\r\n  );\r\n  return new;\r\nend;\r\n"
  },
  {
    "function_name": "haversine_distance",
    "argument_count": 4,
    "source_code": "\r\nDECLARE\r\n  R DOUBLE PRECISION := 6371000;\r\n  dlat DOUBLE PRECISION;\r\n  dlon DOUBLE PRECISION;\r\n  a DOUBLE PRECISION;\r\n  c DOUBLE PRECISION;\r\nBEGIN\r\n  dlat := RADIANS(lat2 - lat1);\r\n  dlon := RADIANS(lon2 - lon1);\r\n  a := SIN(dlat/2) * SIN(dlat/2) +\r\n       COS(RADIANS(lat1)) * COS(RADIANS(lat2)) *\r\n       SIN(dlon/2) * SIN(dlon/2);\r\n  c := 2 * ATAN2(SQRT(a), SQRT(1-a));\r\n  RETURN R * c;\r\nEND;\r\n"
  },
  {
    "function_name": "is_contained_2d",
    "argument_count": 2,
    "source_code": "SELECT $2 OPERATOR(public.~) $1;"
  },
  {
    "function_name": "is_contained_2d",
    "argument_count": 2,
    "source_code": "gserialized_within_box2df_geom_2d"
  },
  {
    "function_name": "is_contained_2d",
    "argument_count": 2,
    "source_code": "gserialized_contains_box2df_box2df_2d"
  },
  {
    "function_name": "json",
    "argument_count": 1,
    "source_code": "geometry_to_json"
  },
  {
    "function_name": "jsonb",
    "argument_count": 1,
    "source_code": "geometry_to_jsonb"
  },
  {
    "function_name": "lockrow",
    "argument_count": 5,
    "source_code": "\nDECLARE\n\tmyschema alias for $1;\n\tmytable alias for $2;\n\tmyrid   alias for $3;\n\tauthid alias for $4;\n\texpires alias for $5;\n\tret int;\n\tmytoid oid;\n\tmyrec RECORD;\n\nBEGIN\n\n\tIF NOT LongTransactionsEnabled() THEN\n\t\tRAISE EXCEPTION 'Long transaction support disabled, use EnableLongTransaction() to enable.';\n\tEND IF;\n\n\tEXECUTE 'DELETE FROM authorization_table WHERE expires < now()';\n\n\tSELECT c.oid INTO mytoid FROM pg_class c, pg_namespace n\n\t\tWHERE c.relname = mytable\n\t\tAND c.relnamespace = n.oid\n\t\tAND n.nspname = myschema;\n\n\t-- RAISE NOTICE 'toid: %', mytoid;\n\n\tFOR myrec IN SELECT * FROM authorization_table WHERE\n\t\ttoid = mytoid AND rid = myrid\n\tLOOP\n\t\tIF myrec.authid != authid THEN\n\t\t\tRETURN 0;\n\t\tELSE\n\t\t\tRETURN 1;\n\t\tEND IF;\n\tEND LOOP;\n\n\tEXECUTE 'INSERT INTO authorization_table VALUES ('||\n\t\tquote_literal(mytoid::text)||','||quote_literal(myrid)||\n\t\t','||quote_literal(expires::text)||\n\t\t','||quote_literal(authid) ||')';\n\n\tGET DIAGNOSTICS ret = ROW_COUNT;\n\n\tRETURN ret;\nEND;\n"
  },
  {
    "function_name": "lockrow",
    "argument_count": 3,
    "source_code": " SELECT LockRow(current_schema(), $1, $2, $3, now()::timestamp+'1:00'); "
  },
  {
    "function_name": "lockrow",
    "argument_count": 4,
    "source_code": " SELECT LockRow($1, $2, $3, $4, now()::timestamp+'1:00'); "
  },
  {
    "function_name": "lockrow",
    "argument_count": 4,
    "source_code": " SELECT LockRow(current_schema(), $1, $2, $3, $4); "
  },
  {
    "function_name": "longtransactionsenabled",
    "argument_count": 0,
    "source_code": "\nDECLARE\n\trec RECORD;\nBEGIN\n\tFOR rec IN SELECT oid FROM pg_class WHERE relname = 'authorized_tables'\n\tLOOP\n\t\treturn 't';\n\tEND LOOP;\n\treturn 'f';\nEND;\n"
  },
  {
    "function_name": "overlaps_2d",
    "argument_count": 2,
    "source_code": "gserialized_overlaps_box2df_geom_2d"
  },
  {
    "function_name": "overlaps_2d",
    "argument_count": 2,
    "source_code": "gserialized_contains_box2df_box2df_2d"
  },
  {
    "function_name": "overlaps_2d",
    "argument_count": 2,
    "source_code": "SELECT $2 OPERATOR(public.&&) $1;"
  },
  {
    "function_name": "overlaps_geog",
    "argument_count": 2,
    "source_code": "SELECT $2 OPERATOR(public.&&) $1;"
  },
  {
    "function_name": "overlaps_geog",
    "argument_count": 2,
    "source_code": "gserialized_gidx_geog_overlaps"
  },
  {
    "function_name": "overlaps_geog",
    "argument_count": 2,
    "source_code": "gserialized_gidx_gidx_overlaps"
  },
  {
    "function_name": "overlaps_nd",
    "argument_count": 2,
    "source_code": "SELECT $2 OPERATOR(public.&&&) $1;"
  },
  {
    "function_name": "overlaps_nd",
    "argument_count": 2,
    "source_code": "gserialized_gidx_gidx_overlaps"
  },
  {
    "function_name": "overlaps_nd",
    "argument_count": 2,
    "source_code": "gserialized_gidx_geom_overlaps"
  },
  {
    "function_name": "path",
    "argument_count": 1,
    "source_code": "geometry_to_path"
  },
  {
    "function_name": "point",
    "argument_count": 1,
    "source_code": "geometry_to_point"
  },
  {
    "function_name": "polygon",
    "argument_count": 1,
    "source_code": "geometry_to_polygon"
  },
  {
    "function_name": "populate_geometry_columns",
    "argument_count": 2,
    "source_code": "\nDECLARE\n\tgcs\t\t RECORD;\n\tgc\t\t  RECORD;\n\tgc_old\t  RECORD;\n\tgsrid\t   integer;\n\tgndims\t  integer;\n\tgtype\t   text;\n\tquery\t   text;\n\tgc_is_valid boolean;\n\tinserted\tinteger;\n\tconstraint_successful boolean := false;\n\nBEGIN\n\tinserted := 0;\n\n\t-- Iterate through all geometry columns in this table\n\tFOR gcs IN\n\tSELECT n.nspname, c.relname, a.attname, c.relkind\n\t\tFROM pg_class c,\n\t\t\t pg_attribute a,\n\t\t\t pg_type t,\n\t\t\t pg_namespace n\n\t\tWHERE c.relkind IN('r', 'f', 'p')\n\t\tAND t.typname = 'geometry'\n\t\tAND a.attisdropped = false\n\t\tAND a.atttypid = t.oid\n\t\tAND a.attrelid = c.oid\n\t\tAND c.relnamespace = n.oid\n\t\tAND n.nspname NOT ILIKE 'pg_temp%'\n\t\tAND c.oid = tbl_oid\n\tLOOP\n\n\t\tRAISE DEBUG 'Processing column %.%.%', gcs.nspname, gcs.relname, gcs.attname;\n\n\t\tgc_is_valid := true;\n\t\t-- Find the srid, coord_dimension, and type of current geometry\n\t\t-- in geometry_columns -- which is now a view\n\n\t\tSELECT type, srid, coord_dimension, gcs.relkind INTO gc_old\n\t\t\tFROM geometry_columns\n\t\t\tWHERE f_table_schema = gcs.nspname AND f_table_name = gcs.relname AND f_geometry_column = gcs.attname;\n\n\t\tIF upper(gc_old.type) = 'GEOMETRY' THEN\n\t\t-- This is an unconstrained geometry we need to do something\n\t\t-- We need to figure out what to set the type by inspecting the data\n\t\t\tEXECUTE 'SELECT public.ST_srid(' || quote_ident(gcs.attname) || ') As srid, public.GeometryType(' || quote_ident(gcs.attname) || ') As type, public.ST_NDims(' || quote_ident(gcs.attname) || ') As dims ' ||\n\t\t\t\t\t ' FROM ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) ||\n\t\t\t\t\t ' WHERE ' || quote_ident(gcs.attname) || ' IS NOT NULL LIMIT 1;'\n\t\t\t\tINTO gc;\n\t\t\tIF gc IS NULL THEN -- there is no data so we can not determine geometry type\n\t\t\t\tRAISE WARNING 'No data in table %.%, so no information to determine geometry type and srid', gcs.nspname, gcs.relname;\n\t\t\t\tRETURN 0;\n\t\t\tEND IF;\n\t\t\tgsrid := gc.srid; gtype := gc.type; gndims := gc.dims;\n\n\t\t\tIF use_typmod THEN\n\t\t\t\tBEGIN\n\t\t\t\t\tEXECUTE 'ALTER TABLE ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || ' ALTER COLUMN ' || quote_ident(gcs.attname) ||\n\t\t\t\t\t\t' TYPE geometry(' || postgis_type_name(gtype, gndims, true) || ', ' || gsrid::text  || ') ';\n\t\t\t\t\tinserted := inserted + 1;\n\t\t\t\tEXCEPTION\n\t\t\t\t\t\tWHEN invalid_parameter_value OR feature_not_supported THEN\n\t\t\t\t\t\tRAISE WARNING 'Could not convert ''%'' in ''%.%'' to use typmod with srid %, type %: %', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname), gsrid, postgis_type_name(gtype, gndims, true), SQLERRM;\n\t\t\t\t\t\t\tgc_is_valid := false;\n\t\t\t\tEND;\n\n\t\t\tELSE\n\t\t\t\t-- Try to apply srid check to column\n\t\t\t\tconstraint_successful = false;\n\t\t\t\tIF (gsrid > 0 AND postgis_constraint_srid(gcs.nspname, gcs.relname,gcs.attname) IS NULL ) THEN\n\t\t\t\t\tBEGIN\n\t\t\t\t\t\tEXECUTE 'ALTER TABLE ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) ||\n\t\t\t\t\t\t\t\t ' ADD CONSTRAINT ' || quote_ident('enforce_srid_' || gcs.attname) ||\n\t\t\t\t\t\t\t\t ' CHECK (ST_srid(' || quote_ident(gcs.attname) || ') = ' || gsrid || ')';\n\t\t\t\t\t\tconstraint_successful := true;\n\t\t\t\t\tEXCEPTION\n\t\t\t\t\t\tWHEN check_violation THEN\n\t\t\t\t\t\t\tRAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not apply constraint CHECK (st_srid(%) = %)', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname), quote_ident(gcs.attname), gsrid;\n\t\t\t\t\t\t\tgc_is_valid := false;\n\t\t\t\t\tEND;\n\t\t\t\tEND IF;\n\n\t\t\t\t-- Try to apply ndims check to column\n\t\t\t\tIF (gndims IS NOT NULL AND postgis_constraint_dims(gcs.nspname, gcs.relname,gcs.attname) IS NULL ) THEN\n\t\t\t\t\tBEGIN\n\t\t\t\t\t\tEXECUTE 'ALTER TABLE ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || '\n\t\t\t\t\t\t\t\t ADD CONSTRAINT ' || quote_ident('enforce_dims_' || gcs.attname) || '\n\t\t\t\t\t\t\t\t CHECK (st_ndims(' || quote_ident(gcs.attname) || ') = '||gndims||')';\n\t\t\t\t\t\tconstraint_successful := true;\n\t\t\t\t\tEXCEPTION\n\t\t\t\t\t\tWHEN check_violation THEN\n\t\t\t\t\t\t\tRAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not apply constraint CHECK (st_ndims(%) = %)', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname), quote_ident(gcs.attname), gndims;\n\t\t\t\t\t\t\tgc_is_valid := false;\n\t\t\t\t\tEND;\n\t\t\t\tEND IF;\n\n\t\t\t\t-- Try to apply geometrytype check to column\n\t\t\t\tIF (gtype IS NOT NULL AND postgis_constraint_type(gcs.nspname, gcs.relname,gcs.attname) IS NULL ) THEN\n\t\t\t\t\tBEGIN\n\t\t\t\t\t\tEXECUTE 'ALTER TABLE ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || '\n\t\t\t\t\t\tADD CONSTRAINT ' || quote_ident('enforce_geotype_' || gcs.attname) || '\n\t\t\t\t\t\tCHECK (geometrytype(' || quote_ident(gcs.attname) || ') = ' || quote_literal(gtype) || ')';\n\t\t\t\t\t\tconstraint_successful := true;\n\t\t\t\t\tEXCEPTION\n\t\t\t\t\t\tWHEN check_violation THEN\n\t\t\t\t\t\t\t-- No geometry check can be applied. This column contains a number of geometry types.\n\t\t\t\t\t\t\tRAISE WARNING 'Could not add geometry type check (%) to table column: %.%.%', gtype, quote_ident(gcs.nspname),quote_ident(gcs.relname),quote_ident(gcs.attname);\n\t\t\t\t\tEND;\n\t\t\t\tEND IF;\n\t\t\t\t --only count if we were successful in applying at least one constraint\n\t\t\t\tIF constraint_successful THEN\n\t\t\t\t\tinserted := inserted + 1;\n\t\t\t\tEND IF;\n\t\t\tEND IF;\n\t\tEND IF;\n\n\tEND LOOP;\n\n\tRETURN inserted;\nEND\n\n"
  },
  {
    "function_name": "populate_geometry_columns",
    "argument_count": 1,
    "source_code": "\nDECLARE\n\tinserted\tinteger;\n\toldcount\tinteger;\n\tprobed\t  integer;\n\tstale\t   integer;\n\tgcs\t\t RECORD;\n\tgc\t\t  RECORD;\n\tgsrid\t   integer;\n\tgndims\t  integer;\n\tgtype\t   text;\n\tquery\t   text;\n\tgc_is_valid boolean;\n\nBEGIN\n\tSELECT count(*) INTO oldcount FROM public.geometry_columns;\n\tinserted := 0;\n\n\t-- Count the number of geometry columns in all tables and views\n\tSELECT count(DISTINCT c.oid) INTO probed\n\tFROM pg_class c,\n\t\t pg_attribute a,\n\t\t pg_type t,\n\t\t pg_namespace n\n\tWHERE c.relkind IN('r','v','f', 'p')\n\t\tAND t.typname = 'geometry'\n\t\tAND a.attisdropped = false\n\t\tAND a.atttypid = t.oid\n\t\tAND a.attrelid = c.oid\n\t\tAND c.relnamespace = n.oid\n\t\tAND n.nspname NOT ILIKE 'pg_temp%' AND c.relname != 'raster_columns' ;\n\n\t-- Iterate through all non-dropped geometry columns\n\tRAISE DEBUG 'Processing Tables.....';\n\n\tFOR gcs IN\n\tSELECT DISTINCT ON (c.oid) c.oid, n.nspname, c.relname\n\t\tFROM pg_class c,\n\t\t\t pg_attribute a,\n\t\t\t pg_type t,\n\t\t\t pg_namespace n\n\t\tWHERE c.relkind IN( 'r', 'f', 'p')\n\t\tAND t.typname = 'geometry'\n\t\tAND a.attisdropped = false\n\t\tAND a.atttypid = t.oid\n\t\tAND a.attrelid = c.oid\n\t\tAND c.relnamespace = n.oid\n\t\tAND n.nspname NOT ILIKE 'pg_temp%' AND c.relname != 'raster_columns'\n\tLOOP\n\n\t\tinserted := inserted + public.populate_geometry_columns(gcs.oid, use_typmod);\n\tEND LOOP;\n\n\tIF oldcount > inserted THEN\n\t\tstale = oldcount-inserted;\n\tELSE\n\t\tstale = 0;\n\tEND IF;\n\n\tRETURN 'probed:' ||probed|| ' inserted:'||inserted;\nEND\n\n"
  },
  {
    "function_name": "postgis_addbbox",
    "argument_count": 1,
    "source_code": "LWGEOM_addBBOX"
  },
  {
    "function_name": "postgis_cache_bbox",
    "argument_count": 0,
    "source_code": "cache_bbox"
  },
  {
    "function_name": "postgis_constraint_dims",
    "argument_count": 3,
    "source_code": "\nSELECT  replace(split_part(s.consrc, ' = ', 2), ')', '')::integer\n\t\t FROM pg_class c, pg_namespace n, pg_attribute a\n\t\t , (SELECT connamespace, conrelid, conkey, pg_get_constraintdef(oid) As consrc\n\t\t\tFROM pg_constraint) AS s\n\t\t WHERE n.nspname = $1\n\t\t AND c.relname = $2\n\t\t AND a.attname = $3\n\t\t AND a.attrelid = c.oid\n\t\t AND s.connamespace = n.oid\n\t\t AND s.conrelid = c.oid\n\t\t AND a.attnum = ANY (s.conkey)\n\t\t AND s.consrc LIKE '%ndims(% = %';\n"
  },
  {
    "function_name": "postgis_constraint_srid",
    "argument_count": 3,
    "source_code": "\nSELECT replace(replace(split_part(s.consrc, ' = ', 2), ')', ''), '(', '')::integer\n\t\t FROM pg_class c, pg_namespace n, pg_attribute a\n\t\t , (SELECT connamespace, conrelid, conkey, pg_get_constraintdef(oid) As consrc\n\t\t\tFROM pg_constraint) AS s\n\t\t WHERE n.nspname = $1\n\t\t AND c.relname = $2\n\t\t AND a.attname = $3\n\t\t AND a.attrelid = c.oid\n\t\t AND s.connamespace = n.oid\n\t\t AND s.conrelid = c.oid\n\t\t AND a.attnum = ANY (s.conkey)\n\t\t AND s.consrc LIKE '%srid(% = %';\n"
  },
  {
    "function_name": "postgis_constraint_type",
    "argument_count": 3,
    "source_code": "\nSELECT  replace(split_part(s.consrc, '''', 2), ')', '')::varchar\n\t\t FROM pg_class c, pg_namespace n, pg_attribute a\n\t\t , (SELECT connamespace, conrelid, conkey, pg_get_constraintdef(oid) As consrc\n\t\t\tFROM pg_constraint) AS s\n\t\t WHERE n.nspname = $1\n\t\t AND c.relname = $2\n\t\t AND a.attname = $3\n\t\t AND a.attrelid = c.oid\n\t\t AND s.connamespace = n.oid\n\t\t AND s.conrelid = c.oid\n\t\t AND a.attnum = ANY (s.conkey)\n\t\t AND s.consrc LIKE '%geometrytype(% = %';\n"
  },
  {
    "function_name": "postgis_dropbbox",
    "argument_count": 1,
    "source_code": "LWGEOM_dropBBOX"
  },
  {
    "function_name": "postgis_extensions_upgrade",
    "argument_count": 0,
    "source_code": "\nDECLARE\n\trec record;\n\tsql text;\n\tvar_schema text;\n\ttarget_version text; -- TODO: optionally take as argument\nBEGIN\n\n\tFOR rec IN\n\t\tSELECT name, default_version, installed_version\n\t\tFROM pg_catalog.pg_available_extensions\n\t\tWHERE name IN (\n\t\t\t'postgis',\n\t\t\t'postgis_raster',\n\t\t\t'postgis_sfcgal',\n\t\t\t'postgis_topology',\n\t\t\t'postgis_tiger_geocoder'\n\t\t)\n\t\tORDER BY length(name) -- this is to make sure 'postgis' is first !\n\tLOOP --{\n\n\t\tIF target_version IS NULL THEN\n\t\t\ttarget_version := rec.default_version;\n\t\tEND IF;\n\n\t\tIF rec.installed_version IS NULL THEN --{\n\t\t\t-- If the support installed by available extension\n\t\t\t-- is found unpackaged, we package it\n\t\t\tIF --{\n\t\t\t\t -- PostGIS is always available (this function is part of it)\n\t\t\t\t rec.name = 'postgis'\n\n\t\t\t\t -- PostGIS raster is available if type 'raster' exists\n\t\t\t\t OR ( rec.name = 'postgis_raster' AND EXISTS (\n\t\t\t\t\t\t\tSELECT 1 FROM pg_catalog.pg_type\n\t\t\t\t\t\t\tWHERE typname = 'raster' ) )\n\n\t\t\t\t -- PostGIS SFCGAL is availble if\n\t\t\t\t -- 'postgis_sfcgal_version' function exists\n\t\t\t\t OR ( rec.name = 'postgis_sfcgal' AND EXISTS (\n\t\t\t\t\t\t\tSELECT 1 FROM pg_catalog.pg_proc\n\t\t\t\t\t\t\tWHERE proname = 'postgis_sfcgal_version' ) )\n\n\t\t\t\t -- PostGIS Topology is available if\n\t\t\t\t -- 'topology.topology' table exists\n\t\t\t\t -- NOTE: watch out for https://trac.osgeo.org/postgis/ticket/2503\n\t\t\t\t OR ( rec.name = 'postgis_topology' AND EXISTS (\n\t\t\t\t\t\t\tSELECT 1 FROM pg_catalog.pg_class c\n\t\t\t\t\t\t\tJOIN pg_catalog.pg_namespace n ON (c.relnamespace = n.oid )\n\t\t\t\t\t\t\tWHERE n.nspname = 'topology' AND c.relname = 'topology') )\n\n\t\t\t\t OR ( rec.name = 'postgis_tiger_geocoder' AND EXISTS (\n\t\t\t\t\t\t\tSELECT 1 FROM pg_catalog.pg_class c\n\t\t\t\t\t\t\tJOIN pg_catalog.pg_namespace n ON (c.relnamespace = n.oid )\n\t\t\t\t\t\t\tWHERE n.nspname = 'tiger' AND c.relname = 'geocode_settings') )\n\t\t\tTHEN --}{\n\t\t\t\t-- Force install in same schema as postgis\n\t\t\t\tSELECT INTO var_schema n.nspname\n\t\t\t\t  FROM pg_namespace n, pg_proc p\n\t\t\t\t  WHERE p.proname = 'postgis_full_version'\n\t\t\t\t\tAND n.oid = p.pronamespace\n\t\t\t\t  LIMIT 1;\n\t\t\t\tIF rec.name NOT IN('postgis_topology', 'postgis_tiger_geocoder')\n\t\t\t\tTHEN\n\t\t\t\t\tsql := format(\n\t\t\t\t\t\t\t  'CREATE EXTENSION %1$I SCHEMA %2$I VERSION unpackaged;'\n\t\t\t\t\t\t\t  'ALTER EXTENSION %1$I UPDATE TO %3$I',\n\t\t\t\t\t\t\t  rec.name, var_schema, target_version);\n\t\t\t\tELSE\n\t\t\t\t\tsql := format(\n\t\t\t\t\t\t\t 'CREATE EXTENSION %1$I VERSION unpackaged;'\n\t\t\t\t\t\t\t 'ALTER EXTENSION %1$I UPDATE TO %2$I',\n\t\t\t\t\t\t\t rec.name, target_version);\n\t\t\t\tEND IF;\n\t\t\t\tRAISE NOTICE 'Packaging and updating %', rec.name;\n\t\t\t\tRAISE DEBUG '%', sql;\n\t\t\t\tEXECUTE sql;\n\t\t\tELSE\n\t\t\t\tRAISE DEBUG 'Skipping % (not in use)', rec.name;\n\t\t\tEND IF;\n\t\tELSE -- IF target_version != rec.installed_version THEN --}{\n\t\t\tsql = '';\n\t\t\t-- If logged in as super user\n\t\t\t-- force an update regardless if at target version, no downgrade allowed\n\t\t\tIF (SELECT usesuper FROM pg_user WHERE usename = CURRENT_USER)\n\t\t\t\t\t\tAND pg_catalog.substring(target_version, '[0-9]+\\.[0-9]+\\.[0-9]+')\n\t\t\t\t\t\t\t\t>= pg_catalog.substring(rec.installed_version, '[0-9]+\\.[0-9]+\\.[0-9]+')\n\t\t\tTHEN\n\t\t\t\tsql = format(\n\t\t\t\t\t'UPDATE pg_catalog.pg_extension SET extversion = ''ANY'' WHERE extname = %1$L;'\n\t\t\t\t\t'ALTER EXTENSION %1$I UPDATE TO %2$I',\n\t\t\t\t\trec.name, target_version\n\t\t\t\t);\n\t\t\t-- sandboxed users do standard upgrade\n\t\t\tELSE\n\t\t\t\tsql = format(\n\t\t\t\t'ALTER EXTENSION %1$I UPDATE TO %2$I',\n\t\t\t\trec.name, target_version\n\t\t\t\t);\n\t\t\tEND IF;\n\t\t\tRAISE NOTICE 'Updating extension % %',\n\t\t\t\trec.name, rec.installed_version;\n\t\t\tRAISE DEBUG '%', sql;\n\t\t\tEXECUTE sql;\n\t\tEND IF; --}\n\n\tEND LOOP; --}\n\n\tRETURN format(\n\t\t'Upgrade to version %s completed, run SELECT postgis_full_version(); for details',\n\t\ttarget_version\n\t);\n\n\nEND\n"
  },
  {
    "function_name": "postgis_full_version",
    "argument_count": 0,
    "source_code": "\nDECLARE\n\tlibver text;\n\tlibrev text;\n\tprojver text;\n\tgeosver text;\n\tsfcgalver text;\n\tgdalver text := NULL;\n\tlibxmlver text;\n\tliblwgeomver text;\n\tdbproc text;\n\trelproc text;\n\tfullver text;\n\trast_lib_ver text := NULL;\n\trast_scr_ver text := NULL;\n\ttopo_scr_ver text := NULL;\n\tjson_lib_ver text;\n\tprotobuf_lib_ver text;\n\twagyu_lib_ver text;\n\tsfcgal_lib_ver text;\n\tsfcgal_scr_ver text;\n\tpgsql_scr_ver text;\n\tpgsql_ver text;\n\tcore_is_extension bool;\nBEGIN\n\tSELECT public.postgis_lib_version() INTO libver;\n\tSELECT public.postgis_proj_version() INTO projver;\n\tSELECT public.postgis_geos_version() INTO geosver;\n\tSELECT public.postgis_libjson_version() INTO json_lib_ver;\n\tSELECT public.postgis_libprotobuf_version() INTO protobuf_lib_ver;\n\tSELECT public.postgis_wagyu_version() INTO wagyu_lib_ver;\n\tSELECT public._postgis_scripts_pgsql_version() INTO pgsql_scr_ver;\n\tSELECT public._postgis_pgsql_version() INTO pgsql_ver;\n\tBEGIN\n\t\tSELECT public.postgis_gdal_version() INTO gdalver;\n\tEXCEPTION\n\t\tWHEN undefined_function THEN\n\t\t\tRAISE DEBUG 'Function postgis_gdal_version() not found.  Is raster support enabled and rtpostgis.sql installed?';\n\tEND;\n\tBEGIN\n\t\tSELECT public.postgis_sfcgal_full_version() INTO sfcgalver;\n\t\tBEGIN\n\t\t\tSELECT public.postgis_sfcgal_scripts_installed() INTO sfcgal_scr_ver;\n\t\tEXCEPTION\n\t\t\tWHEN undefined_function THEN\n\t\t\t\tsfcgal_scr_ver := 'missing';\n\t\tEND;\n\tEXCEPTION\n\t\tWHEN undefined_function THEN\n\t\t\tRAISE DEBUG 'Function postgis_sfcgal_scripts_installed() not found. Is sfcgal support enabled and sfcgal.sql installed?';\n\tEND;\n\tSELECT public.postgis_liblwgeom_version() INTO liblwgeomver;\n\tSELECT public.postgis_libxml_version() INTO libxmlver;\n\tSELECT public.postgis_scripts_installed() INTO dbproc;\n\tSELECT public.postgis_scripts_released() INTO relproc;\n\tSELECT public.postgis_lib_revision() INTO librev;\n\tBEGIN\n\t\tSELECT topology.postgis_topology_scripts_installed() INTO topo_scr_ver;\n\tEXCEPTION\n\t\tWHEN undefined_function OR invalid_schema_name THEN\n\t\t\tRAISE DEBUG 'Function postgis_topology_scripts_installed() not found. Is topology support enabled and topology.sql installed?';\n\t\tWHEN insufficient_privilege THEN\n\t\t\tRAISE NOTICE 'Topology support cannot be inspected. Is current user granted USAGE on schema \"topology\" ?';\n\t\tWHEN OTHERS THEN\n\t\t\tRAISE NOTICE 'Function postgis_topology_scripts_installed() could not be called: % (%)', SQLERRM, SQLSTATE;\n\tEND;\n\n\tBEGIN\n\t\tSELECT postgis_raster_scripts_installed() INTO rast_scr_ver;\n\tEXCEPTION\n\t\tWHEN undefined_function THEN\n\t\t\tRAISE DEBUG 'Function postgis_raster_scripts_installed() not found. Is raster support enabled and rtpostgis.sql installed?';\n\t\tWHEN OTHERS THEN\n\t\t\tRAISE NOTICE 'Function postgis_raster_scripts_installed() could not be called: % (%)', SQLERRM, SQLSTATE;\n\tEND;\n\n\tBEGIN\n\t\tSELECT public.postgis_raster_lib_version() INTO rast_lib_ver;\n\tEXCEPTION\n\t\tWHEN undefined_function THEN\n\t\t\tRAISE DEBUG 'Function postgis_raster_lib_version() not found. Is raster support enabled and rtpostgis.sql installed?';\n\t\tWHEN OTHERS THEN\n\t\t\tRAISE NOTICE 'Function postgis_raster_lib_version() could not be called: % (%)', SQLERRM, SQLSTATE;\n\tEND;\n\n\tfullver = 'POSTGIS=\"' || libver;\n\n\tIF  librev IS NOT NULL THEN\n\t\tfullver = fullver || ' ' || librev;\n\tEND IF;\n\n\tfullver = fullver || '\"';\n\n\tIF EXISTS (\n\t\tSELECT * FROM pg_catalog.pg_extension\n\t\tWHERE extname = 'postgis')\n\tTHEN\n\t\t\tfullver = fullver || ' [EXTENSION]';\n\t\t\tcore_is_extension := true;\n\tELSE\n\t\t\tcore_is_extension := false;\n\tEND IF;\n\n\tIF liblwgeomver != relproc THEN\n\t\tfullver = fullver || ' (liblwgeom version mismatch: \"' || liblwgeomver || '\")';\n\tEND IF;\n\n\tfullver = fullver || ' PGSQL=\"' || pgsql_scr_ver || '\"';\n\tIF pgsql_scr_ver != pgsql_ver THEN\n\t\tfullver = fullver || ' (procs need upgrade for use with PostgreSQL \"' || pgsql_ver || '\")';\n\tEND IF;\n\n\tIF  geosver IS NOT NULL THEN\n\t\tfullver = fullver || ' GEOS=\"' || geosver || '\"';\n\tEND IF;\n\n\tIF  sfcgalver IS NOT NULL THEN\n\t\tfullver = fullver || ' SFCGAL=\"' || sfcgalver || '\"';\n\tEND IF;\n\n\tIF  projver IS NOT NULL THEN\n\t\tfullver = fullver || ' PROJ=\"' || projver || '\"';\n\tEND IF;\n\n\tIF  gdalver IS NOT NULL THEN\n\t\tfullver = fullver || ' GDAL=\"' || gdalver || '\"';\n\tEND IF;\n\n\tIF  libxmlver IS NOT NULL THEN\n\t\tfullver = fullver || ' LIBXML=\"' || libxmlver || '\"';\n\tEND IF;\n\n\tIF json_lib_ver IS NOT NULL THEN\n\t\tfullver = fullver || ' LIBJSON=\"' || json_lib_ver || '\"';\n\tEND IF;\n\n\tIF protobuf_lib_ver IS NOT NULL THEN\n\t\tfullver = fullver || ' LIBPROTOBUF=\"' || protobuf_lib_ver || '\"';\n\tEND IF;\n\n\tIF wagyu_lib_ver IS NOT NULL THEN\n\t\tfullver = fullver || ' WAGYU=\"' || wagyu_lib_ver || '\"';\n\tEND IF;\n\n\tIF dbproc != relproc THEN\n\t\tfullver = fullver || ' (core procs from \"' || dbproc || '\" need upgrade)';\n\tEND IF;\n\n\tIF topo_scr_ver IS NOT NULL THEN\n\t\tfullver = fullver || ' TOPOLOGY';\n\t\tIF topo_scr_ver != relproc THEN\n\t\t\tfullver = fullver || ' (topology procs from \"' || topo_scr_ver || '\" need upgrade)';\n\t\tEND IF;\n\t\tIF core_is_extension AND NOT EXISTS (\n\t\t\tSELECT * FROM pg_catalog.pg_extension\n\t\t\tWHERE extname = 'postgis_topology')\n\t\tTHEN\n\t\t\t\tfullver = fullver || ' [UNPACKAGED!]';\n\t\tEND IF;\n\tEND IF;\n\n\tIF rast_lib_ver IS NOT NULL THEN\n\t\tfullver = fullver || ' RASTER';\n\t\tIF rast_lib_ver != relproc THEN\n\t\t\tfullver = fullver || ' (raster lib from \"' || rast_lib_ver || '\" need upgrade)';\n\t\tEND IF;\n\t\tIF core_is_extension AND NOT EXISTS (\n\t\t\tSELECT * FROM pg_catalog.pg_extension\n\t\t\tWHERE extname = 'postgis_raster')\n\t\tTHEN\n\t\t\t\tfullver = fullver || ' [UNPACKAGED!]';\n\t\tEND IF;\n\tEND IF;\n\n\tIF rast_scr_ver IS NOT NULL AND rast_scr_ver != relproc THEN\n\t\tfullver = fullver || ' (raster procs from \"' || rast_scr_ver || '\" need upgrade)';\n\tEND IF;\n\n\tIF sfcgal_scr_ver IS NOT NULL AND sfcgal_scr_ver != relproc THEN\n\t\tfullver = fullver || ' (sfcgal procs from \"' || sfcgal_scr_ver || '\" need upgrade)';\n\tEND IF;\n\n\t-- Check for the presence of deprecated functions\n\tIF EXISTS ( SELECT oid FROM pg_catalog.pg_proc WHERE proname LIKE '%_deprecated_by_postgis_%' )\n\tTHEN\n\t\tfullver = fullver || ' (deprecated functions exist, upgrade is not complete)';\n\tEND IF;\n\n\tRETURN fullver;\nEND\n"
  },
  {
    "function_name": "postgis_geos_noop",
    "argument_count": 1,
    "source_code": "GEOSnoop"
  },
  {
    "function_name": "postgis_geos_version",
    "argument_count": 0,
    "source_code": "postgis_geos_version"
  },
  {
    "function_name": "postgis_getbbox",
    "argument_count": 1,
    "source_code": "LWGEOM_to_BOX2DF"
  },
  {
    "function_name": "postgis_hasbbox",
    "argument_count": 1,
    "source_code": "LWGEOM_hasBBOX"
  },
  {
    "function_name": "postgis_index_supportfn",
    "argument_count": 1,
    "source_code": "postgis_index_supportfn"
  },
  {
    "function_name": "postgis_lib_build_date",
    "argument_count": 0,
    "source_code": "postgis_lib_build_date"
  },
  {
    "function_name": "postgis_lib_revision",
    "argument_count": 0,
    "source_code": "postgis_lib_revision"
  },
  {
    "function_name": "postgis_lib_version",
    "argument_count": 0,
    "source_code": "postgis_lib_version"
  },
  {
    "function_name": "postgis_libjson_version",
    "argument_count": 0,
    "source_code": "postgis_libjson_version"
  },
  {
    "function_name": "postgis_liblwgeom_version",
    "argument_count": 0,
    "source_code": "postgis_liblwgeom_version"
  },
  {
    "function_name": "postgis_libprotobuf_version",
    "argument_count": 0,
    "source_code": "postgis_libprotobuf_version"
  },
  {
    "function_name": "postgis_libxml_version",
    "argument_count": 0,
    "source_code": "postgis_libxml_version"
  },
  {
    "function_name": "postgis_noop",
    "argument_count": 1,
    "source_code": "LWGEOM_noop"
  },
  {
    "function_name": "postgis_proj_version",
    "argument_count": 0,
    "source_code": "postgis_proj_version"
  },
  {
    "function_name": "postgis_scripts_build_date",
    "argument_count": 0,
    "source_code": "SELECT '2024-09-05 22:13:41'::text AS version"
  },
  {
    "function_name": "postgis_scripts_installed",
    "argument_count": 0,
    "source_code": " SELECT trim('3.3.7'::text || $rev$ a0c7967 $rev$) AS version "
  },
  {
    "function_name": "postgis_scripts_released",
    "argument_count": 0,
    "source_code": "postgis_scripts_released"
  },
  {
    "function_name": "postgis_svn_version",
    "argument_count": 0,
    "source_code": "\n\tSELECT public._postgis_deprecate(\n\t\t'postgis_svn_version', 'postgis_lib_revision', '3.1.0');\n\tSELECT public.postgis_lib_revision();\n"
  },
  {
    "function_name": "postgis_transform_geometry",
    "argument_count": 4,
    "source_code": "transform_geom"
  },
  {
    "function_name": "postgis_type_name",
    "argument_count": 3,
    "source_code": "\n\tSELECT CASE WHEN $3 THEN new_name ELSE old_name END As geomname\n\tFROM\n\t( VALUES\n\t\t\t('GEOMETRY', 'Geometry', 2),\n\t\t\t('GEOMETRY', 'GeometryZ', 3),\n\t\t\t('GEOMETRYM', 'GeometryM', 3),\n\t\t\t('GEOMETRY', 'GeometryZM', 4),\n\n\t\t\t('GEOMETRYCOLLECTION', 'GeometryCollection', 2),\n\t\t\t('GEOMETRYCOLLECTION', 'GeometryCollectionZ', 3),\n\t\t\t('GEOMETRYCOLLECTIONM', 'GeometryCollectionM', 3),\n\t\t\t('GEOMETRYCOLLECTION', 'GeometryCollectionZM', 4),\n\n\t\t\t('POINT', 'Point', 2),\n\t\t\t('POINT', 'PointZ', 3),\n\t\t\t('POINTM','PointM', 3),\n\t\t\t('POINT', 'PointZM', 4),\n\n\t\t\t('MULTIPOINT','MultiPoint', 2),\n\t\t\t('MULTIPOINT','MultiPointZ', 3),\n\t\t\t('MULTIPOINTM','MultiPointM', 3),\n\t\t\t('MULTIPOINT','MultiPointZM', 4),\n\n\t\t\t('POLYGON', 'Polygon', 2),\n\t\t\t('POLYGON', 'PolygonZ', 3),\n\t\t\t('POLYGONM', 'PolygonM', 3),\n\t\t\t('POLYGON', 'PolygonZM', 4),\n\n\t\t\t('MULTIPOLYGON', 'MultiPolygon', 2),\n\t\t\t('MULTIPOLYGON', 'MultiPolygonZ', 3),\n\t\t\t('MULTIPOLYGONM', 'MultiPolygonM', 3),\n\t\t\t('MULTIPOLYGON', 'MultiPolygonZM', 4),\n\n\t\t\t('MULTILINESTRING', 'MultiLineString', 2),\n\t\t\t('MULTILINESTRING', 'MultiLineStringZ', 3),\n\t\t\t('MULTILINESTRINGM', 'MultiLineStringM', 3),\n\t\t\t('MULTILINESTRING', 'MultiLineStringZM', 4),\n\n\t\t\t('LINESTRING', 'LineString', 2),\n\t\t\t('LINESTRING', 'LineStringZ', 3),\n\t\t\t('LINESTRINGM', 'LineStringM', 3),\n\t\t\t('LINESTRING', 'LineStringZM', 4),\n\n\t\t\t('CIRCULARSTRING', 'CircularString', 2),\n\t\t\t('CIRCULARSTRING', 'CircularStringZ', 3),\n\t\t\t('CIRCULARSTRINGM', 'CircularStringM' ,3),\n\t\t\t('CIRCULARSTRING', 'CircularStringZM', 4),\n\n\t\t\t('COMPOUNDCURVE', 'CompoundCurve', 2),\n\t\t\t('COMPOUNDCURVE', 'CompoundCurveZ', 3),\n\t\t\t('COMPOUNDCURVEM', 'CompoundCurveM', 3),\n\t\t\t('COMPOUNDCURVE', 'CompoundCurveZM', 4),\n\n\t\t\t('CURVEPOLYGON', 'CurvePolygon', 2),\n\t\t\t('CURVEPOLYGON', 'CurvePolygonZ', 3),\n\t\t\t('CURVEPOLYGONM', 'CurvePolygonM', 3),\n\t\t\t('CURVEPOLYGON', 'CurvePolygonZM', 4),\n\n\t\t\t('MULTICURVE', 'MultiCurve', 2),\n\t\t\t('MULTICURVE', 'MultiCurveZ', 3),\n\t\t\t('MULTICURVEM', 'MultiCurveM', 3),\n\t\t\t('MULTICURVE', 'MultiCurveZM', 4),\n\n\t\t\t('MULTISURFACE', 'MultiSurface', 2),\n\t\t\t('MULTISURFACE', 'MultiSurfaceZ', 3),\n\t\t\t('MULTISURFACEM', 'MultiSurfaceM', 3),\n\t\t\t('MULTISURFACE', 'MultiSurfaceZM', 4),\n\n\t\t\t('POLYHEDRALSURFACE', 'PolyhedralSurface', 2),\n\t\t\t('POLYHEDRALSURFACE', 'PolyhedralSurfaceZ', 3),\n\t\t\t('POLYHEDRALSURFACEM', 'PolyhedralSurfaceM', 3),\n\t\t\t('POLYHEDRALSURFACE', 'PolyhedralSurfaceZM', 4),\n\n\t\t\t('TRIANGLE', 'Triangle', 2),\n\t\t\t('TRIANGLE', 'TriangleZ', 3),\n\t\t\t('TRIANGLEM', 'TriangleM', 3),\n\t\t\t('TRIANGLE', 'TriangleZM', 4),\n\n\t\t\t('TIN', 'Tin', 2),\n\t\t\t('TIN', 'TinZ', 3),\n\t\t\t('TINM', 'TinM', 3),\n\t\t\t('TIN', 'TinZM', 4) )\n\t\t\t As g(old_name, new_name, coord_dimension)\n\tWHERE (upper(old_name) = upper($1) OR upper(new_name) = upper($1))\n\t\tAND coord_dimension = $2;\n"
  },
  {
    "function_name": "postgis_typmod_dims",
    "argument_count": 1,
    "source_code": "postgis_typmod_dims"
  },
  {
    "function_name": "postgis_typmod_srid",
    "argument_count": 1,
    "source_code": "postgis_typmod_srid"
  },
  {
    "function_name": "postgis_typmod_type",
    "argument_count": 1,
    "source_code": "postgis_typmod_type"
  },
  {
    "function_name": "postgis_version",
    "argument_count": 0,
    "source_code": "postgis_version"
  },
  {
    "function_name": "postgis_wagyu_version",
    "argument_count": 0,
    "source_code": "postgis_wagyu_version"
  },
  {
    "function_name": "reduce_stock_in_bins_quantity",
    "argument_count": 2,
    "source_code": "\r\nBEGIN\r\n    UPDATE stock_in_bins\r\n    SET quantity = quantity - p_quantity,\r\n        updated_at = NOW()\r\n    WHERE id = p_stock_in_bins_id;\r\nEND;\r\n"
  },
  {
    "function_name": "reduce_stock_in_bins_quantity",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    UPDATE stock_in_bins\r\n    SET quantity = quantity - NEW.quantity,\r\n        updated_at = NOW()\r\n    WHERE id = NEW.stock_in_bins_id;\r\n    \r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "set_buildings_created_by",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    NEW.created_by = auth.uid();\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "set_floors_created_by",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    NEW.created_by = auth.uid();\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "set_ref_asset_categories_created_by",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    NEW.created_by = auth.uid();\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "set_ref_asset_sub_categories_created_by",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    NEW.created_by = auth.uid();\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "set_ref_asset_types_created_by",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    NEW.created_by = auth.uid();\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "set_ref_building_functions_created_by",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    NEW.created_by = auth.uid();\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "set_ref_room_categories_created_by",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    NEW.created_by = auth.uid();\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "set_ref_stock_categories_created_by",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    NEW.created_by = auth.uid();\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "set_ref_stock_sub_categories_created_by",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    NEW.created_by = auth.uid();\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "set_ref_stock_types_created_by",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    NEW.created_by = auth.uid();\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "set_rooms_created_by",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    NEW.created_by = auth.uid();\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "set_stock_bins_created_by",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    NEW.created_by = auth.uid();\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "set_stock_racks_created_by",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    NEW.created_by = auth.uid();\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "set_stock_shelves_created_by",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    NEW.created_by = auth.uid();\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "set_stock_warehouses_created_by",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    NEW.created_by = auth.uid();\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "set_stock_zones_created_by",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    NEW.created_by = auth.uid();\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "spheroid_in",
    "argument_count": 1,
    "source_code": "ellipsoid_in"
  },
  {
    "function_name": "spheroid_out",
    "argument_count": 1,
    "source_code": "ellipsoid_out"
  },
  {
    "function_name": "st_3dclosestpoint",
    "argument_count": 2,
    "source_code": "LWGEOM_closestpoint3d"
  },
  {
    "function_name": "st_3ddfullywithin",
    "argument_count": 3,
    "source_code": "LWGEOM_dfullywithin3d"
  },
  {
    "function_name": "st_3ddistance",
    "argument_count": 2,
    "source_code": "ST_3DDistance"
  },
  {
    "function_name": "st_3ddwithin",
    "argument_count": 3,
    "source_code": "LWGEOM_dwithin3d"
  },
  {
    "function_name": "st_3dextent",
    "argument_count": 1,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_3dintersects",
    "argument_count": 2,
    "source_code": "ST_3DIntersects"
  },
  {
    "function_name": "st_3dlength",
    "argument_count": 1,
    "source_code": "LWGEOM_length_linestring"
  },
  {
    "function_name": "st_3dlineinterpolatepoint",
    "argument_count": 2,
    "source_code": "ST_3DLineInterpolatePoint"
  },
  {
    "function_name": "st_3dlongestline",
    "argument_count": 2,
    "source_code": "LWGEOM_longestline3d"
  },
  {
    "function_name": "st_3dmakebox",
    "argument_count": 2,
    "source_code": "BOX3D_construct"
  },
  {
    "function_name": "st_3dmaxdistance",
    "argument_count": 2,
    "source_code": "LWGEOM_maxdistance3d"
  },
  {
    "function_name": "st_3dperimeter",
    "argument_count": 1,
    "source_code": "LWGEOM_perimeter_poly"
  },
  {
    "function_name": "st_3dshortestline",
    "argument_count": 2,
    "source_code": "LWGEOM_shortestline3d"
  },
  {
    "function_name": "st_addmeasure",
    "argument_count": 3,
    "source_code": "ST_AddMeasure"
  },
  {
    "function_name": "st_addpoint",
    "argument_count": 2,
    "source_code": "LWGEOM_addpoint"
  },
  {
    "function_name": "st_addpoint",
    "argument_count": 3,
    "source_code": "LWGEOM_addpoint"
  },
  {
    "function_name": "st_affine",
    "argument_count": 7,
    "source_code": "SELECT public.ST_Affine($1,  $2, $3, 0,  $4, $5, 0,  0, 0, 1,  $6, $7, 0)"
  },
  {
    "function_name": "st_affine",
    "argument_count": 13,
    "source_code": "LWGEOM_affine"
  },
  {
    "function_name": "st_angle",
    "argument_count": 2,
    "source_code": "SELECT ST_Angle(St_StartPoint($1), ST_EndPoint($1), St_StartPoint($2), ST_EndPoint($2))"
  },
  {
    "function_name": "st_angle",
    "argument_count": 4,
    "source_code": "LWGEOM_angle"
  },
  {
    "function_name": "st_area",
    "argument_count": 2,
    "source_code": "geography_area"
  },
  {
    "function_name": "st_area",
    "argument_count": 1,
    "source_code": "ST_Area"
  },
  {
    "function_name": "st_area",
    "argument_count": 1,
    "source_code": " SELECT public.ST_Area($1::public.geometry);  "
  },
  {
    "function_name": "st_area2d",
    "argument_count": 1,
    "source_code": "ST_Area"
  },
  {
    "function_name": "st_asbinary",
    "argument_count": 1,
    "source_code": "LWGEOM_asBinary"
  },
  {
    "function_name": "st_asbinary",
    "argument_count": 2,
    "source_code": "LWGEOM_asBinary"
  },
  {
    "function_name": "st_asbinary",
    "argument_count": 2,
    "source_code": "LWGEOM_asBinary"
  },
  {
    "function_name": "st_asbinary",
    "argument_count": 1,
    "source_code": "LWGEOM_asBinary"
  },
  {
    "function_name": "st_asencodedpolyline",
    "argument_count": 2,
    "source_code": "LWGEOM_asEncodedPolyline"
  },
  {
    "function_name": "st_asewkb",
    "argument_count": 1,
    "source_code": "WKBFromLWGEOM"
  },
  {
    "function_name": "st_asewkb",
    "argument_count": 2,
    "source_code": "WKBFromLWGEOM"
  },
  {
    "function_name": "st_asewkt",
    "argument_count": 1,
    "source_code": "LWGEOM_asEWKT"
  },
  {
    "function_name": "st_asewkt",
    "argument_count": 2,
    "source_code": "LWGEOM_asEWKT"
  },
  {
    "function_name": "st_asewkt",
    "argument_count": 1,
    "source_code": "LWGEOM_asEWKT"
  },
  {
    "function_name": "st_asewkt",
    "argument_count": 1,
    "source_code": " SELECT public.ST_AsEWKT($1::public.geometry);  "
  },
  {
    "function_name": "st_asewkt",
    "argument_count": 2,
    "source_code": "LWGEOM_asEWKT"
  },
  {
    "function_name": "st_asflatgeobuf",
    "argument_count": 2,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_asflatgeobuf",
    "argument_count": 1,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_asflatgeobuf",
    "argument_count": 3,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_asgeobuf",
    "argument_count": 1,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_asgeobuf",
    "argument_count": 2,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_asgeojson",
    "argument_count": 4,
    "source_code": "ST_AsGeoJsonRow"
  },
  {
    "function_name": "st_asgeojson",
    "argument_count": 1,
    "source_code": " SELECT public.ST_AsGeoJson($1::public.geometry, 9, 0);  "
  },
  {
    "function_name": "st_asgeojson",
    "argument_count": 3,
    "source_code": "geography_as_geojson"
  },
  {
    "function_name": "st_asgeojson",
    "argument_count": 3,
    "source_code": "LWGEOM_asGeoJson"
  },
  {
    "function_name": "st_asgml",
    "argument_count": 5,
    "source_code": "geography_as_gml"
  },
  {
    "function_name": "st_asgml",
    "argument_count": 3,
    "source_code": "LWGEOM_asGML"
  },
  {
    "function_name": "st_asgml",
    "argument_count": 6,
    "source_code": "geography_as_gml"
  },
  {
    "function_name": "st_asgml",
    "argument_count": 1,
    "source_code": " SELECT public._ST_AsGML(2,$1::public.geometry,15,0, NULL, NULL);  "
  },
  {
    "function_name": "st_asgml",
    "argument_count": 6,
    "source_code": "LWGEOM_asGML"
  },
  {
    "function_name": "st_ashexewkb",
    "argument_count": 2,
    "source_code": "LWGEOM_asHEXEWKB"
  },
  {
    "function_name": "st_ashexewkb",
    "argument_count": 1,
    "source_code": "LWGEOM_asHEXEWKB"
  },
  {
    "function_name": "st_askml",
    "argument_count": 1,
    "source_code": " SELECT public.ST_AsKML($1::public.geometry, 15);  "
  },
  {
    "function_name": "st_askml",
    "argument_count": 3,
    "source_code": "LWGEOM_asKML"
  },
  {
    "function_name": "st_askml",
    "argument_count": 3,
    "source_code": "geography_as_kml"
  },
  {
    "function_name": "st_aslatlontext",
    "argument_count": 2,
    "source_code": "LWGEOM_to_latlon"
  },
  {
    "function_name": "st_asmarc21",
    "argument_count": 2,
    "source_code": "ST_AsMARC21"
  },
  {
    "function_name": "st_asmvt",
    "argument_count": 3,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_asmvt",
    "argument_count": 4,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_asmvt",
    "argument_count": 5,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_asmvt",
    "argument_count": 1,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_asmvt",
    "argument_count": 2,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_asmvtgeom",
    "argument_count": 5,
    "source_code": "ST_AsMVTGeom"
  },
  {
    "function_name": "st_assvg",
    "argument_count": 1,
    "source_code": " SELECT public.ST_AsSVG($1::public.geometry,0,15);  "
  },
  {
    "function_name": "st_assvg",
    "argument_count": 3,
    "source_code": "geography_as_svg"
  },
  {
    "function_name": "st_assvg",
    "argument_count": 3,
    "source_code": "LWGEOM_asSVG"
  },
  {
    "function_name": "st_astext",
    "argument_count": 2,
    "source_code": "LWGEOM_asText"
  },
  {
    "function_name": "st_astext",
    "argument_count": 1,
    "source_code": "LWGEOM_asText"
  },
  {
    "function_name": "st_astext",
    "argument_count": 1,
    "source_code": "LWGEOM_asText"
  },
  {
    "function_name": "st_astext",
    "argument_count": 1,
    "source_code": " SELECT public.ST_AsText($1::public.geometry);  "
  },
  {
    "function_name": "st_astext",
    "argument_count": 2,
    "source_code": "LWGEOM_asText"
  },
  {
    "function_name": "st_astwkb",
    "argument_count": 6,
    "source_code": "TWKBFromLWGEOM"
  },
  {
    "function_name": "st_astwkb",
    "argument_count": 7,
    "source_code": "TWKBFromLWGEOMArray"
  },
  {
    "function_name": "st_asx3d",
    "argument_count": 3,
    "source_code": "SELECT public._ST_AsX3D(3,$1,$2,$3,'');"
  },
  {
    "function_name": "st_azimuth",
    "argument_count": 2,
    "source_code": "geography_azimuth"
  },
  {
    "function_name": "st_azimuth",
    "argument_count": 2,
    "source_code": "LWGEOM_azimuth"
  },
  {
    "function_name": "st_bdmpolyfromtext",
    "argument_count": 2,
    "source_code": "\nDECLARE\n\tgeomtext alias for $1;\n\tsrid alias for $2;\n\tmline public.geometry;\n\tgeom public.geometry;\nBEGIN\n\tmline := public.ST_MultiLineStringFromText(geomtext, srid);\n\n\tIF mline IS NULL\n\tTHEN\n\t\tRAISE EXCEPTION 'Input is not a MultiLinestring';\n\tEND IF;\n\n\tgeom := public.ST_Multi(public.ST_BuildArea(mline));\n\n\tRETURN geom;\nEND;\n"
  },
  {
    "function_name": "st_bdpolyfromtext",
    "argument_count": 2,
    "source_code": "\nDECLARE\n\tgeomtext alias for $1;\n\tsrid alias for $2;\n\tmline public.geometry;\n\tgeom public.geometry;\nBEGIN\n\tmline := public.ST_MultiLineStringFromText(geomtext, srid);\n\n\tIF mline IS NULL\n\tTHEN\n\t\tRAISE EXCEPTION 'Input is not a MultiLinestring';\n\tEND IF;\n\n\tgeom := public.ST_BuildArea(mline);\n\n\tIF public.GeometryType(geom) != 'POLYGON'\n\tTHEN\n\t\tRAISE EXCEPTION 'Input returns more then a single polygon, try using BdMPolyFromText instead';\n\tEND IF;\n\n\tRETURN geom;\nEND;\n"
  },
  {
    "function_name": "st_boundary",
    "argument_count": 1,
    "source_code": "boundary"
  },
  {
    "function_name": "st_boundingdiagonal",
    "argument_count": 2,
    "source_code": "ST_BoundingDiagonal"
  },
  {
    "function_name": "st_box2dfromgeohash",
    "argument_count": 2,
    "source_code": "box2d_from_geohash"
  },
  {
    "function_name": "st_buffer",
    "argument_count": 3,
    "source_code": " SELECT public.ST_Buffer($1::public.geometry, $2, $3);  "
  },
  {
    "function_name": "st_buffer",
    "argument_count": 3,
    "source_code": " SELECT public.ST_Buffer($1, $2, CAST('quad_segs='||CAST($3 AS text) as text)) "
  },
  {
    "function_name": "st_buffer",
    "argument_count": 3,
    "source_code": "buffer"
  },
  {
    "function_name": "st_buffer",
    "argument_count": 2,
    "source_code": "SELECT public.geography(public.ST_Transform(public.ST_Buffer(public.ST_Transform(public.geometry($1), public._ST_BestSRID($1)), $2), public.ST_SRID($1)))"
  },
  {
    "function_name": "st_buffer",
    "argument_count": 3,
    "source_code": "SELECT public.geography(public.ST_Transform(public.ST_Buffer(public.ST_Transform(public.geometry($1), public._ST_BestSRID($1)), $2, $3), public.ST_SRID($1)))"
  },
  {
    "function_name": "st_buffer",
    "argument_count": 3,
    "source_code": "SELECT public.geography(public.ST_Transform(public.ST_Buffer(public.ST_Transform(public.geometry($1), public._ST_BestSRID($1)), $2, $3), public.ST_SRID($1)))"
  },
  {
    "function_name": "st_buffer",
    "argument_count": 2,
    "source_code": " SELECT public.ST_Buffer($1::public.geometry, $2);  "
  },
  {
    "function_name": "st_buffer",
    "argument_count": 3,
    "source_code": " SELECT public.ST_Buffer($1::public.geometry, $2, $3);  "
  },
  {
    "function_name": "st_buildarea",
    "argument_count": 1,
    "source_code": "ST_BuildArea"
  },
  {
    "function_name": "st_centroid",
    "argument_count": 1,
    "source_code": " SELECT public.ST_Centroid($1::public.geometry);  "
  },
  {
    "function_name": "st_centroid",
    "argument_count": 2,
    "source_code": "geography_centroid"
  },
  {
    "function_name": "st_centroid",
    "argument_count": 1,
    "source_code": "centroid"
  },
  {
    "function_name": "st_chaikinsmoothing",
    "argument_count": 3,
    "source_code": "LWGEOM_ChaikinSmoothing"
  },
  {
    "function_name": "st_cleangeometry",
    "argument_count": 1,
    "source_code": "ST_CleanGeometry"
  },
  {
    "function_name": "st_clipbybox2d",
    "argument_count": 2,
    "source_code": "ST_ClipByBox2d"
  },
  {
    "function_name": "st_closestpoint",
    "argument_count": 2,
    "source_code": "LWGEOM_closestpoint"
  },
  {
    "function_name": "st_closestpointofapproach",
    "argument_count": 2,
    "source_code": "ST_ClosestPointOfApproach"
  },
  {
    "function_name": "st_clusterdbscan",
    "argument_count": 3,
    "source_code": "ST_ClusterDBSCAN"
  },
  {
    "function_name": "st_clusterintersecting",
    "argument_count": 1,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_clusterintersecting",
    "argument_count": 1,
    "source_code": "clusterintersecting_garray"
  },
  {
    "function_name": "st_clusterkmeans",
    "argument_count": 3,
    "source_code": "ST_ClusterKMeans"
  },
  {
    "function_name": "st_clusterwithin",
    "argument_count": 2,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_clusterwithin",
    "argument_count": 2,
    "source_code": "cluster_within_distance_garray"
  },
  {
    "function_name": "st_collect",
    "argument_count": 1,
    "source_code": "LWGEOM_collect_garray"
  },
  {
    "function_name": "st_collect",
    "argument_count": 1,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_collect",
    "argument_count": 2,
    "source_code": "LWGEOM_collect"
  },
  {
    "function_name": "st_collectionextract",
    "argument_count": 2,
    "source_code": "ST_CollectionExtract"
  },
  {
    "function_name": "st_collectionextract",
    "argument_count": 1,
    "source_code": "ST_CollectionExtract"
  },
  {
    "function_name": "st_collectionhomogenize",
    "argument_count": 1,
    "source_code": "ST_CollectionHomogenize"
  },
  {
    "function_name": "st_combinebbox",
    "argument_count": 2,
    "source_code": "BOX3D_combine_BOX3D"
  },
  {
    "function_name": "st_combinebbox",
    "argument_count": 2,
    "source_code": "BOX2D_combine"
  },
  {
    "function_name": "st_combinebbox",
    "argument_count": 2,
    "source_code": "BOX3D_combine"
  },
  {
    "function_name": "st_concavehull",
    "argument_count": 3,
    "source_code": "ST_ConcaveHull"
  },
  {
    "function_name": "st_contains",
    "argument_count": 2,
    "source_code": "contains"
  },
  {
    "function_name": "st_containsproperly",
    "argument_count": 2,
    "source_code": "containsproperly"
  },
  {
    "function_name": "st_convexhull",
    "argument_count": 1,
    "source_code": "convexhull"
  },
  {
    "function_name": "st_coorddim",
    "argument_count": 1,
    "source_code": "LWGEOM_ndims"
  },
  {
    "function_name": "st_coveredby",
    "argument_count": 2,
    "source_code": "geography_coveredby"
  },
  {
    "function_name": "st_coveredby",
    "argument_count": 2,
    "source_code": " SELECT public.ST_CoveredBy($1::public.geometry, $2::public.geometry);  "
  },
  {
    "function_name": "st_coveredby",
    "argument_count": 2,
    "source_code": "coveredby"
  },
  {
    "function_name": "st_covers",
    "argument_count": 2,
    "source_code": "geography_covers"
  },
  {
    "function_name": "st_covers",
    "argument_count": 2,
    "source_code": " SELECT public.ST_Covers($1::public.geometry, $2::public.geometry);  "
  },
  {
    "function_name": "st_covers",
    "argument_count": 2,
    "source_code": "covers"
  },
  {
    "function_name": "st_cpawithin",
    "argument_count": 3,
    "source_code": "ST_CPAWithin"
  },
  {
    "function_name": "st_crosses",
    "argument_count": 2,
    "source_code": "crosses"
  },
  {
    "function_name": "st_curvetoline",
    "argument_count": 4,
    "source_code": "ST_CurveToLine"
  },
  {
    "function_name": "st_delaunaytriangles",
    "argument_count": 3,
    "source_code": "ST_DelaunayTriangles"
  },
  {
    "function_name": "st_dfullywithin",
    "argument_count": 3,
    "source_code": "LWGEOM_dfullywithin"
  },
  {
    "function_name": "st_difference",
    "argument_count": 3,
    "source_code": "ST_Difference"
  },
  {
    "function_name": "st_dimension",
    "argument_count": 1,
    "source_code": "LWGEOM_dimension"
  },
  {
    "function_name": "st_disjoint",
    "argument_count": 2,
    "source_code": "disjoint"
  },
  {
    "function_name": "st_distance",
    "argument_count": 3,
    "source_code": "geography_distance"
  },
  {
    "function_name": "st_distance",
    "argument_count": 2,
    "source_code": " SELECT public.ST_Distance($1::public.geometry, $2::public.geometry);  "
  },
  {
    "function_name": "st_distance",
    "argument_count": 2,
    "source_code": "ST_Distance"
  },
  {
    "function_name": "st_distancecpa",
    "argument_count": 2,
    "source_code": "ST_DistanceCPA"
  },
  {
    "function_name": "st_distancesphere",
    "argument_count": 2,
    "source_code": "select public.ST_distance( public.geography($1), public.geography($2),false)"
  },
  {
    "function_name": "st_distancesphere",
    "argument_count": 3,
    "source_code": "LWGEOM_distance_sphere"
  },
  {
    "function_name": "st_distancespheroid",
    "argument_count": 2,
    "source_code": "LWGEOM_distance_ellipsoid"
  },
  {
    "function_name": "st_distancespheroid",
    "argument_count": 3,
    "source_code": "LWGEOM_distance_ellipsoid"
  },
  {
    "function_name": "st_dump",
    "argument_count": 1,
    "source_code": "LWGEOM_dump"
  },
  {
    "function_name": "st_dumppoints",
    "argument_count": 1,
    "source_code": "LWGEOM_dumppoints"
  },
  {
    "function_name": "st_dumprings",
    "argument_count": 1,
    "source_code": "LWGEOM_dump_rings"
  },
  {
    "function_name": "st_dumpsegments",
    "argument_count": 1,
    "source_code": "LWGEOM_dumpsegments"
  },
  {
    "function_name": "st_dwithin",
    "argument_count": 3,
    "source_code": " SELECT public.ST_DWithin($1::public.geometry, $2::public.geometry, $3);  "
  },
  {
    "function_name": "st_dwithin",
    "argument_count": 3,
    "source_code": "LWGEOM_dwithin"
  },
  {
    "function_name": "st_dwithin",
    "argument_count": 4,
    "source_code": "geography_dwithin"
  },
  {
    "function_name": "st_endpoint",
    "argument_count": 1,
    "source_code": "LWGEOM_endpoint_linestring"
  },
  {
    "function_name": "st_envelope",
    "argument_count": 1,
    "source_code": "LWGEOM_envelope"
  },
  {
    "function_name": "st_equals",
    "argument_count": 2,
    "source_code": "ST_Equals"
  },
  {
    "function_name": "st_estimatedextent",
    "argument_count": 3,
    "source_code": "gserialized_estimated_extent"
  },
  {
    "function_name": "st_estimatedextent",
    "argument_count": 2,
    "source_code": "gserialized_estimated_extent"
  },
  {
    "function_name": "st_estimatedextent",
    "argument_count": 4,
    "source_code": "gserialized_estimated_extent"
  },
  {
    "function_name": "st_expand",
    "argument_count": 3,
    "source_code": "BOX2D_expand"
  },
  {
    "function_name": "st_expand",
    "argument_count": 2,
    "source_code": "BOX2D_expand"
  },
  {
    "function_name": "st_expand",
    "argument_count": 5,
    "source_code": "LWGEOM_expand"
  },
  {
    "function_name": "st_expand",
    "argument_count": 2,
    "source_code": "LWGEOM_expand"
  },
  {
    "function_name": "st_expand",
    "argument_count": 4,
    "source_code": "BOX3D_expand"
  },
  {
    "function_name": "st_expand",
    "argument_count": 2,
    "source_code": "BOX3D_expand"
  },
  {
    "function_name": "st_extent",
    "argument_count": 1,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_exteriorring",
    "argument_count": 1,
    "source_code": "LWGEOM_exteriorring_polygon"
  },
  {
    "function_name": "st_filterbym",
    "argument_count": 4,
    "source_code": "LWGEOM_FilterByM"
  },
  {
    "function_name": "st_findextent",
    "argument_count": 2,
    "source_code": "\nDECLARE\n\ttablename alias for $1;\n\tcolumnname alias for $2;\n\tmyrec RECORD;\n\nBEGIN\n\tFOR myrec IN EXECUTE 'SELECT public.ST_Extent(\"' || columnname || '\") As extent FROM \"' || tablename || '\"' LOOP\n\t\treturn myrec.extent;\n\tEND LOOP;\nEND;\n"
  },
  {
    "function_name": "st_findextent",
    "argument_count": 3,
    "source_code": "\nDECLARE\n\tschemaname alias for $1;\n\ttablename alias for $2;\n\tcolumnname alias for $3;\n\tmyrec RECORD;\nBEGIN\n\tFOR myrec IN EXECUTE 'SELECT public.ST_Extent(\"' || columnname || '\") As extent FROM \"' || schemaname || '\".\"' || tablename || '\"' LOOP\n\t\treturn myrec.extent;\n\tEND LOOP;\nEND;\n"
  },
  {
    "function_name": "st_flipcoordinates",
    "argument_count": 1,
    "source_code": "ST_FlipCoordinates"
  },
  {
    "function_name": "st_force2d",
    "argument_count": 1,
    "source_code": "LWGEOM_force_2d"
  },
  {
    "function_name": "st_force3d",
    "argument_count": 2,
    "source_code": "SELECT public.ST_Force3DZ($1, $2)"
  },
  {
    "function_name": "st_force3dm",
    "argument_count": 2,
    "source_code": "LWGEOM_force_3dm"
  },
  {
    "function_name": "st_force3dz",
    "argument_count": 2,
    "source_code": "LWGEOM_force_3dz"
  },
  {
    "function_name": "st_force4d",
    "argument_count": 3,
    "source_code": "LWGEOM_force_4d"
  },
  {
    "function_name": "st_forcecollection",
    "argument_count": 1,
    "source_code": "LWGEOM_force_collection"
  },
  {
    "function_name": "st_forcecurve",
    "argument_count": 1,
    "source_code": "LWGEOM_force_curve"
  },
  {
    "function_name": "st_forcepolygonccw",
    "argument_count": 1,
    "source_code": " SELECT public.ST_Reverse(public.ST_ForcePolygonCW($1)) "
  },
  {
    "function_name": "st_forcepolygoncw",
    "argument_count": 1,
    "source_code": "LWGEOM_force_clockwise_poly"
  },
  {
    "function_name": "st_forcerhr",
    "argument_count": 1,
    "source_code": "LWGEOM_force_clockwise_poly"
  },
  {
    "function_name": "st_forcesfs",
    "argument_count": 1,
    "source_code": "LWGEOM_force_sfs"
  },
  {
    "function_name": "st_forcesfs",
    "argument_count": 2,
    "source_code": "LWGEOM_force_sfs"
  },
  {
    "function_name": "st_frechetdistance",
    "argument_count": 3,
    "source_code": "ST_FrechetDistance"
  },
  {
    "function_name": "st_fromflatgeobuf",
    "argument_count": 2,
    "source_code": "pgis_fromflatgeobuf"
  },
  {
    "function_name": "st_fromflatgeobuftotable",
    "argument_count": 3,
    "source_code": "pgis_tablefromflatgeobuf"
  },
  {
    "function_name": "st_generatepoints",
    "argument_count": 3,
    "source_code": "ST_GeneratePoints"
  },
  {
    "function_name": "st_generatepoints",
    "argument_count": 2,
    "source_code": "ST_GeneratePoints"
  },
  {
    "function_name": "st_geogfromtext",
    "argument_count": 1,
    "source_code": "geography_from_text"
  },
  {
    "function_name": "st_geogfromwkb",
    "argument_count": 1,
    "source_code": "geography_from_binary"
  },
  {
    "function_name": "st_geographyfromtext",
    "argument_count": 1,
    "source_code": "geography_from_text"
  },
  {
    "function_name": "st_geohash",
    "argument_count": 2,
    "source_code": "ST_GeoHash"
  },
  {
    "function_name": "st_geohash",
    "argument_count": 2,
    "source_code": "ST_GeoHash"
  },
  {
    "function_name": "st_geomcollfromtext",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE\n\tWHEN public.geometrytype(public.ST_GeomFromText($1)) = 'GEOMETRYCOLLECTION'\n\tTHEN public.ST_GeomFromText($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_geomcollfromtext",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE\n\tWHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'GEOMETRYCOLLECTION'\n\tTHEN public.ST_GeomFromText($1,$2)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_geomcollfromwkb",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE\n\tWHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'GEOMETRYCOLLECTION'\n\tTHEN public.ST_GeomFromWKB($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_geomcollfromwkb",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE\n\tWHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'GEOMETRYCOLLECTION'\n\tTHEN public.ST_GeomFromWKB($1, $2)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_geometricmedian",
    "argument_count": 4,
    "source_code": "ST_GeometricMedian"
  },
  {
    "function_name": "st_geometryfromtext",
    "argument_count": 1,
    "source_code": "LWGEOM_from_text"
  },
  {
    "function_name": "st_geometryfromtext",
    "argument_count": 2,
    "source_code": "LWGEOM_from_text"
  },
  {
    "function_name": "st_geometryn",
    "argument_count": 2,
    "source_code": "LWGEOM_geometryn_collection"
  },
  {
    "function_name": "st_geometrytype",
    "argument_count": 1,
    "source_code": "geometry_geometrytype"
  },
  {
    "function_name": "st_geomfromewkb",
    "argument_count": 1,
    "source_code": "LWGEOMFromEWKB"
  },
  {
    "function_name": "st_geomfromewkt",
    "argument_count": 1,
    "source_code": "parse_WKT_lwgeom"
  },
  {
    "function_name": "st_geomfromgeohash",
    "argument_count": 2,
    "source_code": " SELECT CAST(public.ST_Box2dFromGeoHash($1, $2) AS geometry); "
  },
  {
    "function_name": "st_geomfromgeojson",
    "argument_count": 1,
    "source_code": "SELECT public.ST_GeomFromGeoJson($1::text)"
  },
  {
    "function_name": "st_geomfromgeojson",
    "argument_count": 1,
    "source_code": "SELECT public.ST_GeomFromGeoJson($1::text)"
  },
  {
    "function_name": "st_geomfromgeojson",
    "argument_count": 1,
    "source_code": "geom_from_geojson"
  },
  {
    "function_name": "st_geomfromgml",
    "argument_count": 2,
    "source_code": "geom_from_gml"
  },
  {
    "function_name": "st_geomfromgml",
    "argument_count": 1,
    "source_code": "SELECT public._ST_GeomFromGML($1, 0)"
  },
  {
    "function_name": "st_geomfromkml",
    "argument_count": 1,
    "source_code": "geom_from_kml"
  },
  {
    "function_name": "st_geomfrommarc21",
    "argument_count": 1,
    "source_code": "ST_GeomFromMARC21"
  },
  {
    "function_name": "st_geomfromtext",
    "argument_count": 2,
    "source_code": "LWGEOM_from_text"
  },
  {
    "function_name": "st_geomfromtext",
    "argument_count": 1,
    "source_code": "LWGEOM_from_text"
  },
  {
    "function_name": "st_geomfromtwkb",
    "argument_count": 1,
    "source_code": "LWGEOMFromTWKB"
  },
  {
    "function_name": "st_geomfromwkb",
    "argument_count": 2,
    "source_code": "SELECT public.ST_SetSRID(public.ST_GeomFromWKB($1), $2)"
  },
  {
    "function_name": "st_geomfromwkb",
    "argument_count": 1,
    "source_code": "LWGEOM_from_WKB"
  },
  {
    "function_name": "st_gmltosql",
    "argument_count": 1,
    "source_code": "SELECT public._ST_GeomFromGML($1, 0)"
  },
  {
    "function_name": "st_gmltosql",
    "argument_count": 2,
    "source_code": "geom_from_gml"
  },
  {
    "function_name": "st_hasarc",
    "argument_count": 1,
    "source_code": "LWGEOM_has_arc"
  },
  {
    "function_name": "st_hausdorffdistance",
    "argument_count": 3,
    "source_code": "hausdorffdistancedensify"
  },
  {
    "function_name": "st_hausdorffdistance",
    "argument_count": 2,
    "source_code": "hausdorffdistance"
  },
  {
    "function_name": "st_hexagon",
    "argument_count": 4,
    "source_code": "ST_Hexagon"
  },
  {
    "function_name": "st_hexagongrid",
    "argument_count": 2,
    "source_code": "ST_ShapeGrid"
  },
  {
    "function_name": "st_interiorringn",
    "argument_count": 2,
    "source_code": "LWGEOM_interiorringn_polygon"
  },
  {
    "function_name": "st_interpolatepoint",
    "argument_count": 2,
    "source_code": "ST_InterpolatePoint"
  },
  {
    "function_name": "st_intersection",
    "argument_count": 3,
    "source_code": "ST_Intersection"
  },
  {
    "function_name": "st_intersection",
    "argument_count": 2,
    "source_code": "SELECT public.geography(public.ST_Transform(public.ST_Intersection(public.ST_Transform(public.geometry($1), public._ST_BestSRID($1, $2)), public.ST_Transform(public.geometry($2), public._ST_BestSRID($1, $2))), public.ST_SRID($1)))"
  },
  {
    "function_name": "st_intersection",
    "argument_count": 2,
    "source_code": " SELECT public.ST_Intersection($1::public.geometry, $2::public.geometry);  "
  },
  {
    "function_name": "st_intersects",
    "argument_count": 2,
    "source_code": "geography_intersects"
  },
  {
    "function_name": "st_intersects",
    "argument_count": 2,
    "source_code": " SELECT public.ST_Intersects($1::public.geometry, $2::public.geometry);  "
  },
  {
    "function_name": "st_intersects",
    "argument_count": 2,
    "source_code": "ST_Intersects"
  },
  {
    "function_name": "st_isclosed",
    "argument_count": 1,
    "source_code": "LWGEOM_isclosed"
  },
  {
    "function_name": "st_iscollection",
    "argument_count": 1,
    "source_code": "ST_IsCollection"
  },
  {
    "function_name": "st_isempty",
    "argument_count": 1,
    "source_code": "LWGEOM_isempty"
  },
  {
    "function_name": "st_ispolygonccw",
    "argument_count": 1,
    "source_code": "ST_IsPolygonCCW"
  },
  {
    "function_name": "st_ispolygoncw",
    "argument_count": 1,
    "source_code": "ST_IsPolygonCW"
  },
  {
    "function_name": "st_isring",
    "argument_count": 1,
    "source_code": "isring"
  },
  {
    "function_name": "st_issimple",
    "argument_count": 1,
    "source_code": "issimple"
  },
  {
    "function_name": "st_isvalid",
    "argument_count": 2,
    "source_code": "SELECT (public.ST_isValidDetail($1, $2)).valid"
  },
  {
    "function_name": "st_isvalid",
    "argument_count": 1,
    "source_code": "isvalid"
  },
  {
    "function_name": "st_isvaliddetail",
    "argument_count": 2,
    "source_code": "isvaliddetail"
  },
  {
    "function_name": "st_isvalidreason",
    "argument_count": 1,
    "source_code": "isvalidreason"
  },
  {
    "function_name": "st_isvalidreason",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE WHEN valid THEN 'Valid Geometry' ELSE reason END FROM (\n\t\tSELECT (public.ST_isValidDetail($1, $2)).*\n\t) foo\n\t"
  },
  {
    "function_name": "st_isvalidtrajectory",
    "argument_count": 1,
    "source_code": "ST_IsValidTrajectory"
  },
  {
    "function_name": "st_length",
    "argument_count": 1,
    "source_code": "LWGEOM_length2d_linestring"
  },
  {
    "function_name": "st_length",
    "argument_count": 1,
    "source_code": " SELECT public.ST_Length($1::public.geometry);  "
  },
  {
    "function_name": "st_length",
    "argument_count": 2,
    "source_code": "geography_length"
  },
  {
    "function_name": "st_length2d",
    "argument_count": 1,
    "source_code": "LWGEOM_length2d_linestring"
  },
  {
    "function_name": "st_length2dspheroid",
    "argument_count": 2,
    "source_code": "LWGEOM_length2d_ellipsoid"
  },
  {
    "function_name": "st_lengthspheroid",
    "argument_count": 2,
    "source_code": "LWGEOM_length_ellipsoid_linestring"
  },
  {
    "function_name": "st_letters",
    "argument_count": 2,
    "source_code": "\nDECLARE\n  letterarray text[];\n  letter text;\n  geom geometry;\n  prevgeom geometry = NULL;\n  adjustment float8 = 0.0;\n  position float8 = 0.0;\n  text_height float8 = 100.0;\n  width float8;\n  m_width float8;\n  spacing float8;\n  dist float8;\n  wordarr geometry[];\n  wordgeom geometry;\n  -- geometry has been run through replace(encode(st_astwkb(geom),'base64'), E'\\n', '')\n  font_default_height float8 = 1000.0;\n  font_default json = '{\n  \"!\":\"BgACAQhUrgsTFOQCABQAExELiwi5AgAJiggBYQmJCgAOAg4CDAIOBAoEDAYKBgoGCggICAgICAgGCgYKBgoGCgQMBAoECgQMAgoADAIKAAoADAEKAAwBCgMKAQwDCgMKAwoFCAUKBwgHBgcIBwYJBgkECwYJBAsCDQILAg0CDQANAQ0BCwELAwsDCwUJBQkFCQcHBwcHBwcFCQUJBQkFCQMLAwkDCQMLAQkACwEJAAkACwIJAAsCCQQJAgsECQQJBAkGBwYJCAcIBQgHCAUKBQoDDAUKAQwDDgEMAQ4BDg==\",\n  \"&\":\"BgABAskBygP+BowEAACZAmcAANsCAw0FDwUNBQ0FDQcLBw0HCwcLCQsJCwkLCQkJCwsJCwkLCQ0HCwcNBw8HDQUPBQ8DDwMRAw8DEQERAREBEQERABcAFQIXAhUCEwQVBBMGEwYTBhEIEQgPChEKDwoPDA0MDQwNDgsOCRAJEAkQBxAHEgUSBRQFFAMUAxQBFgEWARgAigEAFAISABICEgQQAhAEEAQQBg4GEAoOCg4MDg4ODgwSDgsMCwoJDAcMBwwFDgUMAw4DDgEOARABDgEQARIBEAASAHgAIAQeBB4GHAgaChoMGA4WDhYQFBISEhISDhQQFAwWDBYKFgoYBhgIGAQYBBgCGgAaABgBGAMYAxYHFgUWCRYJFAsUCxIPEg0SERARDhMOFQwVDBcIGQYbBhsCHQIfAR+dAgAADAAKAQoBCgEIAwgFBgUGBQYHBAUEBwQHAgcCBwIHAAcABwAHAQcBBwMHAwUDBwUFBQUHBQUBBwMJAQkBCQAJAJcBAAUCBQAFAgUEBQIDBAUEAwQDBgMEAQYDBgEGAAgBBgAKSeECAJ8BFi84HUQDQCAAmAKNAQAvExMx\",\n  \"\\\"\":\"BgACAQUmwguEAgAAkwSDAgAAlAQBBfACAIACAACTBP8BAACUBA==\",\n  \"''\":\"BgABAQUmwguEAgAAkwSDAgAAlAQ=\",\n  \"(\":\"BgABAUOQBNwLDScNKw0rCysLLwsxCTEJMwc1BzcHNwM7AzsDPwE/AEEANwI1AjMEMwIzBjEGLwYvCC0ILQgrCCkKKQonCicMJbkCAAkqCSoHLAksBywFLgcuBS4FMAMwAzADMgEwATQBMgA0ADwCOgI6BDoEOAY4BjYINgg2CjQKMgoyCjIMMAwwDi7AAgA=\",\n  \")\":\"BgABAUMQ3Au6AgAOLQwvDC8KMQoxCjEKMwg1CDUGNQY3BDcEOQI5AjkAOwAzATEBMQExAy8DLwMvBS8FLQctBS0HKwktBykJKwkpswIADCYKKAooCioIKggsCC4ILgYwBjAGMgQ0AjQCNAI2ADgAQgFAAz4DPAM8BzgHOAc2CTQJMgsyCzALLg0sDSoNKg==\",\n  \"+\":\"BgABAQ3IBOwGALcBuAEAANUBtwEAALcB0wEAALgBtwEAANYBuAEAALgB1AEA\",\n  \"/\":\"BgABAQVCAoIDwAuyAgCFA78LrQIA\",\n  \"4\":\"BgABAhDkBr4EkgEAEREApwJ/AADxARIR5QIAEhIA9AHdAwAA7ALIA9AG6gIAEREA8QYFqwIAAIIDwwH/AgABxAEA\",\n  \"v\":\"BgABASDmA5AEPu4CROwBExb6AgAZFdMC0wgUFaECABIU0wLWCBcW+AIAExVE6wEEFQQXBBUEFwQVBBUEFwQVBBUEFwQVBBUEFwQXBBUEFwYA\",\n  \",\":\"BgABAWMYpAEADgIOAgwCDgQMBAoGDAYKBgoICAgICAgICAoGCgYKBAoEDAQKBAoCDAIKAgwCCgAKAAwACgEMAQoBCgMMAwoDCgUKBQgFCgUIBwYJCAcGCQYJBAsGCQQLAg0CCwINAg0AAwABAAMAAwADAQMAAwADAAMBBQAFAQcBBwEHAwcBCQMJAQsDCwMLAw0FDQMNBQ8FDwURBxMFEwkTBxcJFwkXswEAIMgBCQYJBgkGBwYJCAcIBQgHCgUKBQoFDAEMAwwBDgEOABA=\",\n  \"-\":\"BgABAQUq0AMArALEBAAAqwLDBAA=\",\n  \".\":\"BgABAWFOrAEADgIOAg4CDgQMBAoGDAYKBgoICAgKCAgIBgoGCgYKBgoEDAQKBAwECgIMAAwCDAAMAAwBCgAMAQoDDAMKAwoDCgUKBQgFCgUIBwgJBgcICQYJBgsGCQQLAg0CDQINAA0ADQENAQ0BCwMNAwkFCwUJBQkHBwcJBwUHBwkFCQUJBQkDCwMJAwsDCQELAAsBCwALAAsCCQALAgkECwQJBAkECQYJBgcGBwgJBgcKBQgHCgUKBQwFCgEOAwwBDgEOAA4=\",\n  \"0\":\"BgABAoMB+APaCxwAHAEaARoDFgMYBRYFFAcUBxIJEgkQCRALEAsOCwwNDA0MDQoPCg0IDwgPBhEGDwYRBA8EEQIRAhMCEQITABMA4QUAEQETAREBEQMRAxEFEQURBREHDwkPBw8JDwsNCw0LDQ0NDQsNCw8JEQkRCREJEwcTBxUFFQUVAxUDFwEXARkAGQAZAhcCFwQXBBUGEwYTCBMIEQoRCg8KDwoPDA0MDQ4NDgsOCQ4JEAkQBxAHEAUSBRIDEgMSAxIDEgESARQAEgDiBQASAhQCEgISBBIEEgYSBhIGEggQChAIEAoQDBAMDgwODg4ODA4MEgwQChIKEggUCBQIFgYWBBYGGAQYAhgCGgILZIcDHTZBEkMRHTUA4QUeOUITRBIePADiBQ==\",\n  \"2\":\"BgABAWpUwALUA44GAAoBCAEKAQgDBgMGBQYFBgUEBwQFBAUCBwIHAgUABwAHAAUBBwMFAQcFBQMHBQUHBQcFBwMJAwkBCQELAQsAC68CAAAUAhIAFAISBBQCEgQUBBIEEgYUCBIGEAgSChAKEAoQDBAMDg4ODgwQDBIMEgoSChQIFggWCBgGGAQaAhwCHAIWABQBFgEUARQDFAMSAxQFEgUSBxIHEAkQCRALDgsODQ4NDA8KDwwRCBMKEwgTBhUGFwQXBBcEGwAbABsAHQEftwPJBdIDAACpAhIPzwYAFBIArgI=\",\n  \"1\":\"BgABARCsBLALAJ0LEhERADcA2QEANwATABQSAOYIpwEAALgCERKEBAASABER\",\n  \"3\":\"BgABAZ0B/gbEC/sB0QQOAwwBDAMMAwwFCgMKBQoFCgUIBwoFCAcICQgJBgkICQYLCAsECwYLBA0GDwINBA8CDwQRAhECEQITABUCFQAVAH0AEQETAREBEQETAxEDEQURBREFDwcRBw8JDwkNCQ8LDQsNDQsNCw0LDwsPCREJEQcRBxMFFQUVBRUDFwEXARkAGQAZAhkCFwQVBBUEEwYTCBEIEQgRCg0MDwoNDA0OCw4LDgkQCRAHEAkQBRAFEgUSAxIDFAMSAxYBFAEWARYAFqQCAAALAgkCCQQHAgcGBwYHBgUIBQYDCAMIAwYDCAEIAQgACAAIAAgCCAIIAgYCCAQIBAgGBgYEBgQIBAoCCgAKAAwAvAEABgEIAAYBBgMGAwQDBgMEBQQDBAUCBQQFAgUABwIFAJkBAACmAaIB3ALbAgAREQDmAhIRggYA\",\n  \"5\":\"BgABAaAB0APgBxIAFAESABIBEgMSARADEgMQAxIFEAcOBRAHDgkOCQ4JDgsMCwwLCgsKDQoPCA0IDwgPBhEEEwYTAhMEFwIXABcAiQIAEwETABEBEQMTAxEDDwMRBQ8FDwUPBw8JDQcNCQ0LDQsLCwsNCw0JDwkPCREHEQcTBxMFEwMVAxcDGQEZARkAFwAVAhUCFQQTBBMGEwYRCBEIDwoPCg8KDQwNDA0MCw4LDgkOCRAJEAcOBxAHEgUQBRIDEAMSAxIBEgEUARIAFLgCAAAFAgUABQIFBAUCBQQDBAUEAwYDBgMIAwgBCAEIAQoACAAIAgYACAQGAgQEBgQEBAQGBAQCBgIGAgYCBgIIAAYA4AEABgEIAAYBBgMGAQQDBgMEAwQFBAMCBQQFAgUABwIFAPkBAG+OAQCCBRESAgAAAuYFABMRAK8CjQMAAJ8BNgA=\",\n  \"7\":\"BgABAQrQBsILhQOvCxQR7wIAEhK+AvYIiwMAAKgCERKwBgA=\",\n  \"6\":\"BgABAsYBnAOqBxgGFgYYBBYEFgIWABQBFgEUAxQDFAUUBRIFEAcSCRAJEAkOCw4NDgsMDQoPCg8KDwgRCBEGEQYRBBMCEwITAhUAkwIBAAERAREBEQEPAxEFEQMPBREFDwcPBw8HDwkNCQ0LDQsNCwsNCw0LDQkPCQ8JDwcRBxEHEwUTAxMFFQEXAxcBGQAVABUCEwIVBBMEEQYTBhEIEQgPChEKDQoPDA0MDQwNDgsOCxALDgkQCRAHEgcQBxIFEgUSBRIBFAMSARIBFAASAOIFABACEgIQAhIEEAQQBhIGEAYQCBAKEAgOChAMDgwMDA4ODA4MDgwODBAKEAoQChIIEggSBhQGFgYUAhYCGAIYABoAGAEYARYBFgMUBRQFEgUSBxAHEAcQCQ4LDgkMCwwNDA0KDQgPCg0GEQgPBhEEEQQRBBMEEwITAhMCFQIVABWrAgAACgEIAQoBCAEGAwYDBgUGBQQFBAUEBQQFAgUABwIFAAUABwEFAAUBBQMFAwUDBQMFBQMFAwUBBQEHAQkBBwAJAJcBDUbpBDASFi4A4AETLC8SBQAvERUrAN8BFC0yEQQA\",\n  \"8\":\"BgABA9gB6gPYCxYAFAEUARYBEgMUBRQFEgUSBxIHEAcSCQ4JEAkOCw4LDgsMDQwNCg0KDQoPCg8IDwgPBhEGEQQPBBMCEQIRABMAQwAxAA8BEQEPAREDDwMRAw8FEQUPBxEJDwkPCQ8NDw0PDQ8IBwYHCAcGBwgHBgkGBwYJBgcECQYJBAkGCQQJBAsECwQLBA0CCwINAg8CDwIPAA8AaQATAREBEwERAxEFEQURBREHEQcPBw8JDwkPCw8LDQsNDQ0LCw0LDwsNCQ8JDwcPBw8HEQURAxEFEQMRARMBEwFDABEAEwIRAhEEEQQRBg8GEQgPCA8KDwoPCg0MDQwNDAsOCw4LDgkQCRAJDgkQBxIHEAcSBRADEgMUAxIBFAEUABQAagAOAhAADgIOAg4EDAIOBAwEDAQMBgwECgYMBAoGCAYKBgoGCggKBgoICgYICAoICA0MCwwLDgsOCRAHEAcQBxIFEgUSAxIDEgMSARABEgASADIARAASAhICEgQSAhIGEAYSBhAIEAgQCBAKDgoODA4MDgwMDgwODA4KEAwQCBIKEggSCBQIFAYUBBQEFgQWAhYCGAANT78EFis0EwYANBIYLgC0ARcsMRQFADERGS0AswELogHtAhcuNxA3DRkvALMBGjE6ETYSGDIAtAE=\",\n  \"9\":\"BgABAsYBpASeBBcFFQUXAxUDFQEVABMCFQITBBMEEwYRBhMGDwgRCg8KDwoNDA0OCwwNDgkQCRAJEAcSBxIFEgUSAxQBFAEUARYAlAICAAISAhICEgQSAhAGEgQQBhIGEAgSCA4IEAoOChAMDAwODAwODA4MEAoOChAKEAgSCBIIFAYUBBQGFgIYBBgCGgAWABYBFAEWAxQDEgUUBRIHEgcQCRIJEAkOCw4LDgsODQwNDA0MDwoPCg8IDwgRCBEGEQYRBhEEEQITAhECEwARAOEFAA8BEQEPAREDDwMPBREFDwUPBw8JDwcNCQ8LDQsLCw0NCw0LDQsNCw8JEQkPCREHEQcTBRMFEwUTARUBFQEXABkAFwIXAhcCFQQTBhMGEQYRCA8IDwgNCg8MCwoLDAsOCQ4JDgkQBxAHEAUQBRIFEgMSAxQDFAEUAxQAFgEWABamAgAACwIJAgkCCQIHBAcEBwYFBgUGAwYDBgMGAQgBBgEIAAgABgIIAgYCBgQGBAYEBgYGBgQIBAgECAIKAgoCCgAMAJgBDUXqBC8RFS0A3wEUKzARBgAwEhYsAOABEy4xEgMA\",\n  \":\":\"BgACAWE0rAEADgIOAg4CDgQMBAoGDAYKBgoICAgKCAgIBgoGCgYKBgoEDAQKBAwECgIMAAwCDAAMAAwBCgAMAQoDDAMKAwoDCgUKBQgFCgUIBwgJBgcICQYJBgsGCQQLAg0CDQINAA0ADQENAQ0BCwMNAwkFCwUJBQkHBwcJBwUHBwkFCQUJBQkDCwMJAwsDCQELAAsBCwALAAsCCQALAgkECwQJBAkECQYJBgcGBwgJBgcKBQgHCgUKBQwFCgEOAwwBDgEOAA4BYQDqBAAOAg4CDgIOBAwECgYMBgoGCggICAoICAgGCgYKBgoGCgQMBAoEDAQKAgwADAIMAAwADAEKAAwBCgMMAwoDCgMKBQoFCAUKBQgHCAkGBwgJBgkGCwYJBAsCDQINAg0ADQANAQ0BDQELAw0DCQULBQkFCQcHBwkHBQcHCQUJBQkFCQMLAwkDCwEJAwsACwELAAsACwIJAAsECQILBAkECQQJBgkGBwYHCAkGBwoFCAcKBQoFDAUKAQ4DDAEOAQ4ADg==\",\n  \"x\":\"BgABARHmAoAJMIMBNLUBNrYBMIQB1AIA9QG/BI4CvwTVAgA5hgFBwAFFxwE1fdUCAI4CwATzAcAE1AIA\",\n  \";\":\"BgACAWEslgYADgIOAg4CDgQMBAoGDAYKBgoICAgKCAgIBgoGCgYKBgoEDAQKBAwECgIMAAwCDAAMAAwBCgAMAQoDDAMKAwoDCgUKBQgFCgUIBwgJBgcICQYJBgsGCQQLAg0CDQINAA0ADQENAQ0BCwMNAwkFCwUJBQkHBwcJBwUHBwkFCQUJBQkDCwMJAwsBCQMLAAsBCwALAAsCCQALBAkCCwQJBAkECQYJBgcGBwgJBgcKBQgHCgUKBQwFCgEOAwwBDgEOAA4BYwjxBAAOAg4CDAIOBAwECgYMBgoGCggICAgICAgICgYKBgoECgQMBAoECgIMAgoCDAIKAAoADAAKAQwBCgEKAwwDCgMKBQoFCAUKBQgHBgkIBwYJBgkECwYJBAsCDQILAg0CDQADAAEAAwADAAMBAwADAAMAAwEFAAUBBwEHAQcDBwEJAwkBCwMLAwsDDQUNAw0FDwUPBREHEwUTCRMHFwkXCRezAQAgyAEJBgkGCQYHBgkIBwgFCAcKBQoFCgUMAQwDDAEOAQ4AEA==\",\n  \"=\":\"BgACAQUawAUA5gHEBAAA5QHDBAABBQC5AgDsAcQEAADrAcMEAA==\",\n  \"B\":\"BgABA2e2BMQLFgAUARQBFAEUAxIDEgUSBRIFEAcQBxAJDgkOCQ4LDgsMCwwNDA0KDQgNCg0IDwYPBg8GDwQRBBEEEQIRAhMAEwAHAAkABwEHAAkBCQAHAQkBCQEHAQkBCQMJAwcDCQMJAwkFBwUJAwkHCQUHBQkHCQcJBwcHBwkHBwcJBwsHCQUQBQ4FDgcOCQ4JDAkMCwoNCg0IDwgRBhMEFQQXAhcCGwDJAQEvAysFJwklDSMPHREbFRkXFRsTHw8fCyUJJwcrAy0B6wMAEhIAoAsREuYDAAiRAYEElgEAKioSSA1EOR6JAQAA0wEJkAGPBSwSEiwAzAETKikSjwEAAMUCkAEA\",\n  \"A\":\"BgABAg/KBfIBqQIAN98BEhHzAgAWEuwCngsREvwCABMR8gKdCxIR8QIAFBI54AEFlwGCBk3TA6ABAE3UAwMA\",\n  \"?\":\"BgACAe4BsgaYCAAZABkBFwEXBRUDEwUTBxEHEQcPCQ8JDQkNCQ0LCwsLCwsLCQsJCwcNBwsHDQcLBQsFDQULAwkFCwMLAwkDCQMBAAABAQABAAEBAQABAAEAAQABAAABAQAAAQEAEwcBAQABAAMBAwADAAUABQAFAAcABwAFAAcABwAFAgcABQAHAAUAW7cCAABcABgBFgAUAhQAFAISAhACEAIQBA4EDgQMBgwGDAYMBgoICgYKCAgKCggICAgKBgoICgYMCAwGDAgOBg4GEAYQBgIAAgIEAAICBAACAgQCBAIKBAoGCAQKBggIBgYICAYIBggGCgQIBAoECAQKAggCCgIKAAgACgAKAAgBCAEKAwgDCAMIAwgFBgMIBQYHBAUGBQQFBAcCBQQHAgcCCQIHAgkCBwAJAgkACQAJAAkBCQAJAQsACQELAQsDCwELAwsDCwMLAwsDCwULAwsFCwMLBV2YAgYECAQKBAwGDAQMBhAIEAYSBhIIEgYUBhIEFgYUBBYEFgQWAhgCFgIYABYAGAAYARgBGAMWBRYHFgcWCRYLFA0IBQYDCAUIBwYFCAcGBwgHBgcICQYJCAkGCQYJCAsGCwYLBgsGDQYNBA0GDQQNBA8EDwQPAg8EEQIRAhEAEQITAWGpBesGAA4CDgIOAg4EDAQKBgwGCgYKCAgICggICAYKBgoGCgYKBAwECgQMBAoCDAAMAgwADAAMAQoADAEKAwwDCgMKAwoFCgUIBQoFCAcICQYHCAkGCQYLBgkECwINAg0CDQANAA0BDQENAQsDDQMJBQsFCQUJBwcHCQcFBwcJBQkFCQUJAwsDCQMLAwkBCwALAQsACwALAgkACwIJBAsECQQJBAkGCQYHBgcICQYHCgUIBwoFCgUMBQoBDgMMAQ4BDgAO\",\n  \"C\":\"BgABAWmmA4ADAAUCBQAFAgUEBQIDBAUEAwQDBgMEAQYDBgEGAAgBBgDWAgAAwQLVAgATABMCEQITBBEEEQQRBhEIEQgPCA8KDwoNCg0MDQwNDAsOCw4LDgkOCxAHEAkQBxIHEgUSBRIDEgEUARIBFAAUAMIFABQCFAISBBQEEgQSBhIIEggSCBAKEAoQCg4MDgwODA4ODA4MDgwQDA4KEggQChIIEggSBhIGFAQSAhQCEgIUAMYCAADBAsUCAAUABwEFAAUBBQMDAQUDAwMDAwMFAQMDBQEFAAUBBwAFAMEF\",\n  \"L\":\"BgABAQmcBhISEdkFABIQALQLwgIAAIEJ9AIAAK8C\",\n  \"D\":\"BgABAkeyBMQLFAAUARIBFAESAxIDEgMSBRIFEAcQBxAHDgkOCQ4LDgsMCwwNDA0KDwoPCg8IDwgRCBEGEwQTBBMEEwIVAhUAFwDBBQAXARcBFwMTAxUDEwUTBxEHEQcPCQ8JDwkNCw0LCwsLDQsNCQ0JDQcPBw8HDwcRBREFEQMRAxEDEwERARMBEwDfAwASEgCgCxES4AMACT6BAxEuKxKLAQAAvwaMAQAsEhIsAMIF\",\n  \"F\":\"BgABARGABoIJ2QIAAIECsgIAEhIA4QIRErECAACvBBIR5QIAEhIAsgucBQASEgDlAhES\",\n  \"E\":\"BgABARRkxAuWBQAQEgDlAhES0QIAAP0BtgIAEhIA5wIRFLUCAAD/AfACABISAOUCERLDBQASEgCyCw==\",\n  \"G\":\"BgABAZsBjgeIAgMNBQ8FDQUNBQ0HCwcNBwsHCwkLCQsJCwsJCwsLCQsJDQkLBw0HDwcNBw8FDwUPAw8DEQMPAxEBEQERARMBEQAXABUCFwIVAhMEFQQTBhMGEwYRCBEIDwoRCg8KDwwNDA0MDQ4LDgkQCRAJEAcQBxIFEgUUBRQDFAMUARYBFgEYAMoFABQCFAASBBQCEgQSBBIEEgYSBhAGEAgQCBAKDgoOCg4MDgwMDgwOChAKEAoSCBIIFAgUBhQEGAYWAhgEGAIaAOoCAAC3AukCAAcABwEFAQUBBQMFAwMFAwUDBQEFAQcBBQEFAQUABwAFAMUFAAUCBwIFAgUCBQQFBAMGBQYDBgUGAwgDBgMIAQgDCAEIAQoBCAEIAAgACgAIAAgCCAIIAggECgQGBAgECAYIBgC6AnEAAJwCmAMAAJcF\",\n  \"H\":\"BgABARbSB7ILAQAAnwsSEeUCABISAOAE5QEAAN8EEhHlAgASEgCiCxEQ5gIAEREA/QPmAQAAgAQPEOYCABER\",\n  \"I\":\"BgABAQmuA7ILAJ8LFBHtAgAUEgCgCxMS7gIAExE=\",\n  \"J\":\"BgABAWuqB7ILALEIABEBEwERAREDEwMRAxEFEQURBw8HEQcPCQ0LDwsNCw0NDQ0LDwsPCxEJEQkTCRMJFQcVBxcFFwMZAxsBGwEbAB8AHQIbAhsEGQYXBhcGFQgTCBMKEwoRDA8KDwwNDA0OCw4LDgkQCRAJEAcQBRIFEgUSAxQDEgESARIBFAESABIAgAEREtoCABERAn8ACQIHBAcEBwYHBgUIBQoDCgMKAwoDDAEKAQwBCgEMAAwACgAMAgoCDAIKBAoECgYKBggGBgYGCAQGBAgCCgAIALIIERLmAgAREQ==\",\n  \"M\":\"BgACAQRm1gsUABMAAAABE5wIAQDBCxIR5QIAEhIA6gIK5gLVAe0B1wHuAQztAgDhAhIR5QIAEhIAxAsUAPoDtwT4A7YEFgA=\",\n  \"K\":\"BgABAVXMCRoLBQsDCQMLAwsDCwMLAwsBCwELAQsBCwELAQ0ACwELAAsADQALAg0ACwILAA0CCwILAgsCDQQLBAsECwYNBAsGCwYLCAsGCwgJCgsICQoJCgkMCQwJDAkOCRALEAkQCRKZAdICUQAAiwQSEecCABQSAKALExLoAgAREQC3BEIA+AG4BAEAERKCAwAREdkCzQXGAYUDCA0KDQgJCgkMBwoFDAUMAQwBDgAMAg4CDAQOBAwGDghmlQI=\",\n  \"O\":\"BgABAoMBsATaCxwAHAEaARoDGgMYBRYFFgcWBxQJEgkSCRILEAsODQ4NDg0MDwoNDA8KDwgPCBEIDwYRBg8GEQQRAhMCEQITABMA0QUAEQETAREBEQMTBREFEQURBxEHDwcRCQ8LDQsPCw0NDQ0NDwsPCw8LEQkTCRMJEwkVBxUHFwUXAxkDGQEbARsAGwAZAhkCGQQXBhcGFQYVCBUIEwoRChEMEQoRDA8MDQ4NDg0OCxAJEAsQCRAHEgcSBxIFFAMSAxIDEgEUARIAEgDSBQASAhQCEgISBBIEEgYSBhIIEggQCBAKEgwODBAMEA4ODg4QDhIMEAwSChQKFAgUCBYIFgYYBBoGGgQcAh4CHgILggGLAylCWxZbFSlBANEFKklcGVwYKkwA0gU=\",\n  \"N\":\"BgABAQ+YA/oEAOUEEhHVAgASEgC+CxQAwATnBQDIBRMS2AIAExEAzQsRAL8ElgU=\",\n  \"P\":\"BgABAkqoB5AGABcBFQEVAxMDEwMTBREHEQcRBw8JDwkNCQ0LDQsNCwsNCw0JDQkNCQ8HDwcPBxEFEQURAxEDEQMTAREBEwETAH8AAIMDEhHlAgASEgCgCxES1AMAFAAUARIAFAESAxIDEgMSAxIFEAUQBRAHDgkOCQ4JDgsMCwwNDA0KDQoNCg8IDwgRCBEGEwQTBBUEFQIXAhkAGQCzAgnBAsoCESwrEn8AANUDgAEALBISLgDYAg==\",\n  \"R\":\"BgABAj9msgsREvYDABQAFAESARQBEgESAxIDEgUSBRAFEAcQBw4JDgkOCQ4LDAsMDQwLCg0KDwoNCA8IDwgPBhEEEwYTAhMEFQIXABcAowIAEwEVARMDEwMTBRMFEQcTBxELEQsRDQ8PDREPEQ0VC8QB/QMSEfkCABQSiQGyA3EAALEDFBHnAgASEgCgCwnCAscFogEALhISLACqAhEsLRKhAQAApQM=\",\n  \"Q\":\"BgABA4YBvAniAbkB8wGZAYABBQUFAwUFBQUHBQUDBwUFBQcFBQMHBQcDBwUJAwcDCQMJAwkDCQMJAQsDCwMLAQsDCwENAw0BDQEPAA8BDwAPABsAGwIZAhcEGQQXBBUGFQgVCBMIEQoTChEKDwwPDA8ODQ4NDgsQCxAJEAkQBxIHEgUSBRQFFAMUARQDFAEWABYAxgUAEgIUAhICEgQSBBIGEgYSCBIIEAgQChIMDgwQDBAODg4OEA4SDBAMEgoUChQIFAgWCBYGGAQaBhoEHAIeAh4CHAAcARoBGgMaAxgFFgUWBxYHFAkSCRIJEgsQCw4NDg0ODQwPCg0MDwoPCA8IEQgPBhEGDwYRBBECEwIRAhMAEwC7BdgBrwEImQSyAwC6AylAWxZbFSk/AP0BjAK7AQeLAoMCGEc4J0wHVBbvAaYBAEM=\",\n  \"S\":\"BgABAYMC8gOEBxIFEgUQBxIFEgcSBxIJEgcSCRIJEAkQCRALEAsOCw4NDg0MDQ4PDA0KEQoPChEKEQgRCBMGFQQTBBcCFQAXABkBEwARAREBEQMPAQ8DDwMPAw0DDQUNAw0FCwULBwsFCwUJBwsFCQcHBQkHCQUHBwcHBwUHBwUFBQcHBwUHAwcFEQsRCxMJEwkTBxMFEwUVBRUDFQMVARMBFwEVABUAFQIVAhUCFQQVBBUEEwYVBhMIEwgTCBMIEwgRCBMKEQgRCmK6AgwFDgUMAw4FEAUOBRAFEAUQBRAFEAMSAw4DEAMQAxABEAEOAQ4AEAIMAg4CDgQMBAwGCggKCAoKBgwGDgYQBBACCgAMAAoBCAMKBQgFCAcIBwgJCAsGCQgLCA0IDQgNCA8IDQgPCA8IDwgPChEIDwgPCBEKDwoPDBEMDwwPDg8ODw4NEA0QCxALEgsSCRIHEgcUBRQFGAUYAxgBGgEcAR4CJAYkBiAIIAweDBwQHBAYEhgUFBYUFhQWEBoQGg4aDBwKHAoeBh4GIAQgAiACIgEiASIFIgUiBSAJIgkgCyINZ58CBwQJAgkECwQLAgsECwINBA0CDQQNAg0CDQALAg0ADQANAAsBCwELAQsDCwULBQkFCQcHBwcJBwkFCwMLAw0BDQENAAsCCwQLBAkGCQgJCAkKBwoJCgcMBQoHDAcMBQwF\",\n  \"V\":\"BgABARG2BM4DXrYEbKwDERL0AgAVEesCnQsSEfsCABQS8QKeCxES8gIAExFuqwNgtQQEAA==\",\n  \"T\":\"BgABAQskxAv0BgAAtQKVAgAA+wgSEeUCABISAPwImwIAALYC\",\n  \"U\":\"BgABAW76B7ALAKMIABcBFwMXARUFFQUTBxMHEwkRCREJEQsPDQ0LDw0NDwsPCw8LEQkPCRMJEQcTBxMFEwUVBRUDEwMXARUBFQEXABUAEwIVAhMCFQQTBBUEEwYTBhMIEwgRChEIEQwRDA8MDw4PDg0OCxANEAsSCRIJEgcUBxQHFAMWBRYBGAEYARgApggBAREU9AIAExMAAgClCAALAgkECQQHBAcIBwgHCAUKBQoDCgMKAwwBCgEMAQwADAAMAgoCDAIKAgoECgQKBggGCAYICAYKBAgCCgIMAgwApggAARMU9AIAExM=\",\n  \"X\":\"BgABARmsCBISEYkDABQSS54BWYICXYkCRZUBEhGJAwAUEtYCzgXVAtIFExKIAwATEVClAVj3AVb0AVKqAREShgMAERHXAtEF2ALNBQ==\",\n  \"W\":\"BgABARuODcQLERHpAp8LFBHlAgASEnW8A2+7AxIR6wIAFBKNA6ALERKSAwATEdQB7wZigARZ8AIREugCAA8RaKsDYsMDXsoDaqYDExLqAgA=\",\n  \"Y\":\"BgABARK4BcQLhgMAERHnAvMGAKsEEhHnAgAUEgCsBOkC9AYREoYDABERWOEBUJsCUqICVtwBERI=\",\n  \"Z\":\"BgABAQmAB8QLnwOBCaADAADBAusGAMgDggmhAwAAwgLGBgA=\",\n  \"`\":\"BgABAQfqAd4JkQHmAQAOlgJCiAGpAgALiwIA\",\n  \"c\":\"BgABAW3UA84GBQAFAQUABQEFAwMBBQMDAwMDAwUBAwMFAQUABQEHAAUAnQMABQIFAAUCBQQFAgMEBQQDBAMGAwQBBgMGAQYABgEGAPABABoMAMsCGw7tAQATABMCEwARAhMEEQIPBBEEDwQPBg8IDwYNCA0KDQoNCgsMCwwLDAkOCRAHDgcQBxIFEgUUBRQDFAEWAxgBGAAYAKQDABQCFAISBBQCEgYSBhAGEggQCBAIEAoQCg4MDAwODAwODAwKDgwQCg4IEAgQCBAIEAYSBhIGEgQSAhQCFAIUAOABABwOAM0CGQzbAQA=\",\n  \"a\":\"BgABApoB8AYCxwF+BwkHCQcJCQkHBwkHBwcJBQkFBwUJBQkFCQMHBQkDCQMJAwcDCQEHAQkBBwEJAQcABwAHAQcABQAHAAUBBQAFABMAEwITAhEEEwQPBBEGDwgPCA0IDwoLCg0KCwwLDAsMCQ4JDgkOBw4HEAcQBRAFEAUSAxADEgESAxIBFAESABQAFAISAhQCEgQSBBIEEgYSBhIIEAgQChAIDgwODA4MDg4MDgwODBAMEAoSCBIKEggUCBQGFgYWBBgEGAIaAhoAcgAADgEMAQoBCgEIAwgDBgUEBQQFBAcCBwIHAgkCCQAJAKsCABcPAMwCHAvCAgAUABYBEgAUARIDFAMQAxIDEAUSBQ4FEAcOCRAJDAkOCwwLDA0MCwoNCg8IDwgPCA8GEQYRBhMEEwIXAhUCFwAZAIMGFwAKmQLqA38ATxchQwgnGiMwD1AMUDYAdg==\",\n  \"b\":\"BgABAkqmBIIJGAAYARYBFgEUAxQDEgUSBRIFEAcQCQ4HDgkOCw4LDAsMDQoNCg0KDQgPBg8GDwYRBBEEEQQTBBECEwIVAhMAFQD/AgAZARcBFwEXAxUDEwUTBREFEQcPBw8JDwkNCQ0LDQsLCwsNCQ0JDQcPBw8HDwURAxEDEQMTAxMBEwMVARUAFQHPAwAUEgCWCxEY5gIAERkAowKCAQAJOvECESwrEn8AAJsEgAEALBISLgCeAw==\",\n  \"d\":\"BgABAkryBgDLAXAREQ8NEQ0PDREJDwkRBw8FDwURAw8DDwERAw8BEQEPACMCHwQfCB0MGw4bEhcUFxgVGhEeDSANJAkmBSgDKgEuAIADABYCFAIUAhQCFAQUBBIGEgYSBhAIEAgQCBAKDgoODAwMDAwMDgoOCg4KEAgQCBIGEgYSBhQEFgQWBBYCGAIYAHwAAKQCERrmAgARFwCnCxcADOsCugJGMgDmA3sAKxERLQCfAwolHBUmBSQKBAA=\",\n  \"e\":\"BgABAqMBigP+AgAJAgkCCQQHBAcGBwYFCAUIBQgDCgMIAQoDCAEKAQoACgAKAAoCCAIKAggECgQIBAgGCAYGBgQIBAoECAIKAAyiAgAAGQEXARcBFwMVBRMFEwURBxEHDwcPCQ8LDQkNCwsNCw0LDQkNBw8JDwcPBQ8FEQURAxEDEwMTAxMBFQAVARcALwIrBCkIJwwlDiESHxQbGBkaFR4TIA0iCyQJKAMqASwAggMAFAIUABIEFAISBBIEEgQSBhIGEAgQCBAIEAoODA4MDgwODgwQDBAKEAoSChIIFAgUCBYGGAQYBhoCGgQcAh4ALgEqAygFJgkkDSANHhEaFRgXFBsSHQ4fDCUIJwQpAi0AGQEXAxcDFQcTBRMJEQkPCw8LDQ0PDQsNDQ8LEQsRCxEJEwkTCRMJEwcTBxUHFQUVBRUHFQUVBRUHFwcVBRUHCs4BkAMfOEUURxEfMwBvbBhAGBwaBiA=\",\n  \"h\":\"BgABAUHYBJAGAAYBBgAGAQYDBgEEAwYDBAMEBQQDAgUEBQIFAAUCBQB1AAC5BhIT5wIAFhQAlAsRGOYCABEZAKMCeAAYABgBFgEWARQDFAMSBRIFEgUQBxAJDgcOCQ4LDgsMCwwNCg0KDQoNCA8GDwYPBhEEEQQRBBMEEQITAhUCEwAVAO0FFhPnAgAUEgD+BQ==\",\n  \"g\":\"BgABArkBkAeACQCNCw8ZERkRFxEVExMVERUPFQ8XDRcLGQkZBxsFGwUdAR0BDQALAA0ADQINAAsCDQANAg0CDQILAg0EDQINBA0GDQQNBg0EDQYNCA0GDwgNCA0IDQgPCg0KDwwNDA8MDw4PDqIB7gEQDRALEAkQCQ4JEAcOBw4FDgUOAwwFDgMMAQwBDAEMAQwACgEKAAoACAIIAAgCCAIGAggCBgIGBAYCBgQEAgYEAqIBAQADAAEBAwADAAMABQADAAUAAwAFAAMABQAFAAMABQA3ABMAEwIRAhMCEQQRBBEEEQYRBg8IDwgPCA0KDQoNCg0MCwwLDgsOCQ4JDgkQBxAHEgcSBRIDFAMWAxQBFgEYABgA/gIAFgIWAhQEFgQUBBIGFAgSCBIIEAoSChAKDgwODA4MDg4MDgwODA4KEAgQCBAIEgYSBhIEEgYSBBQCEgIUAhQCOgAQABABDgEQAQ4BEAMOAw4FDgUOBQwFDgcMBQ4HDAkMB4oBUBgACbsCzQYAnAR/AC0RES0AnQMSKy4RgAEA\",\n  \"f\":\"BgABAUH8A6QJBwAHAAUABwEFAQcBBQEFAwUDBQMDAwMDAwUDAwMFAQUAwQHCAQAWEgDZAhUUwQEAAOMEFhftAgAWFADKCQoSChIKEAoQCg4KDgwOCgwMDAoKDAwMCgwIDAgMCAwIDAYOCAwEDgYMBA4GDAIOBA4CDgQOAg4CDgAOAg4ADgC2AQAcDgDRAhkQowEA\",\n  \"i\":\"BgACAQlQABISALoIERLqAgAREQC5CBIR6QIAAWELyAoADgIOAgwEDgIKBgwGCgYKCAoGCAgICggIBggGCgYKBAoECgQMBAoCDAIMAgwCDAAMAAwADAEMAQoBDAMKAwoDCgUKBQgFCgUIBwgHCAcICQgJBgkECwQJBA0CCwANAA0ADQELAQ0BCwMJBQsFCQUJBwkFBwcHBwcJBQcFCQUJBQkDCQMLAwkBCwELAQsACwALAAsCCwILAgkCCwIJBAkECQQJBgcGCQYHCAcIBwgHCgUKBQwFCgMMAQwBDgEMAA4=\",\n  \"j\":\"BgACAWFKyAoADgIOAgwEDgIKBgwGCgYKCAoGCAgICggIBggGCgYKBAoECgQMBAoCDAIMAgwCDAAMAAwADAEMAQoBDAMKAwoDCgUKBQgFCgUIBwgHCAcICQgJBgkECwQJBA0CCwANAA0ADQELAQ0BCwMJBQsFCQUJBwkFBwcHBwcJBQcFCQUJBQkDCQMLAwkBCwELAQsACwALAAsCCwILAgkCCwIJBAkECQQJBgcGCQYHCAcIBwgHCgUKBQwFCgMMAQwBDgEMAA4BO+YCnwwJEQkRCQ8JDwsNCQ0LDQkLCwsJCQsLCQkLBwsHCwcLBwsFCwcNAwsFDQMLBQ0BDQMNAQ0DDQENAQ0ADQENAA0AVwAbDQDSAhoPQgAIAAgABgAIAgYCCAIGAgYEBgQGBAQEBAQEBgQEBAYCBgC4CRES6gIAEREAowo=\",\n  \"k\":\"BgABARKoA/QFIAC0AYoD5gIAjwK5BJICwwTfAgDDAbIDFwAAnwMSEeUCABISAJILERLmAgAREQCvBQ==\",\n  \"n\":\"BgABAW1yggmQAU8GBAgEBgQGBgYCCAQGBAYEBgQIAgYECAQGAggEBgIIBAgCCAQIAggCCAIIAgoACAIKAAgCCgAKAgoADAAKAgwAFgAWARQAFAEUAxQDFAMSAxIFEgUQBRIHEAkOBxAJDgsOCwwLDA0MDQoPCA8IEQgRBhEGEwYVBBUEFQIXAhkCGQDtBRQR5QIAFBAA/AUACAEIAQYBCAMGBQQFBgUEBwQFBAcCBwIHAgcCCQIHAAcACQAHAQcABwMHAQUDBwMFAwUFBQUDBQEFAwcBBwAHAPkFEhHjAgASEgDwCBAA\",\n  \"m\":\"BgABAZoBfoIJigFbDAwMCg4KDggOCA4IDgYQBhAGEAQQBBAEEAISAhACEgAmASQDJAciCyANHhEcFRwXDg4QDBAKEAwQCBAKEggSBhIGEgYSBBQEEgIUAhICFAAUABQBEgEUARIDEgMSAxIFEgUQBxAHEAcQBw4JDgkOCw4LDAsMDQoNCg8KDwgPCBEIEQYRBBMEEwQTAhMCFQAVAP0FEhHlAgASEgCCBgAIAQgBBgEGAwYFBgUEBQQHBAUEBwIHAgcCBwIJAAcABwAJAAcBBwEHAQUBBwMFAwUDBQMDBQMFAwUBBQEHAQcAgQYSEeUCABISAIIGAAgBCAEGAQYDBgUGBQQFBAcEBQQHAgcCBwIHAgkABwAHAAkABwEHAQcBBQEHAwUDBQMFAwMFAwUDBQEFAQcBBwCBBhIR5QIAEhIA8AgYAA==\",\n  \"l\":\"BgABAQnAAwDrAgASFgDWCxEa6gIAERkA0wsUFw==\",\n  \"y\":\"BgABAZ8BogeNAg8ZERkRFxEVExMVERUPFQ8XDRcLGQkZBxsFGwUdAR0BDQALAA0ADQINAAsCDQANAg0CDQILAg0EDQINBA0GDQQNBg0EDQYNCA0GDwgNCA0IDQgPCg0KDwwNDA8MDw4PDqIB7gEQDRALEAkQCQ4JEAcOBw4FDgUOAwwFDgMMAQwBDAEMAQwACgEKAAoACAIIAAgCCAIGAggCBgIGBAYCBgQEAgYEAqIBAQADAAEBAwADAAMABQADAAUAAwAFAAMABQAFAAMABQA3ABMAEwIRABECEwQRAg8EEQQPBBEGDwgNCA8IDQgNCg0MDQwLDAkOCw4JDgcQBxAHEgUSBRQFFAMWARgDGAEaABwA9AUTEuQCABEPAP8FAAUCBQAFAgUEBQIDBAUEAwQDBgMEAQYDBgEGAAgBBgCAAQAAvAYREuICABMPAP0K\",\n  \"q\":\"BgABAmj0A4YJFgAWARQAEgESAxADEAMOAw4FDgUMBQ4HDgcOBwwJDgmeAU4A2QwWGesCABYaAN4DAwADAAMBAwADAAUAAwADAAMABQAFAAUABwAHAQcACQAVABUCFQATAhUCEwQRAhMEEQQRBhEGDwgPCA8IDQoNDA0MCwwLDgkOCRAJEAkQBxIHEgUUBRYDFgMYARoBGgAcAP4CABYCFgIWBBYEFAQSBhQIEggSCBAKEgoQDA4MDgwODg4ODBAMDgwQChIIEAoSCBIGEgYUBhQEFAQWAhYCFgIWAApbkQYSKy4ReAAAjARTEjkRHykJMwDvAg==\",\n  \"p\":\"BgABAmiCBIYJFgAWARYBFAEWAxQDEgUUBRIFEgcSBxAJEAkQCQ4LDgsOCwwNDA0KDwoPCg8IEQgRCBEGEwQTBhMCFQQVAhUAFQD9AgAbARkBFwMXAxcDEwUTBxMHEQcRCQ8JDQsNCw0LCw0LDQkPCQ0JDwURBxEFEQURAxMDEQMTARUBEwEVARUBFQAJAAcABwAFAAcABQAFAAMAAwADAAUAAwIDAAMAAwIDAADdAxYZ6wIAFhoA2gyeAU0OCgwIDgoMCA4GDgYMBg4GDgQQBBAEEgQUAhQCFgIWAApcoQMJNB8qNxJVEQCLBHgALhISLADwAg==\",\n  \"o\":\"BgABAoMB8gOICRYAFgEWARQBFgMUAxIDFAUSBRIHEgcQBxAJEAkOCw4LDgsMDQwNCg8KDwoPCg8IEQgRBhMGEwQTBBMCFQIVABcAiwMAFwEVARUDEwMTAxMFEwcRBxEHDwkPCQ8LDQsNCw0NCw0LDwkNCw8HEQkPBxEHEQcRBRMFEwMTAxUDFQEVABUAFQAVAhUCFQITBBMEEwYTBhEGEQgRCA8KDwoPCg0KDQwNDAsOCw4JDgkQCRAJEgcSBxIFFAUUAxQDFgEWARYAFgCMAwAYAhYCFgQUBBQEFAYUCBIIEggQChAKEAwODA4MDg4MDgwQCg4KEgoQChIIEggSBhQGEgYUBBYEFAIWAhYCFgALYv0CHTZBFEMRHTcAjwMcNUITQhIiOACQAw==\",\n  \"r\":\"BgACAQRigAkQAA8AAAABShAAhAFXDAwODAwKDgoOCBAIDgYQBhAEEAQQBBAEEAISABACEAAQAA4BEAAQARADEAEQAxADEAUSBRIHFAcUCxQLFA0WDVJFsQHzAQsMDQwLCgkICwgLCAkGCQYJBAkGBwIJBAcCBwQHAAcCBwAFAgcABQAHAQUABQEFAQUBBQEDAQUBAwMDAQMDAwEAmwYSEeMCABISAO4IEAA=\",\n  \"u\":\"BgABAV2KBwGPAVANCQsHDQcNBw0FCwUNBQ0FDQMPAw8DEQMTARMBFQEVABUAFQITABMEEwITBBMEEQQRBhEGDwYRCA8KDQgPCg0MDQwLDAsOCRALDgcQBxIHEgUUBRQFFAMWAxgBGAEYARoA7gUTEuYCABMPAPsFAAcCBwIFBAcCBQYDBgUGAwgDBgMIAQgBCAEIAQoBCAAIAAoACAIIAggCCAIGBAgEBgQGBgYGBAYCBgQIAggACAD6BRES5AIAEREA7wgPAA==\",\n  \"s\":\"BgABAasC/gLwBQoDCgMMBQ4DDgUOBRAFEAUSBRAHEgcQCRIJEAkSCxALEAsQDRANDg0ODw4PDA8MDwoRChEIEwYTBBcCFQIXABkBGQEXAxcFFQUTBRMHEwcRCREJDwkNCQ8LDQ0LCwsNCw0JDQkPBw8HDwUPBREDEQMRAREDEQETABEBEwARABMADwIRABECEQIRBBMCEwQVBBUEFQYVBhMIFwgVChUKFQxgsAIIAwYDCAMKAQgDCAMKAQoDCgEKAwoBCgMKAQwDCgEKAwoBDAMKAQoBCgEMAQoACgEKAAoBCgAKAQgACgAIAQgABgoECAIKAgoCCgAMAQoBDAUEBwIHBAcEBwIHBAkECQQJBAkECQYLBAkGCwYJBgsGCwYJCAsGCwgJBgsICQgLCAkICwgJCgkKCQoJCgcKCQwHDAcMBwwFDAcMAw4FDAMOAw4BDgMQARAAEAESABIAEgIQAg4CDgIOBA4CDgQMBAwEDAQMBgoECgYKBgoGCgYIBggGCAgIBggGBgYIBgYGBgYGBgYGBAgGBgQIBAYECAQQChIIEggSBhIEEgQSBBQCFAISABQAEgASABIAEgESARIBEAEQAxIDDgMQAxADDgUOBQwDDAMMAwoDCAMIAQYBe6cCAwIDAgUAAwIFAgUCBwIFAgcCBQIHAgUCBwIHAAUCBwIHAgUABwIHAgcABQIHAAcCBwAFAgUABQIFAAUABQIDAAEAAQABAQEAAQEBAQEBAQEBAQEDAQEAAwEBAQMAAwEDAAMBAwADAQMAAwABAQMAAwADAAEAAwIBAAMCAQQDAgE=\",\n  \"t\":\"BgABAUe8BLACWAAaEADRAhsOaQANAA0ADwINAA0CDQANAg0CDQINBA0CCwYNBA0GCwYNBgsIDQgLCAsKCwgJDAsKCQwJDAkOCQ4HEAcSBxIHEgUUAOAEawAVEQDWAhYTbAAAygIVFOYCABUXAMUCogEAFhQA1QIVEqEBAADzAwIFBAMEBQQDBAMEAwYDBgMGAwYBCAEGAQgBBgEIAAgA\",\n  \"w\":\"BgABARz8BsAEINYCKNgBERLuAgARD+8B3QgSEc0CABQSW7YCV7UCFBHJAgASEpMC3AgREvACABERmAHxBDDaAVeYAxES7gIAEREo1QE81wIIAA==\",\n  \"z\":\"BgABAQ6cA9AGuQIAFw8AzAIaC9QFAAAr9wKjBuACABYQAMsCGQyZBgCaA9AG\"\n   }';\nBEGIN\n\n  IF font IS NULL THEN\n    font := font_default;\n  END IF;\n\n  -- For character spacing, use m as guide size\n  geom := ST_GeomFromTWKB(decode(font->>'m', 'base64'));\n  m_width := ST_XMax(geom) - ST_XMin(geom);\n  spacing := m_width / 12;\n\n  letterarray := regexp_split_to_array(replace(letters, ' ', E'\\t'), E'');\n  FOREACH letter IN ARRAY letterarray\n  LOOP\n    geom := ST_GeomFromTWKB(decode(font->>(letter), 'base64'));\n    -- Chars are not already zeroed out, so do it now\n    geom := ST_Translate(geom, -1 * ST_XMin(geom), 0.0);\n    -- unknown characters are treated as spaces\n    IF geom IS NULL THEN\n      -- spaces are a \"quarter m\" in width\n      width := m_width / 3.5;\n    ELSE\n      width := (ST_XMax(geom) - ST_XMin(geom));\n    END IF;\n    geom := ST_Translate(geom, position, 0.0);\n    -- Tighten up spacing when characters have a large gap\n    -- between them like Yo or To\n    adjustment := 0.0;\n    IF prevgeom IS NOT NULL AND geom IS NOT NULL THEN\n      dist = ST_Distance(prevgeom, geom);\n      IF dist > spacing THEN\n        adjustment = spacing - dist;\n        geom := ST_Translate(geom, adjustment, 0.0);\n      END IF;\n    END IF;\n    prevgeom := geom;\n    position := position + width + spacing + adjustment;\n    wordarr := array_append(wordarr, geom);\n  END LOOP;\n  -- apply the start point and scaling options\n  wordgeom := ST_CollectionExtract(ST_Collect(wordarr));\n  wordgeom := ST_Scale(wordgeom,\n                text_height/font_default_height,\n                text_height/font_default_height);\n  return wordgeom;\nEND;\n"
  },
  {
    "function_name": "st_linecrossingdirection",
    "argument_count": 2,
    "source_code": "ST_LineCrossingDirection"
  },
  {
    "function_name": "st_linefromencodedpolyline",
    "argument_count": 2,
    "source_code": "line_from_encoded_polyline"
  },
  {
    "function_name": "st_linefrommultipoint",
    "argument_count": 1,
    "source_code": "LWGEOM_line_from_mpoint"
  },
  {
    "function_name": "st_linefromtext",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'LINESTRING'\n\tTHEN public.ST_GeomFromText($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_linefromtext",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'LINESTRING'\n\tTHEN public.ST_GeomFromText($1,$2)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_linefromwkb",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'LINESTRING'\n\tTHEN public.ST_GeomFromWKB($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_linefromwkb",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'LINESTRING'\n\tTHEN public.ST_GeomFromWKB($1, $2)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_lineinterpolatepoint",
    "argument_count": 2,
    "source_code": "LWGEOM_line_interpolate_point"
  },
  {
    "function_name": "st_lineinterpolatepoints",
    "argument_count": 3,
    "source_code": "LWGEOM_line_interpolate_point"
  },
  {
    "function_name": "st_linelocatepoint",
    "argument_count": 2,
    "source_code": "LWGEOM_line_locate_point"
  },
  {
    "function_name": "st_linemerge",
    "argument_count": 2,
    "source_code": "linemerge"
  },
  {
    "function_name": "st_linemerge",
    "argument_count": 1,
    "source_code": "linemerge"
  },
  {
    "function_name": "st_linestringfromwkb",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'LINESTRING'\n\tTHEN public.ST_GeomFromWKB($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_linestringfromwkb",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'LINESTRING'\n\tTHEN public.ST_GeomFromWKB($1, $2)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_linesubstring",
    "argument_count": 3,
    "source_code": "LWGEOM_line_substring"
  },
  {
    "function_name": "st_linetocurve",
    "argument_count": 1,
    "source_code": "LWGEOM_line_desegmentize"
  },
  {
    "function_name": "st_locatealong",
    "argument_count": 3,
    "source_code": "ST_LocateAlong"
  },
  {
    "function_name": "st_locatebetween",
    "argument_count": 4,
    "source_code": "ST_LocateBetween"
  },
  {
    "function_name": "st_locatebetweenelevations",
    "argument_count": 3,
    "source_code": "ST_LocateBetweenElevations"
  },
  {
    "function_name": "st_longestline",
    "argument_count": 2,
    "source_code": "SELECT public._ST_LongestLine(public.ST_ConvexHull($1), public.ST_ConvexHull($2))"
  },
  {
    "function_name": "st_m",
    "argument_count": 1,
    "source_code": "LWGEOM_m_point"
  },
  {
    "function_name": "st_makebox2d",
    "argument_count": 2,
    "source_code": "BOX2D_construct"
  },
  {
    "function_name": "st_makeenvelope",
    "argument_count": 5,
    "source_code": "ST_MakeEnvelope"
  },
  {
    "function_name": "st_makeline",
    "argument_count": 1,
    "source_code": "LWGEOM_makeline_garray"
  },
  {
    "function_name": "st_makeline",
    "argument_count": 1,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_makeline",
    "argument_count": 2,
    "source_code": "LWGEOM_makeline"
  },
  {
    "function_name": "st_makepoint",
    "argument_count": 4,
    "source_code": "LWGEOM_makepoint"
  },
  {
    "function_name": "st_makepoint",
    "argument_count": 3,
    "source_code": "LWGEOM_makepoint"
  },
  {
    "function_name": "st_makepoint",
    "argument_count": 2,
    "source_code": "LWGEOM_makepoint"
  },
  {
    "function_name": "st_makepointm",
    "argument_count": 3,
    "source_code": "LWGEOM_makepoint3dm"
  },
  {
    "function_name": "st_makepolygon",
    "argument_count": 2,
    "source_code": "LWGEOM_makepoly"
  },
  {
    "function_name": "st_makepolygon",
    "argument_count": 1,
    "source_code": "LWGEOM_makepoly"
  },
  {
    "function_name": "st_makevalid",
    "argument_count": 2,
    "source_code": "ST_MakeValid"
  },
  {
    "function_name": "st_makevalid",
    "argument_count": 1,
    "source_code": "ST_MakeValid"
  },
  {
    "function_name": "st_maxdistance",
    "argument_count": 2,
    "source_code": "SELECT public._ST_MaxDistance(public.ST_ConvexHull($1), public.ST_ConvexHull($2))"
  },
  {
    "function_name": "st_maximuminscribedcircle",
    "argument_count": 1,
    "source_code": "ST_MaximumInscribedCircle"
  },
  {
    "function_name": "st_memcollect",
    "argument_count": 1,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_memsize",
    "argument_count": 1,
    "source_code": "LWGEOM_mem_size"
  },
  {
    "function_name": "st_memunion",
    "argument_count": 1,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_minimumboundingcircle",
    "argument_count": 2,
    "source_code": "ST_MinimumBoundingCircle"
  },
  {
    "function_name": "st_minimumboundingradius",
    "argument_count": 1,
    "source_code": "ST_MinimumBoundingRadius"
  },
  {
    "function_name": "st_minimumclearance",
    "argument_count": 1,
    "source_code": "ST_MinimumClearance"
  },
  {
    "function_name": "st_minimumclearanceline",
    "argument_count": 1,
    "source_code": "ST_MinimumClearanceLine"
  },
  {
    "function_name": "st_mlinefromtext",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'MULTILINESTRING'\n\tTHEN public.ST_GeomFromText($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_mlinefromtext",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE\n\tWHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'MULTILINESTRING'\n\tTHEN public.ST_GeomFromText($1,$2)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_mlinefromwkb",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'MULTILINESTRING'\n\tTHEN public.ST_GeomFromWKB($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_mlinefromwkb",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'MULTILINESTRING'\n\tTHEN public.ST_GeomFromWKB($1, $2)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_mpointfromtext",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'MULTIPOINT'\n\tTHEN ST_GeomFromText($1, $2)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_mpointfromtext",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'MULTIPOINT'\n\tTHEN public.ST_GeomFromText($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_mpointfromwkb",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'MULTIPOINT'\n\tTHEN public.ST_GeomFromWKB($1, $2)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_mpointfromwkb",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'MULTIPOINT'\n\tTHEN public.ST_GeomFromWKB($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_mpolyfromtext",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'MULTIPOLYGON'\n\tTHEN public.ST_GeomFromText($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_mpolyfromtext",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'MULTIPOLYGON'\n\tTHEN public.ST_GeomFromText($1,$2)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_mpolyfromwkb",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'MULTIPOLYGON'\n\tTHEN public.ST_GeomFromWKB($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_mpolyfromwkb",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'MULTIPOLYGON'\n\tTHEN public.ST_GeomFromWKB($1, $2)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_multi",
    "argument_count": 1,
    "source_code": "LWGEOM_force_multi"
  },
  {
    "function_name": "st_multilinefromwkb",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'MULTILINESTRING'\n\tTHEN public.ST_GeomFromWKB($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_multilinestringfromtext",
    "argument_count": 2,
    "source_code": "SELECT public.ST_MLineFromText($1, $2)"
  },
  {
    "function_name": "st_multilinestringfromtext",
    "argument_count": 1,
    "source_code": "SELECT public.ST_MLineFromText($1)"
  },
  {
    "function_name": "st_multipointfromtext",
    "argument_count": 1,
    "source_code": "SELECT public.ST_MPointFromText($1)"
  },
  {
    "function_name": "st_multipointfromwkb",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'MULTIPOINT'\n\tTHEN public.ST_GeomFromWKB($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_multipointfromwkb",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1,$2)) = 'MULTIPOINT'\n\tTHEN public.ST_GeomFromWKB($1, $2)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_multipolyfromwkb",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'MULTIPOLYGON'\n\tTHEN public.ST_GeomFromWKB($1, $2)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_multipolyfromwkb",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'MULTIPOLYGON'\n\tTHEN public.ST_GeomFromWKB($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_multipolygonfromtext",
    "argument_count": 2,
    "source_code": "SELECT public.ST_MPolyFromText($1, $2)"
  },
  {
    "function_name": "st_multipolygonfromtext",
    "argument_count": 1,
    "source_code": "SELECT public.ST_MPolyFromText($1)"
  },
  {
    "function_name": "st_ndims",
    "argument_count": 1,
    "source_code": "LWGEOM_ndims"
  },
  {
    "function_name": "st_node",
    "argument_count": 1,
    "source_code": "ST_Node"
  },
  {
    "function_name": "st_normalize",
    "argument_count": 1,
    "source_code": "ST_Normalize"
  },
  {
    "function_name": "st_npoints",
    "argument_count": 1,
    "source_code": "LWGEOM_npoints"
  },
  {
    "function_name": "st_nrings",
    "argument_count": 1,
    "source_code": "LWGEOM_nrings"
  },
  {
    "function_name": "st_numgeometries",
    "argument_count": 1,
    "source_code": "LWGEOM_numgeometries_collection"
  },
  {
    "function_name": "st_numinteriorring",
    "argument_count": 1,
    "source_code": "LWGEOM_numinteriorrings_polygon"
  },
  {
    "function_name": "st_numinteriorrings",
    "argument_count": 1,
    "source_code": "LWGEOM_numinteriorrings_polygon"
  },
  {
    "function_name": "st_numpatches",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE WHEN public.ST_GeometryType($1) = 'ST_PolyhedralSurface'\n\tTHEN public.ST_NumGeometries($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_numpoints",
    "argument_count": 1,
    "source_code": "LWGEOM_numpoints_linestring"
  },
  {
    "function_name": "st_offsetcurve",
    "argument_count": 3,
    "source_code": "ST_OffsetCurve"
  },
  {
    "function_name": "st_orderingequals",
    "argument_count": 2,
    "source_code": "LWGEOM_same"
  },
  {
    "function_name": "st_orientedenvelope",
    "argument_count": 1,
    "source_code": "ST_OrientedEnvelope"
  },
  {
    "function_name": "st_overlaps",
    "argument_count": 2,
    "source_code": "overlaps"
  },
  {
    "function_name": "st_patchn",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE WHEN public.ST_GeometryType($1) = 'ST_PolyhedralSurface'\n\tTHEN public.ST_GeometryN($1, $2)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_perimeter",
    "argument_count": 1,
    "source_code": "LWGEOM_perimeter2d_poly"
  },
  {
    "function_name": "st_perimeter",
    "argument_count": 2,
    "source_code": "geography_perimeter"
  },
  {
    "function_name": "st_perimeter2d",
    "argument_count": 1,
    "source_code": "LWGEOM_perimeter2d_poly"
  },
  {
    "function_name": "st_point",
    "argument_count": 2,
    "source_code": "LWGEOM_makepoint"
  },
  {
    "function_name": "st_point",
    "argument_count": 3,
    "source_code": "ST_Point"
  },
  {
    "function_name": "st_pointfromgeohash",
    "argument_count": 2,
    "source_code": "point_from_geohash"
  },
  {
    "function_name": "st_pointfromtext",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'POINT'\n\tTHEN public.ST_GeomFromText($1, $2)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_pointfromtext",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'POINT'\n\tTHEN public.ST_GeomFromText($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_pointfromwkb",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'POINT'\n\tTHEN public.ST_GeomFromWKB($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_pointfromwkb",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'POINT'\n\tTHEN public.ST_GeomFromWKB($1, $2)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_pointinsidecircle",
    "argument_count": 4,
    "source_code": "LWGEOM_inside_circle_point"
  },
  {
    "function_name": "st_pointm",
    "argument_count": 4,
    "source_code": "ST_PointM"
  },
  {
    "function_name": "st_pointn",
    "argument_count": 2,
    "source_code": "LWGEOM_pointn_linestring"
  },
  {
    "function_name": "st_pointonsurface",
    "argument_count": 1,
    "source_code": "pointonsurface"
  },
  {
    "function_name": "st_points",
    "argument_count": 1,
    "source_code": "ST_Points"
  },
  {
    "function_name": "st_pointz",
    "argument_count": 4,
    "source_code": "ST_PointZ"
  },
  {
    "function_name": "st_pointzm",
    "argument_count": 5,
    "source_code": "ST_PointZM"
  },
  {
    "function_name": "st_polyfromtext",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'POLYGON'\n\tTHEN public.ST_GeomFromText($1, $2)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_polyfromtext",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'POLYGON'\n\tTHEN public.ST_GeomFromText($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_polyfromwkb",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'POLYGON'\n\tTHEN public.ST_GeomFromWKB($1, $2)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_polyfromwkb",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'POLYGON'\n\tTHEN public.ST_GeomFromWKB($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_polygon",
    "argument_count": 2,
    "source_code": "\n\tSELECT public.ST_SetSRID(public.ST_MakePolygon($1), $2)\n\t"
  },
  {
    "function_name": "st_polygonfromtext",
    "argument_count": 1,
    "source_code": "SELECT public.ST_PolyFromText($1)"
  },
  {
    "function_name": "st_polygonfromtext",
    "argument_count": 2,
    "source_code": "SELECT public.ST_PolyFromText($1, $2)"
  },
  {
    "function_name": "st_polygonfromwkb",
    "argument_count": 2,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1,$2)) = 'POLYGON'\n\tTHEN public.ST_GeomFromWKB($1, $2)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_polygonfromwkb",
    "argument_count": 1,
    "source_code": "\n\tSELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'POLYGON'\n\tTHEN public.ST_GeomFromWKB($1)\n\tELSE NULL END\n\t"
  },
  {
    "function_name": "st_polygonize",
    "argument_count": 1,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_polygonize",
    "argument_count": 1,
    "source_code": "polygonize_garray"
  },
  {
    "function_name": "st_project",
    "argument_count": 3,
    "source_code": "geography_project"
  },
  {
    "function_name": "st_quantizecoordinates",
    "argument_count": 5,
    "source_code": "ST_QuantizeCoordinates"
  },
  {
    "function_name": "st_reduceprecision",
    "argument_count": 2,
    "source_code": "ST_ReducePrecision"
  },
  {
    "function_name": "st_relate",
    "argument_count": 3,
    "source_code": "relate_pattern"
  },
  {
    "function_name": "st_relate",
    "argument_count": 3,
    "source_code": "relate_full"
  },
  {
    "function_name": "st_relate",
    "argument_count": 2,
    "source_code": "relate_full"
  },
  {
    "function_name": "st_relatematch",
    "argument_count": 2,
    "source_code": "ST_RelateMatch"
  },
  {
    "function_name": "st_removepoint",
    "argument_count": 2,
    "source_code": "LWGEOM_removepoint"
  },
  {
    "function_name": "st_removerepeatedpoints",
    "argument_count": 2,
    "source_code": "ST_RemoveRepeatedPoints"
  },
  {
    "function_name": "st_reverse",
    "argument_count": 1,
    "source_code": "LWGEOM_reverse"
  },
  {
    "function_name": "st_rotate",
    "argument_count": 3,
    "source_code": "SELECT public.ST_Affine($1,  cos($2), -sin($2), 0,  sin($2),  cos($2), 0, 0, 0, 1, public.ST_X($3) - cos($2) * public.ST_X($3) + sin($2) * public.ST_Y($3), public.ST_Y($3) - sin($2) * public.ST_X($3) - cos($2) * public.ST_Y($3), 0)"
  },
  {
    "function_name": "st_rotate",
    "argument_count": 2,
    "source_code": "SELECT public.ST_Affine($1,  cos($2), -sin($2), 0,  sin($2), cos($2), 0,  0, 0, 1,  0, 0, 0)"
  },
  {
    "function_name": "st_rotate",
    "argument_count": 4,
    "source_code": "SELECT public.ST_Affine($1,  cos($2), -sin($2), 0,  sin($2),  cos($2), 0, 0, 0, 1,\t$3 - cos($2) * $3 + sin($2) * $4, $4 - sin($2) * $3 - cos($2) * $4, 0)"
  },
  {
    "function_name": "st_rotatex",
    "argument_count": 2,
    "source_code": "SELECT public.ST_Affine($1, 1, 0, 0, 0, cos($2), -sin($2), 0, sin($2), cos($2), 0, 0, 0)"
  },
  {
    "function_name": "st_rotatey",
    "argument_count": 2,
    "source_code": "SELECT public.ST_Affine($1,  cos($2), 0, sin($2),  0, 1, 0,  -sin($2), 0, cos($2), 0,  0, 0)"
  },
  {
    "function_name": "st_rotatez",
    "argument_count": 2,
    "source_code": "SELECT public.ST_Rotate($1, $2)"
  },
  {
    "function_name": "st_scale",
    "argument_count": 4,
    "source_code": "SELECT public.ST_Scale($1, public.ST_MakePoint($2, $3, $4))"
  },
  {
    "function_name": "st_scale",
    "argument_count": 3,
    "source_code": "SELECT public.ST_Scale($1, $2, $3, 1)"
  },
  {
    "function_name": "st_scale",
    "argument_count": 2,
    "source_code": "ST_Scale"
  },
  {
    "function_name": "st_scale",
    "argument_count": 3,
    "source_code": "ST_Scale"
  },
  {
    "function_name": "st_scroll",
    "argument_count": 2,
    "source_code": "ST_Scroll"
  },
  {
    "function_name": "st_segmentize",
    "argument_count": 2,
    "source_code": "LWGEOM_segmentize2d"
  },
  {
    "function_name": "st_segmentize",
    "argument_count": 2,
    "source_code": "geography_segmentize"
  },
  {
    "function_name": "st_seteffectivearea",
    "argument_count": 3,
    "source_code": "LWGEOM_SetEffectiveArea"
  },
  {
    "function_name": "st_setpoint",
    "argument_count": 3,
    "source_code": "LWGEOM_setpoint_linestring"
  },
  {
    "function_name": "st_setsrid",
    "argument_count": 2,
    "source_code": "LWGEOM_set_srid"
  },
  {
    "function_name": "st_setsrid",
    "argument_count": 2,
    "source_code": "LWGEOM_set_srid"
  },
  {
    "function_name": "st_sharedpaths",
    "argument_count": 2,
    "source_code": "ST_SharedPaths"
  },
  {
    "function_name": "st_shiftlongitude",
    "argument_count": 1,
    "source_code": "LWGEOM_longitude_shift"
  },
  {
    "function_name": "st_shortestline",
    "argument_count": 2,
    "source_code": "LWGEOM_shortestline2d"
  },
  {
    "function_name": "st_simplify",
    "argument_count": 3,
    "source_code": "LWGEOM_simplify2d"
  },
  {
    "function_name": "st_simplify",
    "argument_count": 2,
    "source_code": "LWGEOM_simplify2d"
  },
  {
    "function_name": "st_simplifypolygonhull",
    "argument_count": 3,
    "source_code": "ST_SimplifyPolygonHull"
  },
  {
    "function_name": "st_simplifypreservetopology",
    "argument_count": 2,
    "source_code": "topologypreservesimplify"
  },
  {
    "function_name": "st_simplifyvw",
    "argument_count": 2,
    "source_code": "LWGEOM_SetEffectiveArea"
  },
  {
    "function_name": "st_snap",
    "argument_count": 3,
    "source_code": "ST_Snap"
  },
  {
    "function_name": "st_snaptogrid",
    "argument_count": 2,
    "source_code": "SELECT public.ST_SnapToGrid($1, 0, 0, $2, $2)"
  },
  {
    "function_name": "st_snaptogrid",
    "argument_count": 6,
    "source_code": "LWGEOM_snaptogrid_pointoff"
  },
  {
    "function_name": "st_snaptogrid",
    "argument_count": 5,
    "source_code": "LWGEOM_snaptogrid"
  },
  {
    "function_name": "st_snaptogrid",
    "argument_count": 3,
    "source_code": "SELECT public.ST_SnapToGrid($1, 0, 0, $2, $3)"
  },
  {
    "function_name": "st_split",
    "argument_count": 2,
    "source_code": "ST_Split"
  },
  {
    "function_name": "st_square",
    "argument_count": 4,
    "source_code": "ST_Square"
  },
  {
    "function_name": "st_squaregrid",
    "argument_count": 2,
    "source_code": "ST_ShapeGrid"
  },
  {
    "function_name": "st_srid",
    "argument_count": 1,
    "source_code": "LWGEOM_get_srid"
  },
  {
    "function_name": "st_srid",
    "argument_count": 1,
    "source_code": "LWGEOM_get_srid"
  },
  {
    "function_name": "st_startpoint",
    "argument_count": 1,
    "source_code": "LWGEOM_startpoint_linestring"
  },
  {
    "function_name": "st_subdivide",
    "argument_count": 3,
    "source_code": "ST_Subdivide"
  },
  {
    "function_name": "st_summary",
    "argument_count": 1,
    "source_code": "LWGEOM_summary"
  },
  {
    "function_name": "st_summary",
    "argument_count": 1,
    "source_code": "LWGEOM_summary"
  },
  {
    "function_name": "st_swapordinates",
    "argument_count": 2,
    "source_code": "ST_SwapOrdinates"
  },
  {
    "function_name": "st_symdifference",
    "argument_count": 3,
    "source_code": "ST_SymDifference"
  },
  {
    "function_name": "st_symmetricdifference",
    "argument_count": 2,
    "source_code": "SELECT ST_SymDifference(geom1, geom2, -1.0);"
  },
  {
    "function_name": "st_tileenvelope",
    "argument_count": 5,
    "source_code": "ST_TileEnvelope"
  },
  {
    "function_name": "st_touches",
    "argument_count": 2,
    "source_code": "touches"
  },
  {
    "function_name": "st_transform",
    "argument_count": 3,
    "source_code": "SELECT public.postgis_transform_geometry($1, $2, $3, 0)"
  },
  {
    "function_name": "st_transform",
    "argument_count": 2,
    "source_code": "transform"
  },
  {
    "function_name": "st_transform",
    "argument_count": 2,
    "source_code": "SELECT public.postgis_transform_geometry($1, proj4text, $2, 0)\n\tFROM spatial_ref_sys WHERE srid=public.ST_SRID($1);"
  },
  {
    "function_name": "st_transform",
    "argument_count": 3,
    "source_code": "SELECT public.postgis_transform_geometry($1, $2, proj4text, $3)\n\tFROM spatial_ref_sys WHERE srid=$3;"
  },
  {
    "function_name": "st_translate",
    "argument_count": 4,
    "source_code": "SELECT public.ST_Affine($1, 1, 0, 0, 0, 1, 0, 0, 0, 1, $2, $3, $4)"
  },
  {
    "function_name": "st_translate",
    "argument_count": 3,
    "source_code": "SELECT public.ST_Translate($1, $2, $3, 0)"
  },
  {
    "function_name": "st_transscale",
    "argument_count": 5,
    "source_code": "SELECT public.ST_Affine($1,  $4, 0, 0,  0, $5, 0,\n\t\t0, 0, 1,  $2 * $4, $3 * $5, 0)"
  },
  {
    "function_name": "st_triangulatepolygon",
    "argument_count": 1,
    "source_code": "ST_TriangulatePolygon"
  },
  {
    "function_name": "st_unaryunion",
    "argument_count": 2,
    "source_code": "ST_UnaryUnion"
  },
  {
    "function_name": "st_union",
    "argument_count": 2,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_union",
    "argument_count": 3,
    "source_code": "ST_Union"
  },
  {
    "function_name": "st_union",
    "argument_count": 1,
    "source_code": "pgis_union_geometry_array"
  },
  {
    "function_name": "st_union",
    "argument_count": 1,
    "source_code": "aggregate_dummy"
  },
  {
    "function_name": "st_union",
    "argument_count": 2,
    "source_code": "ST_Union"
  },
  {
    "function_name": "st_voronoilines",
    "argument_count": 3,
    "source_code": " SELECT public._ST_Voronoi(g1, extend_to, tolerance, false) "
  },
  {
    "function_name": "st_voronoipolygons",
    "argument_count": 3,
    "source_code": " SELECT public._ST_Voronoi(g1, extend_to, tolerance, true) "
  },
  {
    "function_name": "st_within",
    "argument_count": 2,
    "source_code": "within"
  },
  {
    "function_name": "st_wkbtosql",
    "argument_count": 1,
    "source_code": "LWGEOM_from_WKB"
  },
  {
    "function_name": "st_wkttosql",
    "argument_count": 1,
    "source_code": "LWGEOM_from_text"
  },
  {
    "function_name": "st_wrapx",
    "argument_count": 3,
    "source_code": "ST_WrapX"
  },
  {
    "function_name": "st_x",
    "argument_count": 1,
    "source_code": "LWGEOM_x_point"
  },
  {
    "function_name": "st_xmax",
    "argument_count": 1,
    "source_code": "BOX3D_xmax"
  },
  {
    "function_name": "st_xmin",
    "argument_count": 1,
    "source_code": "BOX3D_xmin"
  },
  {
    "function_name": "st_y",
    "argument_count": 1,
    "source_code": "LWGEOM_y_point"
  },
  {
    "function_name": "st_ymax",
    "argument_count": 1,
    "source_code": "BOX3D_ymax"
  },
  {
    "function_name": "st_ymin",
    "argument_count": 1,
    "source_code": "BOX3D_ymin"
  },
  {
    "function_name": "st_z",
    "argument_count": 1,
    "source_code": "LWGEOM_z_point"
  },
  {
    "function_name": "st_zmax",
    "argument_count": 1,
    "source_code": "BOX3D_zmax"
  },
  {
    "function_name": "st_zmflag",
    "argument_count": 1,
    "source_code": "LWGEOM_zmflag"
  },
  {
    "function_name": "st_zmin",
    "argument_count": 1,
    "source_code": "BOX3D_zmin"
  },
  {
    "function_name": "text",
    "argument_count": 1,
    "source_code": "LWGEOM_to_text"
  },
  {
    "function_name": "unlockrows",
    "argument_count": 1,
    "source_code": "\nDECLARE\n\tret int;\nBEGIN\n\n\tIF NOT LongTransactionsEnabled() THEN\n\t\tRAISE EXCEPTION 'Long transaction support disabled, use EnableLongTransaction() to enable.';\n\tEND IF;\n\n\tEXECUTE 'DELETE FROM authorization_table where authid = ' ||\n\t\tquote_literal($1);\n\n\tGET DIAGNOSTICS ret = ROW_COUNT;\n\n\tRETURN ret;\nEND;\n"
  },
  {
    "function_name": "update_asset_last_pos",
    "argument_count": 0,
    "source_code": "\r\nbegin\r\n  update assets a\r\n  set \r\n    last_detector_id = new.detector_id,\r\n    last_room_id = d.room_id,\r\n    last_detected_at = new.detected_at,\r\n    last_movement_status = new.movement_status,\r\n    updated_at = now()\r\n  from detectors d\r\n  where \r\n    a.id = new.asset_id -- 🔥 SUDAH PAKAI asset_id\r\n    and d.id = new.detector_id\r\n    and (\r\n      a.last_detected_at is null\r\n      or new.detected_at > a.last_detected_at\r\n    );\r\n\r\n  return new;\r\nend;\r\n"
  },
  {
    "function_name": "update_current_stock_from_bins",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    IF TG_OP = 'INSERT' THEN\r\n        UPDATE stocks\r\n        SET current_stock = COALESCE(current_stock, 0) + NEW.quantity,\r\n            updated_at = NOW()\r\n        WHERE id = NEW.stock_id;\r\n        \r\n    ELSIF TG_OP = 'UPDATE' THEN\r\n        UPDATE stocks\r\n        SET current_stock = COALESCE(current_stock, 0) + (NEW.quantity - OLD.quantity),\r\n            updated_at = NOW()\r\n        WHERE id = NEW.stock_id;\r\n        \r\n    ELSIF TG_OP = 'DELETE' THEN\r\n        UPDATE stocks\r\n        SET current_stock = COALESCE(current_stock, 0) - OLD.quantity,\r\n            updated_at = NOW()\r\n        WHERE id = OLD.stock_id;\r\n    END IF;\r\n    \r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "update_people_last_pos",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n  UPDATE people p\r\n  SET \r\n    last_detector_id = NEW.detector_id,\r\n    last_room_id = d.room_id,\r\n    last_detected_at = NEW.detected_at,\r\n    last_movement_status = NEW.movement_status,\r\n    level_contaminated = NEW.level_contaminated, -- Tambahan kolom khusus people\r\n    updated_at = now()\r\n  FROM detectors d\r\n  WHERE \r\n    p.rfid_tag_id = NEW.rfid_tag_id\r\n    AND d.id = NEW.detector_id\r\n    AND (\r\n      p.last_detected_at IS NULL\r\n      OR NEW.detected_at > p.last_detected_at\r\n    );\r\n\r\n  RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "update_stock_in_qty",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    IF TG_OP = 'INSERT' THEN\r\n        -- Tambah stock_in_qty\r\n        UPDATE stocks\r\n        SET stock_in_qty = COALESCE(stock_in_qty, 0) + NEW.quantity,\r\n            updated_at = NOW()\r\n        WHERE id = NEW.stock_id;\r\n        \r\n    ELSIF TG_OP = 'UPDATE' THEN\r\n        -- Jika quantity berubah, adjust selisihnya\r\n        IF NEW.quantity != OLD.quantity THEN\r\n            UPDATE stocks\r\n            SET stock_in_qty = COALESCE(stock_in_qty, 0) + (NEW.quantity - OLD.quantity),\r\n                updated_at = NOW()\r\n            WHERE id = NEW.stock_id;\r\n        END IF;\r\n        \r\n    ELSIF TG_OP = 'DELETE' THEN\r\n        -- Kurangi stock_in_qty\r\n        UPDATE stocks\r\n        SET stock_in_qty = COALESCE(stock_in_qty, 0) - OLD.quantity,\r\n            updated_at = NOW()\r\n        WHERE id = OLD.stock_id;\r\n    END IF;\r\n    \r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "update_stock_in_status",
    "argument_count": 0,
    "source_code": "\r\nDECLARE\r\n    v_stock_in_id UUID;\r\n    v_total_put_away NUMERIC;\r\n    v_total_received NUMERIC;\r\n    v_new_status VARCHAR(30);\r\nBEGIN\r\n    -- Tentukan stock_in_id dari NEW atau OLD\r\n    IF TG_OP = 'DELETE' THEN\r\n        v_stock_in_id := OLD.stock_in_id;\r\n    ELSE\r\n        v_stock_in_id := NEW.stock_in_id;\r\n    END IF;\r\n    \r\n    -- Jika tidak ada stock_in_id, skip\r\n    IF v_stock_in_id IS NULL THEN\r\n        RETURN COALESCE(NEW, OLD);\r\n    END IF;\r\n    \r\n    -- Hitung total yang sudah di-put-away\r\n    SELECT COALESCE(SUM(quantity), 0) INTO v_total_put_away\r\n    FROM stock_in_bins\r\n    WHERE stock_in_id = v_stock_in_id;\r\n    \r\n    -- Ambil total yang diterima\r\n    SELECT quantity INTO v_total_received\r\n    FROM stock_in\r\n    WHERE id = v_stock_in_id;\r\n    \r\n    -- Tentukan status baru\r\n    IF v_total_put_away >= v_total_received THEN\r\n        v_new_status := 'COMPLETED';\r\n    ELSIF v_total_put_away > 0 THEN\r\n        v_new_status := 'PARTIALLY_PUT_AWAY';\r\n    ELSE\r\n        v_new_status := 'RECEIVED';\r\n    END IF;\r\n    \r\n    -- Update status stock_in\r\n    UPDATE stock_in\r\n    SET status = v_new_status,\r\n        updated_at = NOW()\r\n    WHERE id = v_stock_in_id;\r\n    \r\n    -- Debug print (akan muncul di Supabase log)\r\n    RAISE NOTICE 'Stock In ID: %, Total Put Away: %, Total Received: %, New Status: %',\r\n                 v_stock_in_id, v_total_put_away, v_total_received, v_new_status;\r\n    \r\n    RETURN COALESCE(NEW, OLD);\r\nEND;\r\n"
  },
  {
    "function_name": "update_stock_request_fulfillment",
    "argument_count": 0,
    "source_code": "\r\nDECLARE\r\n    v_approved_quantity NUMERIC;\r\n    v_total_fulfilled NUMERIC;\r\n    v_new_status VARCHAR(30);\r\nBEGIN\r\n    -- Ambil approved_quantity dari stock_requests\r\n    SELECT COALESCE(approved_quantity, requested_quantity) \r\n    INTO v_approved_quantity\r\n    FROM stock_requests \r\n    WHERE id = NEW.stock_request_id;\r\n    \r\n    -- Hitung total yang sudah di-fulfill\r\n    SELECT COALESCE(SUM(quantity), 0) \r\n    INTO v_total_fulfilled\r\n    FROM stock_request_fulfillments\r\n    WHERE stock_request_id = NEW.stock_request_id;\r\n    \r\n    -- Tentukan status baru\r\n    IF v_total_fulfilled >= v_approved_quantity THEN\r\n        v_new_status := 'COMPLETED';\r\n    ELSIF v_total_fulfilled > 0 THEN\r\n        v_new_status := 'PARTIALLY_FULFILLED';\r\n    ELSE\r\n        v_new_status := 'APPROVED';\r\n    END IF;\r\n    \r\n    -- Update stock_requests\r\n    UPDATE stock_requests\r\n    SET fulfilled_quantity = v_total_fulfilled,\r\n        status = v_new_status,\r\n        updated_at = NOW()\r\n    WHERE id = NEW.stock_request_id;\r\n    \r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "update_stock_request_status_on_approval",
    "argument_count": 0,
    "source_code": "\r\nBEGIN\r\n    -- Jika status berubah menjadi APPROVED\r\n    IF NEW.status = 'APPROVED' AND OLD.status != 'APPROVED' THEN\r\n        -- Set approved_by, approved_date\r\n        NEW.approved_date := NOW();\r\n    END IF;\r\n    \r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "function_name": "updategeometrysrid",
    "argument_count": 3,
    "source_code": "\nDECLARE\n\tret  text;\nBEGIN\n\tSELECT public.UpdateGeometrySRID('','',$1,$2,$3) into ret;\n\tRETURN ret;\nEND;\n"
  },
  {
    "function_name": "updategeometrysrid",
    "argument_count": 4,
    "source_code": "\nDECLARE\n\tret  text;\nBEGIN\n\tSELECT public.UpdateGeometrySRID('',$1,$2,$3,$4) into ret;\n\tRETURN ret;\nEND;\n"
  },
  {
    "function_name": "updategeometrysrid",
    "argument_count": 5,
    "source_code": "\nDECLARE\n\tmyrec RECORD;\n\tokay boolean;\n\tcname varchar;\n\treal_schema name;\n\tunknown_srid integer;\n\tnew_srid integer := new_srid_in;\n\nBEGIN\n\n\t-- Find, check or fix schema_name\n\tIF ( schema_name != '' ) THEN\n\t\tokay = false;\n\n\t\tFOR myrec IN SELECT nspname FROM pg_namespace WHERE text(nspname) = schema_name LOOP\n\t\t\tokay := true;\n\t\tEND LOOP;\n\n\t\tIF ( okay <> true ) THEN\n\t\t\tRAISE EXCEPTION 'Invalid schema name';\n\t\tELSE\n\t\t\treal_schema = schema_name;\n\t\tEND IF;\n\tELSE\n\t\tSELECT INTO real_schema current_schema()::text;\n\tEND IF;\n\n\t-- Ensure that column_name is in geometry_columns\n\tokay = false;\n\tFOR myrec IN SELECT type, coord_dimension FROM public.geometry_columns WHERE f_table_schema = text(real_schema) and f_table_name = table_name and f_geometry_column = column_name LOOP\n\t\tokay := true;\n\tEND LOOP;\n\tIF (NOT okay) THEN\n\t\tRAISE EXCEPTION 'column not found in geometry_columns table';\n\t\tRETURN false;\n\tEND IF;\n\n\t-- Ensure that new_srid is valid\n\tIF ( new_srid > 0 ) THEN\n\t\tIF ( SELECT count(*) = 0 from spatial_ref_sys where srid = new_srid ) THEN\n\t\t\tRAISE EXCEPTION 'invalid SRID: % not found in spatial_ref_sys', new_srid;\n\t\t\tRETURN false;\n\t\tEND IF;\n\tELSE\n\t\tunknown_srid := public.ST_SRID('POINT EMPTY'::public.geometry);\n\t\tIF ( new_srid != unknown_srid ) THEN\n\t\t\tnew_srid := unknown_srid;\n\t\t\tRAISE NOTICE 'SRID value % converted to the officially unknown SRID value %', new_srid_in, new_srid;\n\t\tEND IF;\n\tEND IF;\n\n\tIF postgis_constraint_srid(real_schema, table_name, column_name) IS NOT NULL THEN\n\t-- srid was enforced with constraints before, keep it that way.\n\t\t-- Make up constraint name\n\t\tcname = 'enforce_srid_'  || column_name;\n\n\t\t-- Drop enforce_srid constraint\n\t\tEXECUTE 'ALTER TABLE ' || quote_ident(real_schema) ||\n\t\t\t'.' || quote_ident(table_name) ||\n\t\t\t' DROP constraint ' || quote_ident(cname);\n\n\t\t-- Update geometries SRID\n\t\tEXECUTE 'UPDATE ' || quote_ident(real_schema) ||\n\t\t\t'.' || quote_ident(table_name) ||\n\t\t\t' SET ' || quote_ident(column_name) ||\n\t\t\t' = public.ST_SetSRID(' || quote_ident(column_name) ||\n\t\t\t', ' || new_srid::text || ')';\n\n\t\t-- Reset enforce_srid constraint\n\t\tEXECUTE 'ALTER TABLE ' || quote_ident(real_schema) ||\n\t\t\t'.' || quote_ident(table_name) ||\n\t\t\t' ADD constraint ' || quote_ident(cname) ||\n\t\t\t' CHECK (st_srid(' || quote_ident(column_name) ||\n\t\t\t') = ' || new_srid::text || ')';\n\tELSE\n\t\t-- We will use typmod to enforce if no srid constraints\n\t\t-- We are using postgis_type_name to lookup the new name\n\t\t-- (in case Paul changes his mind and flips geometry_columns to return old upper case name)\n\t\tEXECUTE 'ALTER TABLE ' || quote_ident(real_schema) || '.' || quote_ident(table_name) ||\n\t\t' ALTER COLUMN ' || quote_ident(column_name) || ' TYPE  geometry(' || public.postgis_type_name(myrec.type, myrec.coord_dimension, true) || ', ' || new_srid::text || ') USING public.ST_SetSRID(' || quote_ident(column_name) || ',' || new_srid::text || ');' ;\n\tEND IF;\n\n\tRETURN real_schema || '.' || table_name || '.' || column_name ||' SRID changed to ' || new_srid::text;\n\nEND;\n"
  }
]