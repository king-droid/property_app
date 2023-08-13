import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:property_feeds/blocs/get_profile/get_profile_bloc.dart';
import 'package:property_feeds/components/custom_icon_button.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/constants/appConstants.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/models/user_profile.dart';
import 'package:property_feeds/provider/user_provider.dart';
import 'package:property_feeds/widgets/native_add_widget_self_profile.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  static Random random = Random();
  List<String> cities = [];
  bool status = false;
  User? user;
  String? userId;
  UserProfile? userProfile;
  GetProfileBloc getProfileBloc = GetProfileBloc();
  bool isLoading = true;

  @override
  void initState() {
    //BlocProvider.of<GetProfileBloc>(context).add(InitProfile());

    SchedulerBinding.instance.addPostFrameCallback((_) {
      userId = user?.userId;
      if (user?.accountType != "guest_account") {
        setState(() {
          isLoading = true;
        });
        getProfileBloc.getProfile(userId ?? "").then((value) {
          userProfile = value;
          user = userProfile?.user;
          cities = (user?.interestedCities ?? "").split(',');
          setState(() {
            isLoading = false;
          });
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
      //BlocProvider.of<GetProfileBloc>(context).add(GetProfile(userId ?? ""));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null)
      user = Provider.of<UserProvider>(context, listen: false).userData;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text("My Profile",
            style: TextStyle(color: AppColors.screenTitleColor, fontSize: 16)),
        elevation: 1,
        leading: user?.accountType == "guest_account"
            ? Container()
            : IconButton(
                icon: Icon(
                  Icons.settings,
                  color: AppColors.screenTitleColor,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.settingsScreen);
                },
              ),
        centerTitle: true,
        actions: <Widget>[
          user?.accountType == "guest_account" || isLoading
              ? Container()
              : IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.screenTitleColor,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.updateProfileScreen,
                            arguments: user)
                        .then((value) {
                      if (value != null) {
                        /*BlocProvider.of<GetProfileBloc>(context)
                            .add(GetProfile(userId ?? ""));*/
                        /*setState(() {
                          user = value as User?;
                        });*/
                        setState(() {
                          isLoading = true;
                        });
                        getProfileBloc.getProfile(userId ?? "").then((value) {
                          userProfile = value;
                          user = userProfile?.user;
                          cities = (user?.interestedCities ?? "").split(',');
                          setState(() {
                            isLoading = false;
                          });
                        });
                      }
                    });
                  },
                ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: user?.accountType == "guest_account"
            ? setProfileGuest(context)
            : setProfile(context),
      ),
    );
  }

  Widget setProfile(BuildContext context) {
    return isLoading
        ? Center(
            child: Container(
              color: AppColors.white,
              margin: const EdgeInsets.only(
                  left: 35.0, right: 35.0, top: 30.0, bottom: 10),
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryColor,
              ),
            ),
          )
        : SingleChildScrollView(
            child: Container(
              color: AppColors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  profilePictureWidget(),
                  profileDetailsWidget(),
                  buildProfileDetailsSections(),
                  //profileSectionsWidget(),
                  NativeAdWidgetSelfProfile(),
                ],
              ),
            ),
          );
  }

  Widget setProfileGuest(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: AppColors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            profilePictureWidget(),
            profileDetailsGuestWidget(),
            guestLoginButtonWidget(),
          ],
        ),
      ),
    );
  }

  Widget guestLoginButtonWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 40, left: 40, right: 40, bottom: 30),
      child: CustomIconButton(
        //width: 200,
        elevation: 1,
        cornerRadius: 10,
        text: "Login/Register account",
        color: AppColors.primaryColor,
        textStyle: const TextStyle(
            fontSize: 16,
            color: AppColors.buttonTextColorWhite,
            fontFamily: "Muli"),
        icon: Icon(
          Icons.app_registration,
          size: 25,
        ),
        onPress: () async {
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushNamed(context, AppRoutes.landingScreen);
        },
      ),
    );
  }

  Widget profileDetailsGuestWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 2, top: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Guest User",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Muli",
                  color: Colors.black87.withOpacity(0.7),
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Row(
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
                      user?.defaultCity ?? "",
                      style: TextStyle(
                        color: AppColors.headingsColor.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ],
    );
  }

  Widget profilePictureWidget() {
    return Container(
      margin: EdgeInsets.only(left: 10, top: 5),
      child: Container(
        child: GestureDetector(
          onTap: () {},
          child: (user?.profilePic ?? "").isNotEmpty
              ? Container(
                  child: CircleAvatar(
                    backgroundColor: AppColors.semiPrimary,
                    radius: 42,
                    child: ClipOval(
                      child: Container(
                        width: 85,
                        height: 85,
                        child: FadeInImage.assetNetwork(
                          image: AppConstants.imagesBaseUrl +
                              "/profile_images/" +
                              (user?.profilePic ?? ""),
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
                  radius: 45,
                  child: ClipOval(
                    child: Container(
                      width: 90,
                      height: 90,
                      child: CircleAvatar(
                          radius: 50,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            user?.userName ?? "",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87.withOpacity(0.7),
              fontSize: 20,
            ),
          ),
          (user?.userType ?? "") == "real_estate_company"
              ? ((user?.companyName ?? "").isEmpty
                  ? Container()
                  : Row(children: [
                      Container(
                        child: Icon(
                          Icons.location_city,
                          color: AppColors.titleColor.withOpacity(0.8),
                          size: 12.0,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Container(
                        color: Colors.transparent,
                        child: Text(
                          user?.companyName ?? "",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                color: AppColors.titleColor.withOpacity(0.8),
                                fontSize: 13,
                              ),
                        ),
                      )
                    ]))
              : Container(
                  child: Text(
                    "(${AppConstants.userTypes[user?.userType ?? ""] ?? ""})",
                    style: TextStyle(
                      color: AppColors.headingsColor,
                      fontSize: 14,
                    ),
                  ),
                ),
          const SizedBox(height: 2),
          (user?.userType ?? "") == "dealer"
              ? (user?.companyName ?? "").isEmpty
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Icon(
                            Icons.location_city,
                            color: AppColors.primaryColor,
                            size: 15.0,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Container(
                          color: Colors.transparent,
                          child: Text(
                            user?.companyName ?? "",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color: AppColors.titleColor.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                          ),
                        ),
                      ],
                    )
              : Container(),
          (user?.userLocation ?? "").isEmpty
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
                      user?.userLocation ?? "",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: AppColors.titleColor.withOpacity(0.8),
                            fontSize: 14,
                          ),
                    ),
                  ),
                ]),
          //const SizedBox(height: 5),
          (user?.mobileNumber ?? "").isEmpty
              ? Container()
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                      user?.mobileNumber ?? "",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: AppColors.titleColor.withOpacity(0.8),
                            fontSize: 14,
                          ),
                    ),
                  ),
                ]),
          const SizedBox(height: 2),
          Container(
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
                            left: 5, right: 5, top: 2, bottom: 3),
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
          (user?.aboutUser ?? "").isEmpty
              ? Container()
              : Container(
                  margin:
                      EdgeInsets.only(left: 25, right: 25, top: 5, bottom: 5),
                  alignment: Alignment.center,
                  child: Text(
                    user?.aboutUser ?? "",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppColors.titleColor.withOpacity(0.6),
                          fontSize: 12,
                        ),
                  ),
                ),
        ],
      ),
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
            'My Property Posts',
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
            'My Promotions',
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
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              color: AppColors.white,
              padding:
                  EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              child: Container(
                //color: AppColors.bgColorLight,
                margin: EdgeInsets.only(left: 1, right: 1, top: 5, bottom: 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, AppRoutes.userPostsScreen,
                              arguments: userProfile?.user?.userId ?? "");
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 5, right: 5),
                          padding: EdgeInsets.only(top: 5, bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: AppColors.primaryColor.withOpacity(0.1),
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
                                "Interests",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.headingsColor,
                                    fontSize: 12),
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
                          Navigator.pushNamed(
                              context, AppRoutes.userPostsScreen,
                              arguments: userProfile?.user?.userId ?? "");
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 5, right: 5),
                          padding: EdgeInsets.only(top: 5, bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: AppColors.primaryColor.withOpacity(0.1),
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
                                    color: AppColors.headingsColor,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ((user?.userType ?? "") != "end_user")
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
                                padding: EdgeInsets.only(top: 5, bottom: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  color:
                                      AppColors.primaryColor.withOpacity(0.1),
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
        ),
      ],
    );
  }
}
