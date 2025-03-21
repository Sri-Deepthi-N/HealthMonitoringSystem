import 'package:flutter/material.dart';
import 'package:health_management/Model/user.dart';

class UserProvider extends ChangeNotifier{
  User _user = User(
    id: 0,
    username: '',
    phoneno: '',
    password: '',
    JWTToken :'',
  );

  User get user => _user;

  void setUser(String user) {
    _user = User.fromJson(user);
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }
}