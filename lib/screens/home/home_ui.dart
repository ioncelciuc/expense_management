import 'package:expense_management/screens/home/create_expense_list/create_expense_list_screen.dart';
import 'package:expense_management/screens/home/expense_lists/expense_lists_widget.dart';
import 'package:expense_management/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/l10n/app_localizations.dart';

class HomeUi extends StatefulWidget {
  const HomeUi({super.key});

  @override
  State<HomeUi> createState() => _HomeUiState();
}

class _HomeUiState extends State<HomeUi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.app_name),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: const ExpenseListsWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateExpenseListScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
