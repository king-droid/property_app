import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_feeds/blocs/get_posts_views/get_post_views_event.dart';
import 'package:property_feeds/blocs/get_posts_views/get_post_views_state.dart';
import 'package:property_feeds/models/get_post_views_response.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/services/post_service.dart';

class GetPostViewsBloc extends Bloc<GetPostViewsEvent, GetPostViewsState> {
  PostService postService = PostService();

  GetPostViewsBloc() : super(Initial()) {
    on<GetPostViews>(getPostViews);
  }

  Future<void> getPostViews(
      GetPostViews event, Emitter<GetPostViewsState> emit) async {
    emit(Loading());
    Map<String, String> params = {
      "method": "get_post_views",
      "post_id": event.postId ?? ""
    };

    print(params);
    final apiResponse = await postService.getPostViews(params);
    if (apiResponse.status == Status.success) {
      GetPostViewsResponse getPostViewsResponse =
          GetPostViewsResponse.fromJson(apiResponse.data);
      if (getPostViewsResponse.status == "success") {
        if (getPostViewsResponse.data != null) {
          emit(PostViewsLoaded(true, getPostViewsResponse.data));
        } else {
          emit(PostViewsLoaded(false, getPostViewsResponse.data));
          emit(Error("Post data not found"));
        }
      } else {
        emit(Error(getPostViewsResponse.message));
      }
    } else {
      emit(Error(apiResponse.message ?? ""));
    }
  }
}
