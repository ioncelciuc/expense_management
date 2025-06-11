import 'package:expense_management/models/expense_list.dart';
import 'package:expense_management/screens/home/expense_list_details/expense_list_details_ui.dart';
import 'package:flutter/material.dart';

class ExpenseListDetailsScreen extends StatelessWidget {
  final ExpenseList expenseList;

  const ExpenseListDetailsScreen({
    super.key,
    required this.expenseList,
  });

  @override
  Widget build(BuildContext context) {
    return ExpenseListDetailsUi(expenseList: expenseList);
  }
}
