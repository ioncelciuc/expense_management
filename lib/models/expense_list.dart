import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseList {
  String id;
  String name;
  String description;
  List allowedUsers;
  String currency;
  DateTime createdAt;
  DateTime modifiedAt;

  ExpenseList({
    required this.id,
    required this.name,
    required this.description,
    required this.allowedUsers,
    required this.currency,
    DateTime? createdAt,
    DateTime? modifiedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? (createdAt ?? DateTime.now());

  factory ExpenseList.fromMap(Map<String, dynamic> map) {
    return ExpenseList(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      allowedUsers: map['allowedUsers'],
      currency: map['currency'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      modifiedAt: (map['modifiedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'allowedUsers': allowedUsers,
      'currency': currency,
      'createdAt': Timestamp.fromDate(createdAt),
      'modifiedAt': Timestamp.fromDate(modifiedAt),
    };
  }
}
