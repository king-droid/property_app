import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:property_feeds/blocs/complete_profile/complete_profile_bloc.dart';
import 'package:property_feeds/blocs/complete_profile/complete_profile_event.dart';
import 'package:property_feeds/blocs/complete_profile/complete_profile_state.dart';
import 'package:property_feeds/components/custom_elevated_button.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/constants/appConstants.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/provider/user_provider.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:provider/provider.dart';
import 'package:textfield_tags/textfield_tags.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  UpdateProfileScreenState createState() {
    return UpdateProfileScreenState();
  }
}

class UpdateProfileScreenState extends State<UpdateProfileScreen> {
  FocusNode passwordFieldFocusNode = FocusNode();
  FocusNode mobileNumberFieldFocusNode = FocusNode();
  FocusNode nameFieldFocusNode = FocusNode();
  FocusNode locationFieldFocusNode = FocusNode();
  FocusNode companyNameFieldFocusNode = FocusNode();
  FocusNode aboutFieldFocusNode = FocusNode();
  late ScrollController scrollController;
  TextEditingController searchCityController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextfieldTagsController? _controller;
  ValueNotifier<bool> isMobileFieldValid = ValueNotifier(true);
  ValueNotifier<bool> isUserNameFieldValid = ValueNotifier(true);
  ValueNotifier<bool> isCompanyNameFieldValid = ValueNotifier(true);
  ValueNotifier<bool> isAboutFieldValid = ValueNotifier(true);
  ValueNotifier<bool> isCitiesFieldValid = ValueNotifier(true);
  final globalKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool isSocialLoading = false;
  bool _buttonActive = false;
  bool passwordVisible = true;
  bool editUserType = false;
  bool showCompanyNameField = false;
  bool showAboutField = false;
  List<String> cities = [];
  String? selectedCity;
  List<int>? selectedCityIndex = [];
  List<String> selectedCities = [];
  List<String> previousCities = [];
  String? userType = "end_user";
  String? name = "";
  String? emailId = "";
  double? _distanceToField;
  User? user;
  File? _image;
  PlatformFile? file;
  Uint8List? bytes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  @override
  void initState() {
    DefaultAssetBundle.of(context)
        .loadString("assets/cities.txt")
        .then((value) {
      value = value.replaceAll("\n", "");
      cities = value.split(',');
      /*var json = jsonDecode(value);
      json.forEach((v) {
        cities.add(v["name"]);
      });*/
    });
    _controller = TextfieldTagsController();
    scrollController = new ScrollController(
      initialScrollOffset: 0.0,
      //keepScrollOffset: true,
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      //scrollController.jumpTo(scrollController.position.maxScrollExtent);
      BlocProvider.of<CompleteProfileBloc>(context).emit(Initial());

      /* AppUtils.getUser().then((value) {
        setState(() {
          user = value;*/
      selectedCities = (user?.interestedCities ?? "").split(',');
      nameController.text = user?.userName ?? "";
      mobileController.text = user?.mobileNumber ?? "";
      locationController.text = user?.userLocation ?? "";
      companyNameController.text = user?.companyName ?? "";
      aboutController.text = user?.aboutUser ?? "";
      userType = user?.userType ?? "end_user";
      if (userType == "real_estate_company" || userType == "dealer") {
        showCompanyNameField = true;
        showAboutField = true;
      }
      setState(() {});
      //});
      //});
    });

