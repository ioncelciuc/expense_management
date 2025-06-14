import 'package:cloud_firestore/cloud_firestore.dart';

class Reciept {
  final String name;
  final double price;
  final int quantity;
  final String purchaseTypeId;
  final DateTime dateTime;
  final String addedByUserId;

  const Reciept({
    required this.name,
    required this.price,
    required this.quantity,
    required this.purchaseTypeId,
    required this.dateTime,
    required this.addedByUserId,
  });

  factory Reciept.fromMap(Map<String, dynamic> map) {
    return Reciept(
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
      purchaseTypeId: map['purchaseTypeId'],
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      addedByUserId: map['addedByUserId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'purchaseTypeId': purchaseTypeId,
      'dateTime': Timestamp.fromDate(dateTime),
      'addedByUserId': addedByUserId,
    };
  }
}
