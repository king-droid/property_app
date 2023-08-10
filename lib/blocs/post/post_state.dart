import 'package:property_feeds/models/post.dart';

abstract class PostState {
  PostState();
}

class Initial extends PostState {
  Initial() : super();
}

class Loading extends PostState {
  Loading() : super();
}

class PostAdded extends PostState {
  final bool? result;
  final Post? user;

  PostAdded(this.result, this.user) : super();
}

class Error extends PostState {
  final String? error;

  Error(this.error) : super();
}
