import 'package:expense_management/core/constants.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class PurchaseTypeWidget extends StatelessWidget {
  final TextEditingController nameController;
  final String selectedIconKey;
  final void Function(String?)? onSelectIcon;
  final void Function(DismissDirection)? onDismissed;
  final DismissDirection dismissDirection;

  const PurchaseTypeWidget({
    super.key,
    required this.nameController,
    required this.selectedIconKey,
    this.onSelectIcon,
    this.onDismissed,
    this.dismissDirection = DismissDirection.endToStart,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(nameController),
      direction: dismissDirection,
      onDismissed: onDismissed,
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              textEditingController: nameController,
              hintText: AppLocalizations.of(context)!.name,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                label: Text(AppLocalizations.of(context)!.icon),
              ),
              value: selectedIconKey,
              isDense: true,
              onChanged: onSelectIcon,
              items: kIconRegistry.keys.map((iconKey) {
                return DropdownMenuItem(
                  value: iconKey,
                  child: Icon(kIconRegistry[iconKey]),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
