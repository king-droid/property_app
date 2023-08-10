import 'package:flutter/material.dart';
import 'package:property_feeds/blocs/promotion/promotion_bloc.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/constants/appConstants.dart';
import 'package:property_feeds/models/promotion.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/provider/user_provider.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:provider/provider.dart';

typedef PromotionDeleteCallback = void Function(String);
typedef PromotionRefreshCallback = void Function(bool);

class PromotionItem extends StatefulWidget {
  Promotion? promotion;
  PromotionDeleteCallback promotionDeleteCallback;
  PromotionRefreshCallback promotionRefreshCallback;

  PromotionItem(
      {Key? key,
      @required this.promotion,
      required this.promotionDeleteCallback,
      required this.promotionRefreshCallback})
      : super(key: key);

  @override
  _PromotionItemState createState() => _PromotionItemState();
}

class _PromotionItemState extends State<PromotionItem> {
  final commentController = TextEditingController();
  FocusNode commentFocusNode = new FocusNode();
  final bloc = PromotionBloc();
  int maxLength = 80;

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<UserProvider>(context, listen: false).userData;
    return GestureDetector(
      onTap: () {
        goToPromotionDetailsScreen(widget.promotion);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black87.withOpacity(.08),
                blurRadius: 2,
                spreadRadius: 1),
          ],
        ),
        margin: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 5),
        width: MediaQuery.of(context).size.width,
        //padding: EdgeInsets.only(left: 2, right: 2, top: 8),
        child: Column(
          children: <Widget>[
            //buildProfileDateWidget(user), // Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        //const SizedBox(height: 10),
                        ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            //borderRadius: BorderRadius.circular(12.0),
                            child: (widget.promotion?.promotionPic ?? "")
                                    .isNotEmpty
                                ? (widget.promotion?.promotionPic ?? "")
                                            .isNotEmpty &&
                                        ((widget.promotion?.promotionPic ?? "")
                                                        .split(",") ??
                                                    [])
                                                .length ==
                                            1
                                    ? Container(
                                        height:
                                            MediaQuery.sizeOf(context).width *
                                                0.8,
                                        width: double.infinity,
                                        //alignment: Alignment.centerLeft,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              width: 0, color: Colors.black26),
                                        ),
                                        /* margin: EdgeInsets.only(
                                                top: 1,
                                                bottom: 5,
                                                right: 5),*/
                                        child: FadeInImage.assetNetwork(
                                          image: AppConstants.imagesBaseUrl +
                                              "/promotion_images/" +
                                              ((widget.promotion
                                                              ?.promotionPic ??
                                                          "")
                                                      .split(",") ??
                                                  [])[0],
                                          placeholder:
                                              "assets/picture_placeholder.webp",
                                          placeholderErrorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                                "assets/picture_error.png",
                                                fit: BoxFit.cover);
                                          },
                                          imageErrorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                                "assets/picture_error.png",
                                                fit: BoxFit.cover);
                                          },
                                          fit: BoxFit.cover,
                                        ))
                                    : Container()
                                : Container()),
                        Container(
                          color: Colors.transparent,
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 10, right: 5, top: 8, bottom: 5),
                                  child: Text(
                                      widget.promotion?.promotionTitle ?? "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              color:
                                                  Colors.black.withOpacity(0.7),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700)),
                                ),
                                //buildDescriptionWidget(),
                                const SizedBox(height: 5),
                              ]),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: 4, bottom: 0, left: 10, right: 10),
                          color: Colors.grey.withOpacity(0.3),
                          height: 0.5,
                        ),
                        Container(
                          color: Colors.transparent,
                          margin: EdgeInsets.only(
                              top: 5, bottom: 5, left: 5, right: 5),
                          child: Container(
                            margin: EdgeInsets.only(top: 5, bottom: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      /*Expanded(
                                        flex: 0,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(context,
                                                AppRoutes.viewProfileScreen,
                                                arguments:
                                                    widget.promotion?.userId ??
                                                        "");
                                          },
                                          child: Container(
                                            child: (widget.promotion
                                                            ?.profilePic ??
                                                        "")
                                                    .isNotEmpty
                                                ? Container(
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          AppColors.semiPrimary,
                                                      radius: 18.5,
                                                      child: ClipOval(
                                                        child: Image(
                                                          width: 36,
                                                          height: 36,
                                                          image: NetworkImage(
                                                            AppConstants
                                                                    .imagesBaseUrl +
                                                                "/profile_images/" +
                                                                (widget.promotion
                                                                        ?.profilePic ??
                                                                    ""),
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    child: CircleAvatar(
                                                        radius: 18,
                                                        backgroundImage: AssetImage(
                                                            'assets/default_profile_pic.png')),
                                                  ), //GestureDetector
                                          ),
                                        ), // Container
                                      ),*/
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 8),
                                                    child: Text(
                                                      widget.promotion
                                                              ?.userName ??
                                                          "",
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall!
                                                          .copyWith(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
                                                              height: 1,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                  ),
                                                ),
                                                /*Container(
                                                  margin: EdgeInsets.only(
                                                      left: 5, bottom: 2),
                                                  child: Text(
                                                      ((widget.promotion
                                                                      ?.userId ??
                                                                  "") ==
                                                              (user?.userId ??
                                                                  ""))
                                                          ? "(You)"
                                                          : "",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall!
                                                          .copyWith(
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                              color: Colors
                                                                  .black54,
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500)),
                                                ),*/
                                              ],
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 10),
                                              child: Text(
                                                widget.promotion?.companyName ??
                                                    "",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                        fontSize: 11,
                                                        color: AppColors
                                                            .subTitleColor),
                                              ),
                                            ),
                                          ], // children
                                        ), // Column
                                      ),
                                    ], // children
                                  ),
                                ),
                                //buildInterestedWidget(user),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.all(1),
                                        child: Icon(
                                          Icons.thumb_up,
                                          size: 15,
                                          color: AppColors.subTitleColor,
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.only(left: 5, right: 5),
                                        child: Text(
                                          "${widget.promotion?.interestsCount ?? 0}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  fontSize: 11,
                                                  color:
                                                      AppColors.subTitleColor),
                                        ),
                                      ),
                                    ]),
                                    Container(
                                      margin: EdgeInsets.only(left: 5),
                                      child: Text(
                                        AppUtils.getFormattedPostDate(
                                            widget.promotion?.createdOn ?? ""),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ), //
                                //buildCommentWidget(),
                                //buildViewsWidget(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ); // Parent column
  }

  buildInterestedWidget(User? user) {
    return GestureDetector(
      onTap: () {
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
          //return;
        } else {
          if ((widget.promotion?.userId ?? "") == (user?.userId ?? "")) {
            Navigator.pushNamed(context, AppRoutes.promotionInterestsScreen,
                arguments: widget.promotion);
          } else {
            bloc
                .interestPromotion(
                    widget.promotion?.userId ?? "",
                    widget.promotion?.promotionId ?? "",
                    (widget.promotion?.userInterestStatus ?? false)
                        ? false
                        : true)
                .then((value) {});
            setState(() {
              (widget.promotion?.userInterestStatus ?? false)
                  ? widget.promotion?.interestsCount =
                      "${(int.parse(widget.promotion?.interestsCount ?? "0") - 1)}"
                  : widget.promotion?.interestsCount =
                      "${(int.parse(widget.promotion?.interestsCount ?? "0") + 1)}";
              widget.promotion?.userInterestStatus =
                  (widget.promotion?.userInterestStatus ?? false)
                      ? false
                      : true;
            });
          }
        }
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.only(left: 5, right: 10, top: 8, bottom: 8),
        margin: EdgeInsets.only(right: 5),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(1),
              child: Icon(
                Icons.thumb_up,
                size: 20,
                color: (widget.promotion?.userInterestStatus ?? false)
                    ? AppColors.primaryColor
                    : AppColors.buttonTextColor,
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 5),
              child: Text(
                "${widget.promotion?.interestsCount ?? 0} Interested",
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: "Roboto_Bold",
                  color: (widget.promotion?.userInterestStatus ?? false)
                      ? AppColors.primaryColor
                      : AppColors.buttonTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildViewsWidget() {
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          /*Container(
                                            margin: EdgeInsets.only(left: 10),
                                            child: Icon(
                                              Icons.remove_red_eye,
                                              size: 20,
                                              color: AppColors.buttonTextColor,
                                            ),
                                          ),*/
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.promotionViewsScreen,
                  arguments: widget.promotion);
            },
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.only(left: 10, right: 8, top: 8, bottom: 8),
              margin: EdgeInsets.only(left: 5, right: 0),
              child: Text(
                  (widget.promotion?.promotionViewsCount ?? "0") == "1" ||
                          (widget.promotion?.promotionViewsCount ?? "0") == "0"
                      ? "${widget.promotion?.promotionViewsCount ?? 0} view"
                      : "${widget.promotion?.promotionViewsCount ?? 0} views",
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
        ],
      ),
      flex: 1,
    );
  }

  buildCommentWidget() {
    return Flexible(
      child: GestureDetector(
        onTap: () async {
          var promotion = await Navigator.pushNamed(
              context, AppRoutes.showPromotionScreen,
              arguments: {"promotion": widget.promotion, "from": "comments"});
          if (promotion != null) {
            setState(() {
              widget.promotion = promotion as Promotion?;
            });
          } else {
            widget.promotionRefreshCallback.call(true);
          }
        },
        child: Container(
          color: Colors.transparent,
          margin: EdgeInsets.only(left: 5),
          padding: EdgeInsets.only(left: 5, right: 10, top: 8, bottom: 8),
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
              Container(
                margin: EdgeInsets.only(left: 5),
                child: Text(
                  (widget.promotion?.promotionCommentsCount ?? "0") == "1" ||
                          (widget.promotion?.promotionCommentsCount ?? "0") ==
                              "0"
                      ? "${widget.promotion?.promotionCommentsCount ?? 0} Comment"
                      : "${widget.promotion?.promotionCommentsCount ?? 0} Comments",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: "Roboto_Bold",
                    color: AppColors.buttonTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      flex: 0,
    );
  }

  buildDescriptionWidget() {
    return Container(
      padding: EdgeInsets.only(left: 1, right: 1, top: 5, bottom: 2),
      //margin: EdgeInsets.only(top: 1, bottom: 2),
      child: Text(
          (widget.promotion?.promotionDescription ?? "").length > maxLength
              ? (widget.promotion?.promotionDescription ?? "")
                      .substring(0, maxLength) +
                  "..."
              : (widget.promotion?.promotionDescription ?? ""),
          //overflow: TextOverflow.ellipsis,
          //maxLines: 2,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.black87.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500)),
    );
  }

  void showPromotionMenuOptions(
      User? user, Promotion? promotion, PromotionDeleteCallback callback) {
    bool isLoading = false;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.0)),
        ),
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              (widget.promotion?.userId ?? "") == (user?.userId ?? "")
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
                          "promotion": widget.promotion
                        }).then((value) {
                          setState(() {
                            widget.promotion = value as Promotion?;
                          });
                        });
                      },
                    )
                  : Container(),
              (widget.promotion?.userId ?? "") == (user?.userId ?? "")
                  ? Divider(color: AppColors.subTitleColor, height: 1)
                  : Container(),
              (widget.promotion?.userId ?? "") == (user?.userId ?? "")
                  ? StatefulBuilder(builder: (context, setState) {
                      return ListTile(
                        leading: new Icon(Icons.delete),
                        trailing: isLoading
                            ? Container(
                                margin: const EdgeInsets.only(
                                    left: 5.0, right: 5.0, top: 1.0),
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
                                bloc
                                    .deletePromotion(
                                        widget.promotion?.promotionId ?? "")
                                    .then((status) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  if (status) {
                                    AppUtils.showToast(
                                        "Promotion deleted successfully");
                                    callback.call(promotion?.promotionId ?? "");
                                    Navigator.pop(context);
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
              (widget.promotion?.userId ?? "") == (user?.userId ?? "")
                  ? Divider(color: AppColors.subTitleColor, height: 1)
                  : Container(),
              new ListTile(
                leading: new Icon(Icons.share),
                title: new Text(
                  'Share this promotion',
                  style: TextStyle(
                      fontFamily: "Roboto_Bold",
                      color: AppColors.buttonTextColor,
                      fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  AppUtils().sharePost(
                      title: promotion?.promotionTitle ?? "",
                      description: promotion?.promotionDescription ?? "");
                },
              ),
              (widget.promotion?.userId ?? "") != (user?.userId ?? "")
                  ? Divider(color: AppColors.subTitleColor, height: 1)
                  : Container(),
              (widget.promotion?.userId ?? "") != (user?.userId ?? "")
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

  buildProfileDateWidget(User? user) {
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
                    child: (widget.promotion?.profilePic ?? "").isNotEmpty
                        ? Container(
                            child: CircleAvatar(
                              backgroundColor: AppColors.semiPrimary,
                              radius: 18.5,
                              child: ClipOval(
                                child: Image(
                                  width: 36,
                                  height: 36,
                                  image: NetworkImage(
                                    AppConstants.imagesBaseUrl +
                                        "/profile_images/" +
                                        (widget.promotion?.profilePic ?? ""),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            child: CircleAvatar(
                                radius: 18,
                                backgroundImage: AssetImage(
                                    'assets/default_profile_pic.png')),
                          ), //GestureDetector
                  ), // Container
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Text(
                                widget.promotion?.userName ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                        color: Colors.black,
                                        fontSize: 14,
                                        height: 1,
                                        fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          /*Container(
                            margin: EdgeInsets.only(left: 5, bottom: 2),
                            child: Text(
                                ((widget.promotion?.userId ?? "") ==
                                        (user?.userId ?? ""))
                                    ? "(You)"
                                    : "",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                        decoration: TextDecoration.none,
                                        color: Colors.black54,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                          ),*/
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(
                          AppUtils.getFormattedPostDate(
                              widget.promotion?.createdOn ?? ""),
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
        ),
        Expanded(
          flex: 0,
          child: Container(
            child: GestureDetector(
              onTap: () {
                showPromotionMenuOptions(user, widget.promotion, (value) {
                  widget.promotionDeleteCallback.call(value);
                });
              },
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
                child: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: AppColors.buttonTextColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void goToPromotionDetailsScreen(Promotion? promotion) async {
    var promotion = await Navigator.pushNamed(
        context, AppRoutes.showPromotionScreen,
        arguments: {"promotion": widget.promotion, "from": ""});
    if (promotion != null) {
      setState(() {
        widget.promotion = promotion as Promotion?;
      });
    } else {
      widget.promotionRefreshCallback.call(true);
    }
  }
}
