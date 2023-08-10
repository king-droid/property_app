import 'package:property_feeds/models/user.dart';

class AppGlobals {
  static final AppGlobals _singleton = AppGlobals._internal();
  static User? user;

  factory AppGlobals() {
    return _singleton;
  }

  initUser(User? _user) async {
    user = _user;
  }

  User? getUser() {
    return user;
  }

  setUser(User? _user) {
    user = _user;
  }

  AppGlobals._internal();
}
