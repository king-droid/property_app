import 'package:property_feeds/models/post.dart';

abstract class GetPostsState {
  GetPostsState();
}

class Initial extends GetPostsState {
  Initial() : super();
}

class Loading extends GetPostsState {
  Loading() : super();
}

class PostsLoaded extends GetPostsState {
  final bool? result;
  final bool? isPagination;
  final String? totalResults;
  final List<Post>? posts;

  PostsLoaded(this.result, this.isPagination, this.totalResults, this.posts)
      : super();
}

class Error extends GetPostsState {
  final String? error;

  Error(this.error) : super();
}
