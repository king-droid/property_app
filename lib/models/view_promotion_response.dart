import 'dart:convert';

class ViewPromotionResponse {
  ViewPromotionResponse({
    this.status,
    this.message,
  });

  ViewPromotionResponse.fromJson(dynamic json) {
    json = jsonDecode(json);
    status = json['status'];
    message = json['message'];
  }

  String? status;
  String? message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    return map;
  }
}
