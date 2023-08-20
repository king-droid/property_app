import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_autosize_screen/auto_size_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_feeds/blocs/common_bloc.dart';
import 'package:property_feeds/blocs/complete_profile/complete_profile_bloc.dart';
import 'package:property_feeds/blocs/get_posts/get_posts_bloc.dart';
import 'package:property_feeds/blocs/get_posts_interests/get_post_interests_bloc.dart';
import 'package:property_feeds/blocs/get_posts_views/get_post_views_bloc.dart';
import 'package:property_feeds/blocs/get_profile/get_profile_bloc.dart';
import 'package:property_feeds/blocs/get_promotion_views/get_promotion_views_bloc.dart';
import 'package:property_feeds/blocs/get_promotions/get_promotions_bloc.dart';
import 'package:property_feeds/blocs/get_user_posts/get_user_posts_bloc.dart';
import 'package:property_feeds/blocs/get_user_promotions/get_user_promotions_bloc.dart';
import 'package:property_feeds/blocs/login/login_bloc.dart';
import 'package:property_feeds/blocs/post/post_bloc.dart';
import 'package:property_feeds/blocs/promotion/promotion_bloc.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/configs/theme.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/firebase_options.dart';
import 'package:property_feeds/models/notification.dart';
import 'package:property_feeds/provider/user_provider.dart';
import 'package:property_feeds/utils/app_storage.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:provider/provider.dart';

bool isFlutterLocalNotificationsInitialized = false;
final GlobalKey<NavigatorState> navKeyRoot = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> navKeyHomeScreen = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Map<String, dynamic> messageData = message.data;
  print(messageData);
  Map<String, String> dataPayload = {};
  messageData.forEach((key, value) => dataPayload[key] = value!.toString());

  String title = messageData["title"] ?? "";
  String msg = messageData["msg"] ?? "";
  String type = messageData["type"] ?? "";
  //await AppStorage.setString("notifications", "");
  /// Save notification in locally for showing on Notification Screen
  AppNotification appNotification = AppNotification.fromJson(messageData);
  await AppUtils.addNewNotification(appNotification);
  bool isLoggedIn = await AppUtils.getLoggedIn();
  if (isLoggedIn) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: Random().nextInt(1000),
            channelKey: 'high_importance_channel',
            title: title,
            body: msg,
            payload: dataPayload,
            actionType: ActionType.Default));
  }
}

void main() async {
  HttpOverrides.global = new MyHttpOverrides();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  //FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await handleFirebase();
  AutoSizeUtil.setStandard(360, isAutoTextSize: true);

  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const MyApp()));
  //FlutterNativeSplash.remove();
}

Future<void> handleFirebase() async {
  /// Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: 'recaptcha-v3-site-key',
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. debug provider
    // 2. safety net provider
    // 3. play integrity provider
    androidProvider: AndroidProvider.playIntegrity,
  );
  //FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
  if (!kIsWeb) {
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);
  }

  handleFirebaseMessages();
  //await FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    print(fcmToken);
    AppStorage.setString("device_token", fcmToken);
    saveDeviceTokenToServer(fcmToken);
  }).onError((err) {});
}

Future<void> handleFirebaseMessages() async {
  AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod);

  /// handle FCM device token and save to server
  setupFlutterNotifications();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    Map<String, dynamic> messageData = message.data;
    print(messageData);
    Map<String, String> dataPayload = {};
    messageData.forEach((key, value) => dataPayload[key] = value!.toString());

    String title = messageData["title"] ?? "";
    String msg = messageData["msg"] ?? "";
    String type = messageData["type"] ?? "";
    //await AppStorage.setString("notifications", "");
    /// Save notification in locally for showing on Notification Screen
    AppNotification appNotification = AppNotification.fromJson(messageData);
    await AppUtils.addNewNotification(appNotification);
    bool isLoggedIn = await AppUtils.getLoggedIn();
    if (isLoggedIn) {
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: Random().nextInt(1000),
              channelKey: 'high_importance_channel',
              title: title,
              body: msg,
              payload: dataPayload,
              actionType: ActionType.Default));
    }
  });
}

/// Get updated device token from Firebase and send of server
_getFCMTokenAndUpdateToServer() async {
  final String? fcmToken = await FirebaseMessaging.instance.getToken();
  print(fcmToken);
  //String prevDeviceToken = await AppStorage.getString("device_token");
  AppStorage.setString("device_token", fcmToken ?? "");
  saveDeviceTokenToServer(fcmToken ?? "");
}

