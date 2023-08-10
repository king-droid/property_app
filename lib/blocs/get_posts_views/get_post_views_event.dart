abstract class GetPostViewsEvent {}

class GetPostViews extends GetPostViewsEvent {
  final String? postId;

  GetPostViews(this.postId);
}
