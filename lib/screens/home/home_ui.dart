import 'package:expense_management/core/constants.dart';
import 'package:expense_management/cubits/auth/auth_cubit.dart';
import 'package:expense_management/screens/create_expense_list/create_expense_list_screen.dart';
import 'package:expense_management/screens/settings/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/l10n/app_localizations.dart';

class HomeUi extends StatelessWidget {
  const HomeUi({super.key});

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
      body: ListView(
        padding: kPagePadding,
        children: [
          Text('Hello, ${FirebaseAuth.instance.currentUser!.email}'),
        ],
      ),
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
