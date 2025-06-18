import 'package:expense_management/core/constants.dart';
import 'package:expense_management/core/shared_functions.dart';
import 'package:expense_management/cubits/expense_lists/expense_lists_cubit.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/models/expense_list.dart';
import 'package:expense_management/models/receipt.dart';
import 'package:expense_management/screens/home/expense_list_details/expense_list_statistics/bar_chart_expenses_per_month.dart';
import 'package:expense_management/screens/home/expense_list_details/expense_list_statistics/financial_advice_screen.dart';
import 'package:expense_management/screens/home/expense_list_details/expense_list_statistics/monthly_budget_progess.dart';
import 'package:expense_management/screens/home/expense_list_details/expense_list_statistics/pie_chart_purchase_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpenseListStatisticsScreen extends StatefulWidget {
  final ExpenseList expenseList;

  const ExpenseListStatisticsScreen({
    super.key,
    required this.expenseList,
  });

  @override
  State<ExpenseListStatisticsScreen> createState() => _ExpenseListStatisticsScreenState();
}

class _ExpenseListStatisticsScreenState extends State<ExpenseListStatisticsScreen> {
  List<Receipt> receipts = [];

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
        title: Text('${AppLocalizations.of(context)!.statistics_for} ${widget.expenseList.name}'),
        actions: [
          IconButton(
            onPressed: () {
              DateTime monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FinancialAdviceScreen(
                    listName: widget.expenseList.name,
                    lastMonthReceipts: receipts.where((r) => r.dateTime.isAfter(monthStart) || r.dateTime.isAtSameMomentAs(monthStart)).toList(),
                    maxBudget: widget.expenseList.maxBudgetPerMonth,
                    currency: widget.expenseList.currency,
                    purchaseTypes: widget.expenseList.purchaseTypes,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.lightbulb),
          ),
        ],
      ),
      body: StreamBuilder(
          stream: context.read<ExpenseListsCubit>().receiptsStream(
                widget.expenseList.id,
                sfGetFilteredDate(AppLocalizations.of(context)!.all, context),
              ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            receipts = snapshot.data!;
            return ListView(
              padding: kPagePadding,
              children: [
                MonthlyBudgetProgess(
                  totalBudget: double.parse(widget.expenseList.maxBudgetPerMonth.toString()),
                  usedBudget: getUsedBudget(),
                  currency: widget.expenseList.currency,
                ),
                const SizedBox(height: 16),
                PieChartPurchaseType(
                  receipts: receipts,
                  purchaseTypeLabels: {
                    for (var pt in widget.expenseList.purchaseTypes) pt.id: pt.name,
                  },
                  purchaseTypeColors: {
                    for (var pt in widget.expenseList.purchaseTypes) pt.id: Colors.primaries[widget.expenseList.purchaseTypes.indexOf(pt) % Colors.primaries.length],
                  },
                  currency: widget.expenseList.currency,
                ),
                const SizedBox(height: 16),
                BarChartExpensesPerMonth(
                  receipts: receipts,
                  currency: widget.expenseList.currency,
                ),
              ],
            );
          }),
    );
  }
}
