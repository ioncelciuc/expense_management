import 'package:expense_management/core/constants.dart';
import 'package:expense_management/core/shared_prefs_keys.dart';
import 'package:expense_management/cubits/theme/theme_cubit.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemesScreen extends StatefulWidget {
  const ThemesScreen({super.key});

  @override
  State<ThemesScreen> createState() => _ThemesScreenState();
}

class _ThemesScreenState extends State<ThemesScreen> {
  String selectedTheme = 'Light';
  List<String> themes = [];

  String selectedColor = 'Cyan';
  List<String> colors = [
    'Cyan',
    'Blue',
    'Purple',
  ];

  void setTheme() async {
    Brightness selectedBrightness = getBrightnessFromString(selectedTheme);
    BlocProvider.of<ThemeCubit>(context).color = BlocProvider.of<ThemeCubit>(context).getSharedPrefsColorFromLocalizedColorName(selectedColor, context);
    Color color = SharedPrefsKeys.getColorFromKey(
      BlocProvider.of<ThemeCubit>(context).getSharedPrefsColorFromLocalizedColorName(selectedColor, context),
    );
    var state = context.findAncestorStateOfType<MyAppState>();
    await BlocProvider.of<ThemeCubit>(context).setColorScheme(selectedBrightness, color);
    state?.setColorScheme();
    setState(() {});
  }

  Brightness getBrightnessFromString(String brightness) {
    return brightness == AppLocalizations.of(context)!.light ? Brightness.light : Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    selectedTheme = BlocProvider.of<ThemeCubit>(context).colorScheme.brightness == Brightness.light ? AppLocalizations.of(context)!.light : AppLocalizations.of(context)!.dark;
    themes = [
      AppLocalizations.of(context)!.light,
      AppLocalizations.of(context)!.dark,
    ];
    selectedColor = BlocProvider.of<ThemeCubit>(context).getLocalizedColorNameFromSharedPrefsColor(context);
    colors = [
      AppLocalizations.of(context)!.red,
      AppLocalizations.of(context)!.orange,
      AppLocalizations.of(context)!.yellow,
      AppLocalizations.of(context)!.green,
      AppLocalizations.of(context)!.blue,
      AppLocalizations.of(context)!.indigo,
      AppLocalizations.of(context)!.purple,
      AppLocalizations.of(context)!.amber,
      AppLocalizations.of(context)!.teal,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.theme)),
      body: ListView(
        padding: kPagePadding,
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              label: Text(AppLocalizations.of(context)!.brightness),
            ),
            value: selectedTheme,
            items: themes.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(e),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedTheme = value);
                setTheme();
              }
            },
          ),
          const SizedBox(height: 32),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              label: Text(AppLocalizations.of(context)!.color),
            ),
            value: selectedColor,
            items: colors.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(e),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedColor = value);
                setTheme();
              }
            },
          ),
        ],
      ),
    );
  }
}
