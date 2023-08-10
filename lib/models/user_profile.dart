import 'package:property_feeds/models/user.dart';

class UserProfile {
  UserProfile({this.postsCount, this.interestsCount, this.user});

  UserProfile.fromJson(dynamic json) {
    //json = jsonDecode(json);
    postsCount = "${json['posts_count']}";
    promotionsCount = "${json['promotions_count']}";
    interestsCount = "${json['interests_count']}";
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  String? postsCount;
  String? promotionsCount;
  String? interestsCount;
  User? user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['posts_count'] = postsCount;
    map['promotions_count'] = promotionsCount;
    map['interests_count'] = interestsCount;
    if (user != null) {
      map['user'] = user!.toJson();
    }
    return map;
  }
}
