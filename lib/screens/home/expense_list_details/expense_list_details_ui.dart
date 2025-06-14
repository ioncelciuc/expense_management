import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/helpers/firebase_helper.dart';
import 'package:expense_management/models/expense_list.dart';
import 'package:expense_management/widgets/expandable_fab.dart';
import 'package:expense_management/widgets/info_text.dart';
import 'package:flutter/material.dart';

class ExpenseListDetailsUi extends StatefulWidget {
  final ExpenseList expenseList;

  const ExpenseListDetailsUi({
    super.key,
    required this.expenseList,
  });

  @override
  State<ExpenseListDetailsUi> createState() => _ExpenseListDetailsUiState();
}

class _ExpenseListDetailsUiState extends State<ExpenseListDetailsUi> {
  Query get query => FirebaseFirestore.instance.collection('${FirebaseHelper.expenseListsCollection}/${widget.expenseList.id}/${FirebaseHelper.expenseItemsSubcollection}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expenseList.name),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bar_chart),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return InfoText(text: 'No expenses');
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data()! as Map<String, dynamic>;
              return ListTile(
                title: Text(index.toString()),
              );
            },
          );
        },
      ),
      floatingActionButton: ExpandableFab(
        children: [
          ActionButton(
            onPressed: () async {},
            icon: const Icon(Icons.photo),
          ),
          ActionButton(
            onPressed: () async {},
            icon: const Icon(Icons.camera_alt),
          ),
          ActionButton(
            onPressed: () async {},
            icon: const Icon(Icons.edit_document),
          ),
        ],
      ),
    );
  }
}
