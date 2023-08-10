import 'package:property_feeds/models/user.dart';

class PostInterest {
  PostInterest({this.postInterestDate, this.user});

  PostInterest.fromJson(dynamic json) {
    postInterestDate = json['post_interest_date'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  String? postInterestDate;
  User? user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['post_interest_date'] = postInterestDate;
    if (user != null) {
      map['user'] = user!.toJson();
    }
    return map;
  }
}
