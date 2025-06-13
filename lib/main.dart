import 'dart:io';

import 'package:expense_management/core/shared_prefs_keys.dart';
import 'package:expense_management/cubits/language/language_cubit.dart';
import 'package:expense_management/cubits/theme/theme_cubit.dart';
import 'package:expense_management/my_app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/firebase_options.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // Print to console however you like:
    // you could pipe to a file or remote service instead
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  final logger = Logger('main');

  String enviroment = 'dev'; //default to dev enviroment
  if (args.isNotEmpty && args[0] == '--prod') {
    enviroment = 'prod';
  }

  await dotenv.load(fileName: enviroment == 'dev' ? 'variables_dev.env' : "variables_prod.env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
  String? sharedPrefsLocale = sharedPrefs.getString(SharedPrefsKeys.language);
  if (sharedPrefsLocale == null) {
    if (Platform.localeName.startsWith('ro')) {
      sharedPrefsLocale = 'ro';
    } else {
      sharedPrefsLocale = 'en';
    }
    await sharedPrefs.setString(SharedPrefsKeys.language, sharedPrefsLocale);
  }

  bool? sharedPrefsIsLightTheme = sharedPrefs.getBool(SharedPrefsKeys.isLightTheme);
  if (sharedPrefsIsLightTheme == null) {
    sharedPrefsIsLightTheme = SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.light;
    await sharedPrefs.setBool(SharedPrefsKeys.isLightTheme, sharedPrefsIsLightTheme);
  }

  String? sharedPrefsColor = sharedPrefs.getString(SharedPrefsKeys.color);
  if (sharedPrefsColor == null) {
    sharedPrefsColor = SharedPrefsKeys.colorTeal;
    await sharedPrefs.setString(SharedPrefsKeys.color, sharedPrefsColor);
  }

  logger.info('Running on $enviroment enviroment, in language $sharedPrefsLocale, using color $sharedPrefsColor. Is lightTheme? $sharedPrefsIsLightTheme');

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LanguageCubit(Locale(sharedPrefsLocale!)),
        ),
        BlocProvider(
          create: (context) => ThemeCubit(
            ColorScheme.fromSeed(
              seedColor: SharedPrefsKeys.getColorFromKey(sharedPrefsColor!),
              brightness: sharedPrefsIsLightTheme! ? Brightness.light : Brightness.dark,
            ),
            sharedPrefsColor,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
