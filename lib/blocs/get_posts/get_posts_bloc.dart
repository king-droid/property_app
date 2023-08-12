import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_feeds/blocs/get_posts/get_posts_event.dart';
import 'package:property_feeds/blocs/get_posts/get_posts_state.dart';
import 'package:property_feeds/models/get_posts_response.dart';
import 'package:property_feeds/models/post.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/services/post_service.dart';

class GetPostsBloc extends Bloc<GetPostsEvent, GetPostsState> {
  PostService postService = PostService();
  List<Post>? allPosts = [];
  String? totalResults;

  GetPostsBloc() : super(Initial()) {
    //on<GetPosts>(getAllPosts);
  }

  Future<List<Post>?> getAllPosts(
      bool isRefresh,
      String? userId,
      String? city,
      String? selectedCategory,
      String? searchKeyword,
      int? offset,
      bool? isPagination) async {
    if (isRefresh == false) {
      //emit(Loading());
    }
    if ((offset ?? 0) == 0) {
      allPosts!.clear();
    }

    Map<String, String> params = {
      "method": "get_all_posts",
      "user_id": userId ?? "",
      "city": city?.trim() ?? "",
      "category": (selectedCategory ?? "all").toLowerCase(),
      "search_keyword": (searchKeyword ?? "").trim().toLowerCase(),
      "offset": "${offset ?? "0"}",
    };

    print(params);
    // if ((allPosts ?? []).isNotEmpty)
    //emit(PostsLoaded(true, event.isPagination, totalResults ?? "0", allPosts));
    final apiResponse = await postService.getAllPosts(params);
    if (apiResponse.status == Status.success && apiResponse.data != null) {
      GetPostsResponse getPostsResponse =
          GetPostsResponse.fromJson(apiResponse.data);
      if (getPostsResponse.status == "success") {
        if (getPostsResponse.data != null) {
          totalResults = getPostsResponse.data?.totalResults ?? "0";
          allPosts!.addAll(getPostsResponse.data?.posts ?? []);
          return allPosts ?? [];
        } else {
          return allPosts ?? [];
          //emit(Error("Post data not found"));
        }
      } else {
        return allPosts ?? [];
        //emit(Error(getPostsResponse.message));
      }
    } else {
      //emit(Error(apiResponse.message ?? ""));
      return allPosts ?? [];
    }
  }
}
