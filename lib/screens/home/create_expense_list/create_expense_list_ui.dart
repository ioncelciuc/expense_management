import 'package:expense_management/core/constants.dart';
import 'package:expense_management/cubits/create_list/create_list_cubit.dart';
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
                  child: Text('Add'),
                ),
              ),
              // IconButton(
              //   icon: const Icon(Icons.add_circle_outline),
              //   onPressed: addChip,
              // ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          //BUDGET SELECTOR
          Text(
            'Add an estimated monthly budget for this list and your preffered currency. You can also add some reocurring monthly payments!',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  textEditingController: budgetController,
                  hintText: 'Monthly budget',
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
              if (rpNameControllers.isNotEmpty) {
                String reocurringPaymentLastAmountError = isReocurringPaymentSumValid(rpAmountControllers.last);
                if (reocurringPaymentLastAmountError.isNotEmpty) {
                  SnackbarHandler(context: context, message: reocurringPaymentLastAmountError);
                  return;
                }
              }
              if (rpNameControllers.isEmpty || rpNameControllers.last.text.trim().isNotEmpty) {
                rpNameControllers.add(TextEditingController());
                rpAmountControllers.add(TextEditingController());
                rpDays.add(1);
              }

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
              'Add monthly reocurring payment',
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          //PURCHASE TYPES
          Text(
            'Create some custom types of expenses. You have some expamples down below. Also, you can add more later or edit the current ones:',
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
                  message: 'A type of purchase can\'t have an empty name',
                );
                return;
              }
              ptControllers.add(TextEditingController());
              ptIcons.add('question');
              setState(() {});
            },
            child: Text('Add another purchase type'),
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

    String monthlyBudgetError = isMonthlyBudgetValid();
    if (monthlyBudgetError.isNotEmpty) {
      return monthlyBudgetError;
    }

    for (int i = 0; i < rpNameControllers.length; i++) {
      String rpSumError = isReocurringPaymentSumValid(rpAmountControllers[i]);
      if (rpSumError.isNotEmpty) {
        return rpSumError;
      }
      if (rpNameControllers[i].text.trim().isEmpty) {
        return 'A reocurring payment can\'t have an empty name';
      }
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
          name: ptControllers[i].text.trim(),
          iconKey: ptIcons[i],
        ),
      );
    }
    ExpenseList expenseList = ExpenseList(
      id: FirebaseHelper.generateDocId(FirebaseHelper.expenseListsCollection),
      name: titleController.text,
      description: descriptionController.text,
      allowedUsers: chips,
      maxBudgetPerMonth: int.parse(budgetController.text.trim()),
      currency: selectedCurrency,
      reocurringPayments: reocurringPayments,
      purchaseTypes: purchaseTypes,
    );
    BlocProvider.of<CreateListCubit>(context).createList(expenseList);
  }

  String isMonthlyBudgetValid() {
    int? monthlyBudget = int.tryParse(budgetController.text.trim());
    if (monthlyBudget == null || monthlyBudget <= 0 || monthlyBudget > 900_000_000_000) {
      return 'This field should contain only positive numbers';
    }
    return '';
  }

  String isReocurringPaymentSumValid(TextEditingController controller) {
    double? sum = double.tryParse(controller.text.trim());
    if (sum == null || sum <= 0) {
      return 'Last monthly payment has a mistake regarding the sum';
    }
    return '';
  }
}
