import 'package:dio/dio.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/networking/dio_client.dart';

class AuthService {
  Future<ApiResponse> guestLogin(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("", data: params);
    return response;
  }

  Future<ApiResponse> emailLogin(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> mobileLogin(Map<String, dynamic> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }
}
