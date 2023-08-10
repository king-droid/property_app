import 'package:flutter/material.dart';
import 'package:property_feeds/components/custom_elevated_button.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';

class WalkthroughScreen extends StatefulWidget {
  static String routeName = "/walkthrough";

  const WalkthroughScreen({super.key});

  @override
  WalkthroughScreenState createState() => WalkthroughScreenState();
}

class WalkthroughScreenState extends State<WalkthroughScreen> {
  static String routeName = "/splash";
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {
      "image": "assets/walkthrough_images/walkthrough_1.png",
      "title": "Find property",
      "subTitle":
          "Browse through hundreds of properties matching to your need and budget"
    },
    {
      "image": "assets/walkthrough_images/walkthrough_2.png",
      "title": "Sell property",
      "subTitle":
          "Sell your property to right buyers at best rate and contact as per your convenience"
    },
    {
      "image": "assets/walkthrough_images/walkthrough_3.png",
      "title": "Promote projects",
      "subTitle":
          "As a dealer, promote builder or your properties which can reach to thousands of end-users or investors"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              /*Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Flutter",
                      style: TextStyle(
                        fontSize: getProportionateScreenWidth(30),
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Feeds",
                      style: TextStyle(
                        fontSize: getProportionateScreenWidth(30),
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),*/
              Expanded(
                flex: 6,
                child: Container(
                  child: PageView.builder(
                    onPageChanged: (value) {
                      setState(() {
                        currentPage = value;
                      });
                    },
                    itemCount: splashData.length,
                    itemBuilder: (context, index) => cardData(
                      splashData[index]['title']!,
                      splashData[index]['subTitle']!,
                      splashData[index]["image"]!,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          splashData.length,
                          (index) => buildDot(index: index),
                        ),
                      ),
                      const Spacer(flex: 1),
                      CustomElevatedButton(
                        text: "Get Started",
                        width: 250,
                        cornerRadius: 5,
                        color: AppColors.primaryColor,
                        textStyle: const TextStyle(
                            fontSize: 16,
                            color: AppColors.buttonTextColorWhite,
                            fontFamily: "Muli"),
                        onPress: () {
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.landingScreen);
                        },
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardData(String title, String subTitle, String image) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Spacer(),
          Image.asset(
            image,
            height: 265,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fitWidth,
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.only(top: 50),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black.withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 30),
            child: Text(
              subTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  AnimatedContainer buildDot({int? index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: currentPage == index ? 8 : 8,
      decoration: BoxDecoration(
        color: currentPage == index
            ? AppColors.primaryColor
            : const Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
