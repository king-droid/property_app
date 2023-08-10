abstract class CompleteProfileEvent {}

class UpdateProfile extends CompleteProfileEvent {
  final String? profile_pic;
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

  UpdateProfile(
      this.profile_pic,
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
