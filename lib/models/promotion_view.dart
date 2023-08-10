import 'package:property_feeds/models/user.dart';

class PromotionView {
  PromotionView({this.promotionViewdate, this.user});

  PromotionView.fromJson(dynamic json) {
    promotionViewdate = json['promotion_view_date'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  String? promotionViewdate;
  User? user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['promotion_view_date'] = promotionViewdate;
    if (user != null) {
      map['user'] = user!.toJson();
    }
    return map;
  }
}
