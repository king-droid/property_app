import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_feeds/blocs/get_user_posts/get_user_posts_event.dart';
import 'package:property_feeds/blocs/get_user_posts/get_user_posts_state.dart';
import 'package:property_feeds/models/get_posts_response.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/services/post_service.dart';

class GetUserPostsBloc extends Bloc<GetUserPostsEvent, GetUserPostsState> {
  PostService postService = PostService();

  GetUserPostsBloc() : super(Initial()) {
    on<GetUserPosts>(getUserPosts);
  }

  Future<void> getUserPosts(
      GetUserPosts event, Emitter<GetUserPostsState> emit) async {
    emit(Loading());
    Map<String, dynamic> params = {
      "method": "get_user_posts",
      "user_id": event.userId ?? ""
    };

    print(params);
    final apiResponse = await postService.getUserPosts(params);
    if (apiResponse.status == Status.success && apiResponse.data != null) {
      GetPostsResponse getPostsResponse =
          GetPostsResponse.fromJson(apiResponse.data);
      if (getPostsResponse.status == "success") {
        if (getPostsResponse.data != null) {
          emit(PostsLoaded(true, getPostsResponse.data?.posts ?? []));
        } else {
          emit(PostsLoaded(false, getPostsResponse.data?.posts ?? []));
          emit(Error("Post data not found"));
        }
      } else {
        emit(Error(getPostsResponse.message));
      }
    } else {
      emit(Error(apiResponse.message ?? ""));
    }
  }
}