    /*nameFieldFocusNode.addListener(() {
      if (nameFieldFocusNode.hasFocus) {
        //scrollController.position = ScrollPosition()
      }
    });*/

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserProvider>(context, listen: false).userData;
    //user = (ModalRoute.of(context)?.settings.arguments) as User?;
    previousCities = (user?.interestedCities ?? "").split(',');
    //var bottom = MediaQuery.of(context).viewInsets.bottom;
    //bottom = max(min(bottom, nameFieldFocusNode.hasFocus ? 0 : 0), 0);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.screenTitleColor,
              size: 22,
            ),
            onPressed: () {
              Navigator.of(context).pop(user);
            }),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text("Update Profile",
            style: TextStyle(color: AppColors.screenTitleColor, fontSize: 16)),
        elevation: 1,
        centerTitle: true,
        actions: <Widget>[],
      ),
      key: globalKey,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: SingleChildScrollView(
              //reverse: true,
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.only(bottom: 0),
                child: Container(
                  //height: 500,
                  color: Colors.white10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      //const SizedBox(height: 20),
                      // _buildHeadingWidget(),
                      //_buildProfilePictureWidget(),
                      _buildProfilePictureWidgetEdit(),
                      _buildNameTextField(),
                      _buildMobileTextField(),
                      _userTypeLabelWidget(),
                      editUserType ? _userTypeSelectionWidget() : Container(),
                      _buildCompanyNameTextField(),
                      _buildAboutTextField(),
                      const SizedBox(height: 10),
                      _buildLocationTextField(),
                      _buildCitySelectTextField(),
                      const SizedBox(height: 50),
                      _buildSubmitButtonWidget(),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  SizedBox addPaddingWhenKeyboardAppears() {
    final viewInsets = EdgeInsets.fromWindowPadding(
      WidgetsBinding.instance!.window.viewInsets,
      WidgetsBinding.instance!.window.devicePixelRatio,
    );

    final bottomOffset = viewInsets.bottom;
    const hiddenKeyboard = 0.0; // Always 0 if keyboard is not opened
    final isNeedPadding = bottomOffset != hiddenKeyboard;

    return SizedBox(height: isNeedPadding ? bottomOffset : hiddenKeyboard);
  }

  Widget _buildHeadingWidget() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* Container(
            child: Icon(
              Icons.account_box,
              color: AppColors.primaryColor,
              size: 70.0,
            ),
          ),*/
          //const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.only(top: 0, bottom: 5),
            child: Text(
              "Complete Profile",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              "Provide us few details about you to give you better experience",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopLogoWidget() {
    return Container(
      //padding: EdgeInsets.only(top: 30, bottom: 20),
      child: Column(
        children: [
          Image.asset("assets/app_icon.png", width: 100, height: 100),
          Container(
            padding: const EdgeInsets.only(top: 1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Property",
                      style: TextStyle(
                          fontSize: 20,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: "muli"),
                    ),
                    Text(
                      " Feeds",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontFamily: "muli"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePictureWidgetEdit() {
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 10),
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {},
        child: Stack(children: <Widget>[
          CircleAvatar(
            backgroundColor: AppColors.semiPrimary,
            radius: 45,
            child: bytes != null
                ? ClipOval(
                    child: Image.memory(
                      bytes!,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  )
                : (user?.profilePic ?? "").isNotEmpty
                    ? Container(
                        child: CircleAvatar(
                          backgroundColor: AppColors.semiPrimary,
                          radius: 45,
                          child: ClipOval(
                            child: Image(
                              width: 90,
                              height: 90,
                              image: NetworkImage(
                                AppConstants.imagesBaseUrl +
                                    "/profile_images/" +
                                    (user?.profilePic ?? ""),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    : ClipOval(
                        child: Container(
                          width: 90,
                          height: 90,
                          child: CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  AssetImage('assets/default_profile_pic.png')),
                        ),
                      ),
          ),
          Positioned(
            right: 0.0,
            bottom: 0.0,
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(18.0)),
                    ),
                    builder: (BuildContext context) {
                      // return your layout
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new ListTile(
                            leading: new Icon(Icons.photo_camera),
                            title: new Text(
                              'Camera',
                              style: TextStyle(
                                  fontFamily: "Roboto_Bold",
                                  color: AppColors.buttonTextColor,
                                  fontSize: 16),
                            ),
                            onTap: () {
                              getImageFromCamera();
                              Navigator.pop(context);
                            },
                          ),
                          new ListTile(
                            leading: new Icon(Icons.photo_library),
                            title: new Text(
                              'Gallery',
                              style: TextStyle(
                                  fontFamily: "Roboto_Bold",
                                  color: AppColors.buttonTextColor,
                                  fontSize: 16),
                            ),
                            onTap: () {
                              getImageFromGallery();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              },
              child: Align(
                alignment: Alignment.bottomRight,
                child: CircleAvatar(
                  radius: 15.0,
                  backgroundColor: AppColors.bgColor2,
                  child: Icon(Icons.camera_alt,
                      size: 15, color: AppColors.primaryColor),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildProfilePictureWidget() {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      alignment: Alignment.center,
      child: Container(
        child: GestureDetector(
          onTap: () {},
          child: CircleAvatar(
            backgroundColor: AppColors.semiPrimary,
            radius: 50,
            child: ClipOval(
              child: Container(
                width: 95,
                height: 95,
                child: CircleAvatar(
                    radius: 25,
                    backgroundImage:
                        AssetImage('assets/default_profile_pic.png')),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameTextField() {
    return ValueListenableBuilder(
        valueListenable: isUserNameFieldValid,
        builder: (BuildContext context, bool isValid, Widget? child) {
          return Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
                  Container(
                    child: Icon(
                      Icons.account_box,
                      color: AppColors.primaryColor,
                      size: 25.0,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      //width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                          left: 10.0, right: 20.0, top: 5.0),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: AppColors.textFieldBgColorLight,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0))),
                      //padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                if (value.length > 0) {
                                  isUserNameFieldValid.value = true;
                                }
                              },
                              onTapOutside: (po) {
                                //updateButtonState();
                              },
                              controller: nameController,
                              onSubmitted: (String value) {},
                              keyboardType: TextInputType.text,
                              maxLength: 50,
                              textCapitalization: TextCapitalization.words,
                              focusNode: nameFieldFocusNode,
                              textInputAction: TextInputAction.done,
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                counterText: "",
                                //border: InputBorder.none,
                                isDense: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: isValid
                                          ? Colors.transparent
                                          : AppColors.red,
                                      width: 0.5),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: isValid
                                          ? Colors.transparent
                                          : AppColors.red,
                                      width: 0.5),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                hintText: 'Your name',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: isValid
                                            ? Colors.black38
                                            : AppColors.red.withOpacity(0.7)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              /* isValid
                  ? Container()
                  : Container(
                      padding: const EdgeInsets.only(left: 50.0, right: 30),
                      alignment: Alignment.centerLeft,
                      child: Text("Enter your name",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: AppColors.red.withOpacity(0.8))),
                    ),*/
            ],
          );
        });
  }

  Widget _buildMobileTextField() {
    return ValueListenableBuilder(
        valueListenable: isMobileFieldValid,
        builder: (BuildContext context, bool isValid, Widget? child) {
          return Column(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(width: 10),
                  Container(
                    child: Icon(
                      Icons.phone_android,
                      color: AppColors.primaryColor,
                      size: 25.0,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      //width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                          left: 10.0, right: 20.0, top: 5.0),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: AppColors.textFieldBgColorLight,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0))),
                      //padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                if (value.length > 0) {
                                  isUserNameFieldValid.value = true;
                                }
                              },
                              onTapOutside: (po) {
                                //updateButtonState();
                              },
                              controller: mobileController,
                              onSubmitted: (String value) {},
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              textCapitalization: TextCapitalization.words,
                              focusNode: mobileNumberFieldFocusNode,
                              textInputAction: TextInputAction.done,
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                counterText: "",
                                //border: InputBorder.none,
                                isDense: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: isValid
                                          ? Colors.transparent
                                          : AppColors.red,
                                      width: 0.5),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: isValid
                                          ? Colors.transparent
                                          : AppColors.red,
                                      width: 0.5),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                hintText: 'Mobile number',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: isValid
                                            ? Colors.black38
                                            : AppColors.red.withOpacity(0.7)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              /* isValid
                  ? Container()
                  : Container(
                      padding: const EdgeInsets.only(left: 50.0, right: 30),
                      alignment: Alignment.centerLeft,
                      child: Text("Enter your name",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: AppColors.red.withOpacity(0.8))),
                    ),*/
            ],
          );
        });
  }

  Widget _buildLocationTextField() {
    return Column(
      children: [
        //const SizedBox(height: 10),
        /*Row(
          children: [
            const SizedBox(width: 10),
            Container(
              child: Icon(
                Icons.location_on,
                color: AppColors.primaryColor,
                size: 25.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text("Your location (Optional)",
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          ],
        ),*/
        Row(
          children: [
            const SizedBox(width: 10),
            Container(
              child: Icon(
                Icons.location_on,
                color: AppColors.primaryColor,
                size: 25.0,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                //width: MediaQuery.of(context).size.width,
                margin:
                    const EdgeInsets.only(left: 10.0, right: 20.0, top: 1.0),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: AppColors.textFieldBgColorLight,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0))),
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        onChanged: (value) {},
                        onTapOutside: (po) {
                          //updateButtonState();
                        },
                        controller: locationController,
                        onSubmitted: (String value) {},
                        keyboardType: TextInputType.text,
                        maxLength: 50,
                        textCapitalization: TextCapitalization.words,
                        focusNode: locationFieldFocusNode,
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: InputDecoration(
                          counterText: "",
                          border: InputBorder.none,
                          hintText: 'Enter your location e.g. Gurgaon',
                          hintStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.black38),
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
    );
  }

  Widget _buildCompanyNameTextField() {
    return !showCompanyNameField
        ? Container()
        : ValueListenableBuilder(
            valueListenable: isCompanyNameFieldValid,
            builder: (BuildContext context, bool isValid, Widget? child) {
              return Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Container(
                        child: Icon(
                          Icons.location_city,
                          color: AppColors.primaryColor,
                          size: 25.0,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.only(left: 10.0, right: 20),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: AppColors.textFieldBgColorLight,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0))),
                          //padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              //const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  onChanged: (value) {
                                    if (value.length > 0) {
                                      isCompanyNameFieldValid.value = true;
                                    }
                                  },
                                  onTapOutside: (po) {
                                    //updateButtonState();
                                  },
                                  controller: companyNameController,
                                  onSubmitted: (String value) {},
                                  keyboardType: TextInputType.text,
                                  maxLength: 50,
                                  textCapitalization: TextCapitalization.words,
                                  focusNode: companyNameFieldFocusNode,
                                  textInputAction: TextInputAction.done,
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    counterText: "",
                                    border: InputBorder.none,
                                    hintText: userType == "real_estate_company"
                                        ? 'Company name'
                                        : "Agency/Business name (Optional)",
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: isValid
                                                ? Colors.black38
                                                : AppColors.red
                                                    .withOpacity(0.7)),
                                    isDense: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: isValid
                                              ? Colors.transparent
                                              : AppColors.red,
                                          width: 0.5),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: isValid
                                              ? Colors.transparent
                                              : AppColors.red,
                                          width: 0.5),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  /*isValid
                      ? Container()
                      : Container(
                          padding: const EdgeInsets.only(left: 50.0, right: 30),
                          alignment: Alignment.centerLeft,
                          child: Text("Enter company name",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: AppColors.red.withOpacity(0.8))),
                        ),*/
                ],
              );
            });
  }

  Widget _buildAboutTextField() {
    return !showAboutField
        ? Container()
        : ValueListenableBuilder(
            valueListenable: isAboutFieldValid,
            builder: (BuildContext context, bool isValid, Widget? child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Container(
                        child: Icon(
                          Icons.info_outline,
                          color: AppColors.primaryColor,
                          size: 25.0,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.only(left: 10.0, right: 20),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: AppColors.textFieldBgColorLight,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0))),
                          //padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              //const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  onChanged: (value) {
                                    if (value.length > 0) {
                                      isAboutFieldValid.value = true;
                                    }
                                  },
                                  onTapOutside: (po) {
                                    //updateButtonState();
                                  },
                                  controller: aboutController,
                                  onSubmitted: (String value) {},
                                  maxLength: 500,
                                  keyboardType: TextInputType.multiline,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  maxLines: 5,
                                  focusNode: aboutFieldFocusNode,
                                  textInputAction: TextInputAction.done,
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    counterText: "",
                                    border: InputBorder.none,
                                    hintText: userType == "real_estate_company"
                                        ? 'Write about your company and services'
                                        : "Write about your company and services",
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: isValid
                                                ? Colors.black38
                                                : AppColors.red
                                                    .withOpacity(0.7)),
                                    isDense: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: isValid
                                              ? Colors.transparent
                                              : AppColors.red,
                                          width: 0.5),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: isValid
                                              ? Colors.transparent
                                              : AppColors.red,
                                          width: 0.5),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  /*isValid
                      ? Container()
                      : Container(
                          padding: const EdgeInsets.only(left: 50.0, right: 30),
                          alignment: Alignment.centerLeft,
                          child: Text("Enter company name",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: AppColors.red.withOpacity(0.8))),
                        ),*/
                ],
              );
            });
  }

  Widget _buildCitySelectTextField() {
    return ValueListenableBuilder(
        valueListenable: isCitiesFieldValid,
        builder: (BuildContext context, bool isValid, Widget? child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 15),
                  Container(
                    child: Icon(
                      Icons.manage_search,
                      color: AppColors.primaryColor,
                      size: 25.0,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 20),
                      child: Text(
                          "Choose cities your are interested for property",
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15.0, top: 10.0),
                child: StatefulBuilder(builder: (context, setState) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 0.0, bottom: 10),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.start,
                        children: List.generate(
                          (cities ?? []).length,
                          (index) {
                            return GestureDetector(
                              onTap: () {
                                selectedCity = cities[index] ?? "";
                                setState(() {
                                  if (selectedCities!.contains(selectedCity)) {
                                    selectedCities!.remove(selectedCity);
                                  } else {
                                    if (selectedCities.length < 3) {
                                      selectedCities!.add(selectedCity!);
                                      print(selectedCities);
                                    } else {
                                      AppUtils.showToast(
                                          "You can select maximum 3 cities");
                                    }
                                  }
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 3, right: 3, top: 5, bottom: 5),
                                decoration: BoxDecoration(
                                  color: selectedCities!
                                          .contains(cities[index] ?? "")
                                      ? AppColors.primaryColor
                                      : AppColors.white,
                                  border: Border.all(
                                      width: 1,
                                      color: selectedCities!
                                              .contains(cities[index] ?? "")
                                          ? AppColors.primaryColor
                                          : AppColors.titleColorLight),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                ),
                                padding: const EdgeInsets.only(
                                    left: 7, right: 7, top: 4, bottom: 4),
                                child: Text(
                                  cities![index] ?? "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color: selectedCities!
                                                  .contains(cities[index] ?? "")
                                              ? AppColors.white
                                              : AppColors.titleColorLight,
                                          fontSize: 13),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }), /*ChipsInput(
                  initialValue: previousCities,
                  decoration: InputDecoration(
                    filled: true,
                    isCollapsed: true,
                    isDense: true,
                    alignLabelWithHint: true,
                    fillColor: AppColors.textFieldBgColorLight,
                    contentPadding: const EdgeInsets.only(
                        left: 10, right: 10, top: 10, bottom: 10),
                    counterText: "",
                    hintText: 'Search city name',
                    hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: isValid
                            ? Colors.black38
                            : AppColors.red.withOpacity(0.7)),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: AppColors.textFieldBgColorLight, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: isValid ? Colors.transparent : AppColors.red,
                          width: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: isValid ? Colors.transparent : AppColors.red,
                          width: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxChips: 3,
                  findSuggestions: (String query) {
                    if (query.length != 0) {
                      var lowercaseQuery = query.toLowerCase();
                      return cities.where((profile) {
                        return profile
                            .toLowerCase()
                            .contains(query.toLowerCase());
                      }).toList(growable: false)
                        ..sort((a, b) => a
                            .toLowerCase()
                            .indexOf(lowercaseQuery)
                            .compareTo(
                                b.toLowerCase().indexOf(lowercaseQuery)));
                    } else {
                      return const <String>[];
                    }
                  },
                  onChanged: (data) {
                    selectedCities.clear();
                    selectedCities.addAll(data);
                    print(selectedCities);
                  },
                  chipBuilder: (BuildContext context,
                      ChipsInputState<String> state, String city) {
                    return InputChip(
                      labelPadding: const EdgeInsets.only(left: 5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      deleteIcon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18.0,
                      ),
                      backgroundColor: AppColors.primaryColor,
                      elevation: 3,
                      shadowColor: Colors.grey[60],
                      key: ObjectKey(city),
                      label: Text(
                        city.toString().trim(),
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      onDeleted: () {
                        state.deleteChip(city);
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  },
                  suggestionBuilder: (context, state, city) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          key: ObjectKey(city),
                          dense: true,
                          contentPadding: EdgeInsets.only(left: 5),
                          title: Text(city.toString().capitalize(),
                              style: Theme.of(context).textTheme.bodySmall!),
                          onTap: () {
                            state.selectSuggestion(city.trim());
                          },
                        ),
                        Container(
                          color: AppColors.bgColor,
                          height: 1,
                        ),
                      ],
                    );
                  },
                )*/
              ),
              /*Container(
                margin: const EdgeInsets.only(left: 40, right: 20.0, top: 10.0),
                child: ChipsInput<String>(
                  decoration: InputDecoration(
                    filled: true,
                    isCollapsed: true,
                    isDense: true,
                    alignLabelWithHint: true,
                    fillColor: AppColors.textFieldBgColorLight,
                    contentPadding: const EdgeInsets.only(
                        left: 10, right: 10, top: 10, bottom: 10),
                    counterText: "",
                    hintText: 'Search city name',
                    hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: isValid
                            ? Colors.black38
                            : AppColors.red.withOpacity(0.7)),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: AppColors.textFieldBgColorLight, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: isValid ? Colors.transparent : AppColors.red,
                          width: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: isValid ? Colors.transparent : AppColors.red,
                          width: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  findSuggestions: _findSuggestions,
                  onChanged: (str) {
                    //isCitiesFieldValid.value = true;
                    print(str);
                  },
                  chipBuilder: (BuildContext context,
                      ChipsInputState<String> state, String city) {
                    return InputChip(
                      //labelPadding: const EdgeInsets.only(left: 5, right: 1, top: 1, bottom: 3),
                      deleteIcon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18.0,
                      ),
                      backgroundColor: AppColors.primaryColor,
                      elevation: 3,
                      shadowColor: Colors.grey[60],
                      key: ObjectKey(city),
                      label: Text(
                        city.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      onDeleted: () {
                        selectedCities.remove(city.toString());
                        state.deleteChip(city);
                        if (selectedCities.isNotEmpty) {
                          isCitiesFieldValid.value = true;
                        }
                        print(selectedCities);
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  },
                  suggestionBuilder: (BuildContext context,
                      ChipsInputState<String> state, String city) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          key: ObjectKey(city),
                          dense: true,
                          contentPadding: EdgeInsets.only(left: 5),
                          title: Text(city.toString(),
                              style: Theme.of(context).textTheme.bodySmall!),
                          onTap: () {
                            selectedCities.add(city.toString());
                            state.selectSuggestion(city);
                            if (selectedCities.isNotEmpty) {
                              isCitiesFieldValid.value = true;
                            }
                            print(selectedCities);
                          },
                        ),
                        Container(
                          color: AppColors.bgColor,
                          height: 1,
                        ),
                      ],
                    );
                  },
                ),
              ),*/
              /* isValid
                  ? Container()
                  : Container(
                      padding: const EdgeInsets.only(left: 50.0, right: 30),
                      alignment: Alignment.centerLeft,
                      child: Text("Select cities",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: AppColors.red.withOpacity(0.8))),
                    ),*/
            ],
          );
        });
  }

  Future<List<String>> _findSuggestions(String query) async {
    if (query.length != 0) {
      return cities.where((city) {
        return city.toLowerCase().startsWith(query.toLowerCase());
      }).toList(growable: false);
    } else {
      return const <String>[];
    }
  }

  Widget _buildCitySelectTextFieldNew() {
    return Autocomplete<String>(
      optionsViewBuilder: (context, onSelected, options) {
        return Container(
          //margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Material(
              elevation: 4.0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final dynamic option = options.elementAt(index);
                        return ListTile(
                          //key: ObjectKey(city),
                          dense: true,
                          contentPadding: EdgeInsets.only(left: 5),
                          title: Text('$option',
                              style: Theme.of(context).textTheme.bodySmall!),
                          onTap: () {
                            onSelected(option);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return cities.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selectedTag) {
        _controller!.addTag = selectedTag;
      },
      fieldViewBuilder: (context, ttec, tfn, onFieldSubmitted) {
        return TextFieldTags(
          textEditingController: ttec,
          focusNode: tfn,
          textfieldTagsController: _controller,
          initialTags: const [],
          textSeparators: const [' '],
          letterCase: LetterCase.normal,
          inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
            return ((context, sc, tags, onTagDelete) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextField(
                  controller: tec,
                  focusNode: fn,
                  decoration: InputDecoration(
                    filled: true,
                    isDense: true,
                    fillColor: AppColors.textFieldBgColorLight,
                    contentPadding: const EdgeInsets.only(
                        left: 10, right: 10, top: 10, bottom: 10),
                    counterText: "",
                    hintText: _controller!.hasTags ? '' : 'Search city name',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.black38),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: AppColors.textFieldBgColorLight, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: AppColors.textFieldBgColorLight, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: AppColors.textFieldBgColorLight, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorText: error,
                    prefixIconConstraints:
                        BoxConstraints(maxWidth: _distanceToField! * 0.74),
                    prefixIcon: tags.isNotEmpty
                        ? Wrap(
                            spacing: 8.0, // gap between adjacent chips
                            runSpacing: 4.0, // gap between lines
                            children: tags.map((String tag) {
                              return Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                  color: Color.fromARGB(255, 74, 137, 92),
                                ),
                                margin: const EdgeInsets.only(right: 10.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      child: Text(
                                        '#$tag',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      onTap: () {
                                        //print("$tag selected");
                                      },
                                    ),
                                    const SizedBox(width: 4.0),
                                    InkWell(
                                      child: const Icon(
                                        Icons.cancel,
                                        size: 14.0,
                                        color:
                                            Color.fromARGB(255, 233, 233, 233),
                                      ),
                                      onTap: () {
                                        onTagDelete(tag);
                                      },
                                    )
                                  ],
                                ),
                              );
                            }).toList())
                        : null,
                  ),
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                ),
              );
            });
          },
        );
      },
    );
  }

  Widget _userTypeLabelWidget() {
    return Row(children: [
      const SizedBox(width: 10),
      Container(
        child: Icon(
          Icons.list_alt,
          color: AppColors.primaryColor,
          size: 25.0,
        ),
      ),
      Expanded(
        flex: 1,
        child: Container(
          height: 50,
          margin: const EdgeInsets.only(left: 10.0, right: 20.0, top: 5.0),
          padding: EdgeInsets.only(left: 12),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
              color: AppColors.textFieldBgColorLight,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0))),
          child: Row(children: [
            Expanded(
              flex: 1,
              child: Text(
                AppConstants.userTypes[user?.userType ?? ""] ?? "",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  editUserType = true;
                });
                /*AppUtils.showNativeAlertDialog(
                    context: context,
                    title: "Premium Section",
                    content:
                        "You need to purchase premium account membership to access below features:.\n\n- Change user type\n- Hide mobile number\n- Remove ads\n- Post upto 2 posts daily\n- Post upto 5 promotions daily",
                    cancelActionText: "Cancel",
                    defaultActionText: "Purchase Membership Now",
                    defaultActionClick: () {});*/
              },
              child: Container(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.edit,
                  color: AppColors.primaryColor,
                  size: 25.0,
                ),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }

  Widget _userTypeSelectionWidget() {
    return StatefulBuilder(builder: (thisLowerContext, innerSetState) {
      return Container(
        padding: const EdgeInsets.only(top: 5, left: 10, right: 30, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 35, top: 5),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  innerSetState(() => userType = "end_user");
                  user?.userType = userType;
                  setState(() {
                    showCompanyNameField = false;
                    editUserType = false;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        userType == "end_user"
                            ? Icons.radio_button_on
                            : Icons.radio_button_off,
                        color: AppColors.primaryColor,
                        size: 25),
                    Container(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        AppConstants.userTypes["end_user"] ?? "",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 35, top: 5),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  innerSetState(() => userType = "investor");
                  user?.userType = userType;
                  setState(() {
                    showCompanyNameField = false;
                    editUserType = false;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        userType == "investor"
                            ? Icons.radio_button_on
                            : Icons.radio_button_off,
                        color: AppColors.primaryColor,
                        size: 25),
                    Container(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        AppConstants.userTypes["investor"] ?? "",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 35, top: 5),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  innerSetState(() => userType = "dealer");
                  user?.userType = userType;
                  setState(() {
                    companyNameController.text = user?.companyName ?? "";
                    showCompanyNameField = true;
                    editUserType = false;
                    companyNameController.text = "";
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      userType == "dealer"
                          ? Icons.radio_button_on
                          : Icons.radio_button_off,
                      color: AppColors.primaryColor,
                      size: 25,
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          AppConstants.userTypes["dealer"] ?? "",
                          style: Theme.of(context).textTheme.bodyLarge,
                        )),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 35, top: 5),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  innerSetState(() => userType = "real_estate_company");
                  user?.userType = userType;
                  setState(() {
                    companyNameController.text = user?.companyName ?? "";
                    showCompanyNameField = true;
                    editUserType = false;
                    companyNameController.text = "";
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      userType == "real_estate_company"
                          ? Icons.radio_button_on
                          : Icons.radio_button_off,
                      color: AppColors.primaryColor,
                      size: 25,
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          AppConstants.userTypes["real_estate_company"] ?? "",
                          style: Theme.of(context).textTheme.bodyLarge,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSubmitButtonWidget() {
    return MediaQuery.of(context).viewInsets.bottom == 0.0
        ? BlocConsumer<CompleteProfileBloc, CompleteProfileState>(
            builder: (context, state) {
              if (state is Initial) {
                return _buildSubmitButton();
              } else if (state is Loading) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.only(
                        left: 35.0, right: 35.0, top: 1.0),
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryColor,
                    ),
                  ),
                );
              } else {
                return _buildSubmitButton();
              }
            },
            listener: (context, state) async {
              if (state is ProfileUpdated) {
                if (state.result ?? false) {
                  Provider.of<UserProvider>(context, listen: false)
                      .updateUser(state.user);
                  print(state.user?.defaultCity ?? "");
                  await AppUtils.saveUser(state.user);
                  Navigator.of(context).pop(state.user);
                }
              } else if (state is Error) {
                AppUtils.showToast(state.error ?? "");
              }
            },
          )
        : Container();
  }

  Widget _buildSubmitButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(left: 35.0, right: 35.0, top: 10.0),
      alignment: Alignment.center,
      child: isLoading
          ? Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 7.0,
                  horizontal: 7.0,
                ),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            )
          : CustomElevatedButton(
              text: "Submit",
              color: AppColors.primaryColor,
              textStyle: const TextStyle(
                  fontSize: 16,
                  color: AppColors.buttonTextColorWhite,
                  fontFamily: "Muli"),
              onPress: () {
                if (!validateForm()) {
                  return;
                }
                FocusScope.of(context).requestFocus(FocusNode());
                goToHomeScreen(context);
              },
            ),
    );
  }

  bool validateForm() {
    bool formStatus = false;
    if (nameController.text.isEmpty) {
      isUserNameFieldValid.value = false;
      formStatus = false;
    } else if (mobileController.text.isEmpty) {
      isUserNameFieldValid.value = false;
      formStatus = false;
    } else if ((userType ?? "").isNotEmpty &&
        (userType ?? "") == "real_estate_company" &&
        companyNameController.text.isEmpty) {
      isCompanyNameFieldValid.value = false;
      formStatus = false;
    } else if (selectedCities.isEmpty) {
      isCitiesFieldValid.value = false;
      formStatus = false;
    } else if ((userType ?? "").isEmpty) {
      formStatus = false;
    } else {
      isUserNameFieldValid.value = true;
      formStatus = true;
    }
    return formStatus;
    /*setState(() {
      _buttonActive = formStatus;
    });*/
  }

  Future<void> goToHomeScreen(BuildContext context) async {
    BlocProvider.of<CompleteProfileBloc>(context).add(UpdateProfile(
        _image?.path ?? "",
        bytes,
        user?.userId ?? "",
        nameController.text,
        mobileController.text,
        locationController.text,
        userType ?? "",
        selectedCities.join(','),
        user?.defaultCity ?? "",
        companyNameController.text,
        aboutController.text,
        (user?.showMobileNumber ?? true) == true ? "true" : "false"));
  }

  Future getImageFromCamera() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
    _image = File(image?.path ?? "");
    File? croppedFile = _image;
    /*File? croppedFile = await ImageCropper().cropImage(
        sourcePath: _image?.path ?? "",
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: '',
            toolbarColor: AppColors.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: '',
        ));*/

    if (croppedFile != null) {
      _clearImage();
      final dir = await getTemporaryDirectory();
      final targetPath = dir.absolute.path + "/temp.jpg";
      var result;
      try {
        result = await FlutterImageCompress.compressAndGetFile(
          croppedFile.absolute.path,
          targetPath,
          minWidth: 320,
          minHeight: 480,
          quality: 90,
        );
      } on UnsupportedError catch (e) {
        print(e);
        result = croppedFile;
      }
      setState(() {
        imageCache.clear();
        _image = result;
        //_buttonActive = true;
      });
    }
  }

  Future getImageFromGallery() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        withReadStream: true,
        type: FileType.custom,
        withData: true,
        allowedExtensions: ['png', 'jpeg', 'jpg'],
      );
      if (result != null) {
        file = result.files.single;
        file!.readStream!.listen((event) {
          bytes = Uint8List.fromList(event);
          setState(() {
            imageCache.clear();
          });
        });
      }

      //final input = Html.FileUploadInputElement()..accept = 'image/*';
      /* input.onChange.listen((event) {
        if ((input.files ?? []).isNotEmpty) {
          //html.Url.createObjectUrl(input.files!.first);
          Html.File webFile = input.files!.first;
          var r = new Html.FileReader();
          r.readAsArrayBuffer(webFile);
          r.onLoadEnd.listen((e) async {
            bytes = r.result as Uint8List?;
            setState(() {
              imageCache.clear();
            });
          });
        }
      });
      input.click();*/
    } else {
      XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
      _image = File(image?.path ?? "");
      bytes = await _image!.readAsBytes();
      File? croppedFile = await ImageCropper().cropImage(
          sourcePath: _image?.path ?? "",
          aspectRatioPresets: Platform.isAndroid
              ? [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9
                ]
              : [
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio5x3,
                  CropAspectRatioPreset.ratio5x4,
                  CropAspectRatioPreset.ratio7x5,
                  CropAspectRatioPreset.ratio16x9
                ],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: '',
              toolbarColor: AppColors.primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            title: '',
          ));

      if (croppedFile != null) {
        _clearImage();
        final dir = await getTemporaryDirectory();
        final targetPath = dir.absolute.path + "/temp.jpg";
        var result;
        try {
          result = await FlutterImageCompress.compressAndGetFile(
            croppedFile.absolute.path,
            targetPath,
            minWidth: 320,
            minHeight: 480,
            quality: 90,
          );
        } on UnsupportedError catch (e) {
          print(e);
          result = croppedFile;
        }
        _image = result;
        //bytes = _image!.readAsBytesSync();
        setState(() {
          imageCache.clear();
          //_buttonActive = true;
        });
      }
    }
  }

  void _clearImage() {
    setState(() {
      _image = null;
    });
  }
}
