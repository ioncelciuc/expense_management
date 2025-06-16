import 'dart:math';

import 'package:expense_management/core/constants.dart';
import 'package:expense_management/core/shared_functions.dart';
import 'package:expense_management/cubits/language/language_cubit.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/models/receipt.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class BarChartExpensesPerMonth extends StatefulWidget {
  final List<Receipt> receipts;
  final String currency;

  const BarChartExpensesPerMonth({
    super.key,
    required this.receipts,
    required this.currency,
  });

  @override
  State<BarChartExpensesPerMonth> createState() => _BarChartExpensesPerMonthState();
}

class _BarChartExpensesPerMonthState extends State<BarChartExpensesPerMonth> {
  String? selectedPeriod;
  List<String> periods = [];
  List<double> monthsAmount = [];
  List<DateTime> months = [];

  List<DateTime> getMonths(DateTime start, DateTime end) {
    // Normalize to the first day of their respective months
    DateTime current = DateTime(start.year, start.month);
    final DateTime last = DateTime(end.year, end.month);

    final List<DateTime> months = [];

    // Iterate month by month until we pass 'last'
    while (!current.isAfter(last)) {
      months.add(current);
      // Advance one month, rolling over year if needed
      final int nextMonth = current.month == 12 ? 1 : current.month + 1;
      final int nextYear = current.month == 12 ? current.year + 1 : current.year;
      current = DateTime(nextYear, nextMonth);
    }

    return months;
  }

  List<double> getSums(List<Receipt> receipts, List<DateTime> months) {
    List<double> sums = [];
    for (int i = 0; i < months.length - 1; i++) {
      List<Receipt> monthlyReceipts = receipts.where((r) => (r.dateTime.isAfter(months[i]) || r.dateTime.isAtSameMomentAs(months[i])) && r.dateTime.isBefore(months[i + 1])).toList();
      double sum = 0;
      for (Receipt receipt in monthlyReceipts) {
        sum += receipt.price;
      }
      sums.add(sum);
    }
    List<Receipt> lastMonthReceipts = receipts.where((r) => r.dateTime.isAfter(months.last) || r.dateTime.isAtSameMomentAs(months.last)).toList();
    double sum = 0;
    for (Receipt receipt in lastMonthReceipts) {
      sum += receipt.price;
    }
    sums.add(sum);
    return sums;
  }

  @override
  Widget build(BuildContext context) {
    selectedPeriod ??= AppLocalizations.of(context)!.time_period_last_three_months;
    periods = [
      AppLocalizations.of(context)!.time_period_last_three_months,
      AppLocalizations.of(context)!.time_period_last_six_months,
    ];

    months = months.isEmpty
        ? getMonths(
            sfGetFilteredDate(selectedPeriod ?? AppLocalizations.of(context)!.time_period_from_month_start, context),
            DateTime.now(),
          )
        : months;
    monthsAmount = monthsAmount.isEmpty
        ? getSums(
            widget.receipts,
            months,
          )
        : monthsAmount;
    final double highest = monthsAmount.isNotEmpty ? monthsAmount.reduce((a, b) => max(a, b)) : 0;
    final double maxY = highest * 1.2;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: kPagePadding,
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.bar_chart_tutorial,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
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
                  DateTime dateTime = sfGetFilteredDate(selectedPeriod ?? AppLocalizations.of(context)!.time_period_from_month_start, context);
                  months = getMonths(dateTime, DateTime.now());
                  monthsAmount = getSums(widget.receipts, months);
                  setState(() {});
                }
              },
              items: periods.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  maxY: (monthsAmount.isNotEmpty ? monthsAmount.reduce((a, b) => a > b ? a : b) : 0) * 1.2,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final int idx = value.toInt();
                          if (idx < 0 || idx >= months.length) return const SizedBox.shrink();
                          final month = months[idx];
                          final label = DateFormat('MMM yy', BlocProvider.of<LanguageCubit>(context).language.languageCode).format(month);
                          return SideTitleWidget(
                            meta: meta,
                            space: 6,
                            child: Text(label, style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: maxY != 0 ? maxY / 5 : 1,
                        reservedSize: 32,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    for (int i = 0; i < monthsAmount.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            color: Theme.of(context).colorScheme.primary,
                            toY: monthsAmount[i],
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                  ],
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String obs = '';
                        if (groupIndex > 0 && monthsAmount[groupIndex] > monthsAmount[groupIndex - 1]) {
                          obs = '${(monthsAmount[groupIndex] - monthsAmount[groupIndex - 1]).toStringAsFixed(2)} ${widget.currency} ${AppLocalizations.of(context)!.more_than_last_month}';
                        } else if (groupIndex > 0 && monthsAmount[groupIndex] < monthsAmount[groupIndex - 1]) {
                          obs = '${(monthsAmount[groupIndex - 1] - monthsAmount[groupIndex]).toStringAsFixed(2)} ${widget.currency} ${AppLocalizations.of(context)!.less_than_last_month}';
                        }
                        final text = rod.toY.toStringAsFixed(2);
                        return BarTooltipItem(
                          '$text ${widget.currency}\n\n$obs',
                          TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
