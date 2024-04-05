class UserModel{
  String? email;
  String? password;
  String? fname;
  String? lname;
  String? username;
  String? phone;
  String? address;
  bool shoppingmode;
  Map<String, dynamic>? favorite;
  UserModel({required this.shoppingmode});
}