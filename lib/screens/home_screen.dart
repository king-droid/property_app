import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:property_feeds/blocs/common_bloc.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/screens/feeds_screen.dart';
import 'package:property_feeds/screens/notifications_screen.dart';
import 'package:property_feeds/screens/profile_screen.dart';
import 'package:property_feeds/screens/promotions_screen.dart';
import 'package:property_feeds/utils/app_storage.dart';
import 'package:property_feeds/utils/app_utils.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/main";

  //const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _page = 2;
  bool? isFromNotification;

  @override
  Widget build(BuildContext context) {
    if (isFromNotification == null) {
      isFromNotification = ModalRoute.of(context)!.settings.arguments != null
          ? (((ModalRoute.of(context)!.settings.arguments
                  as Map)["from_notification"] ??
              false) as bool?)
          : false;
      _page = isFromNotification == true ? 0 : 2;
    }
    return SafeArea(
        // bottom: true,
        child: /*kIsWeb ? _buildWebVersion() : */ Container(
            padding: EdgeInsets.only(
                bottom: (kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
                    ? 20
                    : 0),
            child: _buildMobileVersion()));
  }

  Widget _buildMobileVersion() {
    return Scaffold(
      body: <Widget>[
        // NewsScreen(),
        NotificationsScreen(),
        Promotions(),
        Feeds(),
        ProfileScreen(),
        //SettingsScreen(),
      ][_page],
      bottomNavigationBar: BottomNavigationBar(
        //key: navKeyHomeScreen,
        selectedItemColor: AppColors.primaryColor,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 13,
        unselectedFontSize: 13,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: "Notifications",
            icon: Icon(
              Icons.notifications,
            ),
          ),
          BottomNavigationBarItem(
            label: "Promotions",
            icon: Icon(
              Icons.business_center,
            ),
          ),
          BottomNavigationBarItem(
            label: "Properties",
            icon: Icon(
              Icons.timeline,
            ),
          ),
          /* BottomNavigationBarItem(
                label: "Notifications",
                icon: Icon(
                  Icons.notifications,
                ),
              ),*/
          BottomNavigationBarItem(
            label: "Profile",
            icon: Icon(
              Icons.account_box,
            ),
          ),
          /* BottomNavigationBarItem(
              label: "Settings",
              icon: Icon(
                Icons.settings,
              ),
            ),*/
        ],
        onTap: onPageChanged,
        currentIndex: _page,
      ),
      //),
    );
  }

  Widget _buildWebVersion() {
    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationRail(
            labelType: NavigationRailLabelType.all,
            selectedIndex: _page,
            //groupAlignment: groupAlignment,
            onDestinationSelected: (int index) {
              setState(() {
                _page = index;
              });
            },
            destinations: <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.notifications),
                selectedIcon: Icon(
                  Icons.notifications,
                  color: AppColors.primaryColor,
                ),
                label: Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business_center),
                selectedIcon:
                    Icon(Icons.business_center, color: AppColors.primaryColor),
                label: Text('Promotions',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.timeline),
                selectedIcon:
                    Icon(Icons.timeline, color: AppColors.primaryColor),
                label: Text('Properties',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.account_box),
                selectedIcon:
                    Icon(Icons.account_box, color: AppColors.primaryColor),
                label: Text('Profile',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // This is the main content.
          Expanded(
            child: <Widget>[
              // NewsScreen(),
              NotificationsScreen(),
              Promotions(),
              Feeds(),
              ProfileScreen(),
              //SettingsScreen(),
            ][_page],
          ),
        ],
      ),
      //),
    );
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 2);
    Future<InitializationStatus> _initGoogleMobileAds() {
      // TODO: Initialize Google Mobile Ads SDK
      return MobileAds.instance.initialize();
    }

    _getDeviceTokenAndUpdateToServer();

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed && !kIsWeb) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  /// Get updated device token from Firebase and send of server
  _getDeviceTokenAndUpdateToServer() async {
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

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }
}
