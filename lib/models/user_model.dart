class UserModel {
  final String id;
  final String email;
  final String? status;

  UserModel({
    required this.id,
    required this.email,
    this.status,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return status != null
        ? {
            'id': id,
            'email': email,
            'status': status,
          }
        : {
            'id': id,
            'email': email,
          };
  }
}
