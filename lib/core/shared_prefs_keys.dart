import 'package:flutter/material.dart';

class SharedPrefsKeys {
  static const language = 'LANGUAGE';
  static const isLightTheme = 'IS_LIGHT_THEME';
  static const color = 'COLOR';
  static const colorRed = 'COLOR_RED';
  static const colorOrange = 'COLOR_ORANGE';
  static const colorYellow = 'COLOR_YELLOW';
  static const colorGreen = 'COLOR_GREEN';
  static const colorBlue = 'COLOR_BLUE';
  static const colorIndigo = 'COLOR_INDIGO';
  static const colorPurple = 'COLOR_PURPLE';
  static const colorTeal = 'COLOR_TEAL';
  static const colorAmber = 'COLOR_AMBER';

  static Color getColorFromKey(String color) {
    switch (color) {
      case colorRed:
        return Colors.red;
      case colorOrange:
        return Colors.orange;
      case colorYellow:
        return Colors.yellow;
      case colorGreen:
        return Colors.green;
      case colorBlue:
        return Colors.blue;
      case colorIndigo:
        return Colors.indigo;
      case colorPurple:
        return Colors.purple;
      case colorAmber:
        return Colors.amber;
      case colorTeal:
        return Colors.teal;
      default:
        return Colors.teal;
    }
  }
}
