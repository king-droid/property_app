import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:property_feeds/components/custom_icon_button.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/provider/user_provider.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:provider/provider.dart';
import "package:universal_html/js.dart" as js;

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";

  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool isDark = false;
  bool isStandAlone = false;

  startTime() async {
    if (!kIsWeb) {
      // navigationPage();
      //} else {
      Future.delayed(const Duration(milliseconds: 500), () {
        navigationPage();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        AppUtils.showSnackBar(context, "$kIsWeb $defaultTargetPlatform");
      });
      isStandAlone = window.matchMedia('(display-mode: standalone)').matches;
      if (isStandAlone) {
        navigationPage();
      } else {}
    }
  }

  void navigationPage() {
    AppUtils.getLoggedIn().then((isLoggedIn) async {
      if (isLoggedIn) {
        bool isFromNotification = await AppUtils.isFromNotification();
        User? user = await AppUtils.getUser();
        Provider.of<UserProvider>(context, listen: false).createUser(user);
        if (isFromNotification) {
          await AppUtils.setIsFromNotification(false);
          Navigator.pushReplacementNamed(context, AppRoutes.homeScreen,
              arguments: {"from_notification": true});
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
        }
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.landingScreen);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTime();
    //final isWebMobile = kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDark ? AppColors.semiPrimary : AppColors.primaryColor,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.white,
          width: double.infinity,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // App Logo on screen center top
                Container(
                  margin: const EdgeInsets.only(bottom: 1.0),
                  width: 180.0,
                  height: 180.0,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: ExactAssetImage('assets/app_icon.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // App Title
                Container(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Property",
                            style: TextStyle(
                                fontSize: 25,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: "muli"),
                          ),
                          Text(
                            " Feeds",
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontFamily: "muli"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                kIsWeb
                    ? isStandAlone
                        ? Container()
                        : Container(
                            child: Column(
                            children: [
                              (kIsWeb &&
                                      defaultTargetPlatform ==
                                          TargetPlatform.iOS)
                                  ? buildInstallIOsAppButton()
                                  : buildInstallAndroidAppButton(),
                              buildContinueWebAppButton(),
                            ],
                          ))
                    : Container()
              ])),
    );
  }

  Container buildInstallIOsAppButton() {
    return Container(
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.all(20),
        child: Text(
          "Install ios app by clicking on share icon at bottom and then click 'Add to Home Screen'",
          style: TextStyle(
              fontSize: 14,
              color: AppColors.buttonTextColorBlack,
              fontFamily: "Muli"),
        ));
  }

  Container buildInstallAndroidAppButton() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.2,
      margin: EdgeInsets.only(top: 30),
      alignment: Alignment.center,
      child: CustomIconButton(
        text: "Install App Now",
        color: AppColors.white,
        elevation: 2,
        icon: Image.asset(
          'assets/mobile.png',
          height: 30,
        ),
        textStyle: TextStyle(
            fontSize: 12,
            color: AppColors.buttonTextColorBlack,
            fontFamily: "Muli"),
        onPress: () {
          js.context.callMethod("presentAddToHome");
        },
      ),
    );
  }

  Container buildContinueWebAppButton() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.2,
      margin: EdgeInsets.only(top: 20),
      alignment: Alignment.center,
      child: CustomIconButton(
        text: "Continue in browser",
        color: AppColors.white,
        elevation: 2,
        icon: Image.asset(
          'assets/web.png',
          height: 20,
        ),
        textStyle: TextStyle(
            fontSize: 12,
            color: AppColors.buttonTextColorBlack,
            fontFamily: "Muli"),
        onPress: () {
          navigationPage();
        },
      ),
    );
  }
}
