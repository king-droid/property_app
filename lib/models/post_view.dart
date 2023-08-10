import 'package:property_feeds/models/user.dart';

class PostView {
  PostView({this.postViewdate, this.user});

  PostView.fromJson(dynamic json) {
    postViewdate = json['post_view_date'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  String? postViewdate;
  User? user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['post_view_date'] = postViewdate;
    if (user != null) {
      map['user'] = user!.toJson();
    }
    return map;
  }
}
