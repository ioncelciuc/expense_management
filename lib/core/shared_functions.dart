import 'package:expense_management/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

bool hasDuplicateValues(List<String> values) {
  final trimmedValues = values.map((v) => v.trim()).toList();
  final uniqueValues = trimmedValues.toSet();
  return uniqueValues.length != trimmedValues.length;
}

DateTime subtractMonths(DateTime date, int monthsToSubtract) {
  final int newYear = date.year - ((monthsToSubtract - (date.month - 1)) ~/ 12);
  final int newMonth = ((date.month - monthsToSubtract - 1) % 12 + 12) % 12 + 1;
  return DateTime(newYear, newMonth, 1);
}

DateTime getFilteredDate(String filterSelection, BuildContext context) {
  final loc = AppLocalizations.of(context)!;
  final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  if (filterSelection == loc.time_period_from_month_start) {
    return DateTime(now.year, now.month, 1);
  } else if (filterSelection == loc.time_period_last_month) {
    return subtractMonths(now, 1);
  } else if (filterSelection == loc.time_period_last_three_months) {
    return subtractMonths(now, 3);
  } else if (filterSelection == loc.time_period_last_six_months) {
    return subtractMonths(now, 6);
  } else if (filterSelection == loc.time_period_last_year) {
    return DateTime(now.year - 1, now.month, 1);
  } else if (filterSelection == loc.all) {
    return DateTime(2020);
  }
  return DateTime(2020);
}
