import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_feeds/blocs/get_posts_interests/get_post_interests_event.dart';
import 'package:property_feeds/blocs/get_posts_interests/get_post_interests_state.dart';
import 'package:property_feeds/models/get_post_interests_response.dart';
import 'package:property_feeds/models/get_post_views_response.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/services/post_service.dart';

class GetPostInterestsBloc
    extends Bloc<GetPostInterestsEvent, GetPostInterestsState> {
  PostService postService = PostService();

  GetPostInterestsBloc() : super(Initial()) {
    on<GetPostInterests>(getPostInterests);
  }

  Future<void> getPostInterests(
      GetPostInterests event, Emitter<GetPostInterestsState> emit) async {
    emit(Loading());
    Map<String, dynamic> params = {
      "method": "get_post_interests",
      "post_id": event.postId ?? ""
    };

    print(params);
    final apiResponse = await postService.getPostInterests(params);
    if (apiResponse.status == Status.success) {
      GetPostInterestsResponse getPostInterestsResponse =
          GetPostInterestsResponse.fromJson(apiResponse.data);
      if (getPostInterestsResponse.status == "success") {
        if (getPostInterestsResponse.data != null) {
          emit(PostInterestsLoaded(true, getPostInterestsResponse.data));
        } else {
          emit(PostInterestsLoaded(false, getPostInterestsResponse.data));
          emit(Error("Post data not found"));
        }
      } else {
        emit(Error(getPostInterestsResponse.message));
      }
    } else {
      emit(Error(apiResponse.message ?? ""));
    }
  }
}
