import 'package:property_feeds/models/user.dart';

abstract class LoginState {
  LoginState();
}

class Initial extends LoginState {
  Initial() : super();
}

class Loading extends LoginState {
  Loading() : super();
}

class LoggedInWithEmail extends LoginState {
  final bool? result;
  final User? user;

  LoggedInWithEmail(this.result, this.user) : super();
}

class LoggedInWithMobile extends LoginState {
  final bool? result;
  final User? user;
  
  LoggedInWithMobile(this.result, this.user) : super();
}

class ProfileInComplete extends LoginState {
  final User? user;

  ProfileInComplete(this.user) : super();
}

class Error extends LoginState {
  final String? error;

  Error(this.error) : super();
}
