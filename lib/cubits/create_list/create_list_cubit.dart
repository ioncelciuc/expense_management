import 'package:expense_management/cubits/create_list/create_list_state.dart';
import 'package:expense_management/helpers/firebase_helper.dart';
import 'package:expense_management/models/expense_list.dart';
import 'package:expense_management/models/response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateListCubit extends Cubit<CreateListState> {
  CreateListCubit() : super(CreateListInitial());

  emitInitial() {
    emit(CreateListInitial());
  }

  createList(ExpenseList expenseList) async {
    emit(CreateListLoading());
    Response response = await FirebaseHelper.createExpenseList(expenseList);
    if (response.success) {
      emit(CreateListCompleted());
      return;
    }
    emit(CreateListFailed(response));
  }
}
