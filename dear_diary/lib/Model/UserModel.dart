class UserModel {
  String username;
  String password;

  UserModel(this.username, this.password);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'user_name': username, 'password': password};
    return map;
  }

  UserModel.fromMap(Map<String, dynamic> map) {
    username = map['user_name'];
    password = map['password'];
  }
}
