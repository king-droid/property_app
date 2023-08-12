import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_feeds/blocs/promotion/promotion_event.dart';
import 'package:property_feeds/blocs/promotion/promotion_state.dart';
import 'package:property_feeds/models/add_comment_response.dart';
import 'package:property_feeds/models/delete_promotion_response.dart';
import 'package:property_feeds/models/get_promotion_comments_response.dart';
import 'package:property_feeds/models/post_comment.dart';
import 'package:property_feeds/models/promotion_comment.dart';
import 'package:property_feeds/models/promotion_response.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/models/view_promotion_response.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/services/promotion_service.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:rxdart/rxdart.dart';

class PromotionBloc extends Bloc<PromotionEvent, PromotionState> {
  PromotionService promotionService = PromotionService();

  PromotionBloc() : super(Initial()) {
    on<AddPromotion>(addPromotion);
    on<UpdatePromotion>(updatePromotion);
    on<InitialEvent>(addPromotionInit);
  }

  Future<void> addPromotionInit(
      InitialEvent event, Emitter<PromotionState> emit) async {
    emit(Initial());
  }

  List<PostComment>? comments = [];

  final _commentsController = BehaviorSubject<List<PromotionComment>?>();
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

  getComments(String promotionId) async {
    Map<String, String> params = {
      "method": "get_promotion_comments",
      "promotion_id": promotionId,
    };

    final apiResponse = await promotionService.getPromotionComments(params);
    if (apiResponse.status == Status.success) {
      GetPromotionCommentsResponse getPromotionCommentsResponse =
          GetPromotionCommentsResponse.fromJson(apiResponse.data);
      if (getPromotionCommentsResponse.status == "success") {
        if (getPromotionCommentsResponse.data != null) {
          _commentsController.add(getPromotionCommentsResponse.data);
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
      String toUserId, String commentText, String promotionId) async {
    User? user = await AppUtils.getUser();
    String fromUserId = user?.userId ?? "";
    Map<String, String> params = {
      "method": "add_promotion_comment",
      "from_user_id": fromUserId,
      "to_user_id": toUserId,
      "promotion_id": promotionId,
      "comment": commentText,
    };

    final apiResponse = await promotionService.addPromotionComment(params);
    if (apiResponse.status == Status.success) {
      AddCommentResponse addCommentResponse =
          AddCommentResponse.fromJson(apiResponse.data);
      if (addCommentResponse.status == "success") {
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

  Future<void> addPromotion(
      AddPromotion event, Emitter<PromotionState> emit) async {
    emit(Loading());
    Map<String, dynamic> body;

    if ((event.pictures ?? []).isNotEmpty) {
      body = {
        "method": "add_promotion",
        "user_id": event.userId ?? "",
        "promotion_title": event.title ?? "",
        "promotion_description": event.description ?? "",
        "promotion_city": event.city ?? "",
      };

      /// Images files
      int i = 1;
      for (String? filePath in event.pictures ?? []) {
        body["file$i"] = await MultipartFile.fromFile(filePath ?? "",
            filename: filePath ?? "".split('/').last);
        i = i + 1;
      }
    } else {
      body = {
        "method": "add_promotion",
        "user_id": event.userId ?? "",
        "promotion_title": event.title ?? "",
        "promotion_description": event.description ?? "",
        "promotion_city": event.city ?? "",
      };
    }
    print(body);
    FormData formData = new FormData.fromMap(body);

    final apiResponse = await promotionService.addPromotion(formData);
    if (apiResponse.status == Status.success) {
      PromotionResponse promotionResponse =
          PromotionResponse.fromJson(apiResponse.data);
      if (promotionResponse.status == "success") {
        if (promotionResponse.data != null) {
          emit(PromotionAdded(true, promotionResponse.data));
        } else {
          emit(PromotionAdded(false, promotionResponse.data));
          emit(Error("Promotion data not found"));
        }
      } else {
        emit(Error(promotionResponse.message));
      }
    } else {
      emit(Error(apiResponse.message ?? ""));
    }
  }

  Future<void> updatePromotion(
      UpdatePromotion event, Emitter<PromotionState> emit) async {
    emit(Loading());
    Map<String, dynamic> body;

    if ((event.pictures ?? []).isNotEmpty) {
      //List<MultipartFile> multipartFiles = [];

      body = {
        "method": "update_promotion",
        "promotion_id": event.promotionId ?? "",
        "user_id": event.userId ?? "",
        "promotion_title": event.title ?? "",
        "promotion_description": event.description ?? "",
        "promotion_city": event.city ?? "",
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
        "method": "update_promotion",
        "promotion_id": event.promotionId ?? "",
        "user_id": event.userId ?? "",
        "promotion_title": event.title ?? "",
        "promotion_description": event.description ?? "",
        "promotion_city": event.city ?? "",
        "property_pic_old": "",
      };
    }

    print(body);

    FormData formData = new FormData.fromMap(body);

    final apiResponse = await promotionService.addPromotion(formData);
    if (apiResponse.status == Status.success) {
      PromotionResponse promotionResponse =
          PromotionResponse.fromJson(apiResponse.data);
      if (promotionResponse.status == "success") {
        if (promotionResponse.data != null) {
          emit(PromotionAdded(true, promotionResponse.data));
        } else {
          emit(PromotionAdded(false, promotionResponse.data));
          emit(Error("Post data not found"));
        }
      } else {
        emit(Error(promotionResponse.message));
      }
    } else {
      emit(Error(apiResponse.message ?? ""));
    }
  }

  Future<bool> viewPromotion(String promotionId, String userId) async {
    User? user = await AppUtils.getUser();
    String loggedInUserId = user?.userId ?? "";
    Map<String, String> body;
    body = {
      "method": "view_promotion",
      "user_id": userId,
      "promotion_id": promotionId,
    };

    /*if (userId == loggedInUserId) {
      return false;
    }*/

    final apiResponse = await promotionService.viewPromotion(body);
    if (apiResponse.status == Status.success) {
      ViewPromotionResponse viewPromotionResponse =
          ViewPromotionResponse.fromJson(apiResponse.data);
      if (viewPromotionResponse.status == "success") {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> interestPromotion(
      String promotionUserId, String promotionId, bool interested) async {
    User? user = await AppUtils.getUser();
    String userId = user?.userId ?? "";
    Map<String, String> body;
    body = {
      "method": "interest_promotion",
      "user_id": userId,
      "promotion_user_id": promotionUserId,
      "promotion_id": promotionId,
      "status": interested ? "true" : "false",
    };
    print(body);
    final apiResponse = await promotionService.interestPromotion(body);
    if (apiResponse.status == Status.success) {
      ViewPromotionResponse viewPromotionResponse =
          ViewPromotionResponse.fromJson(apiResponse.data);
      if (viewPromotionResponse.status == "success") {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> deletePromotion(String promotionId) async {
    Map<String, String> body;
    body = {
      "method": "delete_promotion",
      "promotion_id": promotionId,
    };

    final apiResponse = await promotionService.deletePromotion(body);
    if (apiResponse.status == Status.success) {
      DeletePromotionResponse deletePromotionResponse =
          DeletePromotionResponse.fromJson(apiResponse.data);
      if (deletePromotionResponse.status == "success") {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
