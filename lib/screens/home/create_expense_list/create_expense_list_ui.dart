import 'package:expense_management/core/constants.dart';
import 'package:expense_management/cubits/create_list/create_list_cubit.dart';
import 'package:expense_management/helpers/firebase_helper.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/models/expense_list.dart';
import 'package:expense_management/models/user_model.dart';
import 'package:expense_management/widgets/custom_text_field.dart';
import 'package:expense_management/widgets/snackbar_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateExpenseListUi extends StatefulWidget {
  const CreateExpenseListUi({super.key});

  @override
  State<CreateExpenseListUi> createState() => _CreateExpenseListUiState();
}

class _CreateExpenseListUiState extends State<CreateExpenseListUi> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController budgetController = TextEditingController();

  TextEditingController chipController = TextEditingController();
  final List<UserModel> chips = [];
  final ScrollController chipScrollController = ScrollController();

  final List<String> currencies = [
    'RON',
    'EUR',
    'USD',
    'GBP',
    'CHF',
  ];
  String selectedCurrency = 'RON';

  @override
  void initState() {
    chips.add(
      UserModel(
        id: FirebaseAuth.instance.currentUser!.uid,
        email: FirebaseAuth.instance.currentUser!.email!,
      ),
    );
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
            'People\'s email who can access this list:',
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
                width: 100,
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
                width: 100,
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

    ExpenseList expenseList = ExpenseList(
      id: FirebaseHelper.generateDocId(FirebaseHelper.expenseListsCollection),
      name: titleController.text,
      description: descriptionController.text,
      allowedUsers: chips,
      currency: selectedCurrency,
    );
    BlocProvider.of<CreateListCubit>(context).createList(expenseList);
  }
}
