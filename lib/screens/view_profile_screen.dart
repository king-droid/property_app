import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_feeds/blocs/get_profile/get_profile_bloc.dart';
import 'package:property_feeds/blocs/get_profile/get_profile_event.dart';
import 'package:property_feeds/blocs/get_profile/get_profile_state.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/constants/appConstants.dart';
import 'package:property_feeds/models/user_profile.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:property_feeds/widgets/native_add_widget_other_profile.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewProfileScreen extends StatefulWidget {
  @override
  ViewProfileScreenState createState() => ViewProfileScreenState();
}

class ViewProfileScreenState extends State<ViewProfileScreen> {
  static Random random = Random();
  List<String> cities = [];
  bool status = false;
  UserProfile? userProfile;
  String? userId;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<GetProfileBloc>(context).add(GetProfile(userId ?? ""));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userId = ((ModalRoute.of(context)!.settings.arguments) as String) ?? "";
    return Scaffold(
      backgroundColor: Colors.white,
      /*appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.overlayButtonColor,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Container(
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        */ /* title: Text("User Profile",
            style: TextStyle(color: AppColors.screenTitleColor, fontSize: 16)),
       */ /*
        elevation: 0,
        centerTitle: true,
      ),*/
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: Colors.white,
              child: setProfile(context),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.overlayButtonColor,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Container(
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget setProfile(BuildContext context) {
    return BlocConsumer<GetProfileBloc, GetProfileState>(
      builder: (context, state) {
        if (state is Loading) {
          return Center(
            child: Container(
              //color: AppColors.white,
              margin: const EdgeInsets.only(
                  left: 35.0, right: 35.0, top: 30.0, bottom: 10),
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryColor,
              ),
            ),
          );
        } else if (state is ProfileLoaded) {
          userProfile = state.userProfile;
          cities = (userProfile?.user?.interestedCities ?? "").split(',');
          return SingleChildScrollView(
            child: Container(
              //color: AppColors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        profilePictureWidget(),
                        profileDetailsWidget(),
                      ],
                    ),
                  ),
                  (userProfile?.user?.aboutUser ?? "").isEmpty
                      ? Container()
                      : Container(
                          margin: EdgeInsets.only(
                              left: 25, right: 25, top: 5, bottom: 5),
                          alignment: Alignment.center,
                          child: Text(
                            userProfile?.user?.aboutUser ?? "",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color: AppColors.titleColor.withOpacity(0.6),
                                  fontSize: 13,
                                ),
                          ),
                        ),
                  buildCallWidget(),
                  buildProfileDetailsSections(),
                  //profileSectionsWidget(),
                  NativeAdWidgetOtherProfile(),
                ],
              ),
            ),
          );
        } else {
          return Container(
            child: Center(
              child: Text(
                "Failed to get user profile",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 13,
                    color: AppColors.lineBorderColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
          );
        }
      },
      listener: (context, state) async {
        if (state is ProfileLoaded) {}
      },
    );
  }

  Widget profilePictureWidget() {
    return Container(
      margin: EdgeInsets.only(left: 10, top: 0),
      child: Container(
        child: GestureDetector(
          onTap: () {},
          child: (userProfile?.user?.profilePic ?? "").isNotEmpty
              ? Container(
                  child: CircleAvatar(
                    backgroundColor: AppColors.semiPrimary,
                    radius: 40,
                    child: ClipOval(
                      child: Container(
                        width: 80,
                        height: 80,
                        child: FadeInImage.assetNetwork(
                          image: AppConstants.imagesBaseUrl +
                              "/profile_images/" +
                              (userProfile?.user?.profilePic ?? ""),
                          placeholder: "assets/picture_loading.gif",
                          placeholderErrorBuilder:
                              (context, error, stackTrace) {
                            return Image.asset("assets/default_profile_pic.png",
                                fit: BoxFit.fill);
                          },
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset("assets/default_profile_pic.png",
                                fit: BoxFit.fill);
                          },
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                )
              : CircleAvatar(
                  backgroundColor: AppColors.semiPrimary,
                  radius: 40,
                  child: ClipOval(
                    child: Container(
                      width: 80,
                      height: 80,
                      child: CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/default_profile_pic.png')),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget profileDetailsWidget() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: EdgeInsets.only(left: 10, top: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            userProfile?.user?.userName ?? "",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
          (userProfile?.user?.userType ?? "") == "real_estate_company"
              ? ((userProfile?.user?.companyName ?? "").isEmpty
                  ? Container()
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        child: Icon(
                          Icons.location_city,
                          color: AppColors.primaryColor,
                          size: 12.0,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Container(
                        color: Colors.transparent,
                        child: Text(
                          userProfile?.user?.companyName ?? "",
                          style: TextStyle(
                            color: AppColors.headingsColor.withOpacity(0.7),
                            fontFamily: "Roboto_Medium",
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      )
                    ]))
              : Container(
                  child: Text(
                    "${AppConstants.userTypes[userProfile?.user?.userType ?? ""] ?? ""}",
                    style: TextStyle(
                      color: AppColors.headingsColor,
                      fontFamily: "Roboto_Medium",
                      fontSize: 14,
                    ),
                  ),
                ),
          const SizedBox(height: 5),
          (userProfile?.user?.userType ?? "") == "dealer"
              ? (userProfile?.user?.companyName ?? "").isEmpty
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Icon(
                            Icons.location_city,
                            color: AppColors.primaryColor,
                            size: 12.0,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Container(
                          color: Colors.transparent,
                          child: Text(
                            userProfile?.user?.companyName ?? "",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color: AppColors.titleColor.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                          ),
                        ),
                      ],
                    )
              : Container(),
          const SizedBox(height: 2),
          (userProfile?.user?.userLocation ?? "").isEmpty
              ? Container()
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    child: Icon(
                      Icons.location_on,
                      color: AppColors.primaryColor,
                      size: 14.0,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    color: Colors.transparent,
                    child: Text(
                      userProfile?.user?.userLocation ?? "",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: AppColors.titleColor.withOpacity(0.8),
                            fontSize: 11,
                          ),
                    ),
                  ),
                ]),
          SizedBox(height: 5),
          (userProfile?.user?.mobileNumber ?? "").isEmpty
              ? Container()
              : userProfile?.user?.showMobileNumber ?? true
                  ? Container(
                      margin: EdgeInsets.only(bottom: 5),
                      alignment: Alignment.center,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Icon(
                                Icons.call,
                                color: AppColors.primaryColor,
                                size: 14.0,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Container(
                              color: Colors.transparent,
                              child: Text(
                                userProfile?.user?.mobileNumber ?? "",
                                style: TextStyle(
                                  color:
                                      AppColors.headingsColor.withOpacity(0.7),
                                  fontFamily: "Roboto_Medium",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ]),
                    )
                  : Container(),
          Container(
            width: double.infinity,
            child: Align(
              alignment: Alignment.center,
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.start,
                children: cities
                    .map(
                      (i) => Container(
                        margin:
                            const EdgeInsets.only(right: 5, top: 5, bottom: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.8),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, top: 2, bottom: 3),
                        child: Text(
                          i ?? "",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCallWidget() {
    return (userProfile?.user?.mobileNumber ?? "").isEmpty
        ? Container()
        : !(userProfile?.user?.showMobileNumber ?? true)
            ? Container()
            : Container(
                //color: AppColors.bgColor,
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 10),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  InkWell(
                    onTap: () {
                      AppUtils().makeAudioCall(
                          '+91${userProfile?.user?.mobileNumber ?? ""}');
                    },
                    child: Container(
                      //padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        //color: AppColors.bgColorLight,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22.0),
                              color: AppColors.primaryColor,
                            ),
                            child: Icon(
                              Icons.call,
                              color: Colors.white,
                              size: 23,
                            ),
                          ),
                          Text(
                            "Call Now",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color: AppColors.titleColor.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  InkWell(
                    onTap: () {
                      launchUrl(
                          Uri.parse(
                              'https://wa.me/91${userProfile?.user?.mobileNumber ?? ""}'),
                          mode: LaunchMode.externalApplication);
                    },
                    child: Container(
                      ///padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        //color: AppColors.bgColorLight,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22.0),
                              //color: AppColors.primaryColor,
                            ),
                            child: Image.asset(
                              "assets/whatsapp_icon.png",
                              width: 37,
                              height: 37,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          Text(
                            "WhatsApp",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color: AppColors.titleColor.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              );
  }

  Widget profileSectionsWidget() {
    return Column(
      children: [
        Divider(
          color: AppColors.bgColor2,
          height: 1.5,
        ),
        ListTile(
          leading: new Icon(Icons.list),
          trailing: new Icon(Icons.chevron_right),
          title: new Text(
            //'Property Posts (${userProfile?.postsCount ?? "0"})',
            'Property Posts',
            style: TextStyle(
                fontFamily: "Roboto_Bold",
                color: AppColors.buttonTextColor,
                fontSize: 16),
          ),
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.userPostsScreen,
                arguments: userProfile?.user?.userId ?? "");
          },
        ),
        Divider(
          color: AppColors.bgColor2,
          height: 1.5,
        ),
        ListTile(
          leading: new Icon(Icons.list_alt),
          trailing: new Icon(Icons.chevron_right),
          title: new Text(
            'Promotions',
            style: TextStyle(
                fontFamily: "Roboto_Bold",
                color: AppColors.buttonTextColor,
                fontSize: 16),
          ),
          onTap: () {
            //Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget buildProfileDetailsSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(left: 0, top: 1, bottom: 5),
          child: Container(
            //color: AppColors.bgColorLight,
            margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 12),
            //padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      /*Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) =>
                                My_Posts_Screen(user.userId)));*/
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      padding: EdgeInsets.only(top: 2, bottom: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: AppColors.bgColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.05),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            userProfile?.interestsCount ?? "0",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Interested",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.headingsColor, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.userPostsScreen,
                          arguments: userProfile?.user?.userId ?? "");
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      padding: EdgeInsets.only(top: 2, bottom: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: AppColors.bgColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.05),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            userProfile?.postsCount ?? "0",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Posts",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.headingsColor, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ((userProfile?.user?.userType ?? "") == "dealer") ||
                        ((userProfile?.user?.userType ?? "") ==
                            "real_estate_company")
                    ? Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, AppRoutes.userPromotionsScreen,
                                arguments: userProfile?.user?.userId ?? "");
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 5, right: 5),
                            padding: EdgeInsets.only(top: 2, bottom: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              color: AppColors.bgColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.05),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  userProfile?.promotionsCount ?? "0",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Promotions",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: AppColors.headingsColor,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
