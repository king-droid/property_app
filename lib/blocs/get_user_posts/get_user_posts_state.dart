import 'package:property_feeds/models/post.dart';

abstract class GetUserPostsState {
  GetUserPostsState();
}

class Initial extends GetUserPostsState {
  Initial() : super();
}

class Loading extends GetUserPostsState {
  Loading() : super();
}

class PostsLoaded extends GetUserPostsState {
  final bool? result;
  final List<Post>? posts;

  PostsLoaded(this.result, this.posts) : super();
}

class Error extends GetUserPostsState {
  final String? error;

  Error(this.error) : super();
}
