import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:property_feeds/constants/appConstants.dart';

class ApiHelper {
  static Dio createDio({Map<String, String>? header}) {
    Dio dio = Dio(BaseOptions(
        baseUrl: AppConstants.apiBaseUrl ?? "",
        responseType: ResponseType.json,
        connectTimeout: Duration(seconds: AppConstants.connectTimeout),
        receiveTimeout: Duration(seconds: AppConstants.receiveTimeout),
        headers: header));
    return addInterceptors(dio, header ?? {});
  }

  static Dio createDioCustomUrl(String url, Map<String, String> header) {
    Dio dio = Dio(BaseOptions(
        baseUrl: url,
        responseType: ResponseType.bytes,
        connectTimeout: Duration(seconds: AppConstants.connectTimeout),
        receiveTimeout: Duration(seconds: AppConstants.receiveTimeout),
        headers: header));
    return addInterceptors(dio, header);
  }

  static Dio createDioCustomUrlJSONResponse(
      String url, Map<String, String> header) {
    Dio dio = Dio(BaseOptions(
        baseUrl: url,
        responseType: ResponseType.json,
        connectTimeout: Duration(seconds: AppConstants.connectTimeout),
        receiveTimeout: Duration(seconds: AppConstants.receiveTimeout),
        headers: header));
    return addInterceptors(dio, header);
  }

  static Dio createDioCustomUrlPlainResponse(
      String url, Map<String, String> header) {
    Dio dio = Dio(BaseOptions(
        baseUrl: url,
        responseType: ResponseType.plain,
        connectTimeout: Duration(seconds: AppConstants.connectTimeout),
        receiveTimeout: Duration(seconds: AppConstants.receiveTimeout),
        headers: header));
    return addInterceptors(dio, header);
  }

  /// Add request interceptor
  static Dio addInterceptors(Dio dio, Map<String, String> header) {
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      return handler.next(options); //modify your request
    }, onResponse: (response, handler) {
      if (response != null) {
        //on success it is getting called here
        return handler.next(response);
      } else {
        return;
      }
    }, onError: (DioError e, handler) async {
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          /* String isLoggedIn =
              await AppStorage.getValue(AppStorageConstants.isLoggedIn);
          if (isLoggedIn == "true") {
            AppStorage.deleteValue(AppStorageConstants.damageReport);
            AppStorage.deleteValue(AppStorageConstants.isLoggedIn);
            navKeyRoot.currentState!.pushReplacementNamed(AppRoutes.login);
            return null;
          } else {
            if (e.response != null) {
              handler.resolve(e.response!);
            } else {
              return null;
            }
          }*/
        } else {
          handler.next(e);
        }
      } else {
        handler.next(e);
      }
    }));
    return dio..interceptors.add(PrettyDioLogger());
  }

  static dynamic setRequestHeaderInterceptor(
      RequestOptions options, Map<String, String> header) async {
    // Get your JWT token
    const token = '';
    if (token.isNotEmpty) {
      options.headers.addAll({"Authorization": "Bearer: $token"});
    }
    if (header != null) {
      options.headers.addAll(header);
    }
    //options.headers.addAll({"Content-Type": "application/x-www-form-urlencoded"});
    return options;
  }
}