/// Call api to save new token to server
saveDeviceTokenToServer(String? fcmToken) async {
  if (await AppUtils.getLoggedIn()) {
    CommonBloc commonBloc = CommonBloc();
    commonBloc.saveDeviceTokenToServer(fcmToken ?? "").then((value) {
      if (value) {
        print("Token updated");
      } else {
        print("Token failed");
      }
    });
  }
}

Future<void> setupFlutterNotifications() async {
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      'resource://drawable/ic_launcher',
      [
        NotificationChannel(
            channelKey: 'high_importance_channel',
            channelName: 'high_importance_channel',
            channelDescription: 'High_importance_channel',
            defaultColor: AppColors.primaryColor,
            importance: NotificationImportance.High,
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'high_importance_channel',
            channelGroupName: 'High Importance Notifications')
      ],
      debug: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    setPageTitle('Property Feeds', context);
    return MultiBlocProvider(
        providers: [
          BlocProvider<LoginBloc>(
            create: (BuildContext context) => LoginBloc(),
          ),
          BlocProvider<CompleteProfileBloc>(
            create: (BuildContext context) => CompleteProfileBloc(),
          ),
          BlocProvider<PostBloc>(
            create: (BuildContext context) => PostBloc(),
          ),
          BlocProvider<GetPostsBloc>(
            create: (BuildContext context) => GetPostsBloc(),
          ),
          BlocProvider<GetPostViewsBloc>(
            create: (BuildContext context) => GetPostViewsBloc(),
          ),
          BlocProvider<GetPostInterestsBloc>(
            create: (BuildContext context) => GetPostInterestsBloc(),
          ),
          BlocProvider<GetProfileBloc>(
            create: (BuildContext context) => GetProfileBloc(),
          ),
          BlocProvider<GetUserPostsBloc>(
            create: (BuildContext context) => GetUserPostsBloc(),
          ),
          BlocProvider<PromotionBloc>(
            create: (BuildContext context) => PromotionBloc(),
          ),
          BlocProvider<GetPromotionsBloc>(
            create: (BuildContext context) => GetPromotionsBloc(),
          ),
          BlocProvider<GetPromotionViewsBloc>(
            create: (BuildContext context) => GetPromotionViewsBloc(),
          ),
          BlocProvider<GetUserPromotionsBloc>(
            create: (BuildContext context) => GetUserPromotionsBloc(),
          ),
        ],
        child: MaterialApp(
          navigatorKey: navKeyRoot,
          debugShowCheckedModeBanner: false,
          builder: AutoSizeUtil.appBuilder,
          title: "Property Feeds",
          theme: theme(),
          routes: routes,
        ));
  }
}

void setPageTitle(String title, BuildContext context) {
  SystemChrome.setApplicationSwitcherDescription(ApplicationSwitcherDescription(
    label: title,
    primaryColor: Theme.of(context).primaryColor.value, // This line is required
  ));
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
/*class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) {
        final isValidHost = ["https://propertyfeeds.netlify.app"]
            .contains(host); // <-- allow only hosts in array
        return isValidHost;
      });
  }
}*/

class NotificationController {
  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    Map<String, String?>? payload = receivedAction.payload ?? {};
    Map<String, dynamic> data = json.decode(payload["data"] ?? "");

    Map<String, String> dataPayload = {};
    data.forEach((key, value) => dataPayload[key] = value!.toString());

    String notificationType = payload["type"] ?? "";
    if (notificationType == "post_interest") {
      await AppUtils.setIsFromNotification(true);
      /*Post? post = Post.fromJson(dataPayload);
      navKeyRoot.currentState?.pushReplacementNamed(AppRoutes.showPostScreen,
          arguments: {"post": post, "from": "notification"});*/
    } else if (notificationType == "promotion_interest") {
      await AppUtils.setIsFromNotification(true);
      /*Promotion? promotion = Promotion.fromJson(dataPayload);
      navKeyRoot.currentState?.pushReplacementNamed(
          AppRoutes.showPromotionScreen,
          arguments: {"promotion": promotion, "from": "notification"});*/
    } else if (notificationType == "post_comment") {
      await AppUtils.setIsFromNotification(true);
      /*Post? post = Post.fromJson(dataPayload);
      navKeyRoot.currentState?.pushReplacementNamed(AppRoutes.showPostScreen,
          arguments: {"post": post, "from": "notification"});*/
    } else if (notificationType == "promotion_comment") {
      await AppUtils.setIsFromNotification(true);
      /*Promotion? promotion = Promotion.fromJson(dataPayload);
      navKeyRoot.currentState?.pushReplacementNamed(
          AppRoutes.showPromotionScreen,
          arguments: {"promotion": promotion, "from": "notification"});*/
    }
  }
}
