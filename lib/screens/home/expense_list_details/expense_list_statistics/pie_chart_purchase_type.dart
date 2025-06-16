import 'package:expense_management/core/constants.dart';
import 'package:expense_management/core/shared_functions.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/models/receipt.dart';

class PieChartPurchaseType extends StatefulWidget {
  final List<Receipt> receipts;
  final Map<String, String> purchaseTypeLabels;
  final Map<String, Color> purchaseTypeColors;
  final String currency;

  const PieChartPurchaseType({
    super.key,
    required this.receipts,
    required this.purchaseTypeLabels,
    required this.purchaseTypeColors,
    required this.currency,
  });

  @override
  State<PieChartPurchaseType> createState() => _PieChartPurchaseTypeState();
}

class _PieChartPurchaseTypeState extends State<PieChartPurchaseType> {
  String? selectedPeriod;
  List<String> periods = [];
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    selectedPeriod ??= AppLocalizations.of(context)!.time_period_from_month_start;
    periods = [
      AppLocalizations.of(context)!.time_period_from_month_start,
      AppLocalizations.of(context)!.time_period_last_month,
      AppLocalizations.of(context)!.time_period_last_three_months,
      AppLocalizations.of(context)!.time_period_last_six_months,
      AppLocalizations.of(context)!.time_period_last_year,
      AppLocalizations.of(context)!.all,
    ];

    if (widget.receipts.isEmpty) {
      return const Center(child: Text('No receipts to display.'));
    }

    // Compute date threshold and filtered receipts
    final threshold = sfGetFilteredDate(selectedPeriod ?? AppLocalizations.of(context)!.time_period_from_month_start, context);
    final filtered = widget.receipts.where((r) => r.dateTime.isAfter(threshold) || r.dateTime.isAtSameMomentAs(threshold));

    // Aggregate totals by type
    final totalsByType = <String, double>{};
    for (var r in filtered) {
      totalsByType.update(r.purchaseTypeId, (v) => v + r.price, ifAbsent: () => r.price);
    }

    // Convert to list and sort by descending total
    final entries = totalsByType.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final totalAll = entries.fold<double>(0.0, (sum, e) => sum + e.value);

    // Build pie sections with touch response
    final sections = List.generate(entries.length, (i) {
      final typeId = entries[i].key;
      final value = entries[i].value;
      final percent = (value / totalAll) * 100;
      final isTouched = i == touchedIndex;
      final color = widget.purchaseTypeColors[typeId] ?? Colors.grey;

      return PieChartSectionData(
        color: color,
        value: value,
        title: '${percent.toStringAsFixed(1)}%',
        radius: isTouched ? 100 : 90,
        titleStyle: TextStyle(
          fontSize: isTouched ? 16 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: kPagePadding,
        child: Column(
          children: [
            Text(
              'Pie chart representing the percent of budget taken by each purchase type',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            // Period selector
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                label: Text(AppLocalizations.of(context)!.time_period),
              ),
              value: selectedPeriod,
              isDense: true,
              onChanged: (newPeriod) {
                if (newPeriod != null) {
                  setState(() {
                    selectedPeriod = newPeriod;
                    touchedIndex = null; // reset selection on period change
                  });
                }
              },
              items: periods.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            ),

            const SizedBox(height: 32),

            // Pie chart
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 35,
                  sectionsSpace: 0,
                  borderData: FlBorderData(show: false),
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      final idx = response?.touchedSection?.touchedSectionIndex;
                      setState(() {
                        if (idx == null || idx < 0 || idx >= entries.length) {
                          touchedIndex = null;
                        } else {
                          touchedIndex = idx;
                        }
                      });
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Display tapped slice info
            if (touchedIndex != null)
              Column(
                children: [
                  Text(
                    widget.purchaseTypeLabels[entries[touchedIndex!].key]!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${entries[touchedIndex!].value.toStringAsFixed(2)} ${widget.currency} spent',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Legend (sorted by descending total)
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: entries.map((e) {
                final typeId = e.key;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: widget.purchaseTypeColors[typeId] ?? Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(widget.purchaseTypeLabels[typeId] ?? 'Unknown'),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
