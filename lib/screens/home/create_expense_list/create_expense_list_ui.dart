import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/core/constants.dart';
import 'package:expense_management/core/shared_functions.dart';
import 'package:expense_management/cubits/expense_lists/expense_lists_cubit.dart';
import 'package:expense_management/helpers/firebase_helper.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/models/expense_list.dart';
import 'package:expense_management/models/purchase_type.dart';
import 'package:expense_management/models/reocurring_payment.dart';
import 'package:expense_management/models/user_model.dart';
import 'package:expense_management/screens/home/create_expense_list/purchase_type_widget.dart';
import 'package:expense_management/screens/home/create_expense_list/reocurring_payment_widget.dart';
import 'package:expense_management/widgets/custom_text_field.dart';
import 'package:expense_management/widgets/snackbar_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

class CreateExpenseListUi extends StatefulWidget {
  const CreateExpenseListUi({super.key});

  @override
  State<CreateExpenseListUi> createState() => _CreateExpenseListUiState();
}

class _CreateExpenseListUiState extends State<CreateExpenseListUi> {
  final logger = Logger('CreateExpenseListUi');

  final ScrollController pageScrollController = ScrollController();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  TextEditingController chipController = TextEditingController();
  final List<UserModel> chips = [];
  final ScrollController chipScrollController = ScrollController();

  TextEditingController budgetController = TextEditingController();
  final List<String> currencies = [
    'RON',
    'EUR',
    'USD',
    'GBP',
    'CHF',
  ];
  String selectedCurrency = 'RON';
  List<TextEditingController> rpNameControllers = [];
  List<TextEditingController> rpAmountControllers = [];
  List<int> rpDays = [];

  List<TextEditingController> ptControllers = [];
  List<String> ptIcons = [];

