import 'dart:io';

import 'package:dio/dio.dart';
import 'package:property_feeds/networking/api_response.dart';

class NetworkExceptions {
  NetworkExceptions();

  ApiResponse handleDioException(error) {
    if (error is DioError) {
      if (error.response?.data != null) {
        return ApiResponse(
            status: Status.error,
            code: error.response?.statusCode,
            data: error.response?.data,
            message: error.response?.data["message"]);
      } else {
        return ApiResponse(
            status: Status.error,
            code: 0,
            data: null,
            message: getErrorMsg(error));
      }
    } else {
      return ApiResponse(
          status: Status.error,
          code: 0,
          data: null,
          message: "Unexpected error occurred");
    }
  }

  String getErrorMsg(error) {
    var errorMessage = "";
    if (error is Exception) {
      try {
        if (error is DioError) {
          switch (error.type) {
            case DioErrorType.cancel:
              errorMessage = "Request Cancelled";
              break;
            case DioErrorType.connectionTimeout:
              errorMessage = "Connection request timeout";
              break;
            case DioErrorType.unknown:
              errorMessage = error.message ?? "";
              break;
            case DioErrorType.receiveTimeout:
              errorMessage = "Send timeout in connection with API server";
              break;
            case DioErrorType.sendTimeout:
              errorMessage = "Send timeout in connection with API server";
              break;
            case DioErrorType.badCertificate:
              errorMessage = "Bad certificate";
              break;
            case DioErrorType.badResponse:
              errorMessage = "Bad response";
              break;
            case DioErrorType.connectionError:
              errorMessage = "Connection error";
              break;
          }
        } else if (error is SocketException) {
          errorMessage = "No internet connection";
        } else {
          errorMessage = "Unexpected error occurred";
        }
        return errorMessage;
      } on FormatException catch (e) {
        // Helper.printError(e.toString());
        return "Unexpected error occurred:${e.message}";
      } catch (_) {
        return "Unexpected error occurred";
      }
    } else {
      if (error.toString().contains("is not a subtype of")) {
        return "Unexpected error occurred:${error.toString()}";
      } else {
        return "Unexpected error occurred";
      }
    }
  }
}
