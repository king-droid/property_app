import 'package:flutter/material.dart';
import 'package:property_feeds/constants/appColors.dart';

class FeedItem extends StatefulWidget {
  final String? title;
  final String? dateTime;
  final String? postedBy;
  final String? description;

  FeedItem(
      {Key? key,
      @required this.title,
      @required this.dateTime,
      @required this.postedBy,
      @required this.description})
      : super(key: key);

  @override
  _FeedItemState createState() => _FeedItemState();
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

class _FeedItemState extends State<FeedItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: AppColors.cardBgColor,
        boxShadow: [
          BoxShadow(
              color: Color(0xff000000).withOpacity(.08),
              offset: Offset(0, 0),
              blurRadius: 1,
              spreadRadius: 1),
        ],
      ),
      margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              /* new ClipPath(
                clipper: new CustomHalfCircleClipper(),*/
              Container(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: CircleAvatar(
                          radius: 18,
                          backgroundImage:
                              AssetImage('assets/default_profile_pic.png')),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Text(
                            widget.postedBy ?? "",
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: "proxima_nova_regular",
                                fontWeight: FontWeight.bold,
                                color: AppColors.titleColor),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10, top: 3),
                          child: Text(
                            widget.dateTime ?? "",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: "proxima_nova_regular",
                              color: AppColors.subTitleColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 10, top: 15),
                        child: Text(
                          widget.title ?? "",
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: "proxima_nova_regular",
                              fontWeight: FontWeight.w500,
                              color: AppColors.titleColor.withOpacity(0.7)),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: 10, bottom: 10, left: 5, right: 5),
                              color: Color(0x7fF2F6FA),
                              child: Text(
                                widget.description ?? "",
                                maxLines: 3,
                                style: TextStyle(
                                  fontSize: 15,
                                  overflow: TextOverflow.ellipsis,
                                  fontFamily: "proxima_nova_regular",
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(
                            top: 10, bottom: 0, left: 5, right: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.only(left: 1, right: 1),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.all(1),
                                          child: Icon(
                                            Icons.thumb_up,
                                            size: 20,
                                            color: AppColors.buttonTextColor,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 5),
                                          child: Text(
                                            "7 Interested",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily:
                                                  "proxima_nova_regular",
                                              color: AppColors.buttonTextColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.all(1),
                                          child: Icon(
                                            Icons.message,
                                            size: 20,
                                            color: AppColors.buttonTextColor,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 5),
                                          child: Text(
                                            "15 Comments",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily:
                                                  "proxima_nova_regular",
                                              color: AppColors.buttonTextColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.remove_red_eye,
                                          size: 20,
                                          color: AppColors.buttonTextColor,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 5),
                                          child: Text(
                                            "10 Views",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily:
                                                  "proxima_nova_regular",
                                              color: AppColors.buttonTextColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
          //Bottom Line
          /* Container(
            margin: EdgeInsets.only(top: 10, bottom: 0, left: 0, right: 0),
            color: Colors.black12,
            height: 0.7,
          ),*/
        ],
      ),
    );
  }
}
