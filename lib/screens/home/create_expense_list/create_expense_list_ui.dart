import 'package:expense_management/core/constants.dart';
import 'package:expense_management/cubits/create_list/create_list_cubit.dart';
import 'package:expense_management/helpers/firebase_helper.dart';
import 'package:expense_management/models/expense_list.dart';
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

  TextEditingController chipController = TextEditingController();
  final List<String> chips = [];
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
    chips.add('You - ${FirebaseAuth.instance.currentUser!.email}');
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
        title: Text('Create Expense List'),
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
            hintText: 'Name',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            textEditingController: descriptionController,
            hintText: 'Description',
          ),
          const SizedBox(height: 16),
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
                final name = entry.value;
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
                  hintText: 'Add person by Email',
                  onSubmitted: (value) => addChip(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: addChip,
              ),
            ],
          ),
          const SizedBox(height: 16),
          //CURRENCY SELECTOR
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              label: Text('Currency'),
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
        ],
      ),
    );
  }

  void addChip() async {
    final email = chipController.text.trim();
    chipController.clear();

    // basic email validation
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      SnackbarHandler(
        context: context,
        message: 'Please enter a valid email address.',
      );
      return;
    }
    if (chips.contains(email)) {
      SnackbarHandler(
        context: context,
        message: 'That email is already added.',
      );
      return;
    }
    bool emailExists = await FirebaseHelper.checkIfUserExists(email);

    if (!emailExists) {
      SnackbarHandler(
        context: context,
        message: 'There is no user with that email.',
      );
      return;
    }

    setState(() {
      chips.add(email);
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
      return 'Complete all fields to create an expense list';
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

    List<String> users = chips;
    users[0] = FirebaseAuth.instance.currentUser!.email!;
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
