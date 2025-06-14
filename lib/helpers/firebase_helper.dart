import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/models/user_model.dart';
import 'package:logging/logging.dart';

class FirebaseHelper {
  static final logger = Logger('FirebaseHelper');

  static String userCollection = 'users';
  static String expenseListsCollection = 'expense_lists';
  static String expenseItemsSubcollection = 'expense_items';

  static Future<void> addUser(UserModel user) async {
    try {
      await FirebaseFirestore.instance.collection(userCollection).doc(user.id).set(user.toMap());
    } on FirebaseException catch (e) {
      logger.severe(e.message);
    }
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
      logger.severe(e.message);
      return null;
    }
  }
}
