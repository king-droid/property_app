import 'package:property_feeds/models/notifications_response.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/networking/api_response.dart';
import 'package:property_feeds/services/common_service.dart';
import 'package:property_feeds/utils/app_utils.dart';

class NotificationsBloc {
  final CommonService _commonService = CommonService();

  Future<List<NotificationData>?> getAllNotifications() async {
    User? user = await AppUtils.getUser();
    String userId = user?.userId ?? "";

    Map<String, String> params = {
      "method": "get_all_notifications",
      "user_id": userId,
    };

    ApiResponse apiResponse = await _commonService.getAllNotifications(params);
    if (apiResponse.status == Status.success && apiResponse.data != null) {
      try {
        NotificationsResponse notificationsResponse =
            NotificationsResponse.fromJson(apiResponse.data);
        if (notificationsResponse.status == "success") {
          return notificationsResponse.data;
        } else {
          return [];
        }
      } catch (e) {
        return [];
      }
    } else {
      return [];
    }
  }

  dispose() {}
}
