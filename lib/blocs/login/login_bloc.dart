import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:property_feeds/blocs/login/login_event.dart';
import 'package:property_feeds/blocs/login/login_state.dart';
import 'package:property_feeds/models/login_response.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/services/auth_service.dart';
import 'package:property_feeds/utils/app_utils.dart';

import '../../models/user.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  AuthService authService = AuthService();

  LoginBloc() : super(Initial()) {
    on<LoginWithEmail>(loginWithEmail);
    on<LoginWithMobile>(loginWithMobile);
  }

  Future<User?> guestLogin(String guestEmailId) async {
    try {
      var params = {
        "method": "guest_login",
        "email": guestEmailId,
      };

      final apiResponse = await authService.guestLogin(params);
      //return apiResponse.message;
      if (apiResponse.status == Status.success) {
        LoginResponse loginResponse = LoginResponse.fromJson(apiResponse.data);
        if (loginResponse.status == "success") {
          if (loginResponse.data != null) {
            await AppUtils.saveUser(loginResponse.data);
            await AppUtils.setLoggedIn();
            return loginResponse.data;
          } else {
            return null;
          }
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (err) {
      return null;
    }
  }

  Future<void> loginWithEmail(
      LoginWithEmail event, Emitter<LoginState> emit) async {
    emit(Loading());
    var userAccount;
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
        'email',
        /*'https://www.googleapis.com/auth/contacts.readonly',*/
      ]);
      userAccount = await _googleSignIn.signIn();
      var params = {
        "method": "email_login",
        "email": userAccount.email,
      };

      final apiResponse = await authService.emailLogin(params);
      if (apiResponse.status == Status.success) {
        LoginResponse loginResponse = LoginResponse.fromJson(apiResponse.data);
        if (loginResponse.status == "success") {
          if (loginResponse.data != null) {
            if ((loginResponse.data?.accountStatus ?? "") ==
                "PROFILE_INCOMPLETE") {
              emit(ProfileInComplete(loginResponse.data));
            } else {
              AppUtils.setLoggedIn();
              emit(LoggedInWithEmail(true, loginResponse.data));
            }
          } else {
            emit(Error("User data not found"));
          }
        } else {
          emit(Error(loginResponse.message));
        }
      } else {
        emit(Error(apiResponse.message ?? ""));
      }
    } catch (err) {
      print(err);
      emit(
          Error("Failed to login with Gmail account. Please try mobile login"));
    }
  }

  void loginWithMobile(LoginWithMobile event, Emitter<LoginState> emit) async {
    emit(Loading());
    try {
      Map<String, String> params = {
        "method": "mobile_login",
        "mobile_number": event.mobile_number ?? "",
      };

      final apiResponse = await authService.mobileLogin(params);
      if (apiResponse.status == Status.success) {
        LoginResponse loginResponse = LoginResponse.fromJson(apiResponse.data);
        if (loginResponse.status == "success") {
          if (loginResponse.data != null) {
            if ((loginResponse.data?.accountStatus ?? "") ==
                "PROFILE_INCOMPLETE") {
              emit(ProfileInComplete(loginResponse.data));
            } else {
              AppUtils.setLoggedIn();
              emit(LoggedInWithMobile(true, loginResponse.data));
            }
          } else {
            emit(Error("User data not found"));
          }
        } else {
          emit(Error(loginResponse.message));
        }
      } else {
        emit(Error(apiResponse.message ?? ""));
      }
    } catch (err) {
      print(err);
      emit(Error("Failed to login with Mobile. Please try again"));
    }
  }
}
