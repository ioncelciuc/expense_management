import 'package:expense_management/screens/home/expense_list_details/expense_list_details_ui.dart';
import 'package:flutter/material.dart';

class ExpenseListDetailsScreen extends StatelessWidget {
  final String listId;

  const ExpenseListDetailsScreen({
    super.key,
    required this.listId,
  });

  @override
  Widget build(BuildContext context) {
    return ExpenseListDetailsUi(
      listId: listId,
    );
  }
}
