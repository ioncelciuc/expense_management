import 'package:expense_management/models/expense_list.dart';
import 'package:expense_management/widgets/expandable_fab.dart';
import 'package:flutter/material.dart';

class ExpenseListDetailsUi extends StatelessWidget {
  final ExpenseList expenseList;

  const ExpenseListDetailsUi({
    super.key,
    required this.expenseList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(expenseList.name),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bar_chart),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      floatingActionButton: ExpandableFab(
        children: [
          ActionButton(
            onPressed: () async {},
            icon: const Icon(Icons.photo),
          ),
          ActionButton(
            onPressed: () async {},
            icon: const Icon(Icons.camera_alt),
          ),
          ActionButton(
            onPressed: () async {},
            icon: const Icon(Icons.edit_document),
          ),
        ],
      ),
    );
  }
}
