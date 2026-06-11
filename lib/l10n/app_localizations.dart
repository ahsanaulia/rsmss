import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'RSMSS IoT'**
  String get appTitle;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email Operator'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get loginButton;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @scanQrButton.
  ///
  /// In en, this message translates to:
  /// **'SCAN QR TENANT'**
  String get scanQrButton;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed By : PLATFORM PELAYANAN TERBAIK'**
  String get developedBy;

  /// No description provided for @distributedBy.
  ///
  /// In en, this message translates to:
  /// **'Distributed By : PT. REKAMITRA'**
  String get distributedBy;

  /// No description provided for @yearCountry.
  ///
  /// In en, this message translates to:
  /// **'2026 - Indonesia'**
  String get yearCountry;

  /// No description provided for @qrScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Tenant'**
  String get qrScanTitle;

  /// No description provided for @qrScanInstruction.
  ///
  /// In en, this message translates to:
  /// **'Point camera at QR Code'**
  String get qrScanInstruction;

  /// No description provided for @qrScanProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing QR Code...'**
  String get qrScanProcessing;

  /// No description provided for @qrScanSuccess.
  ///
  /// In en, this message translates to:
  /// **'Tenant configuration saved. App will restart.'**
  String get qrScanSuccess;

  /// No description provided for @qrScanError.
  ///
  /// In en, this message translates to:
  /// **'Failed to process QR: '**
  String get qrScanError;

  /// No description provided for @operationHospitalPlatform.
  ///
  /// In en, this message translates to:
  /// **'Hospital Operational Intelligence Platform'**
  String get operationHospitalPlatform;

  /// No description provided for @operationOnDuty.
  ///
  /// In en, this message translates to:
  /// **'ON DUTY'**
  String get operationOnDuty;

  /// No description provided for @operationOffDuty.
  ///
  /// In en, this message translates to:
  /// **'OFF DUTY'**
  String get operationOffDuty;

  /// No description provided for @operationLatestAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'LATEST ANNOUNCEMENTS'**
  String get operationLatestAnnouncements;

  /// No description provided for @operationOperational.
  ///
  /// In en, this message translates to:
  /// **'Operational'**
  String get operationOperational;

  /// No description provided for @operationReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get operationReports;

  /// No description provided for @operationNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get operationNotes;

  /// No description provided for @operationInfo.
  ///
  /// In en, this message translates to:
  /// **'INFO'**
  String get operationInfo;

  /// No description provided for @operationUrgent.
  ///
  /// In en, this message translates to:
  /// **'URGENT'**
  String get operationUrgent;

  /// No description provided for @operationNoAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'No new messages from control room.'**
  String get operationNoAnnouncements;

  /// No description provided for @operationJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get operationJustNow;

  /// No description provided for @operationMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'minutes ago'**
  String get operationMinutesAgo;

  /// No description provided for @operationHourAgo.
  ///
  /// In en, this message translates to:
  /// **'hour ago'**
  String get operationHourAgo;

  /// No description provided for @operationHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String get operationHoursAgo;

  /// No description provided for @operationYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get operationYesterday;

  /// No description provided for @operationDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get operationDaysAgo;

  /// No description provided for @operationWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'weeks ago'**
  String get operationWeeksAgo;

  /// No description provided for @operationMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'months ago'**
  String get operationMonthsAgo;

  /// No description provided for @operationYearsAgo.
  ///
  /// In en, this message translates to:
  /// **'years ago'**
  String get operationYearsAgo;

  /// No description provided for @operationMenuReportIncident.
  ///
  /// In en, this message translates to:
  /// **'Lapor Insiden'**
  String get operationMenuReportIncident;

  /// No description provided for @operationMenuRegisterPeopleRfid.
  ///
  /// In en, this message translates to:
  /// **'Registrasi Orang & RFID'**
  String get operationMenuRegisterPeopleRfid;

  /// No description provided for @operationMenuBedAssignment.
  ///
  /// In en, this message translates to:
  /// **'Penentuan Tempat Tidur'**
  String get operationMenuBedAssignment;

  /// No description provided for @operationMenuBedUnassignment.
  ///
  /// In en, this message translates to:
  /// **'Tempat Tidur Dikosongkan'**
  String get operationMenuBedUnassignment;

  /// No description provided for @operationMenuCheckOutPeople.
  ///
  /// In en, this message translates to:
  /// **'Check Out People'**
  String get operationMenuCheckOutPeople;

  /// No description provided for @operationMenuInitialAsset.
  ///
  /// In en, this message translates to:
  /// **'Inisialisasi Awal Asset'**
  String get operationMenuInitialAsset;

  /// No description provided for @operationMenuRoutineAssetInspection.
  ///
  /// In en, this message translates to:
  /// **'Inspeksi Rutin Asset'**
  String get operationMenuRoutineAssetInspection;

  /// No description provided for @operationMenuInitialStock.
  ///
  /// In en, this message translates to:
  /// **'Inisialisasi Awal Stock'**
  String get operationMenuInitialStock;

  /// No description provided for @operationMenuAssetRequest.
  ///
  /// In en, this message translates to:
  /// **'Permintaan Aset'**
  String get operationMenuAssetRequest;

  /// No description provided for @operationMenuReturnAsset.
  ///
  /// In en, this message translates to:
  /// **'Kembalikan Aset'**
  String get operationMenuReturnAsset;

  /// No description provided for @operationMenuStockOpname.
  ///
  /// In en, this message translates to:
  /// **'Stock Opname'**
  String get operationMenuStockOpname;

  /// No description provided for @operationMenuStockIn.
  ///
  /// In en, this message translates to:
  /// **'Stok Masuk'**
  String get operationMenuStockIn;

  /// No description provided for @operationMenuStockPlacement.
  ///
  /// In en, this message translates to:
  /// **'Penempatan Stok Pada Bin'**
  String get operationMenuStockPlacement;

  /// No description provided for @operationMenuStockRequest.
  ///
  /// In en, this message translates to:
  /// **'Permintaan Stok'**
  String get operationMenuStockRequest;

  /// No description provided for @operationMenuStockRequestApproval.
  ///
  /// In en, this message translates to:
  /// **'Persetujuan Permintaan Stok'**
  String get operationMenuStockRequestApproval;

  /// No description provided for @operationMenuStockFulfillment.
  ///
  /// In en, this message translates to:
  /// **'Pengeluaran Stok Atas Permintaan'**
  String get operationMenuStockFulfillment;

  /// No description provided for @operationMenuStockWriteOff.
  ///
  /// In en, this message translates to:
  /// **'Pengeluaran Stok Atas Kadaluarsa/Rusak'**
  String get operationMenuStockWriteOff;

  /// No description provided for @operationMenuStockWriteOffApproval.
  ///
  /// In en, this message translates to:
  /// **'Persetujuan Pengeluaran Stok Atas Kadaluarsa/Rusak'**
  String get operationMenuStockWriteOffApproval;

  /// No description provided for @operationMenuBuildingReference.
  ///
  /// In en, this message translates to:
  /// **'Tabel Referensi Bangunan'**
  String get operationMenuBuildingReference;

  /// No description provided for @operationMenuBinsReference.
  ///
  /// In en, this message translates to:
  /// **'Tabel Referensi Bins'**
  String get operationMenuBinsReference;

  /// No description provided for @operationReportsMenuWorkHistory.
  ///
  /// In en, this message translates to:
  /// **'Riwayat Pekerjaan'**
  String get operationReportsMenuWorkHistory;

  /// No description provided for @operationReportsMenuTaskHistory.
  ///
  /// In en, this message translates to:
  /// **'Riwayat Tugas'**
  String get operationReportsMenuTaskHistory;

  /// No description provided for @operationReportsMenuTaskReportHistory.
  ///
  /// In en, this message translates to:
  /// **'Riwayat Laporan Tugas'**
  String get operationReportsMenuTaskReportHistory;

  /// No description provided for @operationReportsMenuAttendanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Riwayat Absensi'**
  String get operationReportsMenuAttendanceHistory;

  /// No description provided for @operationBottomNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get operationBottomNavHome;

  /// No description provided for @operationBottomNavAttendance.
  ///
  /// In en, this message translates to:
  /// **'Absensi'**
  String get operationBottomNavAttendance;

  /// No description provided for @operationBottomNavTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get operationBottomNavTasks;

  /// No description provided for @operationBottomNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get operationBottomNavProfile;

  /// No description provided for @operationStatsNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get operationStatsNew;

  /// No description provided for @operationStatsOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get operationStatsOn;

  /// No description provided for @operationStatsUrg.
  ///
  /// In en, this message translates to:
  /// **'Urg'**
  String get operationStatsUrg;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'minutes ago'**
  String get minutesAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String get hoursAgo;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgo;

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'weeks ago'**
  String get weeksAgo;

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'months ago'**
  String get monthsAgo;

  /// No description provided for @yearsAgo.
  ///
  /// In en, this message translates to:
  /// **'years ago'**
  String get yearsAgo;

  /// No description provided for @att_statusOnDuty.
  ///
  /// In en, this message translates to:
  /// **'STATUS: ON DUTY'**
  String get att_statusOnDuty;

  /// No description provided for @att_statusSelfAttendance.
  ///
  /// In en, this message translates to:
  /// **'SELF ATTENDANCE'**
  String get att_statusSelfAttendance;

  /// No description provided for @att_trackingInfo.
  ///
  /// In en, this message translates to:
  /// **'📍 Location will be recorded for team coordination'**
  String get att_trackingInfo;

  /// No description provided for @att_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get att_loading;

  /// No description provided for @att_findingLocation.
  ///
  /// In en, this message translates to:
  /// **'Finding location...'**
  String get att_findingLocation;

  /// No description provided for @att_checkInSuccess.
  ///
  /// In en, this message translates to:
  /// **'Check In Successful! Tracking started.'**
  String get att_checkInSuccess;

  /// No description provided for @att_checkOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Shift ended successfully! You are no longer in location coordination with the team. Have a good rest!'**
  String get att_checkOutSuccess;

  /// No description provided for @att_endShift.
  ///
  /// In en, this message translates to:
  /// **'END SHIFT'**
  String get att_endShift;

  /// No description provided for @att_startShift.
  ///
  /// In en, this message translates to:
  /// **'START SHIFT'**
  String get att_startShift;

  /// No description provided for @att_errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get att_errorPrefix;

  /// No description provided for @att_checkActiveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to check active status: '**
  String get att_checkActiveFailed;

  /// No description provided for @att_fetchShiftsError.
  ///
  /// In en, this message translates to:
  /// **'Error fetching shifts: '**
  String get att_fetchShiftsError;

  /// No description provided for @att_cameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera Error: '**
  String get att_cameraError;

  /// No description provided for @att_locationError.
  ///
  /// In en, this message translates to:
  /// **'Location Error: '**
  String get att_locationError;

  /// No description provided for @att_setupError.
  ///
  /// In en, this message translates to:
  /// **'Setup Error: '**
  String get att_setupError;

  /// No description provided for @task_title.
  ///
  /// In en, this message translates to:
  /// **'TASK LIST'**
  String get task_title;

  /// No description provided for @task_empty.
  ///
  /// In en, this message translates to:
  /// **'Queue is empty 🚀'**
  String get task_empty;

  /// No description provided for @task_error.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get task_error;

  /// No description provided for @task_from.
  ///
  /// In en, this message translates to:
  /// **'FROM'**
  String get task_from;

  /// No description provided for @task_to.
  ///
  /// In en, this message translates to:
  /// **'TO'**
  String get task_to;

  /// No description provided for @task_statusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get task_statusPending;

  /// No description provided for @task_statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'ACCEPTED'**
  String get task_statusAccepted;

  /// No description provided for @task_statusDone.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get task_statusDone;

  /// No description provided for @task_defaultFromRoom.
  ///
  /// In en, this message translates to:
  /// **'Location A'**
  String get task_defaultFromRoom;

  /// No description provided for @task_defaultToRoom.
  ///
  /// In en, this message translates to:
  /// **'Location B'**
  String get task_defaultToRoom;

  /// No description provided for @task_defaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get task_defaultTitle;

  /// No description provided for @taskDetail_appBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Execution Detail'**
  String get taskDetail_appBarTitle;

  /// No description provided for @taskDetail_acceptButton.
  ///
  /// In en, this message translates to:
  /// **'ACCEPT TASK'**
  String get taskDetail_acceptButton;

  /// No description provided for @taskDetail_notAcceptedMessage.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t accepted this task. Click the button below to start working.'**
  String get taskDetail_notAcceptedMessage;

  /// No description provided for @taskDetail_infoTitle.
  ///
  /// In en, this message translates to:
  /// **'TASK INFORMATION'**
  String get taskDetail_infoTitle;

  /// No description provided for @taskDetail_routeLabel.
  ///
  /// In en, this message translates to:
  /// **'Route: '**
  String get taskDetail_routeLabel;

  /// No description provided for @taskDetail_priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority: '**
  String get taskDetail_priorityLabel;

  /// No description provided for @taskDetail_requiresPhoto.
  ///
  /// In en, this message translates to:
  /// **'Requires photo proof'**
  String get taskDetail_requiresPhoto;

  /// No description provided for @taskDetail_locationTitle.
  ///
  /// In en, this message translates to:
  /// **'COMPLETION LOCATION'**
  String get taskDetail_locationTitle;

  /// No description provided for @taskDetail_locationNotTaken.
  ///
  /// In en, this message translates to:
  /// **'Location not taken'**
  String get taskDetail_locationNotTaken;

  /// No description provided for @taskDetail_takeLocationButton.
  ///
  /// In en, this message translates to:
  /// **'TAKE CURRENT LOCATION'**
  String get taskDetail_takeLocationButton;

  /// No description provided for @taskDetail_takingLocation.
  ///
  /// In en, this message translates to:
  /// **'TAKING LOCATION...'**
  String get taskDetail_takingLocation;

  /// No description provided for @taskDetail_completionTitle.
  ///
  /// In en, this message translates to:
  /// **'TASK COMPLETION'**
  String get taskDetail_completionTitle;

  /// No description provided for @taskDetail_completionHint.
  ///
  /// In en, this message translates to:
  /// **'Write completion notes...'**
  String get taskDetail_completionHint;

  /// No description provided for @taskDetail_failButton.
  ///
  /// In en, this message translates to:
  /// **'FAIL'**
  String get taskDetail_failButton;

  /// No description provided for @taskDetail_successButton.
  ///
  /// In en, this message translates to:
  /// **'COMPLETE'**
  String get taskDetail_successButton;

  /// No description provided for @taskDetail_acceptSuccess.
  ///
  /// In en, this message translates to:
  /// **'Task accepted, please work on it'**
  String get taskDetail_acceptSuccess;

  /// No description provided for @taskDetail_acceptFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to accept task: '**
  String get taskDetail_acceptFailed;

  /// No description provided for @taskDetail_locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission required'**
  String get taskDetail_locationPermissionRequired;

  /// No description provided for @taskDetail_locationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Location: '**
  String get taskDetail_locationSuccess;

  /// No description provided for @taskDetail_locationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get location: '**
  String get taskDetail_locationFailed;

  /// No description provided for @taskDetail_incompleteData.
  ///
  /// In en, this message translates to:
  /// **'Please complete photo, category, and description!'**
  String get taskDetail_incompleteData;

  /// No description provided for @taskDetail_reportSent.
  ///
  /// In en, this message translates to:
  /// **'Issue report sent!'**
  String get taskDetail_reportSent;

  /// No description provided for @taskDetail_reportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send report: '**
  String get taskDetail_reportFailed;

  /// No description provided for @taskDetail_photoRequired.
  ///
  /// In en, this message translates to:
  /// **'This task requires photo proof! Please take a photo first.'**
  String get taskDetail_photoRequired;

  /// No description provided for @taskDetail_taskSuccess.
  ///
  /// In en, this message translates to:
  /// **'Task completed! ✅'**
  String get taskDetail_taskSuccess;

  /// No description provided for @taskDetail_taskFailed.
  ///
  /// In en, this message translates to:
  /// **'Task failed ❌'**
  String get taskDetail_taskFailed;

  /// No description provided for @taskDetail_clickToTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Click to take photo'**
  String get taskDetail_clickToTakePhoto;

  /// No description provided for @taskDetail_reportIssueTitle.
  ///
  /// In en, this message translates to:
  /// **'REPORT ISSUE'**
  String get taskDetail_reportIssueTitle;

  /// No description provided for @taskDetail_reportIssueSubtext.
  ///
  /// In en, this message translates to:
  /// **'Found technical/field problem?'**
  String get taskDetail_reportIssueSubtext;

  /// No description provided for @taskDetail_issueCategory.
  ///
  /// In en, this message translates to:
  /// **'Issue Category'**
  String get taskDetail_issueCategory;

  /// No description provided for @taskDetail_issueDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Issue description...'**
  String get taskDetail_issueDescriptionHint;

  /// No description provided for @taskDetail_sendReportButton.
  ///
  /// In en, this message translates to:
  /// **'SEND ISSUE REPORT'**
  String get taskDetail_sendReportButton;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'MY PROFILE'**
  String get profile_title;

  /// No description provided for @profile_avatarSuccess.
  ///
  /// In en, this message translates to:
  /// **'Photo updated'**
  String get profile_avatarSuccess;

  /// No description provided for @profile_avatarFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload photo'**
  String get profile_avatarFailed;

  /// No description provided for @profile_saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully'**
  String get profile_saveSuccess;

  /// No description provided for @profile_saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: '**
  String get profile_saveFailed;

  /// No description provided for @profile_personalData.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL DATA'**
  String get profile_personalData;

  /// No description provided for @profile_fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profile_fullName;

  /// No description provided for @profile_nik.
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get profile_nik;

  /// No description provided for @profile_gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profile_gender;

  /// No description provided for @profile_phone.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Number'**
  String get profile_phone;

  /// No description provided for @profile_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profile_address;

  /// No description provided for @profile_male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get profile_male;

  /// No description provided for @profile_female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get profile_female;

  /// No description provided for @profile_workInfo.
  ///
  /// In en, this message translates to:
  /// **'WORK INFORMATION'**
  String get profile_workInfo;

  /// No description provided for @profile_unit.
  ///
  /// In en, this message translates to:
  /// **'Work Unit'**
  String get profile_unit;

  /// No description provided for @profile_position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get profile_position;

  /// No description provided for @profile_shift.
  ///
  /// In en, this message translates to:
  /// **'Default Shift'**
  String get profile_shift;

  /// No description provided for @profile_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profile_logout;

  /// No description provided for @profile_idPrefix.
  ///
  /// In en, this message translates to:
  /// **'ID: '**
  String get profile_idPrefix;

  /// No description provided for @dutyNote_title.
  ///
  /// In en, this message translates to:
  /// **'Duty Note'**
  String get dutyNote_title;

  /// No description provided for @dutyNote_infoText.
  ///
  /// In en, this message translates to:
  /// **'Record your work activities today. Each note will earn +5 points.'**
  String get dutyNote_infoText;

  /// No description provided for @dutyNote_label.
  ///
  /// In en, this message translates to:
  /// **'Work Notes'**
  String get dutyNote_label;

  /// No description provided for @dutyNote_hint.
  ///
  /// In en, this message translates to:
  /// **'Examples:\n• Visiting patients in VIP room\n• Moving patients from room A to room B\n• Cleaning and sterilizing equipment'**
  String get dutyNote_hint;

  /// No description provided for @dutyNote_saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Note'**
  String get dutyNote_saveButton;

  /// No description provided for @dutyNote_emptyError.
  ///
  /// In en, this message translates to:
  /// **'Note cannot be empty'**
  String get dutyNote_emptyError;

  /// No description provided for @dutyNote_sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get dutyNote_sessionExpired;

  /// No description provided for @dutyNote_notCheckedInError.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t checked in today. Please check in first.'**
  String get dutyNote_notCheckedInError;

  /// No description provided for @dutyNote_saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Note saved successfully'**
  String get dutyNote_saveSuccess;

  /// No description provided for @todo_title.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S TO DO'**
  String get todo_title;

  /// No description provided for @todo_loadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load To Do'**
  String get todo_loadError;

  /// No description provided for @todo_empty.
  ///
  /// In en, this message translates to:
  /// **'No To Do for today'**
  String get todo_empty;

  /// No description provided for @todo_completedMessage.
  ///
  /// In en, this message translates to:
  /// **'To Do completed'**
  String get todo_completedMessage;

  /// No description provided for @stats_title.
  ///
  /// In en, this message translates to:
  /// **'This Month\'s Performance'**
  String get stats_title;

  /// No description provided for @stats_points.
  ///
  /// In en, this message translates to:
  /// **' points'**
  String get stats_points;

  /// No description provided for @stats_fatiguePrefix.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get stats_fatiguePrefix;

  /// No description provided for @stats_fatigueLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get stats_fatigueLow;

  /// No description provided for @stats_fatigueMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get stats_fatigueMedium;

  /// No description provided for @stats_fatigueHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get stats_fatigueHigh;

  /// No description provided for @stats_fatigueCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get stats_fatigueCritical;

  /// No description provided for @stats_remainingNeeded.
  ///
  /// In en, this message translates to:
  /// **'Need {remaining} more points to reach target'**
  String stats_remainingNeeded(Object remaining);

  /// No description provided for @stats_targetAchieved.
  ///
  /// In en, this message translates to:
  /// **'Target achieved! 🎉'**
  String get stats_targetAchieved;

  /// No description provided for @stats_catAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get stats_catAttendance;

  /// No description provided for @stats_catTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get stats_catTask;

  /// No description provided for @stats_catIncident.
  ///
  /// In en, this message translates to:
  /// **'Incident'**
  String get stats_catIncident;

  /// No description provided for @stats_catInspection.
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get stats_catInspection;

  /// No description provided for @stats_catOpname.
  ///
  /// In en, this message translates to:
  /// **'Opname'**
  String get stats_catOpname;

  /// No description provided for @stats_catWellbeing.
  ///
  /// In en, this message translates to:
  /// **'Wellbeing'**
  String get stats_catWellbeing;

  /// No description provided for @stats_catDutyNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get stats_catDutyNote;

  /// No description provided for @stats_remainingNeededPrefix.
  ///
  /// In en, this message translates to:
  /// **'Need'**
  String get stats_remainingNeededPrefix;

  /// No description provided for @stats_remainingNeededSuffix.
  ///
  /// In en, this message translates to:
  /// **'more points to reach target'**
  String get stats_remainingNeededSuffix;

  /// No description provided for @roster_dayOff.
  ///
  /// In en, this message translates to:
  /// **'DAY OFF'**
  String get roster_dayOff;

  /// No description provided for @roster_todaySchedule.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S SCHEDULE'**
  String get roster_todaySchedule;

  /// No description provided for @roster_fatiguePrefix.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get roster_fatiguePrefix;

  /// No description provided for @roster_locationNotSet.
  ///
  /// In en, this message translates to:
  /// **'Location not set'**
  String get roster_locationNotSet;

  /// No description provided for @roster_requiredEquipment.
  ///
  /// In en, this message translates to:
  /// **'Required Equipment:'**
  String get roster_requiredEquipment;

  /// No description provided for @roster_restMessage.
  ///
  /// In en, this message translates to:
  /// **'Have a good rest!'**
  String get roster_restMessage;

  /// No description provided for @roster_nextSchedule.
  ///
  /// In en, this message translates to:
  /// **'NEXT SCHEDULE'**
  String get roster_nextSchedule;

  /// No description provided for @roster_emptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No schedule for today. Please contact your supervisor.'**
  String get roster_emptyMessage;

  /// No description provided for @opMenuReportIncident.
  ///
  /// In en, this message translates to:
  /// **'Report Incident'**
  String get opMenuReportIncident;

  /// No description provided for @opMenuRegisterPeopleRfid.
  ///
  /// In en, this message translates to:
  /// **'Register People & RFID'**
  String get opMenuRegisterPeopleRfid;

  /// No description provided for @opMenuBedAssignment.
  ///
  /// In en, this message translates to:
  /// **'Bed Assignment'**
  String get opMenuBedAssignment;

  /// No description provided for @opMenuBedUnassignment.
  ///
  /// In en, this message translates to:
  /// **'Bed Unassignment'**
  String get opMenuBedUnassignment;

  /// No description provided for @opMenuCheckOutPeople.
  ///
  /// In en, this message translates to:
  /// **'Check Out People'**
  String get opMenuCheckOutPeople;

  /// No description provided for @opMenuInitialAsset.
  ///
  /// In en, this message translates to:
  /// **'Initial Asset Setup'**
  String get opMenuInitialAsset;

  /// No description provided for @opMenuRoutineAssetInspection.
  ///
  /// In en, this message translates to:
  /// **'Routine Asset Inspection'**
  String get opMenuRoutineAssetInspection;

  /// No description provided for @opMenuInitialStock.
  ///
  /// In en, this message translates to:
  /// **'Initial Stock Setup'**
  String get opMenuInitialStock;

  /// No description provided for @opMenuAssetRequest.
  ///
  /// In en, this message translates to:
  /// **'Asset Request'**
  String get opMenuAssetRequest;

  /// No description provided for @opMenuReturnAsset.
  ///
  /// In en, this message translates to:
  /// **'Return Asset'**
  String get opMenuReturnAsset;

  /// No description provided for @opMenuStockOpname.
  ///
  /// In en, this message translates to:
  /// **'Stock Opname'**
  String get opMenuStockOpname;

  /// No description provided for @opMenuStockIn.
  ///
  /// In en, this message translates to:
  /// **'Stock In'**
  String get opMenuStockIn;

  /// No description provided for @opMenuStockPlacement.
  ///
  /// In en, this message translates to:
  /// **'Stock Placement to Bin'**
  String get opMenuStockPlacement;

  /// No description provided for @opMenuStockRequest.
  ///
  /// In en, this message translates to:
  /// **'Stock Request'**
  String get opMenuStockRequest;

  /// No description provided for @opMenuStockRequestApproval.
  ///
  /// In en, this message translates to:
  /// **'Stock Request Approval'**
  String get opMenuStockRequestApproval;

  /// No description provided for @opMenuStockFulfillment.
  ///
  /// In en, this message translates to:
  /// **'Stock Fulfillment'**
  String get opMenuStockFulfillment;

  /// No description provided for @opMenuStockWriteOff.
  ///
  /// In en, this message translates to:
  /// **'Stock Write Off (Expired/Damaged)'**
  String get opMenuStockWriteOff;

  /// No description provided for @opMenuStockWriteOffApproval.
  ///
  /// In en, this message translates to:
  /// **'Stock Write Off Approval'**
  String get opMenuStockWriteOffApproval;

  /// No description provided for @opMenuBuildingReference.
  ///
  /// In en, this message translates to:
  /// **'Building Reference Table'**
  String get opMenuBuildingReference;

  /// No description provided for @opMenuBinsReference.
  ///
  /// In en, this message translates to:
  /// **'Bins Reference Table'**
  String get opMenuBinsReference;

  /// No description provided for @opMenuWorkHistory.
  ///
  /// In en, this message translates to:
  /// **'Work History'**
  String get opMenuWorkHistory;

  /// No description provided for @opMenuTaskHistory.
  ///
  /// In en, this message translates to:
  /// **'Task History'**
  String get opMenuTaskHistory;

  /// No description provided for @opMenuTaskReportHistory.
  ///
  /// In en, this message translates to:
  /// **'Task Report History'**
  String get opMenuTaskReportHistory;

  /// No description provided for @opMenuAttendanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Attendance History'**
  String get opMenuAttendanceHistory;

  /// No description provided for @admin_logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get admin_logoutConfirmTitle;

  /// No description provided for @admin_logoutConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get admin_logoutConfirmContent;

  /// No description provided for @admin_logoutCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get admin_logoutCancel;

  /// No description provided for @admin_logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get admin_logoutConfirm;

  /// No description provided for @admin_sidebarMenuMasterData.
  ///
  /// In en, this message translates to:
  /// **'MASTER DATA'**
  String get admin_sidebarMenuMasterData;

  /// No description provided for @admin_sidebarMenuAssetManagement.
  ///
  /// In en, this message translates to:
  /// **'ASSET MANAGEMENT'**
  String get admin_sidebarMenuAssetManagement;

  /// No description provided for @admin_sidebarMenuStockInventory.
  ///
  /// In en, this message translates to:
  /// **'STOCK/INVENTORY MANAGEMENT'**
  String get admin_sidebarMenuStockInventory;

  /// No description provided for @admin_sidebarMenuOperational.
  ///
  /// In en, this message translates to:
  /// **'OPERATIONAL'**
  String get admin_sidebarMenuOperational;

  /// No description provided for @admin_sidebarMenuReferenceTables.
  ///
  /// In en, this message translates to:
  /// **'REFERENCE TABLES'**
  String get admin_sidebarMenuReferenceTables;

  /// No description provided for @admin_sidebarMenuSystem.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM'**
  String get admin_sidebarMenuSystem;

  /// No description provided for @admin_sidebarSubMenuAssetRef.
  ///
  /// In en, this message translates to:
  /// **'ASSET REF'**
  String get admin_sidebarSubMenuAssetRef;

  /// No description provided for @admin_sidebarSubMenuStockRef.
  ///
  /// In en, this message translates to:
  /// **'STOCK REF'**
  String get admin_sidebarSubMenuStockRef;

  /// No description provided for @admin_sidebarSubMenuLocationHierarchy.
  ///
  /// In en, this message translates to:
  /// **'LOCATION HIERARCHY'**
  String get admin_sidebarSubMenuLocationHierarchy;

  /// No description provided for @admin_sidebarSubMenuWarehouseHierarchy.
  ///
  /// In en, this message translates to:
  /// **'WAREHOUSE HIERARCHY'**
  String get admin_sidebarSubMenuWarehouseHierarchy;

  /// No description provided for @admin_sidebarSubMenuGeneralRef.
  ///
  /// In en, this message translates to:
  /// **'GENERAL & EMPLOYEE REF'**
  String get admin_sidebarSubMenuGeneralRef;

  /// No description provided for @admin_menuEmployees.
  ///
  /// In en, this message translates to:
  /// **'Employees Data'**
  String get admin_menuEmployees;

  /// No description provided for @admin_menuEmployeeQualifications.
  ///
  /// In en, this message translates to:
  /// **'Employee Qualifications'**
  String get admin_menuEmployeeQualifications;

  /// No description provided for @admin_menuScoringCategories.
  ///
  /// In en, this message translates to:
  /// **'Scoring Categories'**
  String get admin_menuScoringCategories;

  /// No description provided for @admin_menuLeaveTypes.
  ///
  /// In en, this message translates to:
  /// **'Leave Types'**
  String get admin_menuLeaveTypes;

  /// No description provided for @admin_menuIncidentCategories.
  ///
  /// In en, this message translates to:
  /// **'Incident Categories'**
  String get admin_menuIncidentCategories;

  /// No description provided for @admin_menuPeopleCategories.
  ///
  /// In en, this message translates to:
  /// **'People Categories'**
  String get admin_menuPeopleCategories;

  /// No description provided for @admin_menuPositions.
  ///
  /// In en, this message translates to:
  /// **'Positions'**
  String get admin_menuPositions;

  /// No description provided for @admin_menuReportCategories.
  ///
  /// In en, this message translates to:
  /// **'Report Categories'**
  String get admin_menuReportCategories;

  /// No description provided for @admin_menuShifts.
  ///
  /// In en, this message translates to:
  /// **'Shifts'**
  String get admin_menuShifts;

  /// No description provided for @admin_menuAssets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get admin_menuAssets;

  /// No description provided for @admin_menuAssetVerification.
  ///
  /// In en, this message translates to:
  /// **'Asset Usage Verification'**
  String get admin_menuAssetVerification;

  /// No description provided for @admin_menuAssetReport.
  ///
  /// In en, this message translates to:
  /// **'Asset Report'**
  String get admin_menuAssetReport;

  /// No description provided for @admin_menuBeds.
  ///
  /// In en, this message translates to:
  /// **'Bed Management'**
  String get admin_menuBeds;

  /// No description provided for @admin_menuStockList.
  ///
  /// In en, this message translates to:
  /// **'Stock List'**
  String get admin_menuStockList;

  /// No description provided for @admin_menuStockIn.
  ///
  /// In en, this message translates to:
  /// **'Stock In'**
  String get admin_menuStockIn;

  /// No description provided for @admin_menuPendingPutAway.
  ///
  /// In en, this message translates to:
  /// **'Pending Put Away'**
  String get admin_menuPendingPutAway;

  /// No description provided for @admin_menuStockWriteOffApproval.
  ///
  /// In en, this message translates to:
  /// **'Stock Write Off Approval'**
  String get admin_menuStockWriteOffApproval;

  /// No description provided for @admin_menuStockMutation.
  ///
  /// In en, this message translates to:
  /// **'Stock Mutation'**
  String get admin_menuStockMutation;

  /// No description provided for @admin_menuPeopleRegistration.
  ///
  /// In en, this message translates to:
  /// **'People & RFID Registration'**
  String get admin_menuPeopleRegistration;

  /// No description provided for @admin_menuBedAssignment.
  ///
  /// In en, this message translates to:
  /// **'Patient Bed Assignment'**
  String get admin_menuBedAssignment;

  /// No description provided for @admin_menuBedUnassignment.
  ///
  /// In en, this message translates to:
  /// **'Bed Unassignment'**
  String get admin_menuBedUnassignment;

  /// No description provided for @admin_menuPeopleCheckout.
  ///
  /// In en, this message translates to:
  /// **'People Checkout (RFID)'**
  String get admin_menuPeopleCheckout;

  /// No description provided for @admin_menuRoster.
  ///
  /// In en, this message translates to:
  /// **'Employee Scheduling'**
  String get admin_menuRoster;

  /// No description provided for @admin_menuAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Employee Announcements'**
  String get admin_menuAnnouncements;

  /// No description provided for @admin_menuTaskAssignment.
  ///
  /// In en, this message translates to:
  /// **'Task Assignment'**
  String get admin_menuTaskAssignment;

  /// No description provided for @admin_menuTodo.
  ///
  /// In en, this message translates to:
  /// **'To Do'**
  String get admin_menuTodo;

  /// No description provided for @admin_menuAssetCategories.
  ///
  /// In en, this message translates to:
  /// **'Asset Categories'**
  String get admin_menuAssetCategories;

  /// No description provided for @admin_menuAssetSubCategories.
  ///
  /// In en, this message translates to:
  /// **'Asset Sub-Categories'**
  String get admin_menuAssetSubCategories;

  /// No description provided for @admin_menuAssetTypes.
  ///
  /// In en, this message translates to:
  /// **'Asset Types'**
  String get admin_menuAssetTypes;

  /// No description provided for @admin_menuAssetDangerLevels.
  ///
  /// In en, this message translates to:
  /// **'Asset Danger Levels'**
  String get admin_menuAssetDangerLevels;

  /// No description provided for @admin_menuStockCategories.
  ///
  /// In en, this message translates to:
  /// **'Stock Categories'**
  String get admin_menuStockCategories;

  /// No description provided for @admin_menuStockSubCategories.
  ///
  /// In en, this message translates to:
  /// **'Stock Sub-Categories'**
  String get admin_menuStockSubCategories;

  /// No description provided for @admin_menuStockTypes.
  ///
  /// In en, this message translates to:
  /// **'Stock Types'**
  String get admin_menuStockTypes;

  /// No description provided for @admin_menuBuildingFunctions.
  ///
  /// In en, this message translates to:
  /// **'Building Functions'**
  String get admin_menuBuildingFunctions;

  /// No description provided for @admin_menuRoomCategories.
  ///
  /// In en, this message translates to:
  /// **'Room Categories'**
  String get admin_menuRoomCategories;

  /// No description provided for @admin_menuBuildings.
  ///
  /// In en, this message translates to:
  /// **'Buildings'**
  String get admin_menuBuildings;

  /// No description provided for @admin_menuFloors.
  ///
  /// In en, this message translates to:
  /// **'Floors'**
  String get admin_menuFloors;

  /// No description provided for @admin_menuRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get admin_menuRooms;

  /// No description provided for @admin_menuWarehouses.
  ///
  /// In en, this message translates to:
  /// **'Warehouses'**
  String get admin_menuWarehouses;

  /// No description provided for @admin_menuZones.
  ///
  /// In en, this message translates to:
  /// **'Storage Zones'**
  String get admin_menuZones;

  /// No description provided for @admin_menuRacks.
  ///
  /// In en, this message translates to:
  /// **'Racks'**
  String get admin_menuRacks;

  /// No description provided for @admin_menuShelves.
  ///
  /// In en, this message translates to:
  /// **'Shelves'**
  String get admin_menuShelves;

  /// No description provided for @admin_menuBins.
  ///
  /// In en, this message translates to:
  /// **'Bins'**
  String get admin_menuBins;

  /// No description provided for @admin_menuUnits.
  ///
  /// In en, this message translates to:
  /// **'Units/Departments'**
  String get admin_menuUnits;

  /// No description provided for @admin_menuLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get admin_menuLogout;

  /// No description provided for @admin_selectMenuHint.
  ///
  /// In en, this message translates to:
  /// **'Select a menu from sidebar'**
  String get admin_selectMenuHint;

  /// No description provided for @admin_footerDevelopedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed By: PLATFORM PELAYANAN TERBAIK'**
  String get admin_footerDevelopedBy;

  /// No description provided for @admin_footerDistributedBy.
  ///
  /// In en, this message translates to:
  /// **'Distributed By: PT. REKAMITRA'**
  String get admin_footerDistributedBy;

  /// No description provided for @admin_footerYearCountry.
  ///
  /// In en, this message translates to:
  /// **'2026 - Indonesia'**
  String get admin_footerYearCountry;

  /// No description provided for @employee_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, NIK, or employee ID...'**
  String get employee_searchHint;

  /// No description provided for @employee_addButton.
  ///
  /// In en, this message translates to:
  /// **'Add Employee'**
  String get employee_addButton;

  /// No description provided for @employee_addNewTitle.
  ///
  /// In en, this message translates to:
  /// **'ADD NEW EMPLOYEE'**
  String get employee_addNewTitle;

  /// No description provided for @employee_editTitle.
  ///
  /// In en, this message translates to:
  /// **'EDIT EMPLOYEE'**
  String get employee_editTitle;

  /// No description provided for @employee_closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get employee_closeButton;

  /// No description provided for @employee_cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get employee_cancelButton;

  /// No description provided for @employee_saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get employee_saveButton;

  /// No description provided for @employee_deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get employee_deleteConfirmTitle;

  /// No description provided for @employee_deleteConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this employee?'**
  String get employee_deleteConfirmContent;

  /// No description provided for @employee_deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get employee_deleteButton;

  /// No description provided for @employee_fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name *'**
  String get employee_fullNameLabel;

  /// No description provided for @employee_fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Employee full name'**
  String get employee_fullNameHint;

  /// No description provided for @employee_roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role *'**
  String get employee_roleLabel;

  /// No description provided for @employee_employeeIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get employee_employeeIdLabel;

  /// No description provided for @employee_employeeIdHint.
  ///
  /// In en, this message translates to:
  /// **'Employee ID number'**
  String get employee_employeeIdHint;

  /// No description provided for @employee_nikLabel.
  ///
  /// In en, this message translates to:
  /// **'NIK'**
  String get employee_nikLabel;

  /// No description provided for @employee_nikHint.
  ///
  /// In en, this message translates to:
  /// **'National ID number'**
  String get employee_nikHint;

  /// No description provided for @employee_phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get employee_phoneLabel;

  /// No description provided for @employee_phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Active mobile number'**
  String get employee_phoneHint;

  /// No description provided for @employee_addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get employee_addressLabel;

  /// No description provided for @employee_addressHint.
  ///
  /// In en, this message translates to:
  /// **'Complete address'**
  String get employee_addressHint;

  /// No description provided for @employee_unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get employee_unitLabel;

  /// No description provided for @employee_unitHint.
  ///
  /// In en, this message translates to:
  /// **'Select unit (optional)'**
  String get employee_unitHint;

  /// No description provided for @employee_positionLabel.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get employee_positionLabel;

  /// No description provided for @employee_positionHint.
  ///
  /// In en, this message translates to:
  /// **'Select position (optional)'**
  String get employee_positionHint;

  /// No description provided for @employee_shiftLabel.
  ///
  /// In en, this message translates to:
  /// **'Default Shift'**
  String get employee_shiftLabel;

  /// No description provided for @employee_shiftHint.
  ///
  /// In en, this message translates to:
  /// **'Select default shift (optional)'**
  String get employee_shiftHint;

  /// No description provided for @employee_statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get employee_statusLabel;

  /// No description provided for @employee_joinDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Join Date'**
  String get employee_joinDateLabel;

  /// No description provided for @employee_joinDateHint.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get employee_joinDateHint;

  /// No description provided for @employee_accessFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Feature Access'**
  String get employee_accessFeaturesTitle;

  /// No description provided for @employee_permissionAssetInitial.
  ///
  /// In en, this message translates to:
  /// **'Asset Initial'**
  String get employee_permissionAssetInitial;

  /// No description provided for @employee_permissionAssetInspection.
  ///
  /// In en, this message translates to:
  /// **'Asset Inspection'**
  String get employee_permissionAssetInspection;

  /// No description provided for @employee_permissionStockInitial.
  ///
  /// In en, this message translates to:
  /// **'Stock Initial'**
  String get employee_permissionStockInitial;

  /// No description provided for @employee_permissionStockOpname.
  ///
  /// In en, this message translates to:
  /// **'Stock Opname'**
  String get employee_permissionStockOpname;

  /// No description provided for @employee_permissionRegisterPeople.
  ///
  /// In en, this message translates to:
  /// **'Register People & RFID'**
  String get employee_permissionRegisterPeople;

  /// No description provided for @employee_permissionBedAssignment.
  ///
  /// In en, this message translates to:
  /// **'Bed Assignment'**
  String get employee_permissionBedAssignment;

  /// No description provided for @employee_permissionBedUnassignment.
  ///
  /// In en, this message translates to:
  /// **'Bed Unassignment'**
  String get employee_permissionBedUnassignment;

  /// No description provided for @employee_permissionCheckoutPeople.
  ///
  /// In en, this message translates to:
  /// **'Check Out People'**
  String get employee_permissionCheckoutPeople;

  /// No description provided for @employee_permissionAssetRequest.
  ///
  /// In en, this message translates to:
  /// **'Asset Request'**
  String get employee_permissionAssetRequest;

  /// No description provided for @employee_permissionReturnAsset.
  ///
  /// In en, this message translates to:
  /// **'Return Asset'**
  String get employee_permissionReturnAsset;

  /// No description provided for @employee_permissionStockIn.
  ///
  /// In en, this message translates to:
  /// **'Stock In'**
  String get employee_permissionStockIn;

  /// No description provided for @employee_permissionStockPlacement.
  ///
  /// In en, this message translates to:
  /// **'Stock Placement'**
  String get employee_permissionStockPlacement;

  /// No description provided for @employee_permissionStockRequest.
  ///
  /// In en, this message translates to:
  /// **'Stock Request'**
  String get employee_permissionStockRequest;

  /// No description provided for @employee_permissionStockRequestApproval.
  ///
  /// In en, this message translates to:
  /// **'Stock Request Approval'**
  String get employee_permissionStockRequestApproval;

  /// No description provided for @employee_permissionStockFulfillment.
  ///
  /// In en, this message translates to:
  /// **'Stock Fulfillment'**
  String get employee_permissionStockFulfillment;

  /// No description provided for @employee_permissionStockWriteOff.
  ///
  /// In en, this message translates to:
  /// **'Stock Write Off'**
  String get employee_permissionStockWriteOff;

  /// No description provided for @employee_permissionStockWriteOffApproval.
  ///
  /// In en, this message translates to:
  /// **'Stock Write Off Approval'**
  String get employee_permissionStockWriteOffApproval;

  /// No description provided for @employee_permissionBuildingReference.
  ///
  /// In en, this message translates to:
  /// **'Building Reference'**
  String get employee_permissionBuildingReference;

  /// No description provided for @employee_permissionBinsReference.
  ///
  /// In en, this message translates to:
  /// **'Bins Reference'**
  String get employee_permissionBinsReference;

  /// No description provided for @employee_accountApproved.
  ///
  /// In en, this message translates to:
  /// **'Account Active (Approved)'**
  String get employee_accountApproved;

  /// No description provided for @employee_avatarInfo.
  ///
  /// In en, this message translates to:
  /// **'Profile photo from system'**
  String get employee_avatarInfo;

  /// No description provided for @employee_nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get employee_nameRequired;

  /// No description provided for @employee_saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Employee saved successfully'**
  String get employee_saveSuccess;

  /// No description provided for @employee_saveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save employee: '**
  String get employee_saveError;

  /// No description provided for @employee_deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Employee deleted successfully'**
  String get employee_deleteSuccess;

  /// No description provided for @employee_deleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete employee: '**
  String get employee_deleteError;

  /// No description provided for @employee_activeChip.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get employee_activeChip;

  /// No description provided for @employee_idPrefix.
  ///
  /// In en, this message translates to:
  /// **'ID: '**
  String get employee_idPrefix;

  /// No description provided for @employee_optionalPrefix.
  ///
  /// In en, this message translates to:
  /// **'Select (optional)'**
  String get employee_optionalPrefix;

  /// No description provided for @employee_selectDateHint.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get employee_selectDateHint;

  /// No description provided for @employee_photoFromSystem.
  ///
  /// In en, this message translates to:
  /// **'Profile photo from system'**
  String get employee_photoFromSystem;

  /// No description provided for @employee_roleOperation.
  ///
  /// In en, this message translates to:
  /// **'operation'**
  String get employee_roleOperation;

  /// No description provided for @employee_roleManagement.
  ///
  /// In en, this message translates to:
  /// **'management'**
  String get employee_roleManagement;

  /// No description provided for @employee_roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'admin'**
  String get employee_roleAdmin;

  /// No description provided for @employee_roleMonitor.
  ///
  /// In en, this message translates to:
  /// **'monitor'**
  String get employee_roleMonitor;

  /// No description provided for @employee_roleControlRoom.
  ///
  /// In en, this message translates to:
  /// **'control_room'**
  String get employee_roleControlRoom;

  /// No description provided for @employee_statusActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get employee_statusActive;

  /// No description provided for @employee_statusInactive.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE'**
  String get employee_statusInactive;

  /// No description provided for @employee_statusOnLeave.
  ///
  /// In en, this message translates to:
  /// **'ON_LEAVE'**
  String get employee_statusOnLeave;

  /// No description provided for @employee_statusSick.
  ///
  /// In en, this message translates to:
  /// **'SICK'**
  String get employee_statusSick;

  /// No description provided for @crud_eq_title.
  ///
  /// In en, this message translates to:
  /// **'Employee Qualifications'**
  String get crud_eq_title;

  /// No description provided for @crud_eq_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Qualification'**
  String get crud_eq_delete_title;

  /// No description provided for @crud_eq_delete_confirm_content.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this qualification?'**
  String get crud_eq_delete_confirm_content;

  /// No description provided for @crud_eq_delete_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get crud_eq_delete_cancel;

  /// No description provided for @crud_eq_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get crud_eq_delete_confirm;

  /// No description provided for @crud_eq_delete_success.
  ///
  /// In en, this message translates to:
  /// **'Qualification deleted successfully'**
  String get crud_eq_delete_success;

  /// No description provided for @crud_eq_empty_data.
  ///
  /// In en, this message translates to:
  /// **'No qualification data'**
  String get crud_eq_empty_data;

  /// No description provided for @crud_eq_add_button.
  ///
  /// In en, this message translates to:
  /// **'Add Qualification'**
  String get crud_eq_add_button;

  /// No description provided for @crud_eq_code_label.
  ///
  /// In en, this message translates to:
  /// **'Code: '**
  String get crud_eq_code_label;

  /// No description provided for @crud_eq_category_label.
  ///
  /// In en, this message translates to:
  /// **'Category: '**
  String get crud_eq_category_label;

  /// No description provided for @crud_eq_validity_label.
  ///
  /// In en, this message translates to:
  /// **'Validity: '**
  String get crud_eq_validity_label;

  /// No description provided for @crud_eq_months_suffix.
  ///
  /// In en, this message translates to:
  /// **' months'**
  String get crud_eq_months_suffix;

  /// No description provided for @crud_eq_status_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get crud_eq_status_active;

  /// No description provided for @crud_eq_status_inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get crud_eq_status_inactive;

  /// No description provided for @crud_eq_requires_renewal.
  ///
  /// In en, this message translates to:
  /// **'Requires Renewal'**
  String get crud_eq_requires_renewal;

  /// No description provided for @crud_eq_menu_detail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get crud_eq_menu_detail;

  /// No description provided for @crud_eq_menu_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get crud_eq_menu_edit;

  /// No description provided for @crud_eq_menu_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get crud_eq_menu_delete;

  /// No description provided for @crud_eq_refresh_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get crud_eq_refresh_tooltip;

  /// No description provided for @crud_eq_detail_title.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get crud_eq_detail_title;

  /// No description provided for @crud_eq_detail_id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get crud_eq_detail_id;

  /// No description provided for @crud_eq_detail_code.
  ///
  /// In en, this message translates to:
  /// **'Qualification Code'**
  String get crud_eq_detail_code;

  /// No description provided for @crud_eq_detail_name.
  ///
  /// In en, this message translates to:
  /// **'Qualification Name'**
  String get crud_eq_detail_name;

  /// No description provided for @crud_eq_detail_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get crud_eq_detail_category;

  /// No description provided for @crud_eq_detail_validity.
  ///
  /// In en, this message translates to:
  /// **'Validity Period'**
  String get crud_eq_detail_validity;

  /// No description provided for @crud_eq_detail_requires_renewal.
  ///
  /// In en, this message translates to:
  /// **'Requires Renewal'**
  String get crud_eq_detail_requires_renewal;

  /// No description provided for @crud_eq_detail_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get crud_eq_detail_description;

  /// No description provided for @crud_eq_detail_created_at.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get crud_eq_detail_created_at;

  /// No description provided for @crud_eq_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get crud_eq_yes;

  /// No description provided for @crud_eq_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get crud_eq_no;

  /// No description provided for @crud_eq_form_code_hint.
  ///
  /// In en, this message translates to:
  /// **'Example: STR, SIP, KLS, ACLS'**
  String get crud_eq_form_code_hint;

  /// No description provided for @crud_eq_form_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Example: Registration Certificate, ACLS Certification'**
  String get crud_eq_form_name_hint;

  /// No description provided for @crud_eq_form_category_hint.
  ///
  /// In en, this message translates to:
  /// **'Select category (optional)'**
  String get crud_eq_form_category_hint;

  /// No description provided for @crud_eq_form_category_picker_title.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get crud_eq_form_category_picker_title;

  /// No description provided for @crud_eq_form_validity_hint.
  ///
  /// In en, this message translates to:
  /// **'Example: 12 (optional)'**
  String get crud_eq_form_validity_hint;

  /// No description provided for @crud_eq_form_renewal_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable if this qualification needs periodic renewal'**
  String get crud_eq_form_renewal_subtitle;

  /// No description provided for @crud_eq_form_active_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Disable if this qualification is no longer used'**
  String get crud_eq_form_active_subtitle;

  /// No description provided for @crud_eq_form_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Brief description of this qualification (optional)'**
  String get crud_eq_form_description_hint;

  /// No description provided for @crud_eq_form_preview_title.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get crud_eq_form_preview_title;

  /// No description provided for @crud_eq_form_update_button.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get crud_eq_form_update_button;

  /// No description provided for @crud_eq_form_save_button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get crud_eq_form_save_button;

  /// No description provided for @crud_eq_validation_code_required.
  ///
  /// In en, this message translates to:
  /// **'Qualification code is required'**
  String get crud_eq_validation_code_required;

  /// No description provided for @crud_eq_validation_code_min.
  ///
  /// In en, this message translates to:
  /// **'Code must be at least 2 characters'**
  String get crud_eq_validation_code_min;

  /// No description provided for @crud_eq_validation_code_max.
  ///
  /// In en, this message translates to:
  /// **'Code cannot exceed 30 characters'**
  String get crud_eq_validation_code_max;

  /// No description provided for @crud_eq_validation_name_required.
  ///
  /// In en, this message translates to:
  /// **'Qualification name is required'**
  String get crud_eq_validation_name_required;

  /// No description provided for @crud_eq_validation_name_min.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get crud_eq_validation_name_min;

  /// No description provided for @crud_eq_validation_name_max.
  ///
  /// In en, this message translates to:
  /// **'Name cannot exceed 100 characters'**
  String get crud_eq_validation_name_max;

  /// No description provided for @crud_eq_validation_validity_min.
  ///
  /// In en, this message translates to:
  /// **'Validity period must be at least 1 month'**
  String get crud_eq_validation_validity_min;

  /// No description provided for @crud_eq_validation_validity_max.
  ///
  /// In en, this message translates to:
  /// **'Validity period cannot exceed 120 months (10 years)'**
  String get crud_eq_validation_validity_max;

  /// No description provided for @crud_eq_success_update.
  ///
  /// In en, this message translates to:
  /// **'Qualification updated successfully'**
  String get crud_eq_success_update;

  /// No description provided for @crud_eq_success_create.
  ///
  /// In en, this message translates to:
  /// **'Qualification added successfully'**
  String get crud_eq_success_create;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
