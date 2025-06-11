import 'package:expense_management/cubits/create_list/create_list_cubit.dart';
import 'package:expense_management/cubits/create_list/create_list_state.dart';
import 'package:expense_management/screens/home/create_expense_list/create_expense_list_ui.dart';
import 'package:expense_management/widgets/snackbar_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateExpenseListScreen extends StatelessWidget {
  const CreateExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<CreateListCubit>(context).emitInitial();
    return BlocConsumer<CreateListCubit, CreateListState>(
      listener: (context, state) {
        if (state is CreateListCompleted) {
          Navigator.of(context).pop();
        }
        if (state is CreateListFailed) {
          BlocProvider.of<CreateListCubit>(context).emitInitial();
          SnackbarHandler(
            context: context,
            message: state.response.message ?? 'Unknown error occured',
          );
        }
      },
      builder: (context, state) {
        if (state is CreateListLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return const CreateExpenseListUi();
      },
    );
  }
}
