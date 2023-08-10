import 'dart:convert';

import 'package:property_feeds/models/promotion.dart';

class PromotionResponse {
  PromotionResponse({
    this.status,
    this.message,
    this.data,
  });

  PromotionResponse.fromJson(dynamic json) {
    json = jsonDecode(json);
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Promotion.fromJson(json['data']) : null;
  }

  String? status;
  String? message;
  Promotion? data;

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
