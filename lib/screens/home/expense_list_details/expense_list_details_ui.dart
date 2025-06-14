import 'package:expense_management/core/constants.dart';
import 'package:expense_management/cubits/expense_lists/expense_lists_cubit.dart';
import 'package:expense_management/cubits/expense_lists/expense_lists_state.dart';
import 'package:expense_management/models/purchase_type.dart';
import 'package:expense_management/widgets/expandable_fab.dart';
import 'package:expense_management/widgets/expense_bottom_sheet_widget.dart';
import 'package:expense_management/widgets/receipt_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

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
          return const Scaffold(
            body: Center(child: Text('Error loading list')),
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
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
            body: ListView.builder(
              itemCount: list.reciepts.length,
              itemBuilder: (context, index) {
                return ReceiptListItem(
                  listId: list.id,
                  reciept: list.reciepts[index],
                  icon: kIconRegistry[list.purchaseTypes.firstWhere((pt) => pt.id == list.reciepts[index].purchaseTypeId).iconKey] ?? Icons.question_mark,
                  currency: list.currency,
                  user: list.allowedUsers.firstWhere((u) => u.id == list.reciepts[index].addedByUserId).email,
                );
                return Dismissible(
                  key: ValueKey(list.reciepts[index].id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    String recieptName = list.reciepts[index].name;

                    BlocProvider.of<ExpenseListsCubit>(context).deleteReciept(
                      widget.listId,
                      list.reciepts[index].id,
                    );

                    Fluttertoast.showToast(
                      msg: 'Deleted $recieptName',
                      backgroundColor: Theme.of(context).colorScheme.error,
                    );
                  },
                  background: Container(
                    color: Theme.of(context).colorScheme.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          kIconRegistry[list.purchaseTypes.firstWhere((pt) => pt.id == list.reciepts[index].purchaseTypeId).iconKey],
                          size: 36,
                        ),
                        title: Text(list.reciepts[index].name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${list.reciepts[index].price} ${list.currency} - ${list.reciepts[index].quantity} pcs'),
                            Text(
                              '${DateFormat('dd/MM/yyyy').format(list.reciepts[index].dateTime)} - ${list.allowedUsers.firstWhere((u) => u.id == list.reciepts[index].addedByUserId).email}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return ExpenseBottomSheetWidget(
                                listId: widget.listId,
                                initialReciept: list.reciepts[index],
                              );
                            },
                          );
                        },
                      ),
                      const Divider(),
                    ],
                  ),
                );
              },
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
                  onPressed: () async {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return ExpenseBottomSheetWidget(listId: widget.listId);
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
