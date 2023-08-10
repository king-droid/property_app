abstract class LoginEvent {}

class LoginWithEmail extends LoginEvent {
  LoginWithEmail();
}

class LoginWithMobile extends LoginEvent {
  final String? mobile_number;

  LoginWithMobile(this.mobile_number);
}
