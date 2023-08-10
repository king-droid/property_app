import 'dart:convert';

import 'user.dart';

class ProfileResponse {
  ProfileResponse({
    this.status,
    this.message,
    this.data,
  });

  ProfileResponse.fromJson(dynamic json) {
    json = jsonDecode(json);
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? User.fromJson(json['data']) : null;
  }

  String? status;
  String? message;
  User? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}
