import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:property_feeds/constants/appColors.dart';

ThemeData? theme() {
  return ThemeData(
    // Define the default brightness and colors.
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColor,
    //secondaryHeaderColor: AppColors.secondaryColor,
    // Define the default font family.
    fontFamily: "Muli",
    primaryColorLight: AppColors.primaryColor,
    primaryColorDark: AppColors.primaryColor,
    pageTransitionsTheme: /*kIsWeb
        ? const PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          })
        : */
        const PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    }),
    // Define the default `TextTheme`. Use this to specify the default
    // text styling for headlines, titles, bodies of text, and more.
    /*  textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
      bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'muli'),
    ),*/
  );

  /*ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: AppColors.primaryColor,
    secondaryHeaderColor: AppColors.secondaryColor,
    accentColor: AppColors.accentColor,
    backgroundColor: AppColors.bgColor,
    fontFamily: "Muli",
    appBarTheme: appBarTheme(),
    */ /*elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)),
          primary: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)),
          primary: AppColors.primaryColor,
        ),
      ),*/ /*
    textTheme: textTheme(),
    brightness: Brightness.light,
    //inputDecorationTheme: inputDecorationTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );*/
}

InputDecorationTheme inputDecorationTheme() {
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(28),
    borderSide: BorderSide(color: AppColors.primaryColor),
    gapPadding: 10,
  );
  return InputDecorationTheme(
    // If  you are using latest version of flutter then lable text and hint text shown like this
    // if you r using flutter less then 1.20.* then maybe this is not working properly
    // if we are define our floatingLabelBehavior in our theme then it's not applayed
    // floatingLabelBehavior: FloatingLabelBehavior.always,
    contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
    enabledBorder: outlineInputBorder,
    focusedBorder: outlineInputBorder,
    border: outlineInputBorder,
  );
}

TextTheme textTheme() {
  return TextTheme(
    headline1: TextStyle(
        fontSize: 25.0,
        fontWeight: FontWeight.bold,
        color: AppColors.headingsColor),
    headline2: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
        color: AppColors.headingsColor),
    headline3: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: AppColors.headingsColor),
    headline4: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: AppColors.headingsColor),
    headline5: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: AppColors.headingsColor),
    headline6: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        color: AppColors.headingsColor),
    bodyText1: TextStyle(fontSize: 14.0, color: AppColors.textColor),
    bodyText2: TextStyle(fontSize: 13.0, color: AppColors.textColor),
    subtitle1: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        color: AppColors.titleColor),
    subtitle2: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: AppColors.subTitleColor),
    button: TextStyle(
        fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.bold),
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    color: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    toolbarTextStyle: TextTheme(
      headlineSmall: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: AppColors.headingsColor),
    ).bodyMedium,
    titleTextStyle: TextTheme(
      headline5: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: AppColors.headingsColor),
    ).titleLarge,
  );
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget? child,
  ) {
    // only return the child without warping it with animations
    return child!;
  }
}
