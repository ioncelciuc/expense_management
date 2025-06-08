import 'dart:io';

import 'package:expense_management/core/shared_prefs_keys.dart';
import 'package:expense_management/cubits/language/language_cubit.dart';
import 'package:expense_management/my_app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/firebase_options.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LanguageCubit(Locale(sharedPrefsLocale!)),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
