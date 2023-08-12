import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:property_feeds/constants/appConstants.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/networking/network_exceptions.dart';
import 'package:property_feeds/utils/app_utils.dart';

const _authorization = "idtoken"; //"Authorization";
const _bearer = ""; //"Bearer ";

class DioClient {
  Dio? _dio;

  /// init Dio client
  DioClient init() {
    _dio = Dio();
    _dio?.options.baseUrl = AppConstants.apiBaseUrl ?? "";
    _dio?.options.connectTimeout =
        Duration(seconds: AppConstants.connectTimeout);
    _dio?.options.receiveTimeout =
        Duration(seconds: AppConstants.receiveTimeout);
    _dio?.httpClientAdapter;

    /// Logging in Debug mode only
    if (kDebugMode) {
      _dio?.interceptors.add(PrettyDioLogger());
    }

    /// Adding request interceptor to handle and process and API requests
    _dio?.interceptors.add(RequestInterceptor());
    return this;
  }

  /// Handle GET API calls
  Future<ApiResponse> get(
    String endPoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    String sessionToken = await AppUtils.getSessionToken() ?? "";
    try {
      var response = await _dio?.get(
        endPoint,
        queryParameters: queryParameters,
        /*options: options ?? Options(headers: {"idtoken": sessionToken}),*/
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResponse(
          status: Status.success,
          code: response?.statusCode ?? 0,
          data: response?.data,
          message: response?.statusMessage ?? "");
    } on DioError catch (error) {
      return NetworkExceptions().handleDioException(error);
    }
  }

  /// Handle POST API calls
  Future<ApiResponse> post(
    String endPoint, {
    data,
    Map<String, String>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var client = http.Client();
      var response = await client.post(Uri.parse(AppConstants.apiBaseUrl),
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: data as Map<String, String>);
      //var decodedResponse = jsonDecode(utf8.decode(response.body);;
      return ApiResponse(
          status: Status.success,
          code: response.statusCode ?? 0,
          data: response.body,
          message: "Success");

      /*var response = await _dio?.post(
        endPoint,
        data: data,
        queryParameters: queryParameters,
        options: options ??
            Options(
              headers: {
                //"Content-Type": "application/x-www-form-urlencoded",
              },
            ),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResponse(
          status: Status.success,
          code: response?.statusCode ?? 0,
          data: response?.data,
          message: response?.statusMessage ?? "");*/
    } on Exception catch (error) {
      return NetworkExceptions().handleDioException(error);
    }
  }

  /// Handle POST Multipart API calls
  Future<ApiResponse> postMultipart(
    String endPoint, {
    Map<String, dynamic>? data,
    String? file,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      String fileName = file?.split('/').last ?? "temp";
      data!["file"] = await MultipartFile.fromFile(file!, filename: fileName);
      FormData formData = FormData.fromMap(data);
      var response = await _dio?.post(
        endPoint,
        data: formData,
        queryParameters: queryParameters,
        options: options ??
            Options(
              headers: {
                //"Content-Type": "application/json; charset=utf-8"
              },
            ),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return ApiResponse(
          status: Status.success,
          code: response?.statusCode ?? 0,
          data: response?.data,
          message: response?.statusMessage ?? "");
    } on DioError catch (error) {
      return NetworkExceptions().handleDioException(error);
    }
  }

  /// Handle POST Multipart API calls with custom multipart file name param
  Future<ApiResponse> postMultipartCustomFileName(
    String endPoint, {
    Map<String, dynamic>? data,
    String? file,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      String fileName = file?.split('/').last ?? "temp";
      data!["uploaded_prescription"] =
          await MultipartFile.fromFile(file!, filename: fileName);
      FormData formData = FormData.fromMap(data!);
      var response = await _dio?.post(
        endPoint,
        data: formData,
        queryParameters: queryParameters,
        options: options ?? Options(),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResponse(
          status: Status.success,
          code: response?.statusCode ?? 0,
          data: response?.data,
          message: response?.statusMessage ?? "");
    } on DioError catch (error) {
      return NetworkExceptions().handleDioException(error);
    }
  }
}

/// Custom request interceptor class
class RequestInterceptor extends InterceptorsWrapper {
  //final IAppAuth? _appAuth;

  RequestInterceptor(/*this._appAuth*/);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    /// Pass token in header in api requests after login
    //String sessionToken = await AppUtils.getSessionToken() ?? "";
    //options.headers.addAll({HttpHeaders.userAgentHeader: "mobile"});
    //if (/*(_appAuth?.loginToken ?? "").isNotEmpty*/ sessionToken.isNotEmpty) {
    //options.headers.addAll({_authorization: _bearer + sessionToken});
    options.headers.addAll({'Access-Control-Allow-Origin': '*'});

    return handler.next(options); //modify your request
  }

  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response != null) {
      /// Logout user on getting unauthorized status code (401) from API
      if (err.response?.statusCode == 401) {
        /*String isLoggedIn =
        await AppStorage.getValue(AppStorageConstants.isLoggedIn);
        if (isLoggedIn == "true") {
          AppStorage.deleteValue(AppStorageConstants.damageReport);
          AppStorage.deleteValue(AppStorageConstants.isLoggedIn);
          navKeyRoot.currentState!.pushReplacementNamed(AppRoutes.login);
          return;
        } else {
          handler.next(err);
        }*/
      } else {
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}
