abstract class GetProfileEvent {}

class GetProfile extends GetProfileEvent {
  final String? userId;

  GetProfile(this.userId);
}

class InitProfile extends GetProfileEvent {
  InitProfile();
}
