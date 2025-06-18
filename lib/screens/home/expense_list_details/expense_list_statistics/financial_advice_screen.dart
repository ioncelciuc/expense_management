import 'package:expense_management/core/constants.dart';
import 'package:expense_management/cubits/ai/ai_cubit.dart';
import 'package:expense_management/cubits/ai/ai_state.dart';
import 'package:expense_management/cubits/language/language_cubit.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/models/purchase_type.dart';
import 'package:expense_management/models/receipt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FinancialAdviceScreen extends StatefulWidget {
  final String listName;
  final List<Receipt> lastMonthReceipts;
  final int maxBudget;
  final String currency;
  final List<PurchaseType> purchaseTypes;

  const FinancialAdviceScreen({
    super.key,
    required this.listName,
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

  @override
  void initState() {
    setPrompt();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AiCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.financial_advice),
        ),
        body: BlocConsumer<AiCubit, AiState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is AiInitial) {
              BlocProvider.of<AiCubit>(context).getFinancialSuggestion(prompt);
              return Center(
                child: Padding(
                  padding: kPagePadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(AppLocalizations.of(context)!.financial_advice_loading),
                    ],
                  ),
                ),
              );
            }
            if (state is AiFailed) {
              return Center(
                child: Padding(
                  padding: kPagePadding,
                  child: Text(state.response.message ?? 'Unknown error occured'),
                ),
              );
            }
            if (state is AiFinancialAdviceCompleted) {
              return SingleChildScrollView(
                padding: kPagePadding,
                child: Text(
                  state.advice,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }
            return Center(
              child: Padding(
                padding: kPagePadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.financial_advice_loading),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  setPrompt() {
    prompt = '''
I have an expense list called ${widget.listName}.
This list represents my expenses since the 1st of this month: ${widget.lastMonthReceipts.map((e) => e.toMap()).toList()}.
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
