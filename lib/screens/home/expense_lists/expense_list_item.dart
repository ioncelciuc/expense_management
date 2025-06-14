import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/models/expense_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseListItem extends StatelessWidget {
  final ExpenseList expenseList;
  final Function()? onTap;

  const ExpenseListItem({
    super.key,
    required this.expenseList,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: onTap,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(expenseList.name),
            subtitle: Text(
              '${AppLocalizations.of(context)!.modified}: ${DateFormat.yMMMd().format(expenseList.modifiedAt)}',
            ),
            trailing: Text(expenseList.currency),
          ),
        ),
      ),
    );
  }
}
