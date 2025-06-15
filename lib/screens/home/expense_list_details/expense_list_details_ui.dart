import 'package:expense_management/core/constants.dart';
import 'package:expense_management/cubits/expense_lists/expense_lists_cubit.dart';
import 'package:expense_management/cubits/expense_lists/expense_lists_state.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/models/purchase_type.dart';
import 'package:expense_management/models/receipt.dart';
import 'package:expense_management/screens/home/expense_list_details/receipt_capture/reciept_capture_screen.dart';
import 'package:expense_management/screens/home/expense_list_details/update_expense_list/update_expense_list_screen.dart';
import 'package:expense_management/widgets/expandable_fab.dart';
import 'package:expense_management/widgets/expense_bottom_sheet_widget.dart';
import 'package:expense_management/widgets/receipt_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ExpenseListDetailsUi extends StatefulWidget {
  final String listId;

  const ExpenseListDetailsUi({
    super.key,
    required this.listId,
  });

  @override
  State<ExpenseListDetailsUi> createState() => _ExpenseListDetailsUiState();
}

class _ExpenseListDetailsUiState extends State<ExpenseListDetailsUi> {
  List<PurchaseType> purchaseTypes = [];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseListsCubit, ExpenseListsState>(
      builder: (context, state) {
        if (state is ExpenseListsError) {
          return Scaffold(
            body: Center(
              child: Text('${AppLocalizations.of(context)!.error_loading}: ${state.message}'),
            ),
          );
        } else if (state is ExpenseListsLoaded) {
          final list = state.expenseLists.firstWhere(
            (e) => e.id == widget.listId,
          );
          return Scaffold(
            appBar: AppBar(
              title: Text(list.name),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bar_chart),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UpdateExpenseListScreen(
                          expenseList: list,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
            body: StreamBuilder<List<Receipt>>(
              stream: context.read<ExpenseListsCubit>().receiptsStream(widget.listId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final receipts = snapshot.data!;
                return ListView.builder(
                  itemCount: receipts.length,
                  itemBuilder: (context, index) => ReceiptListItem(
                    listId: list.id,
                    reciept: receipts[index],
                    icon: kIconRegistry[list.purchaseTypes.firstWhere((pt) => pt.id == receipts[index].purchaseTypeId).iconKey] ?? Icons.question_mark,
                    currency: list.currency,
                    user: list.allowedUsers.firstWhere((u) => u.id == receipts[index].addedByUserId).email,
                  ),
                );
              },
            ),
            floatingActionButton: ExpandableFab(
              children: [
                ActionButton(
                  onPressed: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ReceiptCaptureScreen(
                          imageSource: ImageSource.gallery,
                          expenseListId: list.id,
                          currency: list.currency,
                          purchaseTypes: list.purchaseTypes,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.photo),
                ),
                ActionButton(
                  onPressed: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ReceiptCaptureScreen(
                          imageSource: ImageSource.camera,
                          expenseListId: list.id,
                          currency: list.currency,
                          purchaseTypes: list.purchaseTypes,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_alt),
                ),
                ActionButton(
                  onPressed: () async {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return ExpenseBottomSheetWidget(
                          listId: widget.listId,
                          currency: list.currency,
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.edit_document),
                ),
              ],
            ),
          );
        }
        // While loading
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
