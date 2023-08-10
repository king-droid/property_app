import 'User.dart';

class PostComment {
  final String? postId;
  final String? commentId;
  final String? comment;
  final String? createdDate;
  final User? user;

  PostComment(
      {this.postId, this.commentId, this.comment, this.createdDate, this.user});

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
        postId: json['post_id'],
        commentId: json['comment_id'],
        comment: json['comment'],
        createdDate: json['created_on'],
        user: json["user"] != null ? User.fromJson(json["user"]) : null);
  }
}
