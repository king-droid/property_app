import 'dart:convert';

class GenericResponse {
  GenericResponse({
    this.status,
    this.message,
  });

  GenericResponse.fromJson(dynamic json) {
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
