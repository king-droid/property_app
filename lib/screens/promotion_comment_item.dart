import 'package:flutter/material.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/constants/appConstants.dart';
import 'package:property_feeds/models/promotion_comment.dart';
import 'package:property_feeds/utils/app_utils.dart';

class PromotionCommentItem extends StatefulWidget {
  final PromotionComment? comment;
  final String? postUser;

  PromotionCommentItem({Key? key, @required this.comment, this.postUser})
      : super(key: key);

  @override
  _PromotionCommentItemState createState() => _PromotionCommentItemState();
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

class _PromotionCommentItemState extends State<PromotionCommentItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.transparent,
      ),
      padding: EdgeInsets.only(top: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 0,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.viewProfileScreen,
                          arguments: widget.comment?.user?.userId ?? "");
                    },
                    child: Container(
                      color: Colors.transparent,
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: (widget.comment?.user?.profilePic ?? "").isNotEmpty
                          ? Container(
                              child: CircleAvatar(
                                backgroundColor: AppColors.semiPrimary,
                                radius: 17,
                                child: ClipOval(
                                  child: Image(
                                    width: 34,
                                    height: 34,
                                    image: NetworkImage(
                                      AppConstants.imagesBaseUrl +
                                          "/profile_images/" +
                                          (widget.comment?.user?.profilePic ??
                                              ""),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              child: CircleAvatar(
                                  radius: 17,
                                  backgroundImage: AssetImage(
                                      'assets/default_profile_pic.png')),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(
                            top: 0, bottom: 0, left: 1, right: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 0,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRoutes.viewProfileScreen,
                                      arguments:
                                          widget.comment?.user?.userId ?? "");
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  margin: EdgeInsets.only(left: 5),
                                  padding: EdgeInsets.all(0),
                                  child: Text(
                                    (widget.postUser ?? "") ==
                                            (widget.comment?.user?.userId ?? "")
                                        ? '${(widget.comment?.user?.userName ?? "")} (Owner)'
                                        : widget.comment?.user?.userName ?? "",
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Text(
                                  "\u2022 " +
                                      AppUtils.getFormattedPostDate(
                                          widget.comment?.createdDate ?? ""),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          fontSize: 11,
                                          color: AppColors.subTitleColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(
                              color: Colors.transparent,
                              margin: EdgeInsets.only(
                                  left: 5, right: 5, top: 5, bottom: 1),
                              child: Text(widget.comment?.comment ?? "",
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          //Bottom Line
          Container(
            margin: EdgeInsets.only(top: 5, bottom: 0, left: 0, right: 0),
            color: AppColors.bgColor2,
            height: 0.0,
          ),
        ],
      ),
    );
  }
}
