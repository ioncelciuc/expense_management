import 'package:expense_management/core/shared_prefs_keys.dart';
import 'package:expense_management/cubits/theme/theme_state.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ColorScheme colorScheme;
  String color;

  ThemeCubit(this.colorScheme, this.color) : super(ThemeInitial());

  setColorScheme(Brightness brightness, Color seedColor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SharedPrefsKeys.isLightTheme, brightness == Brightness.light);
    await prefs.setString(SharedPrefsKeys.color, color);
    colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
  }

  String getSharedPrefsColorFromLocalizedColorName(String localizedColor, BuildContext context) {
    if (localizedColor == AppLocalizations.of(context)!.red) {
      return SharedPrefsKeys.colorRed;
    } else if (localizedColor == AppLocalizations.of(context)!.orange) {
      return SharedPrefsKeys.colorOrange;
    } else if (localizedColor == AppLocalizations.of(context)!.yellow) {
      return SharedPrefsKeys.colorYellow;
    } else if (localizedColor == AppLocalizations.of(context)!.green) {
      return SharedPrefsKeys.colorGreen;
    } else if (localizedColor == AppLocalizations.of(context)!.blue) {
      return SharedPrefsKeys.colorBlue;
    } else if (localizedColor == AppLocalizations.of(context)!.indigo) {
      return SharedPrefsKeys.colorIndigo;
    } else if (localizedColor == AppLocalizations.of(context)!.purple) {
      return SharedPrefsKeys.colorPurple;
    } else if (localizedColor == AppLocalizations.of(context)!.amber) {
      return SharedPrefsKeys.colorAmber;
    }
    return SharedPrefsKeys.colorTeal;
  }

  String getLocalizedColorNameFromSharedPrefsColor(BuildContext context) {
    switch (color) {
      case SharedPrefsKeys.colorRed:
        return AppLocalizations.of(context)!.red;
      case SharedPrefsKeys.colorOrange:
        return AppLocalizations.of(context)!.orange;
      case SharedPrefsKeys.colorYellow:
        return AppLocalizations.of(context)!.yellow;
      case SharedPrefsKeys.colorGreen:
        return AppLocalizations.of(context)!.green;
      case SharedPrefsKeys.colorBlue:
        return AppLocalizations.of(context)!.blue;
      case SharedPrefsKeys.colorIndigo:
        return AppLocalizations.of(context)!.indigo;
      case SharedPrefsKeys.colorPurple:
        return AppLocalizations.of(context)!.purple;
      case SharedPrefsKeys.colorAmber:
        return AppLocalizations.of(context)!.amber;
      case SharedPrefsKeys.colorTeal:
        return AppLocalizations.of(context)!.teal;
      default:
        return AppLocalizations.of(context)!.teal;
    }
  }
}
