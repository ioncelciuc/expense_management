import 'package:expense_management/models/expense_list.dart';

sealed class ExpenseListsState {}

final class ExpenseListsInitial extends ExpenseListsState {}

class ExpenseListsLoaded extends ExpenseListsState {
  final List<ExpenseList> expenseLists;
  ExpenseListsLoaded(this.expenseLists);
}

class ExpenseListsError extends ExpenseListsState {
  final String message;
  ExpenseListsError(this.message);
}
