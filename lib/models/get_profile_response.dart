import 'dart:convert';

import 'package:property_feeds/models/user_profile.dart';

class GetProfileResponse {
  GetProfileResponse({
    this.status,
    this.message,
    this.userProfile,
  });

  GetProfileResponse.fromJson(dynamic json) {
    json = jsonDecode(json);
    status = json['status'];
    message = json['message'];
    userProfile =
        (json['data'] != null ? UserProfile.fromJson(json['data']) : null)!;
  }

  String? status;
  String? message;
  UserProfile? userProfile;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (userProfile != null) {
      map['data'] = userProfile!.toJson();
    }
    return map;
  }
}
