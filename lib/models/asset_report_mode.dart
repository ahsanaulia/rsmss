enum AssetReportMode {
  asset,
  category,
  subCategory,
  type,
  condition,
  contamination,
  dangerous,
  assignment,
}

extension AssetReportModeExtension
    on AssetReportMode {
  String get label {
    switch (this) {
      case AssetReportMode.asset:
        return 'Asset';

      case AssetReportMode.category:
        return 'Category';

      case AssetReportMode.subCategory:
        return 'Sub Category';

      case AssetReportMode.type:
        return 'Type';

      case AssetReportMode.condition:
        return 'Condition';

      case AssetReportMode.contamination:
        return 'Contamination';

      case AssetReportMode.dangerous:
        return 'Dangerous';

      case AssetReportMode.assignment:
        return 'Assignment';
    }
  }

  String get exportFileName {
    switch (this) {
      case AssetReportMode.asset:
        return 'asset_report';

      case AssetReportMode.category:
        return 'category_report';

      case AssetReportMode.subCategory:
        return 'sub_category_report';

      case AssetReportMode.type:
        return 'type_report';

      case AssetReportMode.condition:
        return 'condition_report';

      case AssetReportMode.contamination:
        return 'contamination_report';

      case AssetReportMode.dangerous:
        return 'dangerous_asset_report';

      case AssetReportMode.assignment:
        return 'assignment_report';
    }
  }

  bool get isGroupedMode {
    switch (this) {
      case AssetReportMode.asset:
        return false;

      default:
        return true;
    }
  }
}