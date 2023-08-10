import 'dart:convert';

import 'package:property_feeds/models/post_interest.dart';

class GetPostInterestsResponse {
  GetPostInterestsResponse({
    this.status,
    this.message,
    this.data,
  });

  GetPostInterestsResponse.fromJson(dynamic json) {
    json = jsonDecode(json);
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(PostInterest.fromJson(v));
      });
    }
  }

  String? status;
  String? message;
  List<PostInterest>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
