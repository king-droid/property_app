import 'package:flutter/foundation.dart';
import 'package:property_feeds/constants/appConstants.dart';

class AdHelper {
  static String get bannerAdUnitNotificationsScreen {
    if (kIsWeb) {
      return AppConstants.bannerAdUnitTest;
    } else {
      return kDebugMode
          ? AppConstants.bannerAdUnitTest
          : AppConstants.bannerAdUnitNotificationsScreen;
    }
  }

  static String get nativeAdUnitNotificationsList {
    if (kIsWeb) {
      return AppConstants.bannerAdUnitTest;
    } else {
      return kDebugMode
          ? AppConstants.nativeAdUnitTest
          : AppConstants.nativeAdUnitNotificationsListing;
    }
  }

  static String get nativeAdUnitPostsList {
    if (kIsWeb) {
      return "";
    } else {
      return kDebugMode
          ? AppConstants.nativeAdUnitTest
          : AppConstants.nativeAdUnitPostsList;
    }
  }

  static String get nativeAdUnitPromotionsList {
    if (kIsWeb) {
      return "";
    } else {
      return kDebugMode
          ? AppConstants.nativeAdUnitTest
          : AppConstants.nativeAdUnitPromotionsList;
    }
  }

  static String get nativeAdWidgetOtherProfile {
    if (kIsWeb) {
      return "";
    } else {
      return kDebugMode
          ? AppConstants.nativeAdUnitTest
          : AppConstants.bannerAdUnitOtherProfile;
    }
  }

  static String get nativeAdWidgetSelfProfile {
    if (kIsWeb) {
      return "";
    } else {
      return kDebugMode
          ? AppConstants.nativeAdUnitTest
          : AppConstants.bannerAdUnitSelfProfile;
    }
  }
}
