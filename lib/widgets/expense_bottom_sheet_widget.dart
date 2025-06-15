import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/cubits/expense_lists/expense_lists_cubit.dart';
import 'package:expense_management/cubits/expense_lists/expense_lists_state.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/models/purchase_type.dart';
import 'package:expense_management/models/receipt.dart';
import 'package:expense_management/widgets/reciept_input_editor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ExpenseBottomSheetWidget extends StatefulWidget {
  final String listId;
  final String currency;
  final Receipt? initialReciept;

  const ExpenseBottomSheetWidget({
    super.key,
    required this.listId,
    required this.currency,
    this.initialReciept,
  });

  @override
  State<ExpenseBottomSheetWidget> createState() => _ExpenseBottomSheetWidgetState();
}

class _ExpenseBottomSheetWidgetState extends State<ExpenseBottomSheetWidget> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(text: '1');
  PurchaseType? selectedPurchaseType;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    if (widget.initialReciept != null) {
      nameController.text = widget.initialReciept!.name;
      amountController.text = widget.initialReciept!.price.toString();
      quantityController.text = widget.initialReciept!.quantity.toString();
      selectedDate = widget.initialReciept!.dateTime;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 24,
          right: 16,
          left: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BlocBuilder<ExpenseListsCubit, ExpenseListsState>(
          builder: (context, state) {
            if (state is ExpenseListsLoaded) {
              List<PurchaseType> purchaseTypes = state.expenseLists.firstWhere((e) => e.id == widget.listId).purchaseTypes;
              if (selectedPurchaseType == null) {
                if (widget.initialReciept != null) {
                  selectedPurchaseType = purchaseTypes.firstWhere(
                    (pt) => pt.id == widget.initialReciept!.purchaseTypeId,
                    orElse: () => purchaseTypes.first,
                  );
                } else {
                  selectedPurchaseType ??= purchaseTypes.first;
                }
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.initialReciept == null ? AppLocalizations.of(context)!.add_expense : AppLocalizations.of(context)!.update_expense,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  RecieptInputEditor(
                    nameController: nameController,
                    amountController: amountController,
                    currency: widget.currency,
                    quantityController: quantityController,
                    selectedPurchaseType: selectedPurchaseType!,
                    onChangedPurchaseType: (PurchaseType? purchaseType) {
                      if (purchaseType != null) {
                        selectedPurchaseType = purchaseType;
                        setState(() {});
                      }
                    },
                    purchaseTypes: purchaseTypes,
                    selectedDate: selectedDate,
                    onSelectDate: () async {
                      DateTime? newDate = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                      );
                      if (newDate != null) {
                        selectedDate = newDate;
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      String errorMessage = isDataValid();
                      if (errorMessage.isNotEmpty) {
                        Fluttertoast.showToast(
                          msg: errorMessage,
                          backgroundColor: Theme.of(context).colorScheme.error,
                        );
                        return;
                      }

                      Receipt reciept = Receipt(
                        id: widget.initialReciept?.id ?? FirebaseFirestore.instance.collection('reciepts').doc().id,
                        name: nameController.text.trim(),
                        price: double.parse(amountController.text.trim()),
                        quantity: int.parse(quantityController.text.trim()),
                        purchaseTypeId: selectedPurchaseType!.id,
                        dateTime: selectedDate,
                        addedByUserId: widget.initialReciept?.addedByUserId ?? FirebaseAuth.instance.currentUser!.uid,
                      );

                      if (widget.initialReciept == null) {
                        BlocProvider.of<ExpenseListsCubit>(context).addReciept(widget.listId, reciept);
                      } else {
                        BlocProvider.of<ExpenseListsCubit>(context).updateReciept(widget.listId, reciept);
                      }

                      Navigator.of(context).pop();
                    },
                    child: Text(widget.initialReciept == null ? AppLocalizations.of(context)!.add : AppLocalizations.of(context)!.update),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  String isDataValid() {
    if (nameController.text.trim().isEmpty || amountController.text.trim().isEmpty || quantityController.text.trim().isEmpty) {
      return AppLocalizations.of(context)!.error_all_fields_must_be_completed;
    }
    double? price = double.tryParse(amountController.text.trim());
    if (price == null || price < 0) {
      return AppLocalizations.of(context)!.error_price_not_correct;
    }
    int? quantity = int.tryParse(quantityController.text.trim());
    if (quantity == null || quantity < 0) {
      return AppLocalizations.of(context)!.error_quanity_whole_number;
    }
    return '';
  }
}
