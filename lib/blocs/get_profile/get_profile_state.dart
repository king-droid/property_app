import 'package:property_feeds/models/user_profile.dart';

abstract class GetProfileState {
  GetProfileState();
}

class Initial extends GetProfileState {
  Initial() : super();
}

class Loading extends GetProfileState {
  Loading() : super();
}

class ProfileLoaded extends GetProfileState {
  final UserProfile? userProfile;

  ProfileLoaded(this.userProfile) : super();
}

class Error extends GetProfileState {
  final String? error;

  Error(this.error) : super();
}
