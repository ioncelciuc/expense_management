import 'package:expense_management/cubits/auth/auth_cubit.dart';
import 'package:expense_management/cubits/language/language_cubit.dart';
//import this for translations
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/l10n/l10n.dart';
import 'package:expense_management/screens/auth/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late Locale locale;

  void setLocale() {
    setState(() {
      locale = BlocProvider.of<LanguageCubit>(context).language;
    });
  }

  @override
  void initState() {
    locale = BlocProvider.of<LanguageCubit>(context).language;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
      ],
      child: MaterialApp(
        title: 'Expense Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
        ),
        supportedLocales: L10n.all,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: const AuthScreen(),
      ),
    );
  }
}
