import 'package:property_feeds/models/user.dart';

abstract class CompleteProfileState {
  CompleteProfileState();
}

class Initial extends CompleteProfileState {
  Initial() : super();
}

class Loading extends CompleteProfileState {
  Loading() : super();
}

class ProfileUpdated extends CompleteProfileState {
  final bool? result;
  final User? user;

  ProfileUpdated(this.result, this.user) : super();
}

class Error extends CompleteProfileState {
  final String? error;

  Error(this.error) : super();
}
