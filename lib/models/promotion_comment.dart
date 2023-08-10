import 'User.dart';

class PromotionComment {
  final String? promotionId;
  final String? commentId;
  final String? comment;
  final String? createdDate;
  final User? user;

  PromotionComment(
      {this.promotionId,
      this.commentId,
      this.comment,
      this.createdDate,
      this.user});

  factory PromotionComment.fromJson(Map<String, dynamic> json) {
    return PromotionComment(
        promotionId: json['promotion_id'],
        commentId: json['comment_id'],
        comment: json['comment'],
        createdDate: json['created_on'],
        user: json["user"] != null ? User.fromJson(json["user"]) : null);
  }
}
