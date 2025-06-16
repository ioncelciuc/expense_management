import 'package:expense_management/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

bool sfHasDuplicateValues(List<String> values) {
  final trimmedValues = values.map((v) => v.trim()).toList();
  final uniqueValues = trimmedValues.toSet();
  return uniqueValues.length != trimmedValues.length;
}

/// Returns a new [DateTime] corresponding to the first day of the month
/// that is [monthsToSubtract] before [date].
DateTime sfSubtractMonths(DateTime date, int monthsToSubtract) {
  // Convert current year/month into a zero-based total month count
  final int currentTotal = date.year * 12 + (date.month - 1);
  // Subtract the desired number of months
  final int newTotal = currentTotal - monthsToSubtract;
  // Convert back into year/month
  final int newYear = newTotal ~/ 12;
  final int newMonth = (newTotal % 12) + 1;
  // Return the first day of that month
  return DateTime(newYear, newMonth, 1);
}

// DateTime sfSubtractMonths(DateTime date, int monthsToSubtract) {
//   final int newYear = date.year - ((monthsToSubtract - (date.month - 1)) ~/ 12);
//   final int newMonth = ((date.month - monthsToSubtract - 1) % 12 + 12) % 12 + 1;
//   return DateTime(newYear, newMonth, 1);
// }

DateTime sfGetFilteredDate(String filterSelection, BuildContext context) {
  final loc = AppLocalizations.of(context)!;
  final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  if (filterSelection == loc.time_period_from_month_start) {
    return DateTime(now.year, now.month, 1);
  } else if (filterSelection == loc.time_period_last_month) {
    return sfSubtractMonths(now, 1);
  } else if (filterSelection == loc.time_period_last_three_months) {
    return sfSubtractMonths(now, 3);
  } else if (filterSelection == loc.time_period_last_six_months) {
    return sfSubtractMonths(now, 6);
  } else if (filterSelection == loc.time_period_last_year) {
    return DateTime(now.year - 1, now.month, 1);
  } else if (filterSelection == loc.all) {
    return DateTime(2020);
  }
  return DateTime(2020);
}

bool sfIsTheSameYear(DateTime dateTime1, DateTime dateTime2) {
  return dateTime1.year == dateTime2.year;
}

bool sfIsTheSameDay(DateTime dateTime1, DateTime dateTime2) {
  return dateTime1.year == dateTime2.year && dateTime1.month == dateTime2.month && dateTime1.day == dateTime2.day;
}

bool sfIsPositiveInteger(String text) {
  int? integer = int.tryParse(text.trim());
  return integer != null && integer > 0;
}

bool sfIsPositiveDouble(String text) {
  double? sum = double.tryParse(text.trim());
  return sum != null && sum > 0;
}
