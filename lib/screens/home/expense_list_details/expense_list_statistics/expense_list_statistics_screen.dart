import 'package:expense_management/core/constants.dart';
import 'package:expense_management/models/expense_list.dart';
import 'package:expense_management/models/receipt.dart';
import 'package:expense_management/screens/home/expense_list_details/expense_list_statistics/monthly_budget_progess.dart';
import 'package:expense_management/screens/home/expense_list_details/expense_list_statistics/pie_chart_purchase_type.dart';
import 'package:flutter/material.dart';

class ExpenseListStatisticsScreen extends StatelessWidget {
  final ExpenseList expenseList;
  final List<Receipt> receipts;

  const ExpenseListStatisticsScreen({
    super.key,
    required this.expenseList,
    required this.receipts,
  });

  double getUsedBudget() {
    double usedBudget = 0;
    DateTime now = DateTime.now();
    List<Receipt> recieptsFromBegginingOfMonth = receipts
        .where(
          (r) => r.dateTime.isAfter(DateTime(now.year, now.month)) || r.dateTime.isAtSameMomentAs(DateTime(now.year, now.month)),
        )
        .toList();
    for (Receipt receipt in recieptsFromBegginingOfMonth) {
      usedBudget += receipt.price;
    }
    return usedBudget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics for ${expenseList.name}'),
      ),
      body: ListView(
        padding: kPagePadding,
        children: [
          MonthlyBudgetProgess(
            totalBudget: double.parse(expenseList.maxBudgetPerMonth.toString()),
            usedBudget: getUsedBudget(),
            currency: expenseList.currency,
          ),
          const SizedBox(height: 16),
          PieChartPurchaseType(
            receipts: receipts,
            purchaseTypeLabels: {
              for (var pt in expenseList.purchaseTypes) pt.id: pt.name,
            },
            purchaseTypeColors: {
              for (var pt in expenseList.purchaseTypes) pt.id: Colors.primaries[expenseList.purchaseTypes.indexOf(pt) % Colors.primaries.length],
            },
          ),
        ],
      ),
    );
  }
}
