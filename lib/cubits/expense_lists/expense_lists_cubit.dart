import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/cubits/expense_lists/expense_lists_state.dart';
import 'package:expense_management/helpers/firebase_helper.dart';
import 'package:expense_management/models/expense_list.dart';
import 'package:expense_management/models/reciept.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpenseListsCubit extends Cubit<ExpenseListsState> {
  StreamSubscription? _subscription;

  ExpenseListsCubit() : super(ExpenseListsInitial());

  void listenToExpenseLists() {
    _subscription?.cancel();

    final query = FirebaseFirestore.instance.collection(FirebaseHelper.expenseListsCollection).where(
      'allowedUsers',
      arrayContains: {
        'id': FirebaseAuth.instance.currentUser!.uid,
        'email': FirebaseAuth.instance.currentUser!.email,
      },
    ).orderBy('modifiedAt', descending: true);

    _subscription = query.snapshots().listen(
      (snapshot) {
        final expenseLists = snapshot.docs.map((doc) {
          Map<String, dynamic> expenseListMap = doc.data();
          return ExpenseList.fromMap(expenseListMap);
        }).toList();
        emit(ExpenseListsLoaded(expenseLists));
      },
      onError: (error) {
        emit(ExpenseListsError(error.toString()));
      },
    );
  }

  Future<void> addExpenseList(ExpenseList list) async {
    try {
      await FirebaseFirestore.instance.collection(FirebaseHelper.expenseListsCollection).doc(list.id).set(list.toMap());
      // No need to emit here — listener will pick up the change
    } catch (e) {
      emit(ExpenseListsError(e.toString()));
    }
  }

  Future<void> updateExpenseList(ExpenseList updatedList) async {
    try {
      await FirebaseFirestore.instance.collection(FirebaseHelper.expenseListsCollection).doc(updatedList.id).update(updatedList.toMap());
      _updateExpenseListLastModified(updatedList.id);
    } catch (e) {
      emit(ExpenseListsError(e.toString()));
    }
  }

  Future<void> deleteExpenseList(String id) async {
    try {
      await FirebaseFirestore.instance.collection(FirebaseHelper.expenseListsCollection).doc(id).delete();
    } catch (e) {
      emit(ExpenseListsError(e.toString()));
    }
  }

  Future<void> _updateExpenseListLastModified(String listId) async {
    try {
      await FirebaseFirestore.instance.collection(FirebaseHelper.expenseListsCollection).doc(listId).update({
        'modifiedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      emit(ExpenseListsError(e.message ?? 'Failed to update modifiedAt'));
    } catch (e) {
      emit(ExpenseListsError(e.toString()));
    }
  }

  Future<void> addMultipleReciepts(String expenseListId, List<Reciept> reciepts) async {
    try {
      for (Reciept reciept in reciepts) {
        addReciept(expenseListId, reciept);
      }
    } on FirebaseException catch (e) {
      emit(ExpenseListsError(e.message ?? 'Failed to add receipt'));
    } catch (e) {
      emit(ExpenseListsError(e.toString()));
    }
  }

  Future<void> addReciept(String expenseListId, Reciept reciept) async {
    try {
      await FirebaseFirestore.instance.collection(FirebaseHelper.expenseListsCollection).doc(expenseListId).update({
        'reciepts': FieldValue.arrayUnion([reciept.toMap()])
      });
      _updateExpenseListLastModified(expenseListId);
    } on FirebaseException catch (e) {
      emit(ExpenseListsError(e.message ?? 'Failed to add receipt'));
    } catch (e) {
      emit(ExpenseListsError(e.toString()));
    }
  }

  Future<void> updateReciept(String expenseListId, Reciept updatedReciept) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseHelper.expenseListsCollection).doc(expenseListId);

      final doc = await docRef.get();
      final data = doc.data();
      if (data == null) throw Exception("Document does not exist");

      final List<dynamic> existing = data['reciepts'] ?? [];
      final updatedList = existing.map((e) {
        final rec = Reciept.fromMap(Map<String, dynamic>.from(e));
        return rec.id == updatedReciept.id ? updatedReciept.toMap() : e;
      }).toList();

      await docRef.update({'reciepts': updatedList});

      _updateExpenseListLastModified(expenseListId);
    } on FirebaseException catch (e) {
      emit(ExpenseListsError(e.message ?? 'Failed to update receipt'));
    } catch (e) {
      emit(ExpenseListsError(e.toString()));
    }
  }

  Future<void> deleteReciept(String expenseListId, String recieptId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseHelper.expenseListsCollection).doc(expenseListId);

      final doc = await docRef.get();
      final data = doc.data();
      if (data == null) throw Exception("Document does not exist");

      final List<dynamic> existing = data['reciepts'] ?? [];
      final updatedList = existing.where((e) {
        final rec = Reciept.fromMap(Map<String, dynamic>.from(e));
        return rec.id != recieptId;
      }).toList();

      await docRef.update({'reciepts': updatedList});

      _updateExpenseListLastModified(expenseListId);
    } on FirebaseException catch (e) {
      emit(ExpenseListsError(e.message ?? 'Failed to delete receipt'));
    } catch (e) {
      emit(ExpenseListsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
