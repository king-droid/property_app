import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
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
    Map<String, String> body;

    if ((event.profile_pic_mobile ?? "")
            .isEmpty /*&&
        event.profile_pic_web == null*/
        ) {
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
        /*"file": event.profile_pic != null
            ? await MultipartFile.fromFile(event.profile_pic ?? "",
            filename: event.profile_pic ?? ""
                .split('/')
                .last)
            : null,*/
        "about_user": event.about ?? "",
        "show_mobile_number": event.showMobileNumber ?? "true"
      };
    }

    List<http.MultipartFile> multipartFiles = [];
    if (kIsWeb) {
      final httpImage = http.MultipartFile.fromBytes('file', event.bytes!,
          filename: "profile_pic.png");
      multipartFiles.add(httpImage);
    } else {
      final httpImage = http.MultipartFile.fromBytes(
          'file', File(event.profile_pic_mobile!).readAsBytesSync(),
          filename: "profile_pic.png");
      multipartFiles.add(httpImage);
      /* if ((event.profile_pic_mobile ?? "").isNotEmpty) {
        final httpImage = http.MultipartFile.fromPath(
            "file", event.profile_pic_mobile ?? "",
            filename: event.profile_pic_mobile!.split('/').last);
        multipartFiles.add(httpImage);
      }*/
    }

    //FormData formData = new FormData.fromMap(body);

    final apiResponse = await authService.updateProfile(body, multipartFiles);
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
    Map<String, String> body;
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
