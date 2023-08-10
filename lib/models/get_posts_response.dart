import 'dart:convert';

import 'package:property_feeds/models/post.dart';

class GetPostsResponse {
  GetPostsResponse({
    this.status,
    this.message,
    this.data,
  });

  GetPostsResponse.fromJson(dynamic json) {
    json = jsonDecode(json);
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? PostsData.fromJson(json['data']) : null;
  }

  String? status;
  String? message;
  PostsData? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class PostsData {
  PostsData({
    this.posts,
    this.totalResults,
  });

  PostsData.fromJson(dynamic json) {
    //json = jsonDecode(json);
    totalResults = json['total_results'];
    if (json['posts'] != null) {
      posts = [];
      json['posts'].forEach((v) {
        posts!.add(Post.fromJson(v));
      });
    }
  }

  String? totalResults;
  List<Post>? posts;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['total_results'] = totalResults;
    if (posts != null) {
      map['posts'] = posts!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
