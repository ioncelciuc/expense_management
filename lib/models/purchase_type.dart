class PurchaseType {
  final String name;
  final String iconKey;

  PurchaseType({
    required this.name,
    required this.iconKey,
  });

  factory PurchaseType.fromMap(Map<String, dynamic> map) {
    return PurchaseType(
      name: map['name'],
      iconKey: map['iconKey'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconKey': iconKey,
    };
  }
}
