// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get romanian => 'Romanian';

  @override
  String get app_name => 'Expense Management';

  @override
  String get settings => 'Settings';

  @override
  String get sign_out => 'Sign Out';

  @override
  String get theme => 'Theme';

  @override
  String get brightness => 'Brightness';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get color => 'Color';

  @override
  String get red => 'Red';

  @override
  String get orange => 'Orange';

  @override
  String get yellow => 'Yellow';

  @override
  String get green => 'Green';

  @override
  String get blue => 'Blue';

  @override
  String get indigo => 'Indigo';

  @override
  String get purple => 'Purple';

  @override
  String get teal => 'Teal';

  @override
  String get amber => 'Amber';

  @override
  String get email_validation_empty => 'Email can\'t be empty';

  @override
  String get email_validation_invalid_email =>
      'Please enter a valid email address';

  @override
  String get password_validation_no_password => 'You must choose a password';

  @override
  String get password_validation_password_pattern =>
      'Password must be at least 8 characters long and contain at least:\nAn uppercase character\nA lowercase character\nA number\nA special character';

  @override
  String get password_validation_no_match => 'Passwords don\'t match';

  @override
  String get create_an_account => 'Create an account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get repeat_password => 'Repeat password';

  @override
  String get sign_up => 'Sign Up';

  @override
  String get already_have_an_account => 'Already have an account? Sign In!';

  @override
  String get welcome_to => 'Welcome to';

  @override
  String get forgot_password => 'Forgot password?';

  @override
  String get sign_in => 'Sign In';

  @override
  String get dont_have_an_account => 'Don\'t have an account? Create one here';

  @override
  String get themes => 'Themes';

  @override
  String get no_expense_list_found =>
      'No expense list was found. You can add one using the PLUS button';

  @override
  String get error_loading_expense_list => 'Error loading expense list';

  @override
  String get create_expense_list => 'Create expense list';

  @override
  String get expense_list_name => 'Name of the list';

  @override
  String get expense_list_description => 'Details regarding this list';

  @override
  String get expense_list_add_person_by_email => 'Add person by email';

  @override
  String get email_validation_email_taken => 'That email is already added';

  @override
  String get currency => 'Currency';

  @override
  String get no_user_with_that_email => 'There is no user with that email';

  @override
  String get expense_list_complete_all_fields_to_create =>
      'Complete all fields to create an expense list';
}
