import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/provider/user_provider.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";

  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool isDark = false;

  startTime() async {
    if (!kIsWeb) {
      navigationPage();
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        navigationPage();
      });
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
      body: Center(
        child: Container(
            color: Colors.white,
            width: double.infinity,
            child: Center(
                child: /*Container(
                width: 25,
              height: 25,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryColor,
              ),
                ),
          )*/
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                  // App Logo on screen center top
                  Container(
                    margin: const EdgeInsets.only(bottom: 1.0),
                    width: 200.0,
                    height: 200.0,
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
                                  fontSize: 30,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "muli"),
                            ),
                            Text(
                              " Feeds",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "muli"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]))),
      ),
    );
  }
}
