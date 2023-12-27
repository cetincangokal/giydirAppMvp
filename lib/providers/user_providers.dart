import 'package:flutter/widgets.dart';
import 'package:giydir_mvp2/models/user.dart';
import 'package:giydir_mvp2/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  User get getUser => _user ??
      const User(
          username: '',
          uid: '',
          email: '',
          photoUrl: '',
          nameAndSurname: '',
          followers: [],
          following: []);

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
