import 'dart:convert';

class NotificationsResponse {
  NotificationsResponse({
    this.status,
    this.message,
    this.data,
  });

  NotificationsResponse.fromJson(dynamic json) {
    json = jsonDecode(json);
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(NotificationData.fromJson(v));
      });
    }
  }

  String? status;
  String? message;
  List<NotificationData>? data;

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

class NotificationData {
  NotificationData({
    this.userId,
    this.notificationId,
    this.createdOn,
    this.notificationTitle,
    this.notificationMessage,
    this.notificationType,
    this.notificationData,
  });

  NotificationData.fromJson(dynamic json) {
    userId = json['user_id'];
    notificationId = json['notification_id'];
    createdOn = json['created_on'];
    notificationTitle = json['notification_title'];
    notificationMessage = json['notification_message'];
    notificationType = json['notification_type'];
    notificationData = json['notification_data'];
  }

  String? userId;
  String? notificationId;
  String? createdOn;
  String? notificationTitle;
  String? notificationMessage;
  String? notificationType;
  String? notificationData;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['user_id'] = userId;
    map['notification_id'] = notificationId;
    map['created_on'] = createdOn;
    map['notification_title'] = notificationTitle;
    map['notification_message'] = notificationMessage;
    map['notification_type'] = notificationType;
    map['notification_data'] = notificationData;
    return map;
  }
}
