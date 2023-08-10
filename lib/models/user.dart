class User {
  User({
    this.createdOn,
    this.userName,
    this.userLocation,
    this.accountType,
    this.accountStatus,
    this.interestedCities,
    this.defaultCity,
    this.updatedOn,
    this.deviceToken,
    this.userType,
    this.companyName,
    this.aboutUser,
    this.userId,
    this.mobileNumber,
    this.emailId,
    this.profilePic,
    this.password,
    this.showMobileNumber,
  });

  User.fromJson(dynamic json) {
    //json = jsonDecode(json);
    createdOn = json['created_on'];
    userName = json['user_name'];
    userLocation = json['user_location'];
    accountType = json['account_type'];
    accountStatus = json['account_status'];
    interestedCities = json['interested_cities'];
    defaultCity = json['default_city'];
    updatedOn = json['updated_on'];
    deviceToken = json['device_token'];
    userType = json['user_type'];
    companyName = json['company_name'];
    aboutUser = json['about_user'];
    userId = json['user_id'];
    mobileNumber = json['mobile_number'];
    emailId = json['email_id'];
    profilePic = json['profile_pic'];
    password = json['password'];
    showMobileNumber = json['show_mobile_number'] == "true" ? true : false;
  }

  String? createdOn;
  String? userName;
  String? userLocation;
  String? accountType;
  String? accountStatus;
  String? interestedCities;
  String? defaultCity;
  String? updatedOn;
  String? deviceToken;
  String? userType;
  String? companyName;
  String? aboutUser;
  String? userId;
  String? mobileNumber;
  String? emailId;
  String? profilePic;
  String? password;
  bool? showMobileNumber;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['created_on'] = createdOn;
    map['user_name'] = userName;
    map['user_location'] = userLocation;
    map['account_type'] = accountType;
    map['account_status'] = accountStatus;
    map['interested_cities'] = interestedCities;
    map['default_city'] = defaultCity;
    map['updated_on'] = updatedOn;
    map['device_token'] = deviceToken;
    map['user_type'] = userType;
    map['company_name'] = companyName;
    map['about_user'] = aboutUser;
    map['user_id'] = userId;
    map['mobile_number'] = mobileNumber;
    map['email_id'] = emailId;
    map['profile_pic'] = profilePic;
    map['password'] = password;
    map['show_mobile_number'] = showMobileNumber;
    return map;
  }
}
