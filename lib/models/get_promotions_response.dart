import 'dart:convert';

import 'package:property_feeds/models/promotion.dart';

class GetPromotionsResponse {
  GetPromotionsResponse({
    this.status,
    this.message,
    this.data,
  });

  GetPromotionsResponse.fromJson(dynamic json) {
    json = jsonDecode(json);
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? PromotionsData.fromJson(json['data']) : null;
  }

  String? status;
  String? message;
  PromotionsData? data;

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

class PromotionsData {
  PromotionsData({
    this.promotions,
    this.totalResults,
  });

  PromotionsData.fromJson(dynamic json) {
    //json = jsonDecode(json);
    totalResults = json['total_results'];
    if (json['promotions'] != null) {
      promotions = [];
      json['promotions'].forEach((v) {
        promotions!.add(Promotion.fromJson(v));
      });
    }
  }

  String? totalResults;
  List<Promotion>? promotions;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['total_results'] = totalResults;
    if (promotions != null) {
      map['promotions'] = promotions!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
