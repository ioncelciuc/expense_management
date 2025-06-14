class ReocurringPayment {
  String id;
  String name;
  double sum;
  int dayOfMonth;

  ReocurringPayment({
    required this.id,
    required this.name,
    required this.sum,
    required this.dayOfMonth,
  });

  factory ReocurringPayment.fromMap(Map<String, dynamic> map) {
    return ReocurringPayment(
      id: map['id'],
      name: map['name'],
      sum: map['sum'],
      dayOfMonth: map['dateOfMonth'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sum': sum,
      'dateOfMonth': dayOfMonth,
    };
  }
}
