

class AppNotification {
  String? title;
  String? message;
  String? type;
  String? createdDate;
  dynamic post;

  //Promotion? promotion;

  AppNotification({
    this.title,
    this.message,
    this.type,
    this.createdDate,
    this.post,
    //this.promotion
  });

  AppNotification.fromJson(dynamic json) {
    title = json['title'];
    message = json['msg'];
    type = json['type'];
    createdDate = json['created_on'];
    post = json['data'] != null ? json['data'] : null;
    //promotion = json['data'] != null ? Promotion.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = title;
    map['msg'] = message;
    map['type'] = type;
    map['created_on'] = createdDate;
    map['data'] = post;
    //map['promotion'] = promotion;
    return map;
  }
}
