import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_feeds/blocs/complete_profile/complete_profile_event.dart';
import 'package:property_feeds/blocs/complete_profile/complete_profile_state.dart';
import 'package:property_feeds/models/profile_response.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/services/profile_service.dart';
import 'package:property_feeds/utils/app_utils.dart';

import '../../models/user.dart';

class CompleteProfileBloc
    extends Bloc<CompleteProfileEvent, CompleteProfileState> {
  ProfileService authService = ProfileService();

  CompleteProfileBloc() : super(Initial()) {
    on<UpdateProfile>(updateProfile);
  }

  Future<void> updateProfile(
      UpdateProfile event, Emitter<CompleteProfileState> emit) async {
    emit(Loading());
    Map<String, dynamic> body;

    if ((event.profile_pic ?? "").isEmpty) {
      body = {
        "method": "update_profile",
        "profile_pic": "",
        "user_name": event.userName ?? "",
        "mobile_number": event.mobile_number ?? "",
        "user_id": event.userId ?? "",
        "user_location": event.userLocation ?? "",
        "interested_cities": event.interestedCities ?? "",
        "default_city": event.defaultCity ?? "",
        "user_type": event.userType ?? "",
        "company_name": event.companyName ?? "",
        "about_user": event.about ?? "",
        "show_mobile_number": event.showMobileNumber ?? "true"
      };
    } else {
      body = {
        "method": "update_profile",
        "user_name": event.userName ?? "",
        "mobile_number": event.mobile_number ?? "",
        "user_id": event.userId ?? "",
        "user_location": event.userLocation ?? "",
        "interested_cities": event.interestedCities ?? "",
        "default_city": event.defaultCity ?? "",
        "user_type": event.userType ?? "",
        "company_name": event.companyName ?? "",
        "file": event.profile_pic != null
            ? await MultipartFile.fromFile(event.profile_pic ?? "",
                filename: event.profile_pic ?? "".split('/').last)
            : null,
        "about_user": event.about ?? "",
        "show_mobile_number": event.showMobileNumber ?? "true"
      };
    }

    FormData formData = new FormData.fromMap(body);

    final apiResponse = await authService.updateProfile(formData);
    if (apiResponse.status == Status.success) {
      ProfileResponse profileResponse =
          ProfileResponse.fromJson(apiResponse.data);
      if (profileResponse.status == "success") {
        if (profileResponse.data != null) {
          await AppUtils.saveUser(profileResponse.data);
          emit(ProfileUpdated(true, profileResponse.data));
        } else {
          emit(ProfileUpdated(false, profileResponse.data));
          emit(Error("User data not found"));
        }
      } else {
        emit(Error(profileResponse.message));
      }
    } else {
      emit(Error(apiResponse.message ?? ""));
    }
  }

  Future<User?> updateShowMobileNumberSetting(
      String? userId, bool? showMobileNumber) async {
    Map<String, dynamic> body;
    body = {
      "method": "update_show_mobile_number_setting",
      "user_id": userId ?? "",
      "show_mobile_number":
          (showMobileNumber ?? true) == true ? "true" : "false"
    };

    final apiResponse = await authService.updateShowMobileNumberSetting(body);
    if (apiResponse.status == Status.success) {
      ProfileResponse profileResponse =
          ProfileResponse.fromJson(apiResponse.data);
      if (profileResponse.status == "success") {
        if (profileResponse.data != null) {
          await AppUtils.saveUser(profileResponse.data);
          return profileResponse.data;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
}
