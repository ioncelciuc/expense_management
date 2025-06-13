import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/models/expense_list.dart';
import 'package:expense_management/models/response.dart';
import 'package:expense_management/models/user_model.dart';

class FirebaseHelper {
  static String userCollection = 'users';
  static String expenseListsCollection = 'expense_lists';

  static Future<void> addUser(UserModel user) async {
    await FirebaseFirestore.instance.collection(userCollection).doc(user.id).set(user.toMap());
  }

  static Future<UserModel?> getUserByEmail(String email) async {
    try {
      final querySnap = await FirebaseFirestore.instance.collection(userCollection).where('email', isEqualTo: email).limit(1).get();
      final querySnapDocs = querySnap.docs;
      if (querySnapDocs.isEmpty) {
        return null;
      }
      return UserModel.fromMap(querySnapDocs[0].data());
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  static String generateDocId(String collectionPath) {
    return FirebaseFirestore.instance.collection(collectionPath).doc().id;
  }

  static Future<Response> createExpenseList(ExpenseList expenseList) async {
    try {
      await FirebaseFirestore.instance.collection(expenseListsCollection).doc(expenseList.id).set(expenseList.toMap());
      return Response(success: true);
    } on FirebaseException catch (e) {
      return Response(success: false, message: e.message);
    }
  }
}
