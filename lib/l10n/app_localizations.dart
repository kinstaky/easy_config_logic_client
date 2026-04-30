import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
    Locale('zh')
  ];

  /// Tooltip for adding new device.
  ///
  /// In en, this message translates to:
  /// **'Add new device'**
  String get addDeviceTooltip;

  /// Tooltip for refreshing device state.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshTooltip;

  /// Tooltip for editing device settings.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editDeviceTooltip;

  /// Tooltip for deleting existing device.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteDeviceTooltip;

  /// Title for adding new device page.
  ///
  /// In en, this message translates to:
  /// **'New device'**
  String get newDeviceTitle;

  /// Title for editing existing device page.
  ///
  /// In en, this message translates to:
  /// **'Edit device'**
  String get editDeviceTitle;

  /// String for calling something.
  ///
  /// In en, this message translates to:
  /// **'name'**
  String get name;

  /// IP in network.
  ///
  /// In en, this message translates to:
  /// **'IP'**
  String get ip;

  /// Port in network, related to IP.
  ///
  /// In en, this message translates to:
  /// **'port'**
  String get port;

  /// Prefix of hints in inputting device properties.
  ///
  /// In en, this message translates to:
  /// **'Enter device '**
  String get deviceInputHintPrefix;

  /// Action to apply and store changes.
  ///
  /// In en, this message translates to:
  /// **'save'**
  String get save;

  /// Title of tab for showing counts.
  ///
  /// In en, this message translates to:
  /// **'scaler'**
  String get scaler;

  /// Title of tab for config device.
  ///
  /// In en, this message translates to:
  /// **'config'**
  String get config;

  /// Title of tab for editing scaler names.
  ///
  /// In en, this message translates to:
  /// **'scaler names'**
  String get scalerNames;

  /// Selection name for selecting real time mode.
  ///
  /// In en, this message translates to:
  /// **'Real time'**
  String get realTimeSelection;

  /// Selection name for selecting history mode.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historySelection;

  /// Action to clear all data.
  ///
  /// In en, this message translates to:
  /// **'clear'**
  String get clear;

  /// Action to get stored data.
  ///
  /// In en, this message translates to:
  /// **'load'**
  String get load;

  /// Action to change settings back to default.
  ///
  /// In en, this message translates to:
  /// **'reset'**
  String get reset;

  /// Hint for showing last config time.
  ///
  /// In en, this message translates to:
  /// **'Last config: '**
  String get lastConfigHint;

  /// Period of 2 minutes.
  ///
  /// In en, this message translates to:
  /// **'2 minutes'**
  String get liveModeName2m;

  /// Period of 20 minutes.
  ///
  /// In en, this message translates to:
  /// **'20 minutes'**
  String get liveModeName20m;

  /// Period of 2 hours.
  ///
  /// In en, this message translates to:
  /// **'2 hours'**
  String get liveModeName2h;

  /// Period of 24 hours.
  ///
  /// In en, this message translates to:
  /// **'24 hours'**
  String get liveModeName24h;

  /// Hint for selecting theme color.
  ///
  /// In en, this message translates to:
  /// **'Theme: '**
  String get themeColorSettings;

  /// Hint for setting brightness.
  ///
  /// In en, this message translates to:
  /// **'Dark mode: '**
  String get brightnessSettings;

  /// Hint for selecting language.
  ///
  /// In en, this message translates to:
  /// **'Languages: '**
  String get languageSettings;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
