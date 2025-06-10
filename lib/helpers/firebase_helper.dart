import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/models/user_model.dart';

class FirebaseHelper {
  static Future<void> addUser(UserModel user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.id).set(user.toMap());
  }

  static Future<bool> checkIfUserExists(String email) async {
    final querySnap = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).limit(1).get();
    return querySnap.docs.isNotEmpty;
  }
}
