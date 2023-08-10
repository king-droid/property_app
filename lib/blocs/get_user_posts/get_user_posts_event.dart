abstract class GetUserPostsEvent {}

class GetUserPosts extends GetUserPostsEvent {
  final String? userId;

  GetUserPosts(this.userId);
}
