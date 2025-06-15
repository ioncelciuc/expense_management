import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class ReocurringPaymentWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController amountController;
  final int dayOfMonth;
  final void Function(int?)? onSelectDayOfMonth;
  final void Function(DismissDirection)? onDismissed;
  final DismissDirection dismissDirection;

  const ReocurringPaymentWidget({
    super.key,
    required this.nameController,
    required this.amountController,
    required this.dayOfMonth,
    this.onDismissed,
    this.onSelectDayOfMonth,
    this.dismissDirection = DismissDirection.endToStart,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: dismissDirection,
      onDismissed: onDismissed,
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              textEditingController: nameController,
              hintText: AppLocalizations.of(context)!.name,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: CustomTextField(
              textEditingController: amountController,
              hintText: AppLocalizations.of(context)!.price,
              textInputType: const TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: DropdownButtonFormField<int>(
              decoration: InputDecoration(
                label: Text(AppLocalizations.of(context)!.day),
              ),
              value: dayOfMonth,
              isDense: true,
              onChanged: onSelectDayOfMonth,
              items: List.generate(31, (i) => i + 1).map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text('$day'),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
