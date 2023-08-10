import 'dart:convert';

import 'package:property_feeds/models/promotion_comment.dart';

class GetPromotionCommentsResponse {
  GetPromotionCommentsResponse({
    this.status,
    this.message,
    this.data,
  });

  GetPromotionCommentsResponse.fromJson(dynamic json) {
    json = jsonDecode(json);
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(PromotionComment.fromJson(v));
      });
    }
  }

  String? status;
  String? message;
  List<PromotionComment>? data;
}
