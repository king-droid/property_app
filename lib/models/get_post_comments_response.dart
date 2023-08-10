import 'dart:convert';

import 'package:property_feeds/models/post_comment.dart';

class GetPostCommentsResponse {
  GetPostCommentsResponse({
    this.status,
    this.message,
    this.data,
  });

  GetPostCommentsResponse.fromJson(dynamic json) {
    json = jsonDecode(json);
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(PostComment.fromJson(v));
      });
    }
  }

  String? status;
  String? message;
  List<PostComment>? data;

/*Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.map((v) => v.toJson()).toList();
    }
    return map;
  }*/
}
