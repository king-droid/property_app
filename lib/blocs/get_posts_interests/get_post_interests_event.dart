abstract class GetPostInterestsEvent {}

class GetPostInterests extends GetPostInterestsEvent {
  final String? postId;

  GetPostInterests(this.postId);
}
