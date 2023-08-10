import 'package:property_feeds/constants/appColors.dart';
import 'package:flutter/material.dart';

class NewsItem extends StatefulWidget {
  final String? title;
  final String? dateTime;
  final String? source;
  final String? description;
  final String? link;
  final String? postedBy;

  NewsItem(
      {Key? key,
      @required this.title,
      @required this.dateTime,
      @required this.source,
      @required this.description,
      @required this.link,
      @required this.postedBy})
      : super(key: key);

  @override
  _NewsItemState createState() => _NewsItemState();
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

class _NewsItemState extends State<NewsItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: AppColors.cardBgColor,
        boxShadow: [
          BoxShadow(
              color: Color(0xffA22447).withOpacity(.05),
              offset: Offset(0, 0),
              blurRadius: 10,
              spreadRadius: 1),
        ],
      ),
      margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 10, top: 3),
                        alignment: Alignment.centerRight,
                        child: Text(
                          widget.postedBy ?? "",
                          //textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: "proxima_nova_regular",
                            color: AppColors.subTitleColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(
                          widget.title ?? "",
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: "proxima_nova_regular",
                              fontWeight: FontWeight.bold,
                              color: AppColors.titleColor),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin: EdgeInsets.only(left: 10, top: 3),
                              child: Text(
                                widget.source ?? "",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: "proxima_nova_regular",
                                  color: AppColors.subTitleColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10, top: 3),
                            alignment: Alignment.centerRight,
                            child: Text(
                              widget.dateTime ?? "",
                              //textAlign: TextAlign.center,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, top: 10, bottom: 10),
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              color: Color(0x7fF2F6FA),
                              child: Text(
                                widget.description ?? "",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: "proxima_nova_regular",
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      /*  Container(
                        child: Image.asset(
                          "${widget.img}",
                          height: 180,
                          width: 320,
                          fit: BoxFit.cover,
                        ),
                      ),*/
                      /* Container(
                        margin: EdgeInsets.only(top: 2, bottom: 0),
                        color: Colors.black12,
                        height: 0.5,
                      ),*/
                      Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(
                            top: 0, bottom: 0, left: 5, right: 5),
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
                                            "10 Likes",
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
                                            "100 Comments",
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
                                          Icons.share,
                                          size: 20,
                                          color: AppColors.buttonTextColor,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 5),
                                          child: Text(
                                            "18 Shares",
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
