import 'package:property_feeds/models/post_view.dart';

abstract class GetPostViewsState {
  GetPostViewsState();
}

class Initial extends GetPostViewsState {
  Initial() : super();
}

class Loading extends GetPostViewsState {
  Loading() : super();
}

class PostViewsLoaded extends GetPostViewsState {
  final bool? result;
  final List<PostView>? postViews;

  PostViewsLoaded(this.result, this.postViews) : super();
}

class Error extends GetPostViewsState {
  final String? error;

  Error(this.error) : super();
}
