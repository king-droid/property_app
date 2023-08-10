import 'package:flutter/material.dart';
import 'package:property_feeds/blocs/promotion/promotion_bloc.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/provider/user_provider.dart';
import 'package:provider/provider.dart';

typedef PromotionDeleteCallback = void Function(String);
typedef PromotionRefreshCallback = void Function(bool);

class PromotionItemPlaceHolder extends StatefulWidget {
  PromotionDeleteCallback promotionDeleteCallback;
  PromotionRefreshCallback promotionRefreshCallback;

  PromotionItemPlaceHolder(
      {Key? key,
      required this.promotionDeleteCallback,
      required this.promotionRefreshCallback})
      : super(key: key);

  @override
  _PromotionItemPlaceHolderState createState() =>
      _PromotionItemPlaceHolderState();
}

class _PromotionItemPlaceHolderState extends State<PromotionItemPlaceHolder> {
  final commentController = TextEditingController();
  FocusNode commentFocusNode = new FocusNode();
  final bloc = PromotionBloc();
  int maxLength = 80;

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<UserProvider>(context, listen: false).userData;
    return GestureDetector(
      onTap: () {
        //goToPromotionDetailsScreen();
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
                          child: Container(
                            height: MediaQuery.sizeOf(context).width * 0.8,
                            width: double.infinity,
                            alignment: Alignment.center,
                            decoration:
                                BoxDecoration(color: AppColors.whiteLight),
                            child: Center(
                              child: Container(
                                //color: Colors.blue,
                                width: 120,
                                height: 120,
                                child: Image.asset(
                                  "assets/picture_icon_transparent.png",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.transparent,
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.sizeOf(context).width * 0.8,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.black12,
                                  ),
                                  margin: EdgeInsets.only(
                                      left: 10, right: 2, top: 8, bottom: 2),
                                  child: Text("",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              color:
                                                  Colors.black.withOpacity(0.7),
                                              fontSize: 14,
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
                                                  flex: 0,
                                                  child: Container(
                                                    width: MediaQuery.sizeOf(
                                                                context)
                                                            .width /
                                                        3,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Colors.black12,
                                                    ),
                                                    margin: EdgeInsets.only(
                                                        left: 8),
                                                    child: Text(
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
                                              width: MediaQuery.sizeOf(context)
                                                      .width /
                                                  2,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.black12,
                                              ),
                                              margin: EdgeInsets.only(
                                                  top: 8, left: 10),
                                              child: Text(
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
                                        margin: EdgeInsets.all(5),
                                        child: Icon(
                                          Icons.thumb_up,
                                          size: 15,
                                          color: Colors.black12,
                                        ),
                                      ),
                                      Container(
                                        color: AppColors.subTitleColor,
                                        margin:
                                            EdgeInsets.only(left: 5, right: 5),
                                        child: Text(
                                          "",
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
                                      width:
                                          MediaQuery.sizeOf(context).width / 4,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.black12,
                                      ),
                                      margin: EdgeInsets.only(left: 5),
                                      child: Text(
                                        "",
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
}
