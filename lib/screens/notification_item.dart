import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/constants/appConstants.dart';
import 'package:property_feeds/models/notification.dart';
import 'package:property_feeds/models/post.dart';
import 'package:property_feeds/models/promotion.dart';
import 'package:property_feeds/utils/app_utils.dart';

class NotificationItem extends StatefulWidget {
  final AppNotification? notification;
  final String? type;

  NotificationItem({Key? key, @required this.notification, this.type})
      : super(key: key);

  @override
  _NotificationItemState createState() => _NotificationItemState();
}

class CustomHalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = new Path();
    path.lineTo(size.width, size.width / 2);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class _NotificationItemState extends State<NotificationItem> {
  dynamic post;
  String? profilePic;

  @override
  Widget build(BuildContext context) {
    post = (widget.type == "post_interest" || widget.type == "post_comment")
        ? Post.fromJson(jsonDecode(widget.notification?.post))
        : Promotion.fromJson(jsonDecode(widget.notification?.post));
    profilePic = (widget.type == "post_interest" ||
            widget.type == "post_comment")
        ? Post.fromJson(jsonDecode(widget.notification?.post)).profilePic
        : Promotion.fromJson(jsonDecode(widget.notification?.post)).profilePic;
    return Container(
      padding: EdgeInsets.only(left: 5, right: 5, top: 8, bottom: 0),
      /*decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: AppColors.cardBgColor,
        boxShadow: [
          BoxShadow(
              color: Colors.black12.withOpacity(.08),
              offset: Offset(0, 0),
              blurRadius: 10,
              spreadRadius: 1),
        ],
      ),*/
      color: AppColors.cardBgColor,
      //margin: EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(right: 2),
                child: (profilePic ?? "").isNotEmpty
                    ? Container(
                        child: CircleAvatar(
                          backgroundColor: AppColors.semiPrimary,
                          radius: 20,
                          child: ClipOval(
                            child: Image(
                              width: 40,
                              height: 40,
                              image: NetworkImage(
                                AppConstants.imagesBaseUrl +
                                    "/profile_images/" +
                                    (profilePic ?? ""),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        child: CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                AssetImage('assets/default_profile_pic.png')),
                      ), //GestureDetector
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text(widget.notification?.title ?? "",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87.withOpacity(0.7),
                                  fontSize: 14)),
                    ),
                    Container(
                      //padding: EdgeInsets.only(left: 10, right: 10, top: 1, bottom: 10),
                      margin: EdgeInsets.only(left: 5, top: 2, bottom: 2),
                      //color: Color(0x7fF2F6FA),
                      child: Text(widget.notification?.message ?? "",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(color: Colors.black54, fontSize: 12)),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      alignment: Alignment.centerRight,
                      child: Text(
                        AppUtils.getFormattedPostDate(
                            widget.notification?.createdDate ?? ""),
                        //textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.black38,
                            fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 5, bottom: 0, left: 0, right: 0),
            color: Colors.black12,
            height: 0.7,
          )
        ],
      ),
    );
  }
}
