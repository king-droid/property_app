import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_feeds/blocs/post/post_event.dart';
import 'package:property_feeds/blocs/post/post_state.dart';
import 'package:property_feeds/models/add_comment_response.dart';
import 'package:property_feeds/models/delete_post_response.dart';
import 'package:property_feeds/models/get_post_comments_response.dart';
import 'package:property_feeds/models/post_comment.dart';
import 'package:property_feeds/models/post_response.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/models/view_post_response.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/services/post_service.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:rxdart/rxdart.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostService postService = PostService();

  PostBloc() : super(Initial()) {
    on<AddPost>(addPost);
    on<UpdatePost>(updatePost);
    on<InitialEvent>(addPostInit);
  }

  Future<void> addPostInit(InitialEvent event, Emitter<PostState> emit) async {
    emit(Initial());
  }

  List<PostComment>? comments = [];

  final _commentsController = BehaviorSubject<List<PostComment>?>();
  final StreamController<bool> _commentFieldValidatorController =
      new BehaviorSubject();
  final StreamController<bool> _addCommentLoaderController =
      new BehaviorSubject();
  final StreamController<String> _commentCountController =
      new BehaviorSubject();

  Stream get commentsList => _commentsController.stream;

  Stream get commentsCount => _commentCountController.stream;

  Stream<bool> get commentButtonState =>
      _commentFieldValidatorController.stream;

  Stream get addCommentLoaderState => _addCommentLoaderController.stream;

  getComments(String postId) async {
    Map<String, dynamic> params = {
      "method": "get_post_comments",
      "post_id": postId,
    };

    final apiResponse = await postService.getPostComments(params);
    if (apiResponse.status == Status.success) {
      GetPostCommentsResponse getPostCommentsResponse =
          GetPostCommentsResponse.fromJson(apiResponse.data);
      if (getPostCommentsResponse.status == "success") {
        if (getPostCommentsResponse.data != null) {
          _commentsController.add(getPostCommentsResponse.data);
        } else {
          _commentsController.add([]);
        }
      } else {
        _commentsController.add([]);
        //emit(Error(postResponse.message));
      }
    } else {
      _commentsController.add([]);
      //emit(Error(apiResponse.message ?? ""));
    }
  }

  Future<bool?> addComment(
      String toUserId, String commentText, String postId) async {
    User? user = await AppUtils.getUser();
    String userId = user?.userId ?? "";
    Map<String, dynamic> params = {
      "method": "add_post_comment",
      "from_user_id": userId,
      "to_user_id": toUserId,
      "post_id": postId,
      "comment": commentText,
    };

    final apiResponse = await postService.addPostComment(params);
    if (apiResponse.status == Status.success) {
      AddCommentResponse postResponse =
          AddCommentResponse.fromJson(apiResponse.data);
      if (postResponse.status == "success") {
        return true;
        /*if (postResponse.data != null) {

        } else {
          emit(PostAdded(false, postResponse.data));
          emit(Error("Post data not found"));
        }*/
      } else {
        return false;
        //emit(Error(postResponse.message));
      }
    } else {
      return false;
      emit(Error(apiResponse.message ?? ""));
    }
  }

  validateCommentField(String val) {
    if (val != null && val.length > 0) {
      _commentFieldValidatorController.sink.add(true);
    } else {
      _commentFieldValidatorController.sink.add(false);
    }
  }

  handleLoader(bool val) {
    if (val) {
      _addCommentLoaderController.sink.add(true);
    } else {
      _addCommentLoaderController.sink.add(false);
    }
  }

  setCommentsCount(String val) {
    _commentCountController.sink.add(val);
  }

  Future<void> addPost(AddPost event, Emitter<PostState> emit) async {
    emit(Loading());
    Map<String, dynamic> body;

    if ((event.pictures ?? []).isNotEmpty) {
      //List<MultipartFile> multipartFiles = [];

      body = {
        "method": "add_post",
        "user_id": event.userId ?? "",
        "requirement_type": (event.requirementType ?? "").trim(),
        "property_city": (event.city ?? "").trim(),
        "post_title": event.title ?? "",
        "post_description": event.description ?? "",
        "property_location": event.location ?? "",
        "property_price": event.prize ?? "",
        "property_size": event.size ?? "",
        "posted_by": event.userId ?? "",
        "property_price_type": event.prizeType ?? "",
        "property_size_type": event.sizeType ?? "",
      };

      /// Images files
      int i = 1;
      for (String? filePath in event.pictures ?? []) {
        //String fileName = file?.path.split('/').last ?? "";
        body["file$i"] = await MultipartFile.fromFile(filePath ?? "",
            filename: filePath ?? "".split('/').last);
        i = i + 1;
      }
    } else {
      body = {
        "method": "add_post",
        "user_id": event.userId ?? "",
        "requirement_type": (event.requirementType ?? "").trim(),
        "property_city": event.city ?? "",
        "post_title": event.title ?? "",
        "post_description": event.description ?? "",
        "property_location": event.location ?? "",
        "property_price": event.prize ?? "",
        "property_size": event.size ?? "",
        "posted_by": event.userId ?? "",
        "property_price_type": event.prizeType ?? "",
        "property_size_type": event.sizeType ?? "",
      };
    }

    print(body);

    FormData formData = new FormData.fromMap(body);

    final apiResponse = await postService.addPost(formData);
    if (apiResponse.status == Status.success) {
      PostResponse postResponse = PostResponse.fromJson(apiResponse.data);
      if (postResponse.status == "success") {
        if (postResponse.data != null) {
          emit(PostAdded(true, postResponse.data));
        } else {
          emit(PostAdded(false, postResponse.data));
          emit(Error("Post data not found"));
        }
      } else {
        emit(Error(postResponse.message));
      }
    } else {
      emit(Error(apiResponse.message ?? ""));
    }
  }

  Future<void> updatePost(UpdatePost event, Emitter<PostState> emit) async {
    emit(Loading());
    Map<String, dynamic> body;

    if ((event.pictures ?? []).isNotEmpty) {
      //List<MultipartFile> multipartFiles = [];

      body = {
        "method": "update_post",
        "post_id": event.postId ?? "",
        "user_id": event.userId ?? "",
        "requirement_type": (event.requirementType ?? "").trim(),
        "property_city": (event.city ?? "").trim(),
        "post_title": event.title ?? "",
        "post_description": event.description ?? "",
        "property_location": event.location ?? "",
        "property_price": event.prize ?? "",
        "property_size": event.size ?? "",
        "posted_by": event.userId ?? "",
        "property_price_type": event.prizeType ?? "",
        "property_size_type": event.sizeType ?? "",
      };

      String? oldPictures = "";

      /// Images files
      int i = 1;
      try {
        for (String? filePath in event.pictures ?? []) {
          //String fileName = file?.path.split('/').last ?? "";
          if ((filePath ?? "").startsWith("/data")) {
            body["file$i"] = await MultipartFile.fromFile(filePath ?? "",
                filename: filePath ?? "".split('/').last);
            i = i + 1;
          } else {
            oldPictures = (oldPictures ?? "").isEmpty
                ? filePath
                : "$oldPictures,$filePath";
          }
        }
      } catch (e) {
        emit(Error("Failed to add picture"));
        return;
      }

      body["property_pic_old"] = oldPictures;
    } else {
      body = {
        "method": "update_post",
        "post_id": event.postId ?? "",
        "user_id": event.userId ?? "",
        "requirement_type": (event.requirementType ?? "").trim(),
        "property_city": event.city ?? "",
        "post_title": event.title ?? "",
        "post_description": event.description ?? "",
        "property_location": event.location ?? "",
        "property_price": event.prize ?? "",
        "property_size": event.size ?? "",
        "posted_by": event.userId ?? "",
        "property_price_type": event.prizeType ?? "",
        "property_size_type": event.sizeType ?? "",
        "property_pic_old": "",
      };
    }

    print(body);

    FormData formData = new FormData.fromMap(body);

    final apiResponse = await postService.addPost(formData);
    if (apiResponse.status == Status.success) {
      PostResponse postResponse = PostResponse.fromJson(apiResponse.data);
      if (postResponse.status == "success") {
        if (postResponse.data != null) {
          emit(PostAdded(true, postResponse.data));
        } else {
          emit(PostAdded(false, postResponse.data));
          emit(Error("Post data not found"));
        }
      } else {
        emit(Error(postResponse.message));
      }
    } else {
      emit(Error(apiResponse.message ?? ""));
    }
  }

  Future<bool> viewPost(String postId) async {
    User? user = await AppUtils.getUser();
    String userId = user?.userId ?? "";
    Map<String, dynamic> body;
    body = {
      "method": "view_post",
      "user_id": userId,
      "post_id": postId,
    };

    final apiResponse = await postService.viewPost(body);
    if (apiResponse.status == Status.success) {
      ViewPostResponse viewPostResponse =
          ViewPostResponse.fromJson(apiResponse.data);
      if (viewPostResponse.status == "success") {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> interestPost(
      String postUserId, String postId, bool interested) async {
    User? user = await AppUtils.getUser();
    String userId = user?.userId ?? "";
    Map<String, dynamic> body;
    body = {
      "method": "interest_post",
      "user_id": userId,
      "post_user_id": postUserId,
      "post_id": postId,
      "status": interested ? "true" : "false",
    };

    final apiResponse = await postService.interestPost(body);
    if (apiResponse.status == Status.success) {
      ViewPostResponse viewPostResponse =
          ViewPostResponse.fromJson(apiResponse.data);
      if (viewPostResponse.status == "success") {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    Map<String, dynamic> body;
    body = {
      "method": "delete_post",
      "post_id": postId,
    };

    final apiResponse = await postService.deletePost(body);
    if (apiResponse.status == Status.success) {
      DeletePostResponse deletePostResponse =
          DeletePostResponse.fromJson(apiResponse.data);
      if (deletePostResponse.status == "success") {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
