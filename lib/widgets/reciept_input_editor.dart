import 'package:expense_management/core/constants.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/models/purchase_type.dart';
import 'package:expense_management/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class RecieptInputEditor extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController amountController;
  final String currency;
  final TextEditingController quantityController;
  final PurchaseType selectedPurchaseType;
  final void Function(PurchaseType?)? onChangedPurchaseType;
  final List<PurchaseType> purchaseTypes;

  const RecieptInputEditor({
    super.key,
    required this.nameController,
    required this.amountController,
    required this.currency,
    required this.quantityController,
    required this.selectedPurchaseType,
    required this.onChangedPurchaseType,
    required this.purchaseTypes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextField(
          textEditingController: nameController,
          hintText: AppLocalizations.of(context)!.name,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                textEditingController: amountController,
                hintText: '${AppLocalizations.of(context)!.price} - $currency',
                textInputType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                textEditingController: quantityController,
                hintText: AppLocalizations.of(context)!.quantity,
                textInputType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<PurchaseType>(
          decoration: InputDecoration(
            label: Text(AppLocalizations.of(context)!.purchase_type),
          ),
          value: selectedPurchaseType,
          isDense: true,
          onChanged: onChangedPurchaseType,
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
      ],
    );
  }
}
