class PurchaseType {
  final String id;
  final String name;
  final String iconKey;

  PurchaseType({
    required this.id,
    required this.name,
    required this.iconKey,
  });

  factory PurchaseType.fromMap(Map<String, dynamic> map) {
    return PurchaseType(
      id: map['id'],
      name: map['name'],
      iconKey: map['iconKey'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconKey': iconKey,
    };
  }

  // Override equality
  @override
  bool operator ==(Object other) => identical(this, other) || other is PurchaseType && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
