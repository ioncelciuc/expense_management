import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ro.dart';

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
    Locale('ro')
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @romanian.
  ///
  /// In en, this message translates to:
  /// **'Romanian'**
  String get romanian;

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Expense Management'**
  String get app_name;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @sign_out.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get sign_out;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get red;

  /// No description provided for @orange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get orange;

  /// No description provided for @yellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get yellow;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// No description provided for @indigo.
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get indigo;

  /// No description provided for @purple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get purple;

  /// No description provided for @teal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get teal;

  /// No description provided for @amber.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get amber;

  /// No description provided for @email_validation_empty.
  ///
  /// In en, this message translates to:
  /// **'Email can\'t be empty'**
  String get email_validation_empty;

  /// No description provided for @email_validation_invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get email_validation_invalid_email;

  /// No description provided for @password_validation_no_password.
  ///
  /// In en, this message translates to:
  /// **'You must choose a password'**
  String get password_validation_no_password;

  /// No description provided for @password_validation_password_pattern.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long and contain at least:\nAn uppercase character\nA lowercase character\nA number\nA special character'**
  String get password_validation_password_pattern;

  /// No description provided for @password_validation_no_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get password_validation_no_match;

  /// No description provided for @create_an_account.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get create_an_account;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @repeat_password.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get repeat_password;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get sign_up;

  /// No description provided for @already_have_an_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In!'**
  String get already_have_an_account;

  /// No description provided for @welcome_to.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcome_to;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgot_password;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in;

  /// No description provided for @dont_have_an_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Create one here'**
  String get dont_have_an_account;

  /// No description provided for @themes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get themes;

  /// No description provided for @no_expense_list_found.
  ///
  /// In en, this message translates to:
  /// **'No expense list was found. You can add one using the PLUS button'**
  String get no_expense_list_found;

  /// No description provided for @error_loading_expense_list.
  ///
  /// In en, this message translates to:
  /// **'Error loading expense list'**
  String get error_loading_expense_list;

  /// No description provided for @create_expense_list.
  ///
  /// In en, this message translates to:
  /// **'Create expense list'**
  String get create_expense_list;

  /// No description provided for @expense_list_name.
  ///
  /// In en, this message translates to:
  /// **'Name of the list'**
  String get expense_list_name;

  /// No description provided for @expense_list_description.
  ///
  /// In en, this message translates to:
  /// **'Details regarding this list'**
  String get expense_list_description;

  /// No description provided for @expense_list_add_person_by_email.
  ///
  /// In en, this message translates to:
  /// **'Add person by email'**
  String get expense_list_add_person_by_email;

  /// No description provided for @email_validation_email_taken.
  ///
  /// In en, this message translates to:
  /// **'That email is already added'**
  String get email_validation_email_taken;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @no_user_with_that_email.
  ///
  /// In en, this message translates to:
  /// **'There is no user with that email'**
  String get no_user_with_that_email;

  /// No description provided for @expense_list_complete_all_fields_to_create.
  ///
  /// In en, this message translates to:
  /// **'Complete all fields to create an expense list'**
  String get expense_list_complete_all_fields_to_create;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @expense_list_budget_explanation.
  ///
  /// In en, this message translates to:
  /// **'Add an estimated monthly budget for this list and your preffered currency. You can also add some reocurring monthly payments!'**
  String get expense_list_budget_explanation;

  /// No description provided for @monthly_budget.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get monthly_budget;

  /// No description provided for @add_monthly_reocurring_payment.
  ///
  /// In en, this message translates to:
  /// **'Add monthly reocurring payment'**
  String get add_monthly_reocurring_payment;

  /// No description provided for @expense_list_reocurring_payment_explanation.
  ///
  /// In en, this message translates to:
  /// **''**
  String get expense_list_reocurring_payment_explanation;

  /// No description provided for @expense_list_purchase_type_explanation.
  ///
  /// In en, this message translates to:
  /// **'Create some custom types of expenses. You have some expamples down below. Also, you can add more later or edit the current ones:'**
  String get expense_list_purchase_type_explanation;

  /// No description provided for @error_purchase_type_empty_name.
  ///
  /// In en, this message translates to:
  /// **'A type of purchase can\'t have an empty name'**
  String get error_purchase_type_empty_name;

  /// No description provided for @add_another_purchase_type.
  ///
  /// In en, this message translates to:
  /// **'Add another purchase type'**
  String get add_another_purchase_type;

  /// No description provided for @error_reocurring_payment_empty_name.
  ///
  /// In en, this message translates to:
  /// **'A reocurring payment can\'t have an empty name'**
  String get error_reocurring_payment_empty_name;

  /// No description provided for @error_no_purchase_type.
  ///
  /// In en, this message translates to:
  /// **'You must have at least a purchase type'**
  String get error_no_purchase_type;

  /// No description provided for @error_field_must_have_positive_numbers.
  ///
  /// In en, this message translates to:
  /// **'This field should contain only positive numbers'**
  String get error_field_must_have_positive_numbers;

  /// No description provided for @error_reocurring_payment_sum.
  ///
  /// In en, this message translates to:
  /// **'A reocurring payment has a mistake regarding the sum'**
  String get error_reocurring_payment_sum;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @modified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get modified;

  /// No description provided for @error_loading.
  ///
  /// In en, this message translates to:
  /// **'Error while loading'**
  String get error_loading;

  /// No description provided for @no_items_found.
  ///
  /// In en, this message translates to:
  /// **'It\'s empty here'**
  String get no_items_found;

  /// No description provided for @add_expense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get add_expense;

  /// No description provided for @update_expense.
  ///
  /// In en, this message translates to:
  /// **'Update expense'**
  String get update_expense;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @purchase_type.
  ///
  /// In en, this message translates to:
  /// **'Purchase Type'**
  String get purchase_type;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @error_all_fields_must_be_completed.
  ///
  /// In en, this message translates to:
  /// **'All fields must be completed'**
  String get error_all_fields_must_be_completed;

  /// No description provided for @error_price_not_correct.
  ///
  /// In en, this message translates to:
  /// **'Inputted price is not correct'**
  String get error_price_not_correct;

  /// No description provided for @error_quanity_whole_number.
  ///
  /// In en, this message translates to:
  /// **'Quantity should be a whole number'**
  String get error_quanity_whole_number;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @receipt_scanning.
  ///
  /// In en, this message translates to:
  /// **'Reciept scanning'**
  String get receipt_scanning;

  /// No description provided for @autors.
  ///
  /// In en, this message translates to:
  /// **'Autors'**
  String get autors;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @delete_expense_list_title.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete'**
  String get delete_expense_list_title;

  /// No description provided for @delete_expense_list_content.
  ///
  /// In en, this message translates to:
  /// **'Once deleted, there\'s no going back!'**
  String get delete_expense_list_content;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;
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
      <String>['en', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ro':
      return AppLocalizationsRo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
