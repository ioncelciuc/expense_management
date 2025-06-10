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
  late String _selectedLanguageCode;

  void changeLanguage(String localeCode) async {
    var state = context.findAncestorStateOfType<MyAppState>();
    await BlocProvider.of<LanguageCubit>(context).setLanguageLocale(localeCode);
    state?.setLocale();
    setState(() {});
  }

  @override
  void initState() {
    _selectedLanguageCode = BlocProvider.of<LanguageCubit>(context).language.languageCode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.language),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Column(
          children: [
            Text(
              'Choose your preffered language:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: Text(AppLocalizations.of(context)!.english),
              value: 'en',
              groupValue: _selectedLanguageCode,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedLanguageCode = value);
                changeLanguage(value);
              },
            ),

            // Romanian option
            RadioListTile<String>(
              title: Text(AppLocalizations.of(context)!.romanian),
              value: 'ro',
              groupValue: _selectedLanguageCode,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedLanguageCode = value);
                changeLanguage(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
