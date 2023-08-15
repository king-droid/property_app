import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:property_feeds/blocs/promotion/promotion_bloc.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/constants/appConstants.dart';
import 'package:property_feeds/main.dart';
import 'package:property_feeds/models/promotion.dart';
import 'package:property_feeds/models/promotion_comment.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/provider/user_provider.dart';
import 'package:property_feeds/screens/promotion_comment_item.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:provider/provider.dart';

class ShowPromotionScreen extends StatefulWidget {
  @override
  ShowPromotionScreenState createState() {
    return new ShowPromotionScreenState();
  }
}

typedef CommentsRefreshCallback = void Function(String);

class ShowPromotionScreenState extends State<ShowPromotionScreen> {
  Promotion? promotion;
  String? from;
  bool isLoading = false;
  PromotionBloc? promotionBloc = PromotionBloc();

  late ScrollController scrollController;
  User? user;
  final commentController = TextEditingController();
  FocusNode commentFocusNode = new FocusNode();
  final targetKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    scrollController = new ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );
    /*commentFocusNode.addListener(() {
      if (commentFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 600), () {
          final targetContext = targetKey.currentContext;
          if (targetContext != null) {
            Scrollable.ensureVisible(
              targetContext,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });*/
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (user?.accountType != "guest_account" &&
          user?.userId != promotion?.userId) {
        promotionBloc
            ?.viewPromotion(
                promotion?.promotionId ?? "", promotion?.userId ?? "")
            .then((value) {});
      }
      promotionBloc?.getComments(promotion?.promotionId ?? "");
      promotionBloc
          ?.setCommentsCount("${promotion?.promotionCommentsCount ?? "0"}");
      Future.delayed(const Duration(milliseconds: 100), () {
        if ((from ?? "") == "comments") {
          final targetContext = targetKey.currentContext;
          if (targetContext != null) {
            Scrollable.ensureVisible(
              targetContext,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
      });
    });
    super.initState();
  }

  Future<bool> _onWillPop() async {
    if (from == "notification") {
      navKeyRoot.currentState?.pushReplacementNamed(AppRoutes.homeScreen);
    } else {
      Navigator.pop(context, promotion);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserProvider>(context, listen: false).userData;
    if (promotion == null) {
      promotion = (ModalRoute.of(context)!.settings.arguments
          as Map)["promotion"] as Promotion?;
    }
    from =
        (ModalRoute.of(context)!.settings.arguments as Map)["from"] as String?;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        /*appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppColors.screenTitleColor,
                size: 22,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          */ /* BackButton(
              color: AppColors.screenTitleColor,
              onPressed: () {
                Navigator.pop(context, promotion);
              }),*/ /*
          backgroundColor: Colors.black12.withOpacity(0.5),
          automaticallyImplyLeading: false,
          title: Text("Promotion details",
              style:
                  TextStyle(color: AppColors.screenTitleColor, fontSize: 16)),
          elevation: 1,
          centerTitle: true,
          actions: <Widget>[
            Container(
              //color: Colors.blue,
              child: IconButton(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                padding: EdgeInsets.all(5),
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.screenTitleColor,
                ),
                onPressed: () {
                  showPostOptions();
                },
              ),
            ),
          ],
        ),*/
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.white,
                  child: Stack(
                    children: [
                      NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (overscroll) {
                          overscroll.disallowIndicator();
                          return true;
                        },
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            child: Container(
                                //width: double.infinity,
                                color: AppColors.white,
                                //height: MediaQuery.of(context).size.height,
                                child: Column(
                                  children: [
                                    _buildPictureWidget(),
                                    Container(
                                      color: AppColors.bgColorLight,
                                      padding: EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            color: Colors.transparent,
                                            child: Text(
                                              AppUtils.getFormattedPostDate(
                                                  promotion?.createdOn ?? ""),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ),
                                          Container(
                                            color: Colors.transparent,
                                            child: Text(
                                              (promotion
                                                                  ?.promotionViewsCount ??
                                                              "0") ==
                                                          "1" ||
                                                      (promotion?.promotionViewsCount ??
                                                              "0") ==
                                                          "0" ||
                                                      (promotion?.promotionViewsCount ??
                                                              "0") ==
                                                          "1"
                                                  ? "${promotion?.promotionViewsCount ?? 0} view"
                                                  : "${promotion?.promotionViewsCount ?? 0} views",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: 5, right: 5, top: 5, bottom: 5),
                                      child: Column(
                                        children: <Widget>[
                                          //_buildUserDetailsWidget(),
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: 5, right: 5),
                                            //color: Colors.blue,
                                            width: double.infinity,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: 1,
                                                      right: 1,
                                                      top: 5),
                                                  child: Text(
                                                      promotion
                                                              ?.promotionTitle ??
                                                          "",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium!
                                                          .copyWith(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.7),
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      left: 1,
                                                      right: 1,
                                                      top: 5,
                                                      bottom: 2),
                                                  //margin: EdgeInsets.only(top: 1, bottom: 2),
                                                  child: Text(
                                                      promotion
                                                              ?.promotionDescription ??
                                                          "",
                                                      overflow:
                                                          TextOverflow.fade,
                                                      //maxLines: 10,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium!
                                                          .copyWith(
                                                              color: Colors
                                                                  .black87
                                                                  .withOpacity(
                                                                      0.7),
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500)),
                                                ),
                                                const SizedBox(height: 5),
                                              ],
                                            ),
                                          ),

                                          /*Container(
                                            margin: EdgeInsets.only(
                                                top: 4,
                                                bottom: 0,
                                                left: 0,
                                                right: 0),
                                            color: AppColors.lineBorderColor,
                                            height: 0.1,
                                          ),*/
                                          interestedWidget(),
                                          promoterWidget(),
                                          commentsListWidget((value) {
                                            promotionBloc!
                                                .setCommentsCount(value ?? "0");
                                          }),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ),
                      Container(
                        //color: Colors.black12.withOpacity(0.1),
                        decoration: new BoxDecoration(
                          gradient: new LinearGradient(
                            end: const Alignment(0.0, 1),
                            begin: const Alignment(0.0, -1),
                            colors: <Color>[
                              //Colors.black87.withOpacity(0.3),
                              Colors.black87.withOpacity(0.2),
                              Colors.black87.withOpacity(0.1),
                              Colors.black12.withOpacity(0.0)
                            ],
                          ),
                        ),
                        height: 60,
                        child: Row(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: InkWell(
                                onTap: () {
                                  if (from == "notification") {
                                    navKeyRoot.currentState
                                        ?.pushReplacementNamed(
                                            AppRoutes.homeScreen);
                                  } else {
                                    Navigator.pop(context, promotion);
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.all(8),
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.overlayButtonColor,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.arrow_back_ios_new,
                                      color: Colors.black,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.topRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      showPostOptions();
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.all(8),
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.overlayButtonColor,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.more_vert,
                                          color: Colors.black,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showPostOptions() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              (promotion?.userId ?? "") == (user?.userId ?? "")
                  ? ListTile(
                      leading: new Icon(Icons.edit),
                      title: new Text(
                        'Edit promotion',
                        style: TextStyle(
                            fontFamily: "Roboto_Bold",
                            color: AppColors.buttonTextColor,
                            fontSize: 16),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        await Navigator.pushNamed(
                            context, AppRoutes.addPromotionScreen, arguments: {
                          "mode": "edit",
                          "promotion": promotion
                        }).then((value) {
                          setState(() {
                            promotion = value as Promotion?;
                          });
                        });
                      },
                    )
                  : Container(),
              (promotion?.userId ?? "") == (user?.userId ?? "")
                  ? Divider(color: AppColors.subTitleColor, height: 1)
                  : Container(),
              (promotion?.userId ?? "") == (user?.userId ?? "")
                  ? StatefulBuilder(builder: (context, setState) {
                      return ListTile(
                        leading: new Icon(Icons.delete),
                        trailing: isLoading
                            ? Container(
                                margin: const EdgeInsets.only(
                                    left: 1.0, right: 5.0, top: 1.0),
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryColor,
                                ),
                              )
                            : Container(
                                width: 20,
                                height: 20,
                              ),
                        title: new Text(
                          'Delete promotion',
                          style: TextStyle(
                              fontFamily: "Roboto_Bold",
                              color: AppColors.buttonTextColor,
                              fontSize: 16),
                        ),
                        onTap: () async {
                          AppUtils.showNativeAlertDialog(
                              context: context,
                              title: "Delete promotion",
                              content:
                                  "Are you sure you want to delete this promotion?",
                              cancelActionText: "Cancel",
                              defaultActionText: "Delete",
                              defaultActionClick: () {
                                setState(() {
                                  isLoading = true;
                                });
                                promotionBloc
                                    ?.deletePromotion(
                                        promotion?.promotionId ?? "")
                                    .then((status) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  if (status) {
                                    AppUtils.showToast(
                                        "Promotion deleted successfully");
                                    Navigator.pop(context);
                                    Navigator.pop(context, null);
                                  } else {
                                    AppUtils.showToast(
                                        "Failed to delete promotion. Please try again");
                                  }
                                });
                              },
                              cancelActionClick: () {
                                Navigator.pop(context);
                              });
                        },
                      );
                    })
                  : Container(),
              (promotion?.userId ?? "") == (user?.userId ?? "")
                  ? Divider(color: AppColors.subTitleColor, height: 1)
                  : Container(),
              (promotion?.userId ?? "") != (user?.userId ?? "")
                  ? Divider(color: AppColors.subTitleColor, height: 1)
                  : Container(),
              (promotion?.userId ?? "") != (user?.userId ?? "")
                  ? ListTile(
                      leading: new Icon(Icons.report_problem),
                      title: new Text(
                        'Report problem',
                        style: TextStyle(
                            fontFamily: "Roboto_Bold",
                            color: AppColors.buttonTextColor,
                            fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    )
                  : Container(),
            ],
          );
        });
  }

  Widget viewProfileWidget() {
    return Container(
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.viewProfileScreen,
              arguments: promotion?.userId ?? "");
        },
        child: Container(
          //width: double.infinity,
          decoration: BoxDecoration(
            //color: AppColors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
          margin: EdgeInsets.only(
            left: 5,
            right: 5,
          ),
          child: Container(
            margin: EdgeInsets.only(left: 5),
            child: Text("View profile",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.primaryColor,
                    )),
          ),
        ),
      ),
    );
  }

  Widget interestWidget() {
    return /*(promotion?.userId ?? "") == (user?.userId ?? "")
        ? Container()
        :*/
        Container(
      padding: EdgeInsets.only(top: 3, bottom: 3),
      child: GestureDetector(
        onTap: () {
          /*if ((promotion?.userId ?? "") == (user?.userId ?? "")) {
            Navigator.pushNamed(context, AppRoutes.promotionInterestsScreen,
                arguments: promotion);
          } else {*/
          if ((user?.accountType == "guest_account")) {
            AppUtils.showNativeAlertDialog(
                context: context,
                title: "Registration required",
                content:
                    "You are currently using app as guest.\n\nYou need to create account to access all features of app.",
                cancelActionText: "Cancel",
                defaultActionText: "Create account Now",
                defaultActionClick: () {
                  Navigator.pushNamed(context, AppRoutes.landingScreen);
                });
            return;
          } else {
            promotionBloc
                ?.interestPromotion(
                    promotion?.userId ?? "",
                    promotion?.promotionId ?? "",
                    (promotion?.userInterestStatus ?? false) ? false : true)
                .then((value) {});
            setState(() {
              (promotion?.userInterestStatus ?? false)
                  ? promotion?.interestsCount =
                      "${(int.parse(promotion?.interestsCount ?? "0") - 1)}"
                  : promotion?.interestsCount =
                      "${(int.parse(promotion?.interestsCount ?? "0") + 1)}";
              promotion?.userInterestStatus =
                  (promotion?.userInterestStatus ?? false) ? false : true;
            });
          }
          //}
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.bgColor,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
          margin: EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(1),
                child: Icon(
                  Icons.thumb_up_alt_outlined,
                  size: 25,
                  color: (promotion?.userInterestStatus ?? false)
                      ? AppColors.primaryColor
                      : AppColors.buttonTextColor,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 5),
                child: Text(
                  /*"${promotion?.interestsCount ?? 0} Interested",*/
                  (promotion?.userInterestStatus ?? false)
                      ? "Interest sent"
                      : "Interested",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: (promotion?.userInterestStatus ?? false)
                          ? AppColors.primaryColor
                          : AppColors.buttonTextColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget commentsWidget() {
    return Flexible(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          color: Colors.transparent,
          margin: EdgeInsets.only(left: 5),
          padding: EdgeInsets.only(left: 5, right: 10, top: 5, bottom: 5),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 2),
                child: Icon(
                  Icons.chat_bubble_outline,
                  size: 20,
                  color: AppColors.buttonTextColor,
                ),
              ),
              StreamBuilder(
                  stream: promotionBloc!.commentsCount,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      String commentsCount = snapshot.data;
                      return Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Text(
                          (commentsCount ?? "0") == "1" ||
                                  (commentsCount ?? "0") == "0"
                              ? "${commentsCount ?? 0} Comment"
                              : "${commentsCount ?? 0} Comments",
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: "Roboto_Bold",
                            color: AppColors.buttonTextColor,
                          ),
                        ),
                      );
                    } else {
                      String commentsCount =
                          promotion?.promotionCommentsCount ?? "0";
                      return Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Text(
                          (commentsCount ?? "0") == "1" ||
                                  (commentsCount ?? "0") == "0"
                              ? "${commentsCount ?? 0} Comment"
                              : "${commentsCount ?? 0} Comments",
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: "Roboto_Bold",
                            color: AppColors.buttonTextColor,
                          ),
                        ),
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
      flex: 0,
    );
  }

  Widget viewsWidget() {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(left: 5, right: 5, top: 8, bottom: 8),
      margin: EdgeInsets.only(left: 5, right: 0),
      child: Text(
        (promotion?.promotionViewsCount ?? "0") == "1" ||
                (promotion?.promotionViewsCount ?? "0") == "0"
            ? "${promotion?.promotionViewsCount ?? 0} people viewed it recently"
            : "${promotion?.promotionViewsCount ?? 0} people viewed it recently",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  buildProfileWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.only(left: 5),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 0,
                  child: InkWell(
                    onTap: () {
                      //Navigator.pushNamed(context, AppRoutes.viewProfileScreen, arguments: promotion?.userId ?? "");
                    },
                    child: Container(
                      child: (promotion?.profilePic ?? "").isNotEmpty
                          ? Container(
                              child: CircleAvatar(
                                backgroundColor: AppColors.semiPrimary,
                                radius: 25,
                                child: ClipOval(
                                  child: Image(
                                    width: 50,
                                    height: 50,
                                    image: NetworkImage(
                                      AppConstants.imagesBaseUrl +
                                          "/profile_images/" +
                                          (promotion?.profilePic ?? ""),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: AssetImage(
                                      'assets/default_profile_pic.png')),
                            ), //GestureDetector
                    ),
                  ), // Container
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          //Navigator.pushNamed(context, AppRoutes.viewProfileScreen, arguments: promotion?.userId ?? "");
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Text(
                                  promotion?.userName ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                          color: Colors.black,
                                          fontSize: 16,
                                          height: 1,
                                          fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 7),
                        child: Text(
                          promotion?.companyName ?? "",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  fontSize: 12, color: AppColors.subTitleColor),
                        ),
                      ),
                    ], // children
                  ), // Column
                ),
              ], // children
            ), // Row
          ),
        ),
        viewProfileWidget(),
      ],
    );
  }

  Widget promoterWidget() {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        //borderRadius: BorderRadius.circular(8.0),
        color: AppColors.white,
        /*boxShadow: [
          BoxShadow(
              color: Colors.black87.withOpacity(.08),
              blurRadius: 2,
              spreadRadius: 1),
        ],*/
      ),
      child: Column(
        children: [
          /*Container(
            margin: EdgeInsets.only(top: 4, bottom: 0, left: 0, right: 0),
            color: AppColors.lineBorderColor,
            height: 0.1,
          ),*/
          Container(
            color: AppColors.bgColorLight,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 0),
            margin: EdgeInsets.only(top: 5, bottom: 0),
            child: Text(
              "Posted by",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 0, bottom: 20, left: 0, right: 0),
            color: AppColors.bgColor2,
            height: 0.0,
          ),
          buildProfileWidget(),
          //buildProfileDetailsSections(),
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 5),
            color: AppColors.lineBorderColor,
            height: 0.0,
          )
        ],
      ),
    );
  }

  Widget buildProfileDetailsSections() {
    return Container(
      //width: MediaQuery.of(context).size.width / 2,
      padding: EdgeInsets.only(left: 20, right: 10, top: 15, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          //SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.userPostsScreen,
                    arguments: promotion?.userId ?? "");
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: AppColors.white,
                ),
                padding:
                    EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Text(
                        promotion?.postsCount ?? "",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Property listings",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.headingsColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.userPromotionsScreen,
                    arguments: promotion?.userId ?? "");
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: AppColors.white,
                ),
                padding:
                    EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Text(
                        promotion?.promotionsCount ?? "",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Promotions",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.headingsColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget interestedWidget() {
    return Container(
      margin: EdgeInsets.only(top: 15, bottom: 15),
      //color: AppColors.bgColor,
      child: Column(
        children: [
          //viewsWidget(),
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(flex: 1, child: interestWidget()),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        //Navigator.pop(context);
                        AppUtils().sharePost(
                            title: promotion?.promotionTitle ?? "",
                            description: promotion?.promotionDescription ?? "");
                      },
                      child: Container(
                        //width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.bgColor,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        margin: EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(1),
                              child: Icon(
                                Icons.share,
                                size: 25,
                                color: AppColors.buttonTextColor,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 5),
                              child: Text(
                                " Share ",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: AppColors.buttonTextColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 5, top: 10, bottom: 10),
            alignment: Alignment.center,
            child: Text(
                "${promotion?.interestsCount ?? 0} People have shown interest recently",
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget commentsListWidget(CommentsRefreshCallback callback) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          //color: AppColors.bgColor,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.only(top: 5, bottom: 0),
          child: StreamBuilder(
              stream: promotionBloc!.commentsCount,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  String commentsCount = snapshot.data;
                  return Container(
                    color: AppColors.bgColorLight,
                    width: double.infinity,
                    padding:
                        EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 0),
                    child: Text(
                      "Comments (${commentsCount ?? 0})",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                } else {
                  String commentsCount =
                      promotion?.promotionCommentsCount ?? "0";
                  return Container(
                    color: AppColors.bgColorLight,
                    width: double.infinity,
                    padding:
                        EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 0),
                    child: Text(
                      "Comments (${commentsCount ?? 0})",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: AppColors.screenTitleColor,
                          ),
                    ),
                  );
                }
              }),
        ),
        Container(
          margin: EdgeInsets.only(top: 0, bottom: 10, left: 0, right: 0),
          color: AppColors.bgColor2,
          height: 0.0,
        ),
        addCommentWidget(),
        Container(
          //height: MediaQuery.of(context).size.height / 3,
          child: StreamBuilder(
            stream: promotionBloc?.commentsList,
            //initialData: promotionBloc.comments,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // if data not loaded yet
                return Container(
                  margin: EdgeInsets.only(top: 70, bottom: 70),
                  alignment: AlignmentDirectional.center,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                );
              } else if (snapshot.hasData) {
                List<PromotionComment> comments =
                    snapshot.data as List<PromotionComment>;
                promotion?.promotionCommentsCount = "${comments.length ?? 0}";
                callback.call("${comments.length ?? 0}");

                return comments != null && comments.length > 0
                    ? Container(
                        margin: EdgeInsets.only(top: 10, bottom: 30),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          itemCount: comments.length,
                          itemBuilder: (BuildContext context, int index) {
                            return PromotionCommentItem(
                                postUser: promotion?.userId ?? "",
                                comment: comments[index]);
                          },
                        ).build(context),
                      )
                    : Container(
                        margin: EdgeInsets.only(top: 70, bottom: 70),
                        alignment: AlignmentDirectional.center,
                        child: Text("No comments",
                            style: TextStyle(color: AppColors.subTitleColor)),
                      );
              } else
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 70, bottom: 70),
                      alignment: AlignmentDirectional.center,
                      child: Text("No comments",
                          style: TextStyle(color: AppColors.subTitleColor)),
                    ),
                  ],
                );
            },
          ),
        ),
        Container(
          key: targetKey,
        ),
      ],
    );
  }

  Widget addCommentWidget() {
    return Column(
      children: [
        /*
        Container(
          height: 1,
          margin: EdgeInsets.only(top: 10, bottom: 10),
          color: AppColors.bgColor2,
        ),*/

        ///Add Comment TextField
        Container(
          color: AppColors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0))),
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  margin: EdgeInsets.only(left: 5, top: 0, bottom: 5),
                  child: TextField(
                    scrollPadding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom -
                            (MediaQuery.of(context).viewInsets.bottom / 3)),
                    controller: commentController,
                    onChanged: (value) {
                      promotionBloc
                          ?.validateCommentField(commentController.text);
                    },
                    style: Theme.of(context).textTheme.bodyLarge,
                    onSubmitted: (String value) {
                      FocusScope.of(context).requestFocus();
                      commentFocusNode.unfocus();
                    },
                    obscureText: false,
                    focusNode: commentFocusNode,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 3,
                    minLines: 1,
                    maxLength: 300,
                    textInputAction: TextInputAction.newline,
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      fillColor: Colors.transparent,
                      counterText: "",
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            topRight: Radius.circular(15.0),
                            bottomLeft: Radius.circular(15.0),
                            bottomRight: Radius.circular(15.0)),
                        borderSide: BorderSide(
                            color: AppColors.subTitleColor, width: 0.9),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0),
                              bottomLeft: Radius.circular(15.0),
                              bottomRight: Radius.circular(15.0)),
                          borderSide: BorderSide(
                              color: AppColors.subTitleColor, width: 0.4)),
                      filled: true,
                      isDense: true,
                      hintText: 'Write comment',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 0,
                child: StreamBuilder<bool>(
                  stream: promotionBloc?.commentButtonState,
                  initialData: false,
                  builder: (BuildContext c, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data == true
                          ? StreamBuilder(
                              stream: promotionBloc?.addCommentLoaderState,
                              initialData: false,
                              builder: (context, snapshot) {
                                if (snapshot.data == true) {
                                  return Container(
                                    margin: EdgeInsets.only(left: 10, right: 5),
                                    padding: EdgeInsets.all(5),
                                    alignment: AlignmentDirectional.center,
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  );
                                } else {
                                  return Container(
                                    margin: EdgeInsets.only(
                                        left: 5, right: 5, bottom: 8, top: 0),
                                    child: GestureDetector(
                                      onTap: () {
                                        promotionBloc?.handleLoader(true);
                                        promotionBloc
                                            ?.addComment(
                                                promotion?.userId ?? "",
                                                commentController.text,
                                                promotion?.promotionId ?? "")
                                            .then((result) {
                                          promotionBloc?.handleLoader(false);
                                          if ((result ?? false)) {
                                            commentController.text = "";
                                            promotionBloc
                                                ?.validateCommentField("");
                                            promotionBloc?.getComments(
                                                promotion?.promotionId ?? "");
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                          } else {
                                            //final snackBar = SnackBar(content: Text(result.message));
                                            //Scaffold.of(context).showSnackBar(snackBar);
                                          }
                                        }).catchError((onError) {
                                          final snackBar = SnackBar(
                                              content:
                                                  Text(onError.toString()));
                                          //Scaffold.of(context).showSnackBar(snackBar);
                                        });
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: AppColors.primaryColor
                                            .withOpacity(0.9),
                                        radius: 22,
                                        child: ClipOval(
                                          child: Icon(
                                            Icons.send,
                                            size: 25,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              })
                          : Container(
                              margin: EdgeInsets.only(
                                  left: 5, right: 5, bottom: 8, top: 0),
                              child: GestureDetector(
                                onTap: () {
                                  null;
                                },
                                child: CircleAvatar(
                                  backgroundColor:
                                      AppColors.primaryColor.withOpacity(0.9),
                                  radius: 22,
                                  child: ClipOval(
                                    child: Icon(
                                      Icons.send,
                                      size: 25,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                    } else {
                      return Container(
                        margin: EdgeInsets.only(
                            left: 5, right: 5, bottom: 8, top: 0),
                        child: GestureDetector(
                          onTap: () {
                            null;
                          },
                          child: CircleAvatar(
                            backgroundColor:
                                AppColors.primaryColor.withOpacity(0.7),
                            radius: 22,
                            child: ClipOval(
                              child: Icon(
                                Icons.send,
                                size: 25,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildUserDetailsWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.only(left: 10),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 0,
                  child: Container(
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                            context, AppRoutes.viewProfileScreen,
                            arguments: promotion?.userId ?? "");
                      },
                      child: (promotion?.profilePic ?? "").isNotEmpty
                          ? Container(
                              child: CircleAvatar(
                                backgroundColor: AppColors.semiPrimary,
                                radius: 25,
                                child: ClipOval(
                                  child: Image(
                                    width: 50,
                                    height: 50,
                                    image: NetworkImage(
                                      AppConstants.imagesBaseUrl +
                                          "/profile_images/" +
                                          (promotion?.profilePic ?? ""),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              child: CircleAvatar(
                                  radius: 25,
                                  backgroundImage: AssetImage(
                                      'assets/default_profile_pic.png')),
                            ),
                    ), //GestureDetector
                  ), // Container
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                              context, AppRoutes.viewProfileScreen,
                              arguments: promotion?.userId ?? "");
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Text(
                            promotion?.userName ?? "",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    color: Colors.black,
                                    fontSize: 14,
                                    height: 1,
                                    fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(
                          AppUtils.getFormattedPostDate(
                              promotion?.createdOn ?? ""),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 11),
                        ),
                      ), // Container
                    ], // children
                  ), // Column
                ),
              ], // children
            ), // Row
          ),
        ), // Container
        /* Expanded(
                                    flex: 0,
                                    child: Container(
                                      child: GestureDetector(
                                        onTap: () {
                                          showPostOptions();
                                        },
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                              top: 10,
                                              bottom: 10),
                                          child: Icon(
                                            Icons.more_vert,
                                            size: 20,
                                            color: AppColors.buttonTextColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),*/
      ], // children
    );
  }

  Widget _buildPictureWidget() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.previewPictureScreen,
            arguments: AppConstants.imagesBaseUrl +
                "/promotion_images/" +
                ((promotion?.promotionPic ?? "").split(",") ?? [])[0]);
      },
      child: (promotion?.promotionPic ?? "").isNotEmpty
          ? AspectRatio(
              aspectRatio: 1 / 1,
              child: Container(
                width: double.infinity,
                child: (promotion?.promotionPic ?? "").isNotEmpty &&
                        ((promotion?.promotionPic ?? "").split(",") ?? [])
                                .length ==
                            1
                    ? FadeInImage.assetNetwork(
                        image: AppConstants.imagesBaseUrl +
                            "/promotion_images/" +
                            ((promotion?.promotionPic ?? "").split(",") ??
                                [])[0],
                        placeholder: "assets/picture_placeholder.webp",
                        placeholderErrorBuilder: (context, error, stackTrace) {
                          return Image.asset("assets/picture_error.png",
                              fit: BoxFit.fill);
                        },
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset("assets/picture_error.png",
                              fit: BoxFit.fill);
                        },
                        fit: BoxFit.cover,
                      )
                    : Container(),
              ),
            )
          : Container(),
    );
  }
}
