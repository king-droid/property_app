import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:property_feeds/blocs/post/post_bloc.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/constants/appConstants.dart';
import 'package:property_feeds/models/post.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/provider/user_provider.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:provider/provider.dart';

typedef PostDeleteCallback = void Function(String);
typedef PostRefreshCallback = void Function(bool);

class PostItem extends StatefulWidget {
  Post? post;
  PostDeleteCallback postDeleteCallback;
  PostRefreshCallback postRefreshCallback;

  PostItem(
      {Key? key,
      @required this.post,
      required this.postDeleteCallback,
      required this.postRefreshCallback})
      : super(key: key);

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  final commentController = TextEditingController();
  FocusNode commentFocusNode = new FocusNode();

  final bloc = PostBloc();

  bool _isLoading = false;
  bool _buttonActive = false;
  bool _isLiked = false;
  double _overlap = 0;
  int maxLength = 50;

  @override
  void didChangeMetrics() {
    final renderObject = context.findRenderObject();
    final renderBox = renderObject as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final widgetRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      renderBox.size.width,
      renderBox.size.height,
    );
    final keyboardTopPixels =
        window.physicalSize.height - window.viewInsets.bottom;
    final keyboardTopPoints = keyboardTopPixels / window.devicePixelRatio;
    final overlap = widgetRect.bottom - keyboardTopPoints;
    if (overlap >= 0) {
      setState(() {
        _overlap = overlap;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<UserProvider>(context, listen: false).userData;
    return GestureDetector(
      onTap: () {
        goToPostDetailsScreen(widget.post);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black87.withOpacity(.08),
                blurRadius: 2,
                spreadRadius: 1),
          ],
        ),
        // Decoration
        margin: EdgeInsets.only(left: 8, top: 5, right: 8, bottom: 5),
        width: double.infinity,
        padding: EdgeInsets.only(top: 8),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                /* new ClipPath(
                  clipper: new CustomHalfCircleClipper(),*/
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
                            child: (widget.post?.profilePic ?? "").isNotEmpty
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
                                                (widget.post?.profilePic ?? ""),
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: EdgeInsets.only(left: 5),
                                      child: Text(
                                        widget.post?.userName ?? "",
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
                                  Container(
                                    margin: EdgeInsets.only(left: 5, bottom: 0),
                                    child: Text(
                                        ((widget.post?.userId ?? "") ==
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
                                  ),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Text(
                                  AppUtils.getFormattedPostDate(
                                      widget.post?.createdOn ?? ""),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontSize: 11, height: 1.2),
                                ),
                              ), // Container
                            ], // children
                          ), // Column
                        ),
                      ], // children
                    ), // Row
                  ),
                ), // Container
                Expanded(
                  flex: 0,
                  child: Container(
                    child: GestureDetector(
                      onTap: () {
                        showPostMenuOptions(user, widget.post, (value) {
                          widget.postDeleteCallback.call(value);
                        });
                      },
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(
                            left: 8, right: 8, top: 5, bottom: 5),
                        child: Icon(
                          Icons.more_vert,
                          size: 20,
                          color: AppColors.buttonTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ], // children
            ), // Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          color: Colors.transparent,
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 1, right: 1, top: 5),
                                  child: Text(widget.post?.postTitle ?? "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                              color: Colors.black
                                                  .withOpacity(0.65),
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  width: double.infinity,
                                  //color: AppColors.bgColorLight.withOpacity(0.3),
                                  padding: EdgeInsets.only(
                                      left: 1, right: 1, top: 0, bottom: 0),
                                  margin: EdgeInsets.only(top: 2, bottom: 5),
                                  child: Text(
                                      /*(widget.post?.postDescription ?? "")
                                          .length >
                                          maxLength
                                          ? (widget.post?.postDescription ??
                                          "")
                                          .substring(0, maxLength) +
                                          "..."
                                          : (widget.post?.postDescription ??
                                          ""),*/
                                      widget.post?.postDescription ?? "",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                              color: Colors.black87
                                                  .withOpacity(0.6),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                ),
                                /* (widget.post?.postDescription ?? "").length >
                                        maxLength
                                    ? GestureDetector(
                                        onTap: () {
                                          goToPostDetailsScreen(widget.post);
                                        },
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          child: Text("Read more",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                      decoration:
                                                          TextDecoration.none,
                                                      color: AppColors
                                                          .primaryColor
                                                          .withOpacity(0.7),
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                        ),
                                      )
                                    : Container(),*/
                                // const SizedBox(height: 5),
                                Container(
                                  margin: EdgeInsets.only(bottom: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            // const SizedBox(height: 5),
                                            /* (widget.post?.postPic ?? "")
                                                    .isNotEmpty
                                                ? Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.image_sharp,
                                                        size: 18,
                                                        color: Colors.black54,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        (widget.post?.postPic ??
                                                                    "")
                                                                .isNotEmpty
                                                            ? ((widget.post?.postPic ?? "").split(",") ??
                                                                            [])
                                                                        .length ==
                                                                    1
                                                                ? "${((widget.post?.postPic ?? "").split(",") ?? []).length} Picture"
                                                                : "${((widget.post?.postPic ?? "").split(",") ?? []).length} Pictures"
                                                            : "No picture",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .copyWith(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                    ],
                                                  )
                                                : Container(),*/
                                            Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 2),
                                                    child: Icon(
                                                      Icons.location_on_sharp,
                                                      size: 15,
                                                      color: AppColors
                                                          .headingsColor,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      widget.post
                                                              ?.propertyLocation ??
                                                          "",
                                                      //textAlign: TextAlign.end,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColors
                                                                  .headingsColor),
                                                    ),
                                                  ),
                                                ]),
                                          ],
                                        ),
                                      ),
                                      /*Container(
                                        child: Column(
                                          //mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            (widget.post?.propertySize ?? "")
                                                    .isEmpty
                                                ? Container()
                                                : Text(
                                                    "${widget.post?.propertySize ?? ""} ${widget.post?.propertySizeType}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black45,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                  ),
                                            const SizedBox(height: 2),
                                            (widget.post?.propertyPrice ?? "")
                                                    .isEmpty
                                                ? Container()
                                                : Text(
                                                    "Rs. ${widget.post?.propertyPrice ?? ""} ${widget.post?.propertyPriceType != "Total Price" ? widget.post?.propertyPriceType : ""}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black45,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                  ),
                                          ],
                                        ),
                                      ),*/
                                    ],
                                  ),
                                ),
                              ]),
                        ),
                        /* Wrap(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.start,
                          children: List.generate(
                            ((widget.post?.postPic ?? "").split(",") ?? [])
                                .length,
                            (index) {
                              return InkWell(
                                onTap: () {},
                                child: Container(
                                  //margin: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                                  child: ((widget.post?.postPic ?? "")
                                                  .split(",") ??
                                              [])[index]
                                          .isNotEmpty
                                      ? Container(
                                          margin: EdgeInsets.only(
                                              top: 1, bottom: 5, right: 8),
                                          child: Image.network(
                                            AppConstants.imagesBaseUrl +
                                                "/post_images/" +
                                                ((widget.post?.postPic ?? "")
                                                        .split(",") ??
                                                    [])[index],
                                            //scale: 5
                                            height: 80, width: 70,
                                            errorBuilder: (BuildContext context,
                                                Object? exception,
                                                StackTrace? stackTrace) {
                                              return Container();
                                            },
                                          ),
                                        )
                                      : Container(),
                                ),
                              );
                            },
                          ),
                        ),*/
                        /*Container(
                          alignment: Alignment.centerLeft,
                          child: (widget.post?.postPic ?? "").isNotEmpty
                              ? Container(
                              margin: EdgeInsets.only(top: 1, bottom: 5),
                              child: Image(
                                width: 90,
                                height: 50,
                                image: NetworkImage(
                                  AppConstants.imagesBaseUrl +
                                      "/post_images/" +
                                      (widget.post?.postPic ?? ""),
                                  //scale: 5
                                ),
                                fit: BoxFit.fitWidth,
                              ))
                              : Container(),
                        ),*/
                        //const SizedBox(height: 5),
                        Container(
                          margin: EdgeInsets.only(
                              top: 4, bottom: 0, left: 0, right: 0),
                          color: Colors.grey.withOpacity(0.5),
                          height: 0.7,
                        ), //
                        Container(
                          color: Colors.transparent,
                          //padding: EdgeInsets.only(top: 3, bottom: 3, left: 1, right: 1),
                          child: Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                    child: GestureDetector(
                                      onTap: () {
                                        if ((user?.accountType ==
                                            "guest_account")) {
                                          AppUtils.showNativeAlertDialog(
                                              context: context,
                                              title: "Registration required",
                                              content:
                                                  "You are currently using app as guest.\n\nYou need to create account to access all features of app.",
                                              cancelActionText: "Cancel",
                                              defaultActionText:
                                                  "Create account Now",
                                              defaultActionClick: () {
                                                Navigator.pushNamed(context,
                                                    AppRoutes.landingScreen);
                                              });
                                          //return;
                                        } else {
                                          /*if ((widget.post?.userId ?? "") ==
                                              (user?.userId ?? "")) {
                                            Navigator.pushNamed(context,
                                                AppRoutes.postInterestsScreen,
                                                arguments: widget.post);
                                          } else {*/
                                          bloc
                                              .interestPost(
                                                  widget.post?.userId ?? "",
                                                  widget.post?.postId ?? "",
                                                  (widget.post?.userInterestStatus ??
                                                          false)
                                                      ? false
                                                      : true)
                                              .then((value) {});
                                          setState(() {
                                            (widget.post?.userInterestStatus ??
                                                    false)
                                                ? widget.post?.interestsCount =
                                                    "${(int.parse(widget.post?.interestsCount ?? "0") - 1)}"
                                                : widget.post?.interestsCount =
                                                    "${(int.parse(widget.post?.interestsCount ?? "0") + 1)}";
                                            widget.post
                                                ?.userInterestStatus = (widget
                                                        .post
                                                        ?.userInterestStatus ??
                                                    false)
                                                ? false
                                                : true;
                                          });
                                        }
                                        //}
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                        padding: EdgeInsets.only(
                                            left: 5,
                                            right: 10,
                                            top: 8,
                                            bottom: 8),
                                        margin: EdgeInsets.only(right: 5),
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.all(1),
                                              child: Icon(
                                                Icons.thumb_up,
                                                size: 20,
                                                color: (widget.post
                                                            ?.userInterestStatus ??
                                                        false)
                                                    ? AppColors.primaryColor
                                                    : AppColors.buttonTextColor,
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 5),
                                              child: Text(
                                                "${widget.post?.interestsCount ?? 0}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: "Roboto_Bold",
                                                  color: (widget.post
                                                              ?.userInterestStatus ??
                                                          false)
                                                      ? AppColors.primaryColor
                                                      : AppColors
                                                          .buttonTextColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    flex: 0),
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () async {
                                      var post = await Navigator.pushNamed(
                                          context, AppRoutes.showPostScreen,
                                          arguments: {
                                            "post": widget.post,
                                            "from": "comments"
                                          });
                                      if (post != null) {
                                        setState(() {
                                          widget.post = post as Post?;
                                        });
                                      } else {
                                        widget.postRefreshCallback.call(true);
                                      }
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      margin: EdgeInsets.only(left: 5),
                                      padding: EdgeInsets.only(
                                          left: 5,
                                          right: 10,
                                          top: 8,
                                          bottom: 8),
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
                                              (widget.post?.postCommentsCount ??
                                                              "0") ==
                                                          "1" ||
                                                      (widget.post?.postCommentsCount ??
                                                              "0") ==
                                                          "0"
                                                  ? "${widget.post?.postCommentsCount ?? 0} Comment"
                                                  : "${widget.post?.postCommentsCount ?? 0} Comments",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: "Roboto_Bold",
                                                color:
                                                    AppColors.buttonTextColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  flex: 0,
                                ),
                                Flexible(
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
                                          Navigator.pushNamed(context,
                                              AppRoutes.postViewsScreen,
                                              arguments: widget.post);
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          padding: EdgeInsets.only(
                                              left: 10,
                                              right: 8,
                                              top: 8,
                                              bottom: 8),
                                          margin: EdgeInsets.only(
                                              left: 5, right: 0),
                                          child: Text(
                                              (widget.post?.postViewsCount ??
                                                              "0") ==
                                                          "1" ||
                                                      (widget.post?.postViewsCount ??
                                                              "0") ==
                                                          "0"
                                                  ? "${widget.post?.postViewsCount ?? 0} view"
                                                  : "${widget.post?.postViewsCount ?? 0} views",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall),
                                        ),
                                      ),
                                    ],
                                  ),
                                  flex: 1,
                                ),
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

  void showPostMenuOptions(
      User? user, Post? post, PostDeleteCallback callback) {
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
              (widget.post?.userId ?? "") == (user?.userId ?? "")
                  ? ListTile(
                      leading: new Icon(Icons.edit),
                      title: new Text(
                        'Edit post',
                        style: TextStyle(
                            fontFamily: "Roboto_Bold",
                            color: AppColors.buttonTextColor,
                            fontSize: 16),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        await Navigator.pushNamed(
                            context, AppRoutes.addPostScreen, arguments: {
                          "mode": "edit",
                          "post": widget.post
                        }).then((value) {
                          setState(() {
                            widget.post = value as Post?;
                          });
                        });
                      },
                    )
                  : Container(),
              (widget.post?.userId ?? "") == (user?.userId ?? "")
                  ? Divider(color: AppColors.subTitleColor, height: 1)
                  : Container(),
              (widget.post?.userId ?? "") == (user?.userId ?? "")
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
                          'Delete post',
                          style: TextStyle(
                              fontFamily: "Roboto_Bold",
                              color: AppColors.buttonTextColor,
                              fontSize: 16),
                        ),
                        onTap: () async {
                          AppUtils.showNativeAlertDialog(
                              context: context,
                              title: "Delete post",
                              content:
                                  "Are you sure you want to delete this post?",
                              cancelActionText: "Cancel",
                              defaultActionText: "Delete",
                              defaultActionClick: () {
                                setState(() {
                                  isLoading = true;
                                });
                                bloc
                                    .deletePost(widget.post?.postId ?? "")
                                    .then((status) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  if (status) {
                                    AppUtils.showToast(
                                        "Post deleted successfully");
                                    callback.call(post?.postId ?? "");
                                    Navigator.pop(context);
                                  } else {
                                    AppUtils.showToast(
                                        "Failed to delete post. Please try again");
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
              (widget.post?.userId ?? "") == (user?.userId ?? "")
                  ? Divider(color: AppColors.subTitleColor, height: 1)
                  : Container(),
              new ListTile(
                leading: new Icon(Icons.share),
                title: new Text(
                  'Share this post',
                  style: TextStyle(
                      fontFamily: "Roboto_Bold",
                      color: AppColors.buttonTextColor,
                      fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  AppUtils().sharePost(
                      title: post?.postTitle ?? "",
                      description: post?.postDescription ?? "");
                },
              ),
              (widget.post?.userId ?? "") != (user?.userId ?? "")
                  ? Divider(color: AppColors.subTitleColor, height: 1)
                  : Container(),
              (widget.post?.userId ?? "") != (user?.userId ?? "")
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

  void goToPostDetailsScreen(Post? post) async {
    var post = await Navigator.pushNamed(context, AppRoutes.showPostScreen,
        arguments: {"post": widget.post, "from": ""});
    if (post != null) {
      setState(() {
        widget.post = post as Post?;
      });
    } else {
      widget.postRefreshCallback.call(true);
    }
  }
}
