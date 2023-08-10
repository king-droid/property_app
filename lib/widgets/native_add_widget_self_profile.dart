import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/utils/AdHelper.dart';

class NativeAdWidgetSelfProfile extends StatefulWidget {
  double? height;

  NativeAdWidgetSelfProfile({Key? key, @required this.height})
      : super(key: key);

  @override
  _NativeAdWidgetSelfProfileState createState() =>
      _NativeAdWidgetSelfProfileState();
}

class _NativeAdWidgetSelfProfileState extends State<NativeAdWidgetSelfProfile> {
  NativeAd? _nativeAd;
  bool isAdLoaded = false;

  @override
  void initState() {
    /*_nativeAd = NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      factoryId: 'listTile',
      request: AdRequest(),
      listener: NativeAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (Ad ad) {
          var _add = ad as NativeAd;
          print("**** AD ***** ${_add.responseInfo}");
          setState(() {
            _nativeAd = _add;
            isAdLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          // Dispose the ad here to free resources.
          ad.dispose();
          print('Ad load failed (code=${error.code} message=${error.message})');
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) => print('Ad opened.'),
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) => print('Ad closed.'),
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) => print('Ad impression.'),
        // Called when a click is recorded for a NativeAd.
        onAdClicked: (Ad ad) => print('Ad clicked.'),
      ),
    );*/

    _nativeAd = NativeAd(
      adUnitId: AdHelper.nativeAdWidgetSelfProfile,
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
        templateType: TemplateType.medium,
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
    return Container(
        color: AppColors.bgColor,
        child: kIsWeb ? Container() : _buildBottomAdViewWidget());
  }

  _buildBottomAdViewWidget() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black87.withOpacity(.03),
                blurRadius: 1,
                spreadRadius: 0.5),
          ],
        ),
        // Decoration
        margin: EdgeInsets.only(left: 10, right: 10),
        //color: Colors.white,
        child: _nativeAd != null && isAdLoaded
            ? Container(
                height: 350,
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
