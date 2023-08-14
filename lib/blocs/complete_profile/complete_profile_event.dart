import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

abstract class CompleteProfileEvent {}

class UpdateProfile extends CompleteProfileEvent {
  final String? profile_pic_mobile;
  final String? userId;
  final String? userName;
  final String? mobile_number;
  final String? userLocation;
  final String? userType;
  final String? interestedCities;
  final String? defaultCity;
  final String? companyName;
  final String? about;
  final String? showMobileNumber;
  final Uint8List? bytes;

  UpdateProfile(
      this.profile_pic_mobile,
      this.bytes,
      this.userId,
      this.userName,
      this.mobile_number,
      this.userLocation,
      this.userType,
      this.interestedCities,
      this.defaultCity,
      this.companyName,
      this.about,
      this.showMobileNumber);
}
