import 'package:flutter/widgets.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/utils/app_globals.dart';

class UserProvider extends ChangeNotifier {
  /// Internal, private state of the cart.
  User? user;

  /// An unmodifiable view of the items in the cart.
  User? get userData => user;

  void createUser(User? user) {
    this.user = user;
    if ((user?.defaultCity ?? "").isEmpty) {
      user?.defaultCity =
          ((user.interestedCities ?? "").split(',')[0] ?? "").trim();
    }
    AppGlobals().initUser(user);
    notifyListeners();
  }

  void updateUser(User? user) {
    this.user = user;
    AppGlobals().initUser(user);
    notifyListeners();
  }
}
