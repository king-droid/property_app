import 'package:dio/dio.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/networking/dio_client.dart';

class PostService {
  Future<ApiResponse> addPost(FormData formData) async {
    final response = await DioClient().init().post("",
        data: formData,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> viewPost(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> getPostComments(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> addPostComment(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> interestPost(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> deletePost(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> getAllPosts(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> getUserPosts(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> getPostViews(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> getPostInterests(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }
}
