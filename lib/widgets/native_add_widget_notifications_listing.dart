import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:property_feeds/utils/AdHelper.dart';

class NativeAdWidgetNotificationsListing extends StatefulWidget {
  double? height;

  NativeAdWidgetNotificationsListing({Key? key, @required this.height})
      : super(key: key);

  @override
  _NativeAdWidgetNotificationsListingState createState() =>
      _NativeAdWidgetNotificationsListingState();
}

class _NativeAdWidgetNotificationsListingState
    extends State<NativeAdWidgetNotificationsListing> {
  NativeAd? _nativeAd;
  bool isAdLoaded = false;

  @override
  void initState() {
    _nativeAd = NativeAd(
      adUnitId: AdHelper.nativeAdUnitNotificationsList,
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          print('$NativeAd loaded.');
          setState(() {
            isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$NativeAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$NativeAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$NativeAd onAdClosed.'),
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: Colors.white12,
        callToActionTextStyle: NativeTemplateTextStyle(
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black38,
          backgroundColor: Colors.white70,
        ),
      ),
    )..load();
    _nativeAd!.load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            color: Colors.transparent,
            child: kIsWeb ? Container() : _buildBottomAdViewWidget()),
      ],
    );
  }

  _buildBottomAdViewWidget() {
    return Container(
        decoration: BoxDecoration(
          //borderRadius: BorderRadius.circular(12.0),
          color: Colors.transparent,
          /*boxShadow: [
            BoxShadow(
                color: Colors.black87.withOpacity(.03),
                blurRadius: 1,
                spreadRadius: 0.5),
          ],*/
        ),
        // Decoration
        margin: EdgeInsets.only(left: 10, right: 10),
        //color: Colors.white,
        child: _nativeAd != null && isAdLoaded
            ? Container(
                height: 90,
                alignment: Alignment.center,
                child: AdWidget(ad: _nativeAd!),
              )
            : Container());
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }
}
