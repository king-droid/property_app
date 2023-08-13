import 'package:property_feeds/models/generic_response.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/services/common_service.dart';
import 'package:property_feeds/utils/app_utils.dart';

class CommonBloc {
  final CommonService _commonService = CommonService();

  Future<bool> saveDeviceTokenToServer(String deviceToken) async {
    User? user = await AppUtils.getUser();
    String userId = user?.userId ?? "";

    Map<String, String> params = {
      "method": "update_device_token",
      //"device_type": Platform.isAndroid ? "android" : "ios",
      //"sender": userType,
      "user_id": userId,
      "device_token": deviceToken
    };

    ApiResponse apiResponse = await _commonService.updateDeviceToken(params);
    if (apiResponse.status == Status.success && apiResponse.data != null) {
      try {
        GenericResponse genericResponse =
            GenericResponse.fromJson(apiResponse.data);
        if (genericResponse.status == "success") {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }
  }

  dispose() {}
}
