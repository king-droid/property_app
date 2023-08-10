import 'package:dio/dio.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/networking/dio_client.dart';

class PromotionService {
  Future<ApiResponse> addPromotion(FormData formData) async {
    final response = await DioClient().init().post("",
        data: formData,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> viewPromotion(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> getPromotionComments(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> addPromotionComment(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> interestPromotion(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> deletePromotion(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> getAllPromotions(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> getUserPromotions(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> getPromotionViews(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> getPromotionInterests(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }
}
