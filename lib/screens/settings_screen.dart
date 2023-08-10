import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:property_feeds/blocs/complete_profile/complete_profile_bloc.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/provider/user_provider.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationSetting = true;
  bool showMobileNumberSetting = false;
  User? user;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        showMobileNumberSetting = user?.showMobileNumber ?? true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserProvider>(context, listen: false).userData;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.screenTitleColor,
              size: 22,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text("Settings",
            style: TextStyle(color: AppColors.screenTitleColor, fontSize: 16)),
        elevation: 1,
        centerTitle: true,
        actions: <Widget>[
          /*IconButton(
            icon: Icon(
              Icons.search,
              color: AppColors.screenTitleColor,
            ),
            onPressed: () {},
          ),*/
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            /*ListTile(
              leading: new Icon(Icons.account_box),
              trailing: new Icon(Icons.chevron_right),
              title: new Text(
                'Profile',
                style: TextStyle(
                    fontFamily: "Roboto_Bold",
                    color: AppColors.buttonTextColor,
                    fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(
              color: AppColors.bgColor2,
              height: 1.5,
            ),*/
            ListTile(
              leading: new Icon(Icons.notifications_active),
              trailing: CupertinoSwitch(
                activeColor: AppColors.primaryColor,
                value: notificationSetting,
                onChanged: (value) {
                  print("VALUE : $value");
                  setState(() {
                    notificationSetting = value;
                  });
                },
              ),
              title: new Text(
                'Notifications',
                style: TextStyle(
                    fontFamily: "Roboto_Bold",
                    color: AppColors.buttonTextColor,
                    fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(
              color: AppColors.bgColor2,
              height: 1.5,
            ),
            ListTile(
              leading: new Icon(Icons.call),
              trailing: CupertinoSwitch(
                activeColor: AppColors.primaryColor,
                value: showMobileNumberSetting,
                onChanged: (value) {
                  print("VALUE : $value");
                  CompleteProfileBloc()
                      .updateShowMobileNumberSetting(user?.userId ?? "", value)
                      .then((value) {
                    if (value != null) {
                      Provider.of<UserProvider>(context, listen: false)
                          .updateUser(value);
                      setState(() {
                        user = value;
                      });
                    }
                  });
                  setState(() {
                    showMobileNumberSetting = value;
                  });
                },
              ),
              title: new Text(
                'Show mobile number',
                style: TextStyle(
                    fontFamily: "Roboto_Bold",
                    color: AppColors.buttonTextColor,
                    fontSize: 16),
              ),
              subtitle: Text(
                showMobileNumberSetting
                    ? 'Others can see your mobile number from your profile'
                    : "Mobile number not shown in your profile for others",
                style: TextStyle(
                    fontFamily: "Roboto_Regular",
                    color: AppColors.headingsColor,
                    fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(
              color: AppColors.bgColor2,
              height: 1.5,
            ),
            /*ListTile(
              leading: new Icon(Icons.invert_colors),
              trailing: CupertinoSwitch(
                activeColor: AppColors.primaryColor,
                value: status,
                onChanged: (value) {
                  print("VALUE : $value");
                  setState(() {
                    status = value;
                  });
                },
              ),
              title: new Text(
                'Dark Theme',
                style: TextStyle(
                    fontFamily: "Roboto_Bold",
                    color: AppColors.buttonTextColor,
                    fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(
              color: AppColors.bgColor2,
              height: 1.5,
            ),*/
            ListTile(
              leading: new Icon(Icons.comment),
              trailing: new Icon(Icons.chevron_right),
              title: new Text(
                'Terms and Conditions',
                style: TextStyle(
                    fontFamily: "Roboto_Bold",
                    color: AppColors.buttonTextColor,
                    fontSize: 16),
              ),
              onTap: () {},
            ),
            Divider(
              color: AppColors.bgColor2,
              height: 1.5,
            ),
            ListTile(
              leading: new Icon(Icons.comment),
              trailing: new Icon(Icons.chevron_right),
              title: new Text(
                'Privacy Policies',
                style: TextStyle(
                    fontFamily: "Roboto_Bold",
                    color: AppColors.buttonTextColor,
                    fontSize: 16),
              ),
              onTap: () {},
            ),
            Divider(
              color: AppColors.bgColor2,
              height: 1.5,
            ),
            ListTile(
              leading: new Icon(Icons.share),
              title: new Text(
                'Share app',
                style: TextStyle(
                    fontFamily: "Roboto_Bold",
                    color: AppColors.buttonTextColor,
                    fontSize: 16),
              ),
              onTap: () {
                //Navigator.pop(context);
                share();
              },
            ),
            Divider(
              color: AppColors.bgColor2,
              height: 1.5,
            ),
            ListTile(
                leading: new Icon(Icons.exit_to_app),
                title: new Text(
                  'Logout',
                  style: TextStyle(
                      fontFamily: "Roboto_Bold",
                      color: AppColors.buttonTextColor,
                      fontSize: 16),
                ),
                onTap: () async {
                  await AppUtils.logout();
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacementNamed(
                      context, AppRoutes.landingScreen);
                }),
            Divider(
              color: AppColors.bgColor2,
              height: 1.5,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> share() async {
    await FlutterShare.share(
        title: 'Share App',
        text: 'Hey,'
            '\n\nProperty Feeds is a community app to post property, plots, house for sell and purchase. Dealer and promoters can advertise/promote builder properties.'
            '\n\nDownload now and share it with your friends/links over social networks.',
        linkUrl:
            'https://play.google.com/store/apps/details?id=com.propertyfeeds.app',
        chooserTitle: 'Choose a app to share with');
  }
}
