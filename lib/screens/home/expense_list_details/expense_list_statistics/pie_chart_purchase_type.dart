import 'package:expense_management/core/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/models/receipt.dart';
import 'dart:math';

class PieChartPurchaseType extends StatefulWidget {
  final List<Receipt> receipts;
  final Map<String, String> purchaseTypeLabels; // purchaseTypeId → label
  final Map<String, Color> purchaseTypeColors; // purchaseTypeId → color

  const PieChartPurchaseType({
    super.key,
    required this.receipts,
    required this.purchaseTypeLabels,
    required this.purchaseTypeColors,
  });

  @override
  State<PieChartPurchaseType> createState() => _PieChartPurchaseTypeState();
}

class _PieChartPurchaseTypeState extends State<PieChartPurchaseType> {
  String selectedPeriod = 'Month start';
  List<String> periods = [
    'Month start',
    'Past month',
    'Past 3 months',
    'Custom',
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.receipts.isEmpty) {
      return const Center(child: Text('No receipts to display.'));
    }

    // Aggregate total price by purchaseTypeId
    final Map<String, double> totalsByType = {};
    for (var receipt in widget.receipts) {
      totalsByType.update(
        receipt.purchaseTypeId,
        (value) => value + receipt.price,
        ifAbsent: () => receipt.price,
      );
    }

    final double total = totalsByType.values.fold(0, (sum, val) => sum + val);

    final sections = totalsByType.entries.map((entry) {
      final typeId = entry.key;
      final value = entry.value;
      final percent = (value / total) * 100;
      final label = widget.purchaseTypeLabels[typeId] ?? 'Unknown';
      final color = widget.purchaseTypeColors[typeId] ?? Colors.grey;

      return PieChartSectionData(
        color: color,
        value: value,
        title: '${percent.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: kPagePadding,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      label: Text('Period for statistic'),
                    ),
                    value: selectedPeriod,
                    isDense: true,
                    onChanged: (newPeriod) {
                      if (newPeriod != null) {
                        selectedPeriod = newPeriod;
                        setState(() {});
                      }
                    },
                    items: periods.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(p),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text('Date'),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: totalsByType.keys.map((typeId) {
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
