import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:property_feeds/models/notification.dart';
import 'package:property_feeds/models/notifications_data.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/utils/app_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {
  /// Get filtered file name
  static Widget getCustomAppbar(BuildContext context) {
    return AppBar(
      toolbarHeight: 0,
      elevation: 0,
      backgroundColor:
          MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Colors.black54
              : Colors.white,
    );
  }

  static String getFormattedPostDate(String date) {
    if (date.isEmpty) {
      return "";
    }
    DateTime parsedDate =
        DateFormat("yyyy-MM-dd HH:mm:ss").parse(date, true).toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisYear = DateTime(now.year);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final dateToCheck = parsedDate;
    var formattedDate = "";
    final aDate =
        DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
    if (aDate == today) {
      formattedDate = "Today, " + DateFormat('hh:mm a').format(parsedDate);
    } else if (aDate == yesterday) {
      formattedDate = "Yesterday, " + DateFormat('hh:mm a').format(parsedDate);
    } else {
      if (aDate.year == thisYear.year) {
        formattedDate = DateFormat('d MMM, hh:mm a').format(parsedDate);
      } else {
        formattedDate = DateFormat('d MMM yy, hh:mm a').format(parsedDate);
      }
    }

    return formattedDate;
  }

  Future<void> sharePost({String? title, String? description}) async {
    await FlutterShare.share(
        title: title ?? "",
        text: '${title ?? ""}'
            '\n\n${description ?? ""}'
            '\n\nDownload app now to view more properties like this.',
        linkUrl:
            'https://play.google.com/store/apps/details?id=com.property.app',
        chooserTitle: 'Choose app to share with');
  }

  Future<void> shareApp() async {
    await FlutterShare.share(
        title: 'Share App',
        text: 'Hey,'
            '\n\nProperty Feeds is a real estate community app to post property requirements for sale, purchase and rent.'
            '\n\nDownload now and share it with your friends and links over social networks.',
        linkUrl:
            'https://play.google.com/store/apps/details?id=com.property.app',
        chooserTitle: 'Choose app to share with');
  }

  static Future<bool?> addNewNotification(AppNotification? notification) async {
    String notificationsStr = await AppStorage.getString("notifications");
    NotificationsData notificationsData = notificationsStr.isNotEmpty
        ? NotificationsData.fromJson(jsonDecode(notificationsStr))
        : NotificationsData(notifications: []);

    notificationsData.notifications!.add(notification!);

    return await AppStorage.setString(
        "notifications", jsonEncode(notificationsData.toJson()));
  }

  static Future<List<AppNotification>?> getAllNotifications() async {
    String notificationsStr = await AppStorage.getString("notifications");
    NotificationsData notificationsData = notificationsStr.isNotEmpty
        ? NotificationsData.fromJson(jsonDecode(notificationsStr))
        : NotificationsData(notifications: []);

    return notificationsData.notifications;
  }

  static Future<bool> deleteAllNotifications(User? user) async {
    String notificationsStr = await AppStorage.getString("notifications");
    NotificationsData notificationsData = notificationsStr.isNotEmpty
        ? NotificationsData.fromJson(jsonDecode(notificationsStr))
        : NotificationsData(notifications: []);
    return await AppStorage.setString(
        "notifications", notificationsData.toJson().toString());
  }

  static Future<bool?> saveUser(User? user) async {
    String userStr = jsonEncode(user!.toJson());
    return await AppStorage.setString("user", userStr);
  }

  static Future<User?> getUser() async {
    String userStr = await AppStorage.getString("user");
    User? user = User.fromJson(jsonDecode(userStr));
    return user;
  }

  static Future<bool> getLoggedIn() async {
    bool? value = await AppStorage.getBoolean("is_logged_in");
    return value ?? false;
  }

  static Future<bool> isFromNotification() async {
    bool? value = await AppStorage.getBoolean("is_from_notification");
    return value ?? false;
  }

  static Future<void> setIsFromNotification(bool value) async {
    await AppStorage.setBoolean("is_from_notification", value);
  }

  static Future<void> setLoggedIn() async {
    await AppStorage.setBoolean("is_logged_in", true);
  }

  static Future<void> logout() async {
    await AppStorage.setBoolean("is_logged_in", false);
  }

  static Future<String?> getSessionToken() async {
    return await AppStorage.getString("sessionToken");
  }

  static Future<bool?> saveSessionToken(String sessionToken) async {
    return await AppStorage.setString("sessionToken", sessionToken);
  }

  void makeAudioCall(String mobileNumber) async {
    String url = "tel:$mobileNumber";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  /// Capitalize First Character
  static String capitalizeFirstLetter(String val) {
    String finalStr = "";
    if (val.trim().isEmpty) return "";
    val = val.replaceAll("_", " ");
    for (String part in val.split(" ")) {
      finalStr = finalStr +
          " " +
          part[0].toUpperCase() +
          part.substring(1).toLowerCase();
    }
    return finalStr.trim();
  }

  static Future<String> pickDate(
      BuildContext context, String outputDateFormat) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2101));
    if (picked != null) {
      String selectedDate = DateFormat(outputDateFormat).format(picked);
      return selectedDate;
    } else {
      return "";
    }
  }

  Future<String?> pickImageFromCamera(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 720,
        maxHeight: 1280,
        imageQuality: 100,
      );
      return pickedFile?.path ?? "";
    } catch (e) {
      return " ";
    }
  }

  Future<String?> pickImageFromGallery(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 720,
        maxHeight: 1280,
        imageQuality: 100,
      );
      return pickedFile?.path ?? "";
    } catch (e) {
      return " ";
    }
  }

  Future<String?> pickPDFFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        PlatformFile file = result.files.first;
        return file.path ?? "";
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  /// Get filtered file name
  static String getFileName(String value) {
    return value
        .split('/')
        .last
        .replaceAll("image_picker_", "")
        .split('-')
        .last;
  }

  /// Get Age from Date of Birth
  static String getAgeFromDOB(String birthDateString) {
    if (birthDateString.isEmpty) {
      return "0";
    } else {
      String datePattern = "yyyy-MM-dd";

      DateTime birthDate = DateFormat(datePattern).parse(birthDateString);
      DateTime today = DateTime.now();

      int yearDiff = today.year - birthDate.year;

      return '$yearDiff';
    }
  }

  /// null and empty check
  static bool isNullOrEmpty(String value) {
    if (value == null) {
      return true;
    } else if (value.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  /// Show SVG icon
  static Widget showSvgIcon(String assetName, {double? size, Color? color}) {
    return SvgPicture.asset(
      assetName,
      width: size,
      height: size,
      color: color,
    );
  }

  /// Show SVG icon
  static Widget showSvgIconFitHeight(String assetName, {double? size}) {
    return SvgPicture.asset(
      assetName,
      width: size,
      height: size,
      fit: BoxFit.fitHeight,
    );
  }

  /// get pretty formatted json for logging
  static String getPrettyJSONString(jsonObject) {
    var encoder = JsonEncoder.withIndent("     ");
    return encoder.convert(jsonObject);
  }

  /*/// method to get formatted damage report date
  static String getDamageReportFormattedDateAndTime(
      BuildContext context, String date) {
    if (date != null) {
      return '${getDamageReportFormattedDate(date)}, ${getDamageReportFormattedTime(context, date)}';
    }
    return "";
  }*/

  /// method to get formatted date
  static String getFormattedAppointmentDateTime(String date) {
    //2022-08-08 15:00:00
    DateTime parseDate = DateTime.parse(date);
    return DateFormat('dd MMM yyyy - hh:mm a').format(parseDate.toLocal());
  }

  /// method to get formatted date
  static String getFormattedAppointmentDate(String date) {
    DateTime parseDate = DateTime.parse(date);
    return DateFormat('dd MMM yyyy').format(parseDate);
  }

  static String getFormattedPickedDate(DateTime? date) {
    //DateTime parseDate = DateTime.parse(date);
    return DateFormat('dd MMM yyyy').format(date!);
  }

  /// to get formatted time
  static String getFormattedAppointmentTime(String time) {
    DateTime parseDate = DateFormat("hh:mm a").parse(time);
    parseDate = parseDate.add(const Duration(minutes: 15));
    return DateFormat('hh:mm a').format(parseDate);
  }

  /// to get formatted time
  static String getFormattedAppointmentTimeWithoutAmPM(String time) {
    DateTime parseDate = DateFormat("hh:mm a").parse(time);
    parseDate = parseDate.add(const Duration(minutes: 15));
    return DateFormat('hh:mm a').format(parseDate);
  }

  /// 24 Hr time to 12 Hr time
  static String get24HrTo12HrTime(String? _24Hrtime) {
    DateTime parseDate = DateFormat("HH:mm").parse(_24Hrtime ?? "");
    String parseDateStr = DateFormat("hh:mm a").format(parseDate);
    return parseDateStr;
  }

  /// 24 Hr time to DateTime object
  static DateTime get24HrToDateTime(String? _24Hrtime) {
    DateTime parseDate = DateFormat("HH:mm").parse(_24Hrtime ?? "");
    //String parseDateStr = DateFormat("hh:mm a").format(parseDate);
    return parseDate;
  }

  /// Get App's document directory file path
  static Future<String> getLocalDataDir(
      String userName, String damageId) async {
    final directory = await getApplicationDocumentsDirectory();
    Directory dataDir =
        await Directory('${directory.path}/${userName.trim()}/$damageId')
            .create(recursive: true);
    if (await dataDir.exists()) {
      return dataDir.path;
    } else {
      return "";
    }
  }

  static Future<String> pickTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (pickedTime != null) {
      return '${pickedTime.hour}:${pickedTime.minute}';
    } else {
      return "";
    }
  }

  static String formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  Future<void> openEmailApp(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  /// Navigate to a given route
  static void navigateToScreen(BuildContext context, String routeName,
      {Map? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  /// navigate to a screen by replacing current screen
  static void navigateToScreenWithReplace(
      BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  /// Navigate to back/previous screen
  static void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  /// Navigate back until a given route matches in navigation
  static void navigateBackUntil(BuildContext context, routeName) {
    Navigator.popUntil(context, routeName);
  }

  /// Show Snack bar with given message
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 4),
      content: Row(
        children: <Widget>[
          Expanded(
              child: Container(
                  margin: EdgeInsets.only(left: 15),
                  child: Text(
                    message,
                  )))
        ],
      ),
    ));
  }

  /// Show a alert dialog with given title and message
  static void showAlertDialog(
      BuildContext context, String message, VoidCallback btnCallback,
      {String? title}) {
    // set up the button
    Widget okButton = TextButton(
        child: Text("OK"),
        onPressed: () {
          AppUtils.navigateBack(context);
          AppUtils.navigateBack(context);
          btnCallback.call();
        });
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title ?? "Alert"),
      content: Text(message),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(onWillPop: () => Future.value(false), child: alert);
      },
    );
  }

  static void showAlertDialogWithOptions(
    BuildContext context,
    String message, {
    String? titleMain,
    String? titleBtn1,
    String? titleBtn2,
    VoidCallback? btn1Callback,
    VoidCallback? btn2Callback,
  }) {
    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () => Future.value(false),
            child: AlertDialog(
              title: titleMain != null ? Text(titleMain) : null,
              content: Text(message),
              actions: [
                TextButton(
                    child: Text(titleBtn1 ?? ""),
                    onPressed: () {
                      Navigator.pop(context);
                      btn1Callback?.call();
                    }),
                TextButton(
                    child: Text(titleBtn2 ?? ""),
                    onPressed: () {
                      Navigator.pop(context);
                      btn2Callback?.call();
                    }),
              ],
            ));
      },
    );
  }

  static Future<Future> showNativeAlertDialog({
    @required BuildContext? context,
    required String? title,
    @required String? content,
    String? cancelActionText,
    @required String? defaultActionText,
    @required VoidCallback? defaultActionClick,
    VoidCallback? cancelActionClick,
  }) async {
    if (kIsWeb) {
      return showDialog(
        context: context!,
        builder: (context) => AlertDialog(
          title: title != null ? Text(title) : Container(),
          content: Text(content!),
          actions: <Widget>[
            if (cancelActionText != null)
              TextButton(
                  child: Text(cancelActionText),
                  onPressed: () {
                    if (cancelActionClick != null) {
                      cancelActionClick.call();
                    }
                    Navigator.of(context).pop(true);
                  }),
            TextButton(
                child: Text(defaultActionText!),
                onPressed: () {
                  Navigator.of(context).pop(true);
                  defaultActionClick?.call();
                }),
          ],
        ),
      );
    } else {
      return showDialog(
        context: context!,
        builder: (context) => AlertDialog(
          title: title != null ? Text(title) : Container(),
          content: Text(content!),
          actions: <Widget>[
            if (cancelActionText != null)
              TextButton(
                  child: Text(cancelActionText),
                  onPressed: () {
                    if (cancelActionClick != null) {
                      cancelActionClick.call();
                    }
                    Navigator.of(context).pop(true);
                  }),
            TextButton(
                child: Text(defaultActionText!),
                onPressed: () {
                  Navigator.of(context).pop(true);
                  defaultActionClick?.call();
                }),
          ],
        ),
      );
    }

    // todo : showDialog for ios
    return showCupertinoDialog(
      context: context!,
      builder: (context) => CupertinoAlertDialog(
        title: title != null ? Text(title) : Container(),
        content: Text(content!),
        actions: <Widget>[
          if (cancelActionText != null)
            CupertinoDialogAction(
                child: Text(cancelActionText),
                onPressed: () {
                  if (cancelActionClick != null) {
                    cancelActionClick.call();
                  }
                  Navigator.of(context).pop(true);
                }),
          CupertinoDialogAction(
              child: Text(defaultActionText!),
              onPressed: () {
                defaultActionClick?.call();
                Navigator.of(context).pop(true);
              }),
        ],
      ),
    );
  }
}
