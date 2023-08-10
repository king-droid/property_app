import 'dart:convert';

import 'package:property_feeds/models/post.dart';

class PostResponse {
  PostResponse({
    this.status,
    this.message,
    this.data,
  });

  PostResponse.fromJson(dynamic json) {
    json = jsonDecode(json);
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Post.fromJson(json['data']) : null;
  }

  String? status;
  String? message;
  Post? data;

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
