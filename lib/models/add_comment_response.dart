import 'dart:convert';

import 'package:property_feeds/models/post_comment.dart';

class AddCommentResponse {
  AddCommentResponse({
    this.status,
    this.message,
    this.data,
  });

  AddCommentResponse.fromJson(dynamic json) {
    json = jsonDecode(json);
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? PostComment.fromJson(json['data']) : null;
  }

  String? status;
  String? message;
  PostComment? data;

/*Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }*/
}
