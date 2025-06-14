import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/models/purchase_type.dart';
import 'package:expense_management/models/reocurring_payment.dart';
import 'package:expense_management/models/user_model.dart';

class ExpenseList {
  String id;
  String name;
  String description;
  List<UserModel> allowedUsers;
  String currency;
  int maxBudgetPerMonth;
  List<ReocurringPayment> reocurringPayments;
  List<PurchaseType> purchaseTypes;
  DateTime createdAt;
  DateTime modifiedAt;

  ExpenseList({
    required this.id,
    required this.name,
    required this.description,
    required this.allowedUsers,
    required this.maxBudgetPerMonth,
    required this.currency,
    required this.reocurringPayments,
    required this.purchaseTypes,
    DateTime? createdAt,
    DateTime? modifiedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? (createdAt ?? DateTime.now());

  factory ExpenseList.fromMap(Map<String, dynamic> map) {
    return ExpenseList(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      allowedUsers: (map['allowedUsers'] as List).map((um) => UserModel.fromMap(um)).toList(),
      maxBudgetPerMonth: map['maxBudgetPerMonth'],
      currency: map['currency'],
      reocurringPayments: (map['reocurringPayments'] as List).map((rp) => ReocurringPayment.fromMap(rp)).toList(),
      purchaseTypes: (map['purchaseTypes'] as List).map((pt) => PurchaseType.fromMap(pt)).toList(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      modifiedAt: (map['modifiedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'allowedUsers': allowedUsers.map((user) => user.toMap()).toList(),
      'maxBudgetPerMonth': maxBudgetPerMonth,
      'currency': currency,
      'reocurringPayments': reocurringPayments.map((rp) => rp.toMap()).toList(),
      'purchaseTypes': purchaseTypes.map((pt) => pt.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'modifiedAt': Timestamp.fromDate(modifiedAt),
    };
  }
}
