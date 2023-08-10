import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/models/notification.dart';
import 'package:property_feeds/models/post.dart';
import 'package:property_feeds/models/promotion.dart';
import 'package:property_feeds/screens/notification_item.dart';
import 'package:property_feeds/utils/AdHelper.dart';
import 'package:property_feeds/utils/app_storage.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:property_feeds/widgets/native_add_widget_notifications_listing.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification>? notifications = [];
  BannerAd? _ad;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      AppUtils.getAllNotifications().then((value) {
        setState(() {
          notifications = value;
          notifications!
              .sort((a, b) => b.createdDate!.compareTo(a.createdDate!));
        });
      });
    });

    BannerAd(
      adUnitId: AdHelper.bannerAdUnitNotificationsScreen,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _ad = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();
          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    ).load();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text("Notifications",
            style: TextStyle(color: AppColors.screenTitleColor, fontSize: 16)),
        elevation: 1,
        centerTitle: true,
        actions: <Widget>[
          (notifications ?? []).isEmpty
              ? Container()
              : IconButton(
                  icon: Icon(
                    Icons.delete_sweep_rounded,
                    size: 25,
                    color: AppColors.screenTitleColor,
                  ),
                  onPressed: () async {
                    AppUtils.showNativeAlertDialog(
                      context: context,
                      title: "Clear Notifications",
                      content:
                          "Are you sure you want to clear all notifications ?",
                      cancelActionText: "Cancel",
                      defaultActionText: "Yes, Clear",
                      defaultActionClick: () async {
                        await AppStorage.setString("notifications", "");
                        AppUtils.getAllNotifications().then((value) {
                          setState(() {
                            notifications = value;
                          });
                        });
                      },
                    );
                  },
                ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: AppColors.whiteLight,
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: (notifications ?? []).isEmpty
                    ? Center(
                        child: Text(
                          "No notifications",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  color: AppColors.lineBorderColor,
                                  fontWeight: FontWeight.w500),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 0),
                        itemCount: (notifications ?? []).length,
                        itemBuilder: (BuildContext context, int index) {
                          AppNotification notification = notifications![index];
                          /* String title = notification.post["title"] ?? "";
                          String msg = notification.post["msg"] ?? "";
                          String profilePic = notification.post["profilePic"] ?? "";
                          String createdOn = notification.post["created_on"] ?? "";*/
                          String type = notification.type ?? "";

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  if (type == "post_interest" ||
                                      type == "post_comment") {
                                    Post? post = Post.fromJson(
                                        jsonDecode(notification.post));
                                    await Navigator.pushNamed(
                                        context, AppRoutes.showPostScreen,
                                        arguments: {
                                          "post": post,
                                        });
                                  } else if (type == "promotion_interest" ||
                                      type == "promotion_comment") {
                                    Promotion? promotion = Promotion.fromJson(
                                        jsonDecode(notification.post));
                                    await Navigator.pushNamed(
                                        context, AppRoutes.showPromotionScreen,
                                        arguments: {
                                          "promotion": promotion,
                                        });
                                  }
                                },
                                child: NotificationItem(
                                    notification: notification, type: type),
                              ),
                              index != 0 && index % 4 == 0
                                  ? NativeAdWidgetNotificationsListing()
                                  : Container()
                            ],
                          );
                        },
                      ),
              ),
            ),
          ),
          _ad != null
              ? Container(
                  color: Colors.white,
                  width: _ad!.size.width.toDouble(),
                  height: 50.0,
                  alignment: Alignment.center,
                  child: AdWidget(ad: _ad!),
                )
              : Container(
                  height: 0,
                )
        ],
      ),
    );
  }
}
