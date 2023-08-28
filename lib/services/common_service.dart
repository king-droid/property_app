import 'package:dio/dio.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/networking/dio_client.dart';

class CommonService {
  Future<ApiResponse> updateDeviceToken(Map<String, String> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }

  Future<ApiResponse> getAllNotifications(Map<String, String> params) async {
    final response = await DioClient().init().post("",
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    return response;
  }
}
