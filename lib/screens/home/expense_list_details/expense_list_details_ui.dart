import 'package:expense_management/core/constants.dart';
import 'package:expense_management/core/shared_functions.dart';
import 'package:expense_management/cubits/expense_lists/expense_lists_cubit.dart';
import 'package:expense_management/cubits/expense_lists/expense_lists_state.dart';
import 'package:expense_management/cubits/language/language_cubit.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/models/receipt.dart';
import 'package:expense_management/screens/home/expense_list_details/expense_list_statistics/expense_list_statistics_screen.dart';
import 'package:expense_management/screens/home/expense_list_details/receipt_capture/reciept_capture_screen.dart';
import 'package:expense_management/screens/home/expense_list_details/update_expense_list/update_expense_list_screen.dart';
import 'package:expense_management/widgets/expandable_fab.dart';
import 'package:expense_management/widgets/expense_bottom_sheet_widget.dart';
import 'package:expense_management/widgets/receipt_list_item.dart';
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
  List<Receipt> reciepts = [];

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
                reciepts = snapshot.data!;
                if (reciepts.isEmpty && selectedPurchaseType != AppLocalizations.of(context)!.all) {
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
                if (reciepts.isEmpty) {
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
                    itemCount: reciepts.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          index > 0 && sfIsTheSameDay(reciepts[index].dateTime, reciepts[index - 1].dateTime)
                              ? const SizedBox()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Text(
                                        DateFormat(index > 0 && !sfIsTheSameYear(reciepts[index].dateTime, reciepts[index - 1].dateTime) ? 'dd MMM yyyy' : 'dd MMM', BlocProvider.of<LanguageCubit>(context).language.languageCode).format(reciepts[index].dateTime),
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Divider(),
                                  ],
                                ),
                          ReceiptListItem(
                            listId: list.id,
                            reciept: reciepts[index],
                            icon: kIconRegistry[list.purchaseTypes.firstWhere((pt) => pt.id == reciepts[index].purchaseTypeId).iconKey] ?? Icons.question_mark,
                            currency: list.currency,
                            user: list.allowedUsers.firstWhere((u) => u.id == reciepts[index].addedByUserId).email,
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
}
