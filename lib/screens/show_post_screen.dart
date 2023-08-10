import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:property_feeds/blocs/post/post_bloc.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/constants/appConstants.dart';
import 'package:property_feeds/main.dart';
import 'package:property_feeds/models/post.dart';
import 'package:property_feeds/models/post_comment.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/provider/user_provider.dart';
import 'package:property_feeds/screens/post_comment_item.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:provider/provider.dart';

class ShowPostScreen extends StatefulWidget {
  @override
  ShowPostScreenState createState() {
    return new ShowPostScreenState();
  }
}

typedef CommentsRefreshCallback = void Function(String);

class ShowPostScreenState extends State<ShowPostScreen> {
  Post? post;
  String? from;
  bool isLoading = false;
  PostBloc? postBloc = PostBloc();
  late PageController _pageController;
  late ScrollController scrollController;
  User? user;
  final commentController = TextEditingController();
  FocusNode commentFocusNode = new FocusNode();
  final targetKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _pageController =
        PageController(/*viewportFraction: 0.0, */ initialPage: 0);

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
          user?.userId != post?.userId) {
        postBloc?.viewPost(post?.postId ?? "").then((value) {});
      }
      postBloc?.getComments(post?.postId ?? "");
      postBloc?.setCommentsCount("${post?.postCommentsCount ?? "0"}");
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
      Navigator.pop(context, post);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserProvider>(context, listen: false).userData;
    if (post == null) {
      post =
          (ModalRoute.of(context)!.settings.arguments as Map)["post"] as Post?;
    }
    from =
        (ModalRoute.of(context)!.settings.arguments as Map)["from"] as String?;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
                                color: AppColors.white,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    _buildPicturesWidget(),
                                    //buildDateAndViewsWidget(),
                                    buildTitleWidget(),
                                    buildDescriptionWidget(),
                                    buildLocationWidget(),
                                    buildSendInterestedSharePostWidget(),
                                    buildInterestedPeopleWidget(),
                                    promoterWidget(),
                                    commentsListWidget((value) {
                                      postBloc!.setCommentsCount(value ?? "0");
                                    }),
                                  ],
                                )),
                          ),
                        ),
                      ),
                      buildTopAppBarOverlayWidget(),
                    ],
                  ),
                ),
              ),
              //addCommentWidget(),
            ],
          ),
        ),
      ),
    );
  }

  buildTopAppBarOverlayWidget() {
    return Container(
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
      height: 50,
      child: Row(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: () {
                if (from == "notification") {
                  navKeyRoot.currentState
                      ?.pushReplacementNamed(AppRoutes.homeScreen);
                } else {
                  Navigator.pop(context, post);
                }
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
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.overlayButtonColor,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Container(
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildDateAndViewsWidget() {
    return Container(
      margin: EdgeInsets.only(left: 10, bottom: 2, top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(
            Icons.location_on_sharp,
            size: 15,
            color: AppColors.lineBorderColor,
          ),
          const SizedBox(width: 2),
          Expanded(
            flex: 1,
            child: Text(
              post?.propertyLocation ?? "",
              //textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.titleColor.withOpacity(0.6)),
            ),
          ),
        ],
      ),
    );
  }

  buildLocationWidget() {
    return Column(children: [
      Container(
        margin: EdgeInsets.only(left: 10, bottom: 2, top: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.location_on_sharp,
                size: 15,
                color: AppColors.lineBorderColor,
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: 1,
              child: Text(
                post?.propertyLocation ?? "",
                //textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.titleColor.withOpacity(0.6)),
              ),
            ),
          ],
        ),
      ),
      Container(
        width: double.infinity,
        //color: Colors.blue,
        margin: EdgeInsets.only(bottom: 8, left: 10),
        child: Text(
          post?.propertyCity ?? "",
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.titleColor.withOpacity(0.5)),
        ),
      ),
    ]);
  }

  buildTitleWidget() {
    return Container(
      width: double.infinity,
      //color: Colors.blue,
      margin: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 5),
      child: Text(post?.postTitle ?? "",
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.black.withOpacity(0.7),
              fontSize: 17,
              fontWeight: FontWeight.bold)),
    );
  }

  buildDescriptionWidget() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 15, right: 10, top: 5, bottom: 15),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 20),
        child: Text(post?.postDescription ?? "",
            overflow: TextOverflow.fade,
            textAlign: TextAlign.start,
            //maxLines: 10,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.black87.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  buildDividerWidget() {
    return Container(
      margin: EdgeInsets.only(top: 0, bottom: 0),
      color: AppColors.bgColor2,
      height: 0.5,
    );
  }

  buildSendInterestedSharePostWidget() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 0),
      child: Row(children: [
        Expanded(flex: 1, child: interestWidget()),
        Expanded(
          flex: 1,
          child: shareWidget(),
        ),
        Expanded(
          flex: 1,
          child: viewsWidget(),
        ),
      ]),
    );
  }

  buildInterestedPeopleWidget() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      // /color: AppColors.bgColorLight,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontSize: 12, color: AppColors.subTitleColor),
          children: <TextSpan>[
            TextSpan(
                text: "${post?.interestsCount ?? 0} People",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.primaryColor.withOpacity(0.7),
                    fontSize: 12),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushNamed(context, AppRoutes.postInterestsScreen,
                        arguments: post);
                  }),
            TextSpan(text: ' have shown interest recently'),
          ],
        ),
      ),
    );
  }

  buildProfileWidget() {
    return Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      child: Row(
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
                        child: (post?.profilePic ?? "").isNotEmpty
                            ? Container(
                                child: CircleAvatar(
                                  backgroundColor: AppColors.semiPrimary,
                                  radius: 22,
                                  child: ClipOval(
                                    child: Image(
                                      width: 44,
                                      height: 44,
                                      image: NetworkImage(
                                        AppConstants.imagesBaseUrl +
                                            "/profile_images/" +
                                            (post?.profilePic ?? ""),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                child: CircleAvatar(
                                    radius: 22,
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
                                  margin: EdgeInsets.only(left: 5, top: 5),
                                  child: Text(
                                    post?.userName ?? "",
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
                            "${AppConstants.userTypes[post?.userType ?? ""] ?? ""}",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    fontSize: 12,
                                    color: AppColors.subTitleColor),
                          ),
                        ),
                        ((post?.userType ?? "") != "end_user")
                            ? Container(
                                margin: EdgeInsets.only(left: 7),
                                child: Text(
                                  post?.companyName ?? "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          fontSize: 12,
                                          color: AppColors.subTitleColor),
                                ),
                              )
                            : Container(),
                      ], // children
                    ), // Column
                  ),
                ], // children
              ), // Row
            ),
          ),
          viewProfileWidget(),
        ],
      ),
    );
  }

  Widget promoterWidget() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgColorLight,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(width: 0.08, color: AppColors.subTitleColor),
      ),
      padding: EdgeInsets.only(left: 5, right: 5),
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          /*Container(
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
            margin: EdgeInsets.only(top: 0, bottom: 0),
            color: AppColors.bgColor2,
            height: 0.5,
          ),*/
          buildProfileWidget(),
          buildProfileDetailsSections(),
        ],
      ),
    );
  }

  Widget buildProfileDetailsSections() {
    return Container(
      //color: AppColors.bgColorLight,
      //width: MediaQuery.of(context).size.width / 2,
      padding: EdgeInsets.only(left: 20, right: 10, top: 5, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 25),
          Expanded(
            flex: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.userPostsScreen,
                    arguments: post?.userId ?? "");
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  //color: AppColors.primaryColor.withOpacity(0.1),
                ),
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Text(
                        post?.postsCount ?? "",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.headingsColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(width: 2),
                    Text(
                      " Posts",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.headingsColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          //SizedBox(width: 8),
          Container(
              margin: EdgeInsets.only(top: 5),
              width: 1,
              height: 10,
              color: AppColors.bgColor2),
          Expanded(
            flex: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.userPromotionsScreen,
                    arguments: post?.userId ?? "");
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  //color: AppColors.primaryColor.withOpacity(0.1),
                ),
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Text(
                        post?.promotionsCount ?? "",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.headingsColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(width: 2),
                    Text(
                      " Promotions",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.headingsColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
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

  Widget viewProfileWidget() {
    return Container(
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.viewProfileScreen,
              arguments: post?.userId ?? "");
        },
        child: Container(
          ///color: AppColors.white,
          padding: EdgeInsets.all(5),
          child: Text("View profile",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: AppColors.primaryColor, fontSize: 13)),
        ),
      ),
    );
  }

  _buildPicturesWidget() {
    List<String> pictures = (post?.postPic ?? "").isNotEmpty
        ? ((post?.postPic ?? "").split(",") ?? [])
        : [];
    int activePosition = 0;
    return pictures.isEmpty
        ? AspectRatio(
            aspectRatio: 4 / 2.5,
            child: Container(
                child: Image.asset("assets/no_picture_placeholder.png",
                    fit: BoxFit.none)),
          )
        : StatefulBuilder(builder: (context, setState) {
            return Column(
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Container(
                        width: double.infinity,
                        child: PageView.builder(
                            itemCount: pictures.length,
                            pageSnapping: true,
                            controller: _pageController,
                            onPageChanged: (page) {
                              setState(() {
                                activePosition = page;
                              });
                            },
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRoutes.previewPictureScreen,
                                      arguments: AppConstants.imagesBaseUrl +
                                          "/post_images/" +
                                          pictures[index]);
                                },
                                child: Container(
                                  //margin: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                                  child: pictures[index].isNotEmpty
                                      ? Container(
                                          child: FadeInImage.assetNetwork(
                                          image: AppConstants.imagesBaseUrl +
                                              "/post_images/" +
                                              pictures[index],
                                          placeholder:
                                              "assets/picture_placeholder.webp",
                                          placeholderErrorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                                "assets/picture_error.png",
                                                fit: BoxFit.fill);
                                          },
                                          imageErrorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                                "assets/picture_error.png",
                                                fit: BoxFit.fill);
                                          },
                                          fit: BoxFit.cover,
                                        ))
                                      : Container(),
                                ),
                              );
                            }),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                indicators(pictures.length, activePosition)),
                      ),
                    ),
                  ],
                ),
                Container(
                  //color: AppColors.bgColorLight,
                  padding: EdgeInsets.only(top: 5, right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        color: Colors.transparent,
                        child: Text(
                          AppUtils.getFormattedPostDate(post?.createdOn ?? ""),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          });
  }

  List<Widget> indicators(imagesLength, currentIndex) {
    return List<Widget>.generate(imagesLength, (index) {
      return Container(
        margin: EdgeInsets.all(3),
        width: currentIndex == index ? 10 : 9,
        height: currentIndex == index ? 10 : 9,
        decoration: BoxDecoration(
            color: currentIndex == index
                ? AppColors.overlayButtonColor
                : AppColors.whiteLight,
            shape: BoxShape.circle),
      );
    });
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
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                (post?.userId ?? "") == (user?.userId ?? "")
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
                                  context, AppRoutes.addPostScreen,
                                  arguments: {"mode": "edit", "post": post})
                              .then((value) {
                            setState(() {
                              post = value as Post?;
                            });
                          });
                        },
                      )
                    : Container(),
                (post?.userId ?? "") == (user?.userId ?? "")
                    ? Divider(color: AppColors.subTitleColor, height: 1)
                    : Container(),
                (post?.userId ?? "") == (user?.userId ?? "")
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
                                  postBloc
                                      ?.deletePost(post?.postId ?? "")
                                      .then((status) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (status) {
                                      AppUtils.showToast(
                                          "Post deleted successfully");
                                      Navigator.pop(context);
                                      Navigator.pop(context, null);
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
                (post?.userId ?? "") == (user?.userId ?? "")
                    ? Divider(color: AppColors.subTitleColor, height: 1)
                    : Container(),
                /* ListTile(
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
                ),*/
                (post?.userId ?? "") != (user?.userId ?? "")
                    ? Divider(color: AppColors.subTitleColor, height: 1)
                    : Container(),
                (post?.userId ?? "") != (user?.userId ?? "")
                    ? ListTile(
                        leading: new Icon(Icons.report_problem),
                        title: new Text(
                          'Report problem',
                          style: TextStyle(
                              color: AppColors.buttonTextColor, fontSize: 16),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      )
                    : Container(),
              ],
            ),
          );
        });
  }

  Widget shareWidget() {
    return Center(
      child: InkWell(
        onTap: () {
          //Navigator.pop(context);
          AppUtils().sharePost(
              title: post?.postTitle ?? "",
              description: post?.postDescription ?? "");
        },
        child: Container(
          //width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.bgColorLight,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(width: 0.2, color: AppColors.bgColor2),
          ),
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.only(
            left: 5,
            right: 5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(1),
                child: Icon(
                  Icons.share,
                  size: 20,
                  color: AppColors.buttonTextColor,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 5),
                child: Text(
                  " Share ",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.buttonTextColor, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget viewsWidget() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.postViewsScreen,
            arguments: post);
      },
      child: Center(
        child: Container(
          //width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.bgColorLight,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            border: Border.all(width: 0.2, color: AppColors.bgColor2),
          ),
          padding: EdgeInsets.all(7),
          margin: EdgeInsets.only(
            left: 5,
            right: 5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                      (post?.postViewsCount ?? "0") == "1" ||
                              (post?.postViewsCount ?? "0") == "0" ||
                              (post?.postViewsCount ?? "0") == "1"
                          ? "${post?.postViewsCount ?? 0} View"
                          : "${post?.postViewsCount ?? 0} Views",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontSize: 12)),
                ),
              ),
            ],
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
          if ((post?.userId ?? "") == (user?.userId ?? "")) {
            Navigator.pushNamed(context, AppRoutes.postInterestsScreen,
                arguments: post);
          } else {
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
              postBloc
                  ?.interestPost(post?.userId ?? "", post?.postId ?? "",
                      (post?.userInterestStatus ?? false) ? false : true)
                  .then((value) {});
              setState(() {
                (post?.userInterestStatus ?? false)
                    ? post?.interestsCount =
                        "${(int.parse(post?.interestsCount ?? "0") - 1)}"
                    : post?.interestsCount =
                        "${(int.parse(post?.interestsCount ?? "0") + 1)}";
                post?.userInterestStatus =
                    (post?.userInterestStatus ?? false) ? false : true;
              });
            }
          }
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.bgColorLight,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(width: 0.2, color: AppColors.bgColor2),
          ),
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.only(
            left: 5,
            right: 5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(1),
                child: Icon(
                  Icons.thumb_up_alt_outlined,
                  size: 20,
                  color: (post?.userInterestStatus ?? false)
                      ? AppColors.primaryColor
                      : AppColors.buttonTextColor,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 5),
                child: Text(
                  /*"${promotion?.interestsCount ?? 0} Interested",*/
                  (post?.userInterestStatus ?? false)
                      ? "Interested"
                      : "Interested",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontSize: 12,
                      color: (post?.userInterestStatus ?? false)
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

  Widget interestCommentsWidget() {
    return Container(
      color: AppColors.bgColor,
      padding: EdgeInsets.only(top: 3, bottom: 3, left: 1, right: 1),
      child: Container(
        padding: EdgeInsets.only(left: 1, right: 1),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
                child: GestureDetector(
                  onTap: () {
                    if ((post?.userId ?? "") == (user?.userId ?? "")) {
                      Navigator.pushNamed(
                          context, AppRoutes.postInterestsScreen,
                          arguments: post);
                    } else {
                      if ((user?.accountType == "guest_account")) {
                        AppUtils.showNativeAlertDialog(
                            context: context,
                            title: "Registration required",
                            content:
                                "You are currently using app as guest.\n\nYou need to create account to access all features of app.",
                            cancelActionText: "Cancel",
                            defaultActionText: "Create account Now",
                            defaultActionClick: () {
                              Navigator.pushNamed(
                                  context, AppRoutes.landingScreen);
                            });
                        return;
                      } else {
                        postBloc
                            ?.interestPost(
                                post?.userId ?? "",
                                post?.postId ?? "",
                                (post?.userInterestStatus ?? false)
                                    ? false
                                    : true)
                            .then((value) {});
                        setState(() {
                          (post?.userInterestStatus ?? false)
                              ? post?.interestsCount =
                                  "${(int.parse(post?.interestsCount ?? "0") - 1)}"
                              : post?.interestsCount =
                                  "${(int.parse(post?.interestsCount ?? "0") + 1)}";
                          post?.userInterestStatus =
                              (post?.userInterestStatus ?? false)
                                  ? false
                                  : true;
                        });
                      }
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding:
                        EdgeInsets.only(left: 5, right: 10, top: 8, bottom: 8),
                    margin: EdgeInsets.only(right: 5),
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(1),
                          child: Icon(
                            Icons.thumb_up,
                            size: 20,
                            color: (post?.userInterestStatus ?? false)
                                ? AppColors.primaryColor
                                : AppColors.buttonTextColor,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 5),
                          child: Text(
                            "${post?.interestsCount ?? 0} Interested",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: "Roboto_Bold",
                              color: (post?.userInterestStatus ?? false)
                                  ? AppColors.primaryColor
                                  : AppColors.buttonTextColor,
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
                onTap: () {},
                child: Container(
                  color: Colors.transparent,
                  margin: EdgeInsets.only(left: 5),
                  padding:
                      EdgeInsets.only(left: 5, right: 10, top: 5, bottom: 5),
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
                          stream: postBloc!.commentsCount,
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
                                  post?.postCommentsCount ?? "0";
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
                      Navigator.pushNamed(context, AppRoutes.postViewsScreen,
                          arguments: post);
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding:
                          EdgeInsets.only(left: 5, right: 5, top: 8, bottom: 8),
                      margin: EdgeInsets.only(left: 5, right: 0),
                      child: Text(
                          (post?.postViewsCount ?? "0") == "1" ||
                                  (post?.postViewsCount ?? "0") == "0"
                              ? "${post?.postViewsCount ?? 0} view"
                              : "${post?.postViewsCount ?? 0} views",
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                  ),
                ],
              ),
              flex: 1,
            ),
          ],
        ),
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
          margin: EdgeInsets.only(top: 10, bottom: 0),
          child: StreamBuilder(
              stream: postBloc!.commentsCount,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  String commentsCount = snapshot.data;
                  return Container(
                    //color: AppColors.bgColorLight,
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
                  String commentsCount = post?.postCommentsCount ?? "0";
                  return Container(
                    //color: AppColors.bgColorLight,
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
        //buildDividerWidget(),
        addCommentWidget(),
        Container(
          //height: MediaQuery.of(context).size.height / 3,
          child: StreamBuilder(
            stream: postBloc?.commentsList,
            //initialData: postBloc.comments,
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
                List<PostComment> comments = snapshot.data as List<PostComment>;
                post?.postCommentsCount = "${comments.length ?? 0}";
                callback.call("${comments.length ?? 0}");

                return comments != null && comments.length > 0
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 10, bottom: 30),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 0),
                              itemCount: comments.length,
                              itemBuilder: (BuildContext context, int index) {
                                return PostCommentItem(
                                    postUser: post?.userId ?? "",
                                    comment: comments[index]);
                              },
                            ).build(context),
                          ),
                        ],
                      )
                    : Container(
                        margin: EdgeInsets.only(top: 70, bottom: 70),
                        alignment: AlignmentDirectional.center,
                        child: Text("No comments",
                            style: TextStyle(color: AppColors.subTitleColor)),
                      );
              } else {
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
              }
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
                  /*decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0))),*/
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  margin: EdgeInsets.only(left: 10, bottom: 5),
                  child: TextField(
                    controller: commentController,
                    scrollPadding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom -
                            (MediaQuery.of(context).viewInsets.bottom / 3)),
                    onChanged: (value) {
                      postBloc?.validateCommentField(commentController.text);
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
                    maxLines: null,
                    minLines: 1,
                    maxLength: 200,
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
              /*Container(
                margin: EdgeInsets.all(5),
                child: GestureDetector(
                  onTap: () {
                    null;
                  },
                  child: CircleAvatar(
                    backgroundColor: AppColors.lineBorderColor,
                    radius: 22,
                    child: ClipOval(
                      child: Icon(
                        Icons.send,
                        size: 20,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),*/
              Expanded(
                flex: 0,
                child: StreamBuilder<bool>(
                  stream: postBloc?.commentButtonState,
                  initialData: false,
                  builder: (BuildContext c, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data == true
                          ? StreamBuilder(
                              stream: postBloc?.addCommentLoaderState,
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
                                    margin: EdgeInsets.all(5),
                                    child: GestureDetector(
                                      onTap: () {
                                        postBloc?.handleLoader(true);
                                        postBloc
                                            ?.addComment(
                                                post?.userId ?? "",
                                                commentController.text,
                                                post?.postId ?? "")
                                            .then((result) {
                                          postBloc?.handleLoader(false);
                                          if ((result ?? false)) {
                                            commentController.text = "";
                                            postBloc?.validateCommentField("");
                                            postBloc?.getComments(
                                                post?.postId ?? "");
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
                                            .withOpacity(0.7),
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
                              margin: EdgeInsets.all(5),
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
                    } else {
                      return Container(
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
}
