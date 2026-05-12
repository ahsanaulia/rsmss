import 'package:supabase_flutter/supabase_flutter.dart';

import 'v_asset_master_complete.dart';
import 'v_asset_dashboard_summary.dart';
import 'asset_group_model.dart';

class AssetRepository {
  final supabase = Supabase.instance.client;

  Future<List<AssetMasterModel>>
      getAssets() async {
    final response = await supabase
        .from('v_asset_master_complete')
        .select();

    return response
        .map<AssetMasterModel>(
          (e) => AssetMasterModel.fromJson(e),
        )
        .toList();
  }

  Future<AssetDashboardSummaryModel>
      getDashboardSummary() async {
    final response = await supabase
        .from('v_asset_dashboard_summary')
        .select()
        .single();

    return AssetDashboardSummaryModel
        .fromJson(response);
  }

  Future<List<AssetGroupModel>>
      getGroupByCategory() async {
    final response = await supabase
        .from('v_asset_group_by_category')
        .select();

    return response
        .map<AssetGroupModel>(
          (e) => AssetGroupModel.fromJson(e),
        )
        .toList();
  }

  Future<List<AssetGroupModel>>
      getGroupBySubCategory() async {
    final response = await supabase
        .from('v_asset_group_by_sub_category')
        .select();

    return response
        .map<AssetGroupModel>(
          (e) => AssetGroupModel.fromJson(e),
        )
        .toList();
  }

  Future<List<AssetGroupModel>>
      getGroupByType() async {
    final response = await supabase
        .from('v_asset_group_by_type')
        .select();

    return response
        .map<AssetGroupModel>(
          (e) => AssetGroupModel.fromJson(e),
        )
        .toList();
  }

  Future<List<AssetGroupModel>>
      getGroupByCondition() async {
    final response = await supabase
        .from('v_asset_group_by_condition')
        .select();

    return response
        .map<AssetGroupModel>(
          (e) => AssetGroupModel.fromJson(e),
        )
        .toList();
  }
}