  @override
  void initState() {
    chips.add(
      UserModel(
        id: FirebaseAuth.instance.currentUser!.uid,
        email: FirebaseAuth.instance.currentUser!.email!,
      ),
    );
    ptControllers.add(TextEditingController(text: 'Factura curent'));
    ptControllers.add(TextEditingController(text: 'Carburant'));
    ptControllers.add(TextEditingController(text: 'Haine'));
    ptIcons.add('electricity');
    ptIcons.add('gas');
    ptIcons.add('clothing');
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    chipController.dispose();
    chipScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.create_expense_list),
        actions: [
          IconButton(
            onPressed: saveData,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: ListView(
        padding: kPagePadding,
        controller: pageScrollController,
        children: [
          CustomTextField(
            textEditingController: titleController,
            hintText: AppLocalizations.of(context)!.expense_list_name,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            textEditingController: descriptionController,
            hintText: AppLocalizations.of(context)!.expense_list_description,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          //EMAILS THAT CAN ACCESS THIS LIST
          Text(
            'Add people\'s email who can access this expense list:',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          // const SizedBox(height: 8),
          SingleChildScrollView(
            controller: chipScrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: chips.asMap().entries.map((entry) {
                final idx = entry.key;
                final name = entry.value.email;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: idx == 0
                      // First chip is not removable:
                      ? Chip(
                          label: Text(name),
                        )
                      // All others get an "x" delete button:
                      : Chip(
                          label: Text(name),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              chips.removeAt(idx);
                            });
                          },
                        ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          //INPUT TO ADD AN EMAIL
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  textEditingController: chipController,
                  hintText: AppLocalizations.of(context)!.expense_list_add_person_by_email,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) => addChip(),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: ElevatedButton(
                  onPressed: addChip,
                  child: Text(AppLocalizations.of(context)!.add),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          //BUDGET SELECTOR
          Text(
            AppLocalizations.of(context)!.expense_list_budget_explanation,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  textEditingController: budgetController,
                  hintText: AppLocalizations.of(context)!.monthly_budget,
                  textInputType: const TextInputType.numberWithOptions(
                    signed: true,
                    decimal: false,
                  ),
                  textInputAction: TextInputAction.done,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    label: Text(AppLocalizations.of(context)!.currency),
                  ),
                  value: selectedCurrency,
                  items: currencies.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCurrency = value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          //REOCURRING PAYMENTS
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rpNameControllers.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 16);
            },
            itemBuilder: (context, index) => ReocurringPaymentWidget(
              nameController: rpNameControllers[index],
              amountController: rpAmountControllers[index],
              dayOfMonth: rpDays[index],
              onSelectDayOfMonth: (selectedValue) {
                if (selectedValue != null) {
                  rpDays[index] = selectedValue;
                  setState(() {});
                }
              },
              onDismissed: (dir) {
                rpNameControllers.removeAt(index);
                rpAmountControllers.removeAt(index);
                rpDays.removeAt(index);
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              rpNameControllers.add(TextEditingController());
              rpAmountControllers.add(TextEditingController());
              rpDays.add(1);
              setState(() {});
              WidgetsBinding.instance.addPostFrameCallback((_) {
                pageScrollController.animateTo(
                  pageScrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              });
            },
            child: Text(
              AppLocalizations.of(context)!.add_monthly_reocurring_payment,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          //PURCHASE TYPES
          Text(
            AppLocalizations.of(context)!.expense_list_purchase_type_explanation,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ptControllers.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 16);
            },
            itemBuilder: (context, index) {
              return PurchaseTypeWidget(
                nameController: ptControllers[index],
                selectedIconKey: ptIcons[index],
                onSelectIcon: (newIconKey) {
                  if (newIconKey != null) {
                    ptIcons[index] = newIconKey;
                  }
                  setState(() {});
                },
                onDismissed: (dir) {
                  ptControllers.removeAt(index);
                  ptIcons.removeAt(index);
                  setState(() {});
                },
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (ptControllers.isNotEmpty && ptControllers.last.text.isEmpty) {
                SnackbarHandler(
                  context: context,
                  message: AppLocalizations.of(context)!.error_purchase_type_empty_name,
                );
                return;
              }
              ptControllers.add(TextEditingController());
              ptIcons.add('question');
              setState(() {});
            },
            child: Text(AppLocalizations.of(context)!.add_another_purchase_type),
          ),
        ],
      ),
    );
  }

  void addChip() async {
    final email = chipController.text.trim();
    chipController.clear();

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      SnackbarHandler(
        context: context,
        message: AppLocalizations.of(context)!.email_validation_invalid_email,
      );
      return;
    }
    bool emailAlreadyAdded = false;
    for (UserModel userModel in chips) {
      if (userModel.email == email) {
        emailAlreadyAdded = true;
      }
    }
    if (emailAlreadyAdded) {
      SnackbarHandler(
        context: context,
        message: AppLocalizations.of(context)!.email_validation_email_taken,
      );
      return;
    }
    UserModel? userToAdd = await FirebaseHelper.getUserByEmail(email);

    if (userToAdd == null) {
      if (!mounted) return;
      SnackbarHandler(
        context: context,
        message: '${AppLocalizations.of(context)!.no_user_with_that_email}: $email',
      );
      return;
    }

    setState(() {
      chips.add(userToAdd);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chipScrollController.animateTo(
        chipScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String isDataValid() {
    if (titleController.text.trim().isEmpty || descriptionController.text.trim().isEmpty || chips.isEmpty || selectedCurrency.isEmpty) {
      return AppLocalizations.of(context)!.expense_list_complete_all_fields_to_create;
    }

    if (!sfIsPositiveInteger(budgetController.text.trim())) {
      return AppLocalizations.of(context)!.error_field_must_have_positive_numbers;
    }

    for (int i = 0; i < rpNameControllers.length; i++) {
      if (!sfIsPositiveDouble(rpAmountControllers[i].text.trim())) {
        return AppLocalizations.of(context)!.error_reocurring_payment_sum;
      }
      if (rpNameControllers[i].text.trim().isEmpty) {
        return AppLocalizations.of(context)!.error_reocurring_payment_empty_name;
      }
    }

    if (ptControllers.isEmpty) {
      return AppLocalizations.of(context)!.error_no_purchase_type;
    }
    for (int i = 0; i < ptControllers.length; i++) {
      if (ptControllers[i].text.trim().isEmpty) {
        return AppLocalizations.of(context)!.error_purchase_type_empty_name;
      }
    }
    final ptControllerValues = ptControllers.map((c) => c.text.trim()).toList();
    if (sfHasDuplicateValues(ptControllerValues)) {
      return AppLocalizations.of(context)!.error_purchase_type_name_duplicate;
    }

    return '';
  }

  void saveData() {
    String isDataValidMessage = isDataValid();
    if (isDataValidMessage.isNotEmpty) {
      SnackbarHandler(
        context: context,
        message: isDataValidMessage,
        durationSeconds: 8,
      );
      return;
    }

    List<ReocurringPayment> reocurringPayments = [];
    for (int i = 0; i < rpNameControllers.length; i++) {
      reocurringPayments.add(
        ReocurringPayment(
          id: FirebaseFirestore.instance.collection('reocurringPayments').doc().id,
          name: rpNameControllers[i].text.trim(),
          sum: double.parse(rpAmountControllers[i].text.trim()),
          dayOfMonth: rpDays[i],
        ),
      );
    }

    List<PurchaseType> purchaseTypes = [];
    for (int i = 0; i < ptControllers.length; i++) {
      purchaseTypes.add(
        PurchaseType(
          id: FirebaseFirestore.instance.collection('purchaseType').doc().id,
          name: ptControllers[i].text.trim(),
          iconKey: ptIcons[i],
        ),
      );
    }
    ExpenseList expenseList = ExpenseList(
      id: FirebaseFirestore.instance.collection('expense_lists').doc().id,
      name: titleController.text,
      description: descriptionController.text,
      allowedUsers: chips,
      maxBudgetPerMonth: int.parse(budgetController.text.trim()),
      currency: selectedCurrency,
      reocurringPayments: reocurringPayments,
      purchaseTypes: purchaseTypes,
    );
    BlocProvider.of<ExpenseListsCubit>(context).addExpenseList(expenseList);
    Navigator.of(context).pop();
  }
}
