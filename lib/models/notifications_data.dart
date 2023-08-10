import 'package:property_feeds/models/notification.dart';

class NotificationsData {
  NotificationsData({
    this.notifications,
  });

  NotificationsData.fromJson(dynamic json) {
    if (json['notifications'] != null) {
      notifications = [];
      json['notifications'].forEach((v) {
        notifications!.add(AppNotification.fromJson(v));
      });
    }
  }

  List<AppNotification>? notifications;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (notifications != null) {
      map['notifications'] = notifications!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
