import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_feeds/blocs/get_profile/get_profile_event.dart';
import 'package:property_feeds/blocs/get_profile/get_profile_state.dart';
import 'package:property_feeds/models/get_profile_response.dart';
import 'package:property_feeds/models/user_profile.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/services/profile_service.dart';

class GetProfileBloc extends Bloc<GetProfileEvent, GetProfileState> {
  ProfileService profileService = ProfileService();

  GetProfileBloc() : super(Initial()) {
    on<GetProfile>(getUserProfile);
    on<InitProfile>(initUserProfile);
  }

  Future<void> initUserProfile(
      InitProfile event, Emitter<GetProfileState> emit) async {
    emit(Initial());
  }

  Future<void> getUserProfile(
      GetProfile event, Emitter<GetProfileState> emit) async {
    emit(Loading());
    Map<String, String> params = {
      "method": "get_profile",
      "user_id": event.userId ?? ""
    };

    print(params);
    final apiResponse = await profileService.getUserProfile(params);
    if (apiResponse.status == Status.success) {
      GetProfileResponse getProfileResponse =
          GetProfileResponse.fromJson(apiResponse.data);
      if (getProfileResponse.status == "success") {
        if (getProfileResponse.userProfile != null) {
          emit(ProfileLoaded(getProfileResponse.userProfile));
        } else {
          emit(Error("User profile not found"));
        }
      } else {
        emit(Error(getProfileResponse.message));
      }
    } else {
      emit(Error(apiResponse.message ?? ""));
    }
  }

  Future<UserProfile?> getProfile(String userId) async {
    Map<String, String> params = {
      "method": "get_profile",
      "user_id": userId ?? ""
    };

    print(params);
    final apiResponse = await profileService.getUserProfile(params);
    if (apiResponse.status == Status.success) {
      GetProfileResponse getProfileResponse =
          GetProfileResponse.fromJson(apiResponse.data);
      if (getProfileResponse.status == "success") {
        if (getProfileResponse.userProfile != null) {
          return getProfileResponse.userProfile;
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
