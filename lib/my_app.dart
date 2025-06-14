import 'package:expense_management/cubits/auth/auth_cubit.dart';
import 'package:expense_management/cubits/create_list/create_list_cubit.dart';
import 'package:expense_management/cubits/language/language_cubit.dart';
import 'package:expense_management/cubits/theme/theme_cubit.dart';
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
  late ColorScheme colorScheme;

  void setLocale() {
    setState(() {
      locale = BlocProvider.of<LanguageCubit>(context).language;
    });
  }

  void setColorScheme() {
    setState(() {
      colorScheme = BlocProvider.of<ThemeCubit>(context).colorScheme;
    });
  }

  @override
  void initState() {
    locale = BlocProvider.of<LanguageCubit>(context).language;
    colorScheme = BlocProvider.of<ThemeCubit>(context).colorScheme;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(8));
    const outline = BorderSide(color: Colors.grey, width: 2);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => CreateListCubit()),
      ],
      child: MaterialApp(
        title: 'Expense Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: colorScheme.surface,
          appBarTheme: AppBarTheme(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            isDense: true,
            border: const OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: outline,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: outline,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          chipTheme: ChipThemeData(
            labelStyle: TextStyle(color: colorScheme.onSurface),
            backgroundColor: colorScheme.primaryContainer,
            padding: EdgeInsets.zero,
            shape: const StadiumBorder(),
            side: BorderSide.none,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: const RoundedRectangleBorder(
                borderRadius: borderRadius,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              elevation: 0,
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary, width: 2),
              shape: const RoundedRectangleBorder(
                borderRadius: borderRadius,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              shape: const RoundedRectangleBorder(
                borderRadius: borderRadius,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          cardTheme: CardThemeData(
            color: colorScheme.surface,
            elevation: 1,
            margin: const EdgeInsets.all(8),
            shape: const RoundedRectangleBorder(borderRadius: borderRadius),
          ),
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            backgroundColor: colorScheme.error,
            shape: const RoundedRectangleBorder(borderRadius: borderRadius),
          ),
        ),
        supportedLocales: L10n.all,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        locale: locale,
        home: const AuthScreen(),
      ),
    );
  }
}
