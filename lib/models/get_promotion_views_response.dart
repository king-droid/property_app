import 'dart:convert';

import 'package:property_feeds/models/promotion_view.dart';

class GetPromotionViewsResponse {
  GetPromotionViewsResponse({
    this.status,
    this.message,
    this.data,
  });

  GetPromotionViewsResponse.fromJson(dynamic json) {
    json = jsonDecode(json);
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(PromotionView.fromJson(v));
      });
    }
  }

  String? status;
  String? message;
  List<PromotionView>? data;

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
