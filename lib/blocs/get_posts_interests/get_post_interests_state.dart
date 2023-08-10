import 'package:property_feeds/models/post_interest.dart';

abstract class GetPostInterestsState {
  GetPostInterestsState();
}

class Initial extends GetPostInterestsState {
  Initial() : super();
}

class Loading extends GetPostInterestsState {
  Loading() : super();
}

class PostInterestsLoaded extends GetPostInterestsState {
  final bool? result;
  final List<PostInterest>? postViews;

  PostInterestsLoaded(this.result, this.postViews) : super();
}

class Error extends GetPostInterestsState {
  final String? error;

  Error(this.error) : super();
}
