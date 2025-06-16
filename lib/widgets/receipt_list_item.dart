import 'package:expense_management/cubits/expense_lists/expense_lists_cubit.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/models/receipt.dart';
import 'package:expense_management/widgets/expense_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReceiptListItem extends StatelessWidget {
  final String listId;
  final Receipt reciept;
  final IconData icon;
  final String currency;
  final String user;

  const ReceiptListItem({
    super.key,
    required this.listId,
    required this.reciept,
    required this.icon,
    required this.currency,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(reciept.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        String recieptName = reciept.name;
        double recieptPrice = reciept.price;
        int recieptQuantity = reciept.quantity;

        BlocProvider.of<ExpenseListsCubit>(context).deleteReciept(
          listId,
          reciept.id,
        );

        Fluttertoast.showToast(
          msg: '${AppLocalizations.of(context)!.deleted}: $recieptName - $recieptPrice $currency - $recieptQuantity pcs',
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
              icon,
              size: 36,
            ),
            title: Text(reciept.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${reciept.price} $currency - ${reciept.quantity} pcs'),
                Text(
                  user,
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
                    listId: listId,
                    currency: currency,
                    initialReciept: reciept,
                  );
                },
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
