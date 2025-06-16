import 'dart:convert';

import 'package:expense_management/core/constants.dart';
import 'package:expense_management/cubits/language/language_cubit.dart';
import 'package:expense_management/helpers/network_helper.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/models/purchase_type.dart';
import 'package:expense_management/models/receipt.dart';
import 'package:expense_management/models/response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FinancialAdviceScreen extends StatefulWidget {
  final List<Receipt> lastMonthReceipts;
  final int maxBudget;
  final String currency;
  final List<PurchaseType> purchaseTypes;

  const FinancialAdviceScreen({
    super.key,
    required this.lastMonthReceipts,
    required this.maxBudget,
    required this.currency,
    required this.purchaseTypes,
  });

  @override
  State<FinancialAdviceScreen> createState() => _FinancialAdviceScreenState();
}

class _FinancialAdviceScreenState extends State<FinancialAdviceScreen> {
  String prompt = "";
  bool loading = true;
  String advice = '';

  @override
  void initState() {
    setPrompt();
    loadData();
    super.initState();
  }

  loadData() async {
    try {
      Response response = await NetworkHelper.geminiApiCall(prompt);
      if (response.success) {
        print(response.obj);
        final Map<String, dynamic> decoded = jsonDecode(response.obj as String);
        final parts = (decoded['candidates'][0]['content']['parts'] as List);
        final textPart = parts.firstWhere((p) => p.containsKey('text'), orElse: () => {'text': ''})['text'] as String;
        advice = textPart;
      } else {
        Fluttertoast.showToast(msg: response.message ?? 'Unknown error occured');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }

    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.financial_advice),
      ),
      body: loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.financial_advice_loading),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: kPagePadding,
              child: Text(
                advice,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
    );
  }

  setPrompt() {
    prompt = '''
This is my list of expenses since the 1st of this month: ${widget.lastMonthReceipts.map((e) => e.toMap()).toList()}.
Note that price is the total price (so if a product says price 10 and quantity 5, it means 5 products that cost 2).
The purchaseTypes are ${widget.purchaseTypes.map((e) => e.toMap()).toList()}.
For this list, for this month I have a budget of ${widget.maxBudget} ${widget.currency}.
I am using the app Expense Manager in order to manage my expenses.
Based on my spending habits and my budget, please give me thorough financial advice. Something that is NOT generic and can help me spend less.
It should be in the form of a simple text and should be in the language ${BlocProvider.of<LanguageCubit>(context).language.countryCode}.
Don't give me the list in the response.
''';
    setState(() {});
  }
}
