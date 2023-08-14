import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/networking/dio_client.dart';

class ProfileService {
  Future<ApiResponse> updateProfile(Map<String, String> params,
      List<http.MultipartFile> multipartFiles) async {
    final response = await DioClient().init().postMultiPartRequest("",
        data: params,
        multipartFiles: multipartFiles,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> updateShowMobileNumberSetting(
      Map<String, String> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> getUserProfile(Map<String, String> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }
}
