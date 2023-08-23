import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_feeds/blocs/login/login_bloc.dart';
import 'package:property_feeds/blocs/login/login_event.dart';
import 'package:property_feeds/blocs/login/login_state.dart';
import 'package:property_feeds/components/custom_icon_button.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/provider/user_provider.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  LandingScreenState createState() {
    return LandingScreenState();
  }
}

class LandingScreenState extends State<LandingScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  _loginWithGoogle() async {
    try {
      setState(() {
        isLoading = true;
      });
      BlocProvider.of<LoginBloc>(context).add(LoginWithEmail());
    } catch (err) {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          isLoading = false;
        });
      });
      print(err);
      AppUtils.showSnackBar(context,
          "Failed to login with Gmail account. Please try mobile login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              /* Container(
                //color: Colors.blue,
                margin: const EdgeInsets.only(bottom: 1.0),
                width: 80.0,
                height: 80.0,
                child: Image.asset('assets/logo.png', fit: BoxFit.contain),
              ),
              // App Title
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Property",
                      style: TextStyle(
                          fontSize: 20,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: "muli"),
                    ),
                    Text(
                      " Feeds",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontFamily: "muli"),
                    ),
                  ],
                ),
              ),*/
              Spacer(),
              kIsWeb
                  ? Image.asset(
                      "assets/landing_header_image.png",
                      width: double.infinity,
                      //height: 300,
                      fit: BoxFit.fitWidth,
                    )
                  : Image.asset(
                      "assets/landing_header_image.png",
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
              const Spacer(),
              buildLoginWithMobileButton(),
              BlocConsumer<LoginBloc, LoginState>(
                builder: (context, state) {
                  if (state is Initial) {
                    return buildLoginWithGmailButton(false);
                  } else if (state is Loading) {
                    return buildLoginWithGmailButton(true);
                  } else {
                    return buildLoginWithGmailButton(false);
                  }
                },
                listener: (context, state) async {
                  if (state is LoggedInWithEmail) {
                    if (state.result ?? false) {
                      Provider.of<UserProvider>(context, listen: false)
                          .createUser(state.user);
                      await AppUtils.saveUser(state.user);
                      Navigator.pushReplacementNamed(
                          context, AppRoutes.homeScreen);
                    }
                  } else if (state is ProfileInComplete) {
                    Navigator.pushNamed(
                        context, AppRoutes.completeProfileScreen,
                        arguments: state.user);
                  } else if (state is Error) {
                    AppUtils.showToast(state.error ?? "");
                  }
                },
              ),
              const SizedBox(height: 50),
              Text(
                "Don't want to create account?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Muli",
                  color: Colors.black87.withOpacity(0.5),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 15),
              buildSkipButton(),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Container buildLoginWithMobileButton() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.2,
      margin: EdgeInsets.only(top: 20),
      alignment: Alignment.center,
      child: CustomIconButton(
        text: "Login with Mobile Number",
        color: AppColors.white,
        elevation: 1,
        icon: Icon(
          Icons.phone_android,
          color: Colors.black38,
          size: 20,
        ),
        textStyle: TextStyle(
            fontSize: 12,
            color: AppColors.buttonTextColorBlack,
            fontFamily: "Muli"),
        onPress: () {
          Navigator.pushNamed(context, AppRoutes.otpScreen);
        },
      ),
    );
  }

  Container buildLoginWithGmailButton(bool isLoading) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.2,
      margin: EdgeInsets.only(top: 20),
      alignment: Alignment.center,
      child: CustomIconButton(
        text: "Login with Gmail Account",
        color: AppColors.white,
        elevation: 2,
        icon: isLoading
            ? Container(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryColor,
                ),
              )
            : Image.asset(
                'assets/google_logo.png',
                height: 20,
              ),
        textStyle: TextStyle(
            fontSize: 12,
            color: AppColors.buttonTextColorBlack,
            fontFamily: "Muli"),
        onPress: () {
          isLoading ? null : _loginWithGoogle();
        },
      ),
    );
  }

  Widget buildSkipButton() {
    bool isLoading = false;
    return StatefulBuilder(builder: (context, innerSetState) {
      return Container(
        width: MediaQuery.of(context).size.width / 1.2,
        margin: EdgeInsets.only(top: 20),
        child: CustomIconButton(
          //width: 200,
          elevation: 1,
          cornerRadius: 10,
          text: isLoading == true ? "Please wait..." : "Continue as Guest User",
          color: AppColors.primaryColor,
          textStyle: TextStyle(
              fontSize: 12,
              color: AppColors.buttonTextColorWhite,
              fontFamily: "Muli"),
          icon: isLoading == true
              ? Container(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : Container(),
          onPress: () async {
            innerSetState(() {
              isLoading = true;
            });
            var random = Random();
            String? deviceId =
                kIsWeb ? random.nextDouble().toString() : await _getDeviceId();
            LoginBloc()
                .guestLogin("guest_${deviceId}@gmail.com")
                .then((value) async {
              innerSetState(() {
                isLoading = false;
              });
              if (value != null) {
                Provider.of<UserProvider>(context, listen: false)
                    .createUser(value);
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
              } else {
                AppUtils.showSnackBar(
                    context, "Failed to login as Guest. Please try again");
              }
            });
          },
        ),
      );
    });
  }

  Future<String?> _getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }
}
