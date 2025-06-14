import 'package:expense_management/core/constants.dart';
import 'package:expense_management/cubits/expense_lists/expense_lists_cubit.dart';
import 'package:expense_management/cubits/expense_lists/expense_lists_state.dart';
import 'package:expense_management/models/purchase_type.dart';
import 'package:expense_management/models/reciept.dart';
import 'package:expense_management/widgets/custom_text_field.dart';
import 'package:expense_management/widgets/info_text.dart';
import 'package:expense_management/widgets/snackbar_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ExpenseBottomSheetWidget extends StatefulWidget {
  final String listId;

  const ExpenseBottomSheetWidget({
    super.key,
    required this.listId,
  });

  @override
  State<ExpenseBottomSheetWidget> createState() => _ExpenseBottomSheetWidgetState();
}

class _ExpenseBottomSheetWidgetState extends State<ExpenseBottomSheetWidget> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  PurchaseType? selectedPurchaseType;

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
              selectedPurchaseType ??= purchaseTypes.first;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add an expense',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    textEditingController: nameController,
                    hintText: 'Title',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          textEditingController: amountController,
                          hintText: 'Price per unit',
                          textInputType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          textEditingController: quantityController,
                          hintText: 'Quantity',
                          textInputType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<PurchaseType>(
                    decoration: InputDecoration(
                      label: Text('PurchaseType'),
                    ),
                    value: selectedPurchaseType,
                    isDense: true,
                    onChanged: (PurchaseType? purchaseType) {
                      if (purchaseType != null) {
                        selectedPurchaseType = purchaseType;
                        setState(() {});
                      }
                    },
                    items: purchaseTypes.map((pt) {
                      return DropdownMenuItem(
                        value: pt,
                        child: Row(
                          children: [
                            Icon(kIconRegistry[pt.iconKey]),
                            const SizedBox(width: 16),
                            Text(pt.name),
                          ],
                        ),
                      );
                    }).toList(),
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

                      Reciept reciept = Reciept(
                        name: nameController.text.trim(),
                        price: double.parse(amountController.text.trim()),
                        quantity: int.parse(quantityController.text.trim()),
                        purchaseTypeId: selectedPurchaseType!.id,
                        dateTime: DateTime.now(),
                        addedByUserId: FirebaseAuth.instance.currentUser!.uid,
                      );

                      BlocProvider.of<ExpenseListsCubit>(context).addReciept(widget.listId, reciept);

                      Navigator.of(context).pop();
                    },
                    child: Text('Add item'),
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
      return 'All fields must be completed';
    }
    double? price = double.tryParse(amountController.text.trim());
    if (price == null) {
      return 'Inputted price is not correct';
    }
    int? quantity = int.tryParse(quantityController.text.trim());
    if (quantity == null) {
      return 'Quantity should be a whole number';
    }
    return '';
  }
}

class ExpenseQuantity extends StatelessWidget {
  const ExpenseQuantity({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () {},
          child: Icon(Icons.exposure_minus_1),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: CustomTextField(
            textEditingController: TextEditingController(text: '1'),
            hintText: 'Quantity',
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () {},
          child: Icon(Icons.exposure_plus_1),
        ),
      ],
    );
  }
}
