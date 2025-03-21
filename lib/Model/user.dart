// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

class User {
  final int id;
  final String username;
  final String phoneno;
  final String password;
  final String JWTToken;
  User({
    required this.id,
    required this.username,
    required this.phoneno,
    required this.password,
    required this.JWTToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'username': username,
      'phoneno': phoneno,
      'password': password,
      'JWTToken' : JWTToken
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? 0,
      username: map['UserName'] ?? '',
      phoneno: map['PhoneNo'] ?? '',
      password: map['Password'] ?? '',
      JWTToken: map['JWTToken'] ?? ''
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}