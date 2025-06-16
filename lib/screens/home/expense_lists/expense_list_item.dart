import 'package:expense_management/cubits/expense_lists/expense_lists_cubit.dart';
import 'package:expense_management/cubits/language/language_cubit.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/models/expense_list.dart';
import 'package:expense_management/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    String autors = '';
    for (UserModel allowedUser in expenseList.allowedUsers) {
      autors += allowedUser.email.split('@').first;
      autors += ', ';
    }
    if (autors.length >= 2) {
      autors = autors.substring(0, autors.length - 2);
    }
    String currentUserStatus = expenseList.allowedUsers.firstWhere((u) => u.id == FirebaseAuth.instance.currentUser!.uid).status!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8.0),
              onTap: currentUserStatus == 'creator' || currentUserStatus == 'editor' ? onTap : null,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(expenseList.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.modified}: ${DateFormat('dd MMM yyyy', BlocProvider.of<LanguageCubit>(context).language.languageCode).format(expenseList.modifiedAt)}',
                    ),
                    Text('${AppLocalizations.of(context)!.autors}: $autors'),
                    Text('${expenseList.maxBudgetPerMonth} ${expenseList.currency}/${AppLocalizations.of(context)!.month.toLowerCase()}'),
                  ],
                ),
                trailing: currentUserStatus == 'creator'
                    ? IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('${AppLocalizations.of(context)!.delete_expense_list_title} ${expenseList.name}?'),
                              content: Text(AppLocalizations.of(context)!.delete_expense_list_content),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(AppLocalizations.of(context)!.cancel),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    BlocProvider.of<ExpenseListsCubit>(context).deleteExpenseList(expenseList.id);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context).colorScheme.error,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.delete,
                                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete),
                      )
                    : currentUserStatus == 'editor'
                        ? IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('${AppLocalizations.of(context)!.exit_shared_list_title}\n${expenseList.name}'),
                                  content: Text(AppLocalizations.of(context)!.exit_shared_list_content),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(AppLocalizations.of(context)!.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        BlocProvider.of<ExpenseListsCubit>(context).exitExpenseListParticipation(expenseList.id);
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Theme.of(context).colorScheme.error,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.exit,
                                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.person_remove),
                          )
                        : const SizedBox(),
              ),
            ),
            currentUserStatus == 'pending'
                ? Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              BlocProvider.of<ExpenseListsCubit>(context).confirmExpenseListParticipation(expenseList.id);
                            },
                            child: Text(AppLocalizations.of(context)!.confirm),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.error,
                              side: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
                            ),
                            onPressed: () {
                              BlocProvider.of<ExpenseListsCubit>(context).denyExpenseListParticipation(expenseList.id);
                            },
                            child: Text(AppLocalizations.of(context)!.deny),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
