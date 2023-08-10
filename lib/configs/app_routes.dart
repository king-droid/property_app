import 'package:flutter/cupertino.dart';
import 'package:property_feeds/screens/add_post_screen.dart';
import 'package:property_feeds/screens/add_promotion_screen.dart';
import 'package:property_feeds/screens/complete_profile.dart';
import 'package:property_feeds/screens/home_screen.dart';
import 'package:property_feeds/screens/landing_screen.dart';
import 'package:property_feeds/screens/login.dart';
import 'package:property_feeds/screens/otp_screen.dart';
import 'package:property_feeds/screens/post_interests_screen.dart';
import 'package:property_feeds/screens/post_views_screen.dart';
import 'package:property_feeds/screens/preview_local_image.dart';
import 'package:property_feeds/screens/preview_picture.dart';
import 'package:property_feeds/screens/promotion_interests_screen.dart';
import 'package:property_feeds/screens/promotion_views_screen.dart';
import 'package:property_feeds/screens/settings_screen.dart';
import 'package:property_feeds/screens/show_post_screen.dart';
import 'package:property_feeds/screens/show_promotion_screen.dart';
import 'package:property_feeds/screens/splash_screen.dart';
import 'package:property_feeds/screens/update_profile.dart';
import 'package:property_feeds/screens/user_posts_screen.dart';
import 'package:property_feeds/screens/user_promotions_screen.dart';
import 'package:property_feeds/screens/view_profile_screen.dart';
import 'package:property_feeds/screens/walkthrough_screen.dart';

class AppRoutes {
  static String splashScreen = "/";
  static String walkthroughScreen = "/walkthrough_screen";
  static String landingScreen = "/landing_screen";
  static String loginScreen = "/login_screen";
  static String otpScreen = "/otp_screen";
  static String homeScreen = "/home_screen";
  static String completeProfileScreen = "/complete_profile_screen";
  static String updateProfileScreen = "/update_profile_screen";
  static String settingsScreen = "/settings_screen";
  static String addPostScreen = "/ad_post_screen";
  static String showPostScreen = "/show_post_screen";
  static String previewLocalImageScreen = "/preview_local_image_screen";
  static String previewPictureScreen = "/preview_picture_screen";
  static String postViewsScreen = "/post_views_screen";
  static String postInterestsScreen = "/post_interests_screen";
  static String viewProfileScreen = "/view_profile_screen";
  static String userPostsScreen = "/user_posts_screen";
  static String addPromotionScreen = "/add_promotion_screen";
  static String promotionInterestsScreen = "/promotion_interests_screen";
  static String promotionViewsScreen = "/promotion_views_screen";
  static String showPromotionScreen = "/show_promotion_screen";
  static String userPromotionsScreen = "/user_promotions_screen";
}

final Map<String, WidgetBuilder> routes = {
  '/': (context) => const SplashScreen(),
  AppRoutes.walkthroughScreen: (context) => const WalkthroughScreen(),
  AppRoutes.landingScreen: (context) => const LandingScreen(),
  AppRoutes.loginScreen: (context) => const LoginScreen(),
  AppRoutes.otpScreen: (context) => OtpScreen(),
  AppRoutes.homeScreen: (context) => HomeScreen(/*key: navKeyHomeScreen*/),
  AppRoutes.completeProfileScreen: (context) => CompleteProfileScreen(),
  AppRoutes.updateProfileScreen: (context) => UpdateProfileScreen(),
  AppRoutes.settingsScreen: (context) => SettingsScreen(),
  AppRoutes.addPostScreen: (context) => AddPostScreen(),
  AppRoutes.showPostScreen: (context) => ShowPostScreen(),
  AppRoutes.previewLocalImageScreen: (context) => PreviewLocalImageScreen(),
  AppRoutes.previewPictureScreen: (context) => PreviewPictureScreen(),
  AppRoutes.postViewsScreen: (context) => PostViewsScreen(),
  AppRoutes.viewProfileScreen: (context) => ViewProfileScreen(),
  AppRoutes.userPostsScreen: (context) => UserPostsScreen(),
  AppRoutes.postInterestsScreen: (context) => PostInterestsScreen(),
  AppRoutes.addPromotionScreen: (context) => AddPromotionScreen(),
  AppRoutes.promotionInterestsScreen: (context) => PromotionInterestsScreen(),
  AppRoutes.promotionViewsScreen: (context) => PromotionViewsScreen(),
  AppRoutes.showPromotionScreen: (context) => ShowPromotionScreen(),
  AppRoutes.userPromotionsScreen: (context) => UserPromotionsScreen(),
};
