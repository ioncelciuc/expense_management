import 'package:expense_management/core/shared_prefs_keys.dart';
import 'package:expense_management/cubits/language/language_state.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCubit extends Cubit<LanguageState> {
  Locale language;

  LanguageCubit(this.language) : super(LanguageInitial());

  setLanguageLocale(String localeCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharedPrefsKeys.language, localeCode);
    language = Locale(localeCode);
  }

  String getLanguageString(BuildContext context) {
    switch (language.languageCode) {
      case 'en':
        return AppLocalizations.of(context)!.english;
      case 'ro':
        return AppLocalizations.of(context)!.romanian;
      default:
        return '???';
    }
  }
}
