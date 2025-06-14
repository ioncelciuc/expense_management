import 'package:expense_management/cubits/expense_lists/expense_lists_cubit.dart';
import 'package:expense_management/cubits/expense_lists/expense_lists_state.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/screens/home/expense_list_details/expense_list_details_screen.dart';
import 'package:expense_management/screens/home/expense_lists/expense_list_item.dart';
import 'package:expense_management/widgets/info_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpenseListsWidget extends StatefulWidget {
  const ExpenseListsWidget({super.key});

  @override
  State<ExpenseListsWidget> createState() => _ExpenseListsWidgetState();
}

class _ExpenseListsWidgetState extends State<ExpenseListsWidget> {
  @override
  void initState() {
    BlocProvider.of<ExpenseListsCubit>(context).listenToExpenseLists();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseListsCubit, ExpenseListsState>(
      builder: (context, state) {
        if (state is ExpenseListsError) {
          return InfoText(text: '${AppLocalizations.of(context)!.error_loading}: ${state.message}');
        } else if (state is ExpenseListsLoaded) {
          final lists = state.expenseLists;
          if (lists.isEmpty) {
            return InfoText(text: AppLocalizations.of(context)!.no_expense_list_found);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lists.length,
            itemBuilder: (context, index) {
              return ExpenseListItem(
                expenseList: lists[index],
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ExpenseListDetailsScreen(listId: lists[index].id),
                    ),
                  );
                },
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
