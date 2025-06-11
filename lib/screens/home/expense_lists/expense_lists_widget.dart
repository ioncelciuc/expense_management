import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/helpers/firebase_helper.dart';
import 'package:expense_management/models/expense_list.dart';
import 'package:expense_management/screens/home/expense_list_details/expense_list_details_screen.dart';
import 'package:expense_management/screens/home/expense_lists/expense_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExpenseListsWidget extends StatefulWidget {
  const ExpenseListsWidget({super.key});

  @override
  State<ExpenseListsWidget> createState() => _ExpenseListsWidgetState();
}

class _ExpenseListsWidgetState extends State<ExpenseListsWidget> {
  String get email => FirebaseAuth.instance.currentUser?.email ?? '';

  Query get query => FirebaseFirestore.instance.collection(FirebaseHelper.expenseListsCollection).where('allowedUsers', arrayContains: email).orderBy('modifiedAt', descending: true);

  Future<void> handleRefresh() async {
    await query.get(); // this bumps the client cache and triggers the stream
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: handleRefresh,
      child: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading lists: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(child: Text('No expense lists found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data()! as Map<String, dynamic>;
              // inject the ID so fromMap picks it up
              data['id'] = doc.id;
              final list = ExpenseList.fromMap(data);
              return ExpenseListItem(
                expenseList: list,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ExpenseListDetailsScreen(expenseList: list),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
