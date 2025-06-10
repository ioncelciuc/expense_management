import 'package:expense_management/core/constants.dart';
import 'package:expense_management/cubits/language/language_cubit.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String selectedLanguage;
  List<String> languages = [];

  void setLanguage(String language) async {
    String languageLocale = BlocProvider.of<LanguageCubit>(context).getLanguageLocaleFromString(language, context);
    var state = context.findAncestorStateOfType<MyAppState>();
    await BlocProvider.of<LanguageCubit>(context).setLanguageLocale(languageLocale);
    state?.setLocale();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    selectedLanguage = BlocProvider.of<LanguageCubit>(context).getLanguageString(context);
    languages = [
      AppLocalizations.of(context)!.english,
      AppLocalizations.of(context)!.romanian,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.language),
      ),
      body: Padding(
        padding: kPagePadding,
        child: Column(
          children: [
            Text(
              'Choose your preffered language:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                label: Text(AppLocalizations.of(context)!.language),
              ),
              value: selectedLanguage,
              items: languages.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedLanguage = value);
                  setLanguage(selectedLanguage);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
