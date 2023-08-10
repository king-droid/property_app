import 'package:dio/dio.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/networking/dio_client.dart';

class ProfileService {
  Future<ApiResponse> updateProfile(FormData formData) async {
    final response = await DioClient().init().post("",
        data: formData,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> updateShowMobileNumberSetting(
      Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> getUserProfile(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }
}
