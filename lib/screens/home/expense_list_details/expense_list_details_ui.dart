import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/core/constants.dart';
import 'package:expense_management/core/shared_functions.dart';
import 'package:expense_management/cubits/expense_lists/expense_lists_cubit.dart';
import 'package:expense_management/cubits/expense_lists/expense_lists_state.dart';
import 'package:expense_management/cubits/language/language_cubit.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/models/purchase_type.dart';
import 'package:expense_management/models/receipt.dart';
import 'package:expense_management/models/reocurring_payment.dart';
import 'package:expense_management/screens/home/expense_list_details/expense_list_statistics/expense_list_statistics_screen.dart';
import 'package:expense_management/screens/home/expense_list_details/receipt_capture/reciept_capture_screen.dart';
import 'package:expense_management/screens/home/expense_list_details/update_expense_list/update_expense_list_screen.dart';
import 'package:expense_management/widgets/expandable_fab.dart';
import 'package:expense_management/widgets/expense_bottom_sheet_widget.dart';
import 'package:expense_management/widgets/receipt_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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
  bool _didCheckRecurring = false;

  List<Receipt> receipts = [];

  String? selectedPeriod;
  List<String> periods = [];

  String? selectedPurchaseType;
  List<String> purchaseTypes = [];

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
          selectedPeriod ??= AppLocalizations.of(context)!.time_period_from_month_start;
          periods = [
            AppLocalizations.of(context)!.time_period_from_month_start,
            AppLocalizations.of(context)!.time_period_last_month,
            AppLocalizations.of(context)!.time_period_last_three_months,
            AppLocalizations.of(context)!.time_period_last_six_months,
            AppLocalizations.of(context)!.time_period_last_year,
            AppLocalizations.of(context)!.all,
          ];
          selectedPurchaseType ??= AppLocalizations.of(context)!.all;
          purchaseTypes = [];
          purchaseTypes.add(AppLocalizations.of(context)!.all);
          for (int i = 0; i < list.purchaseTypes.length; i++) {
            if (!purchaseTypes.contains(list.purchaseTypes[i].name)) {
              purchaseTypes.add(list.purchaseTypes[i].name);
            }
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(list.name),
              actions: [
                IconButton(
                  onPressed: () {
                    showFilterModal(context);
                  },
                  icon: const Icon(Icons.filter_alt),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ExpenseListStatisticsScreen(
                          expenseList: list,
                        ),
                      ),
                    );
                  },
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
              stream: context.read<ExpenseListsCubit>().receiptsStream(
                    widget.listId,
                    sfGetFilteredDate(selectedPeriod ?? AppLocalizations.of(context)!.all, context),
                    selectedPurchaseType == AppLocalizations.of(context)!.all ? null : list.purchaseTypes.firstWhere((pt) => pt.name == selectedPurchaseType).id,
                  ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                receipts = snapshot.data!;
                if (!_didCheckRecurring) {
                  checkForReocurringPayments(
                    list.id,
                    list.reocurringPayments,
                    receipts,
                    list.purchaseTypes[0],
                  );
                  _didCheckRecurring = true;
                }
                if (receipts.isEmpty && selectedPurchaseType != AppLocalizations.of(context)!.all) {
                  return Padding(
                    padding: kPagePadding,
                    child: Center(
                      child: Text(
                        '${AppLocalizations.of(context)!.filter_no_elements}:\n${AppLocalizations.of(context)!.purchase_type} = $selectedPurchaseType\n${AppLocalizations.of(context)!.time_period} = $selectedPeriod',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (receipts.isEmpty) {
                  return Padding(
                    padding: kPagePadding,
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.no_expenses,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                    itemCount: receipts.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          index > 0 && sfIsTheSameDay(receipts[index].dateTime, receipts[index - 1].dateTime)
                              ? const SizedBox()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Text(
                                        DateFormat(index > 0 && !sfIsTheSameYear(receipts[index].dateTime, receipts[index - 1].dateTime) ? 'dd MMM yyyy' : 'dd MMM', BlocProvider.of<LanguageCubit>(context).language.languageCode).format(receipts[index].dateTime),
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Divider(),
                                  ],
                                ),
                          ReceiptListItem(
                            listId: list.id,
                            reciept: receipts[index],
                            icon: kIconRegistry[list.purchaseTypes.firstWhere((pt) => pt.id == receipts[index].purchaseTypeId).iconKey] ?? Icons.question_mark,
                            currency: list.currency,
                            user: list.allowedUsers.firstWhere((u) => u.id == receipts[index].addedByUserId).email,
                          ),
                        ],
                      );
                    });
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

  Future<dynamic> showFilterModal(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => BottomSheet(
        onClosing: () {},
        builder: (context) => Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 64),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.filter,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  label: Text(AppLocalizations.of(context)!.time_period),
                ),
                value: selectedPeriod,
                isDense: true,
                onChanged: (newPeriod) {
                  if (newPeriod != null) {
                    selectedPeriod = newPeriod;
                    setState(() {});
                  }
                },
                items: periods.map((period) {
                  return DropdownMenuItem(
                    value: period,
                    child: Text(period),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  label: Text(AppLocalizations.of(context)!.purchase_type),
                ),
                value: selectedPurchaseType,
                isDense: true,
                onChanged: (newPurchaseType) {
                  if (newPurchaseType != null) {
                    selectedPurchaseType = newPurchaseType;
                    setState(() {});
                  }
                },
                items: purchaseTypes.map((pt) {
                  return DropdownMenuItem(
                    value: pt,
                    child: Text(pt),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /*
  checkForReocurringPayments(
                  list.id,
                  list.reocurringPayments,
                  receipts,
                  list.purchaseTypes[0],
                );
   */

  checkForReocurringPayments(
    String listId,
    List<ReocurringPayment> reocurringPayments,
    List<Receipt> receipts,
    PurchaseType purchaseType,
  ) {
    DateTime firstOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    List<Receipt> thisMonthReceipts = receipts.where((r) => r.dateTime.isAfter(firstOfMonth) || r.dateTime.isAtSameMomentAs(firstOfMonth)).toList();
    for (ReocurringPayment reocurringPayment in reocurringPayments) {
      List<Receipt> receiptForPayment = thisMonthReceipts
          .where(
            (r) => reocurringPayment.dayOfMonth == r.dateTime.day && reocurringPayment.name == r.name && reocurringPayment.sum == r.price,
          )
          .toList();
      print('RECEIPT FOR PAYMENT');
      print(receiptForPayment.length);
      if (reocurringPayment.dayOfMonth <= DateTime.now().day && receiptForPayment.isEmpty) {
        Receipt receipt = Receipt(
          id: FirebaseFirestore.instance.collection('reocurringPayment').doc().id,
          name: reocurringPayment.name,
          price: reocurringPayment.sum,
          quantity: 1,
          purchaseTypeId: purchaseType.id,
          dateTime: DateTime(firstOfMonth.year, firstOfMonth.month, reocurringPayment.dayOfMonth),
          addedByUserId: FirebaseAuth.instance.currentUser!.uid,
        );
        BlocProvider.of<ExpenseListsCubit>(context).addReciept(listId, receipt);
      }
    }
  }
}
