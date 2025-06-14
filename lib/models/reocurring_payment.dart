class ReocurringPayment {
  String name;
  double sum;
  int dayOfMonth;

  ReocurringPayment({
    required this.name,
    required this.sum,
    required this.dayOfMonth,
  });

  factory ReocurringPayment.fromMap(Map<String, dynamic> map) {
    return ReocurringPayment(
      name: map['name'],
      sum: map['sum'],
      dayOfMonth: map['dateOfMonth'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sum': sum,
      'dateOfMonth': dayOfMonth,
    };
  }
}
