import '../models/asset_report_mode.dart';
import '../models/asset_report_row_model.dart';
import '../models/v_asset_master_complete.dart';

class AssetReportBuilderService {
  List<AssetReportRowModel> build({
    required List<AssetMasterModel> assets,
    required AssetReportMode mode,
  }) {
    switch (mode) {
      case AssetReportMode.asset:
        return _buildAssetRows(assets);

      case AssetReportMode.category:
        return _buildCategoryRows(assets);

      case AssetReportMode.subCategory:
        return _buildSubCategoryRows(assets);

      case AssetReportMode.type:
        return _buildTypeRows(assets);

      case AssetReportMode.condition:
        return _buildConditionRows(assets);

      case AssetReportMode.contamination:
        return _buildContaminationRows(assets);

      case AssetReportMode.dangerous:
        return _buildDangerousRows(assets);

      case AssetReportMode.assignment:
        return _buildAssignmentRows(assets);
    }
  }

  // =========================================================
  // ASSET DETAIL
  // =========================================================

  List<AssetReportRowModel> _buildAssetRows(
    List<AssetMasterModel> assets,
  ) {
    return List.generate(
      assets.length,
      (index) {
        final e = assets[index];

        return AssetReportRowModel(
          no: index + 1,
          rfidTagId: e.rfidTagId,
          categoryName: e.categoryName,
          subCategoryName: e.subCategoryName,
          typeName: e.typeName,
          assetName: e.assetName,
          assignmentName: e.lastUsedByName,
          condition: e.statusCondition,
          contaminationLevel: e.levelContaminated,
          isDangerous: e.isDangerous ?? false,
          total: 1,
        );
      },
    );
  }

  // =========================================================
  // CATEGORY
  // =========================================================

  List<AssetReportRowModel> _buildCategoryRows(
    List<AssetMasterModel> assets,
  ) {
    final Map<String, List<AssetMasterModel>> grouped = {};

    for (final asset in assets) {
      final key = asset.categoryName ?? 'UNKNOWN';

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(asset);
    }

    final rows = <AssetReportRowModel>[];

    int no = 1;

    grouped.forEach((category, items) {
      rows.add(
        AssetReportRowModel(
          no: no++,
          rfidTagId: items.first.rfidTagId,
          categoryName: category,
          typeName: items.first.typeName,
          assetName: items.first.assetName,
          total: items.length,
        ),
      );
    });

    return rows;
  }

  // =========================================================
  // SUB CATEGORY
  // =========================================================

  List<AssetReportRowModel> _buildSubCategoryRows(
    List<AssetMasterModel> assets,
  ) {
    final Map<String, List<AssetMasterModel>> grouped = {};

    for (final asset in assets) {
      final key =
          '${asset.categoryName}|${asset.subCategoryName}';

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(asset);
    }

    final rows = <AssetReportRowModel>[];

    int no = 1;

    grouped.forEach((key, items) {
      final first = items.first;

      rows.add(
        AssetReportRowModel(
          no: no++,
          rfidTagId: first.rfidTagId,
          categoryName: first.categoryName,
          subCategoryName: first.subCategoryName,
          typeName: first.typeName,
          assetName: first.assetName,
          total: items.length,
        ),
      );
    });

    return rows;
  }

  // =========================================================
  // TYPE
  // =========================================================

  List<AssetReportRowModel> _buildTypeRows(
    List<AssetMasterModel> assets,
  ) {
    final Map<String, List<AssetMasterModel>> grouped = {};

    for (final asset in assets) {
      final key =
          '${asset.categoryName}|'
          '${asset.subCategoryName}|'
          '${asset.typeName}';

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(asset);
    }

    final rows = <AssetReportRowModel>[];

    int no = 1;

    grouped.forEach((key, items) {
      final first = items.first;

      rows.add(
        AssetReportRowModel(
          no: no++,
          rfidTagId: first.rfidTagId,
          categoryName: first.categoryName,
          subCategoryName: first.subCategoryName,
          typeName: first.typeName,
          assetName: first.assetName,
          total: items.length,
        ),
      );
    });

    return rows;
  }

  // =========================================================
  // CONDITION
  // =========================================================

  List<AssetReportRowModel> _buildConditionRows(
    List<AssetMasterModel> assets,
  ) {
    final Map<String, List<AssetMasterModel>> grouped = {};

    for (final asset in assets) {
      final key = asset.statusCondition ?? 'UNKNOWN';

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(asset);
    }

    final rows = <AssetReportRowModel>[];

    int no = 1;

    grouped.forEach((condition, items) {
      rows.add(
        AssetReportRowModel(
          no: no++,
          rfidTagId: items.first.rfidTagId,
          assetName: items.first.assetName,
          condition: condition,
          total: items.length,
        ),
      );
    });

    return rows;
  }

  // =========================================================
  // CONTAMINATION
  // =========================================================

  List<AssetReportRowModel> _buildContaminationRows(
    List<AssetMasterModel> assets,
  ) {
    final filtered = assets.where((e) {
      return (e.levelContaminated ?? 0) > 0;
    }).toList();

    return List.generate(
      filtered.length,
      (index) {
        final e = filtered[index];

        return AssetReportRowModel(
          no: index + 1,
          rfidTagId: e.rfidTagId,
          categoryName: e.categoryName,
          subCategoryName: e.subCategoryName,
          typeName: e.typeName,
          assetName: e.assetName,
          contaminationLevel: e.levelContaminated,
          total: 1,
        );
      },
    );
  }

  // =========================================================
  // DANGEROUS
  // =========================================================

  List<AssetReportRowModel> _buildDangerousRows(
    List<AssetMasterModel> assets,
  ) {
    final filtered = assets.where((e) {
      return e.isDangerous == true;
    }).toList();

    return List.generate(
      filtered.length,
      (index) {
        final e = filtered[index];

        return AssetReportRowModel(
          no: index + 1,
          rfidTagId: e.rfidTagId,
          categoryName: e.categoryName,
          subCategoryName: e.subCategoryName,
          typeName: e.typeName,
          assetName: e.assetName,
          isDangerous: true,
          total: 1,
        );
      },
    );
  }

  // =========================================================
  // ASSIGNMENT
  // =========================================================

  List<AssetReportRowModel> _buildAssignmentRows(
    List<AssetMasterModel> assets,
  ) {
    final Map<String, List<AssetMasterModel>> grouped = {};

    for (final asset in assets) {
      final key =
          asset.lastUsedByName ??
          asset.assignedProfileName ??
          'UNASSIGNED';

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(asset);
    }

    final rows = <AssetReportRowModel>[];

    int no = 1;

    grouped.forEach((user, items) {
      rows.add(
        AssetReportRowModel(
          no: no++,
          rfidTagId: items.first.rfidTagId,
          assetName: items.first.assetName,
          assignmentName: user,
          total: items.length,
        ),
      );
    });

    return rows;
  }
}