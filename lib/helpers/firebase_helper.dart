import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/models/user_model.dart';

class FirebaseHelper {
  static Future<void> addUser(UserModel user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.id).set(user.toMap());
  }
}
