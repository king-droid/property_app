import 'dart:convert';

class DeletePostResponse {
  DeletePostResponse({
    this.status,
    this.message,
  });

  DeletePostResponse.fromJson(dynamic json) {
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
