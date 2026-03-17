class UserModel {
  String uid;
  String name;
  String email;
  String role;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "role": role,
      "createdAt": DateTime.now(),
    };
  }
}