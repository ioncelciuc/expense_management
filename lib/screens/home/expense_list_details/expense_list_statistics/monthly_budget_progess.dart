import 'package:expense_management/core/constants.dart';
import 'package:flutter/material.dart';

class MonthlyBudgetProgess extends StatelessWidget {
  final String currency;
  final double totalBudget;
  final double usedBudget;

  const MonthlyBudgetProgess({
    super.key,
    required this.totalBudget,
    required this.usedBudget,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    double percentUsed = totalBudget == 0 ? 0 : (usedBudget / totalBudget).clamp(0.0, 1.0);
    bool isOverBudget = usedBudget > totalBudget;

    // Determine the color
    Color progressColor;
    if (isOverBudget) {
      progressColor = Colors.red; // Over budget
    } else if (percentUsed < 0.25) {
      progressColor = Colors.green;
    } else if (percentUsed < 0.75) {
      progressColor = Colors.amber;
    } else {
      progressColor = Colors.deepOrange; // Approaching limit
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: kPagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Budget used: ${usedBudget.toStringAsFixed(2)} / ${totalBudget.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: isOverBudget ? 1.0 : percentUsed,
                minHeight: 12,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            if (isOverBudget)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'You are over budget by ${(usedBudget - totalBudget).toStringAsFixed(2)} $currency',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
