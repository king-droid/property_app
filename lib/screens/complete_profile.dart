import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_feeds/blocs/complete_profile/complete_profile_bloc.dart';
import 'package:property_feeds/blocs/complete_profile/complete_profile_event.dart';
import 'package:property_feeds/blocs/complete_profile/complete_profile_state.dart';
import 'package:property_feeds/components/custom_elevated_button.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/constants/appConstants.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/provider/user_provider.dart';
import 'package:property_feeds/screens/update_profile.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:property_feeds/utils/chips_input.dart';
import 'package:provider/provider.dart';
import 'package:textfield_tags/textfield_tags.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  CompleteProfileScreenState createState() {
    return CompleteProfileScreenState();
  }
}

class CompleteProfileScreenState extends State<CompleteProfileScreen> {
  FocusNode passwordFieldFocusNode = FocusNode();
  FocusNode mobileNumberFieldFocusNode = FocusNode();
  FocusNode nameFieldFocusNode = FocusNode();
  FocusNode locationFieldFocusNode = FocusNode();
  FocusNode companyNameFieldFocusNode = FocusNode();
  late ScrollController scrollController;
  TextEditingController searchCityController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextfieldTagsController? _controller;
  ValueNotifier<bool> isUserNameFieldValid = ValueNotifier(true);
  ValueNotifier<bool> isCompanyNameFieldValid = ValueNotifier(true);
  ValueNotifier<bool> isCitiesFieldValid = ValueNotifier(true);
  final globalKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool isSocialLoading = false;
  bool _buttonActive = false;
  bool passwordVisible = true;
  bool showCompanyNameField = false;
  List<String> cities = [];
  List<String> searchedCities = [];
  List<String> selectedCities = [];
  String? userType = "end_user";
  String? name = "";
  String? emailId = "";
  double? _distanceToField;
  User? user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  bool validateForm() {
    bool formStatus = false;
    if (nameController.text.isEmpty) {
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
      keepScrollOffset: true,
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
      user = (ModalRoute.of(context)?.settings.arguments) as User?;
      nameController.text = user?.userName ?? "";
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
    var bottom = MediaQuery.of(context).viewInsets.bottom;
    bottom = max(min(bottom, nameFieldFocusNode.hasFocus ? 0 : 0), 0);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text("Complete Profile",
            style: TextStyle(color: AppColors.screenTitleColor, fontSize: 16)),
        elevation: 1,
        centerTitle: true,
        actions: <Widget>[
          /*  IconButton(
            icon: Icon(
              Icons.search,
              color: AppColors.screenTitleColor,
            ),
            onPressed: () {},
          ),*/
        ],
      ),
      key: globalKey,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  //reverse: true,
                  controller: scrollController,
                  physics: ClampingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 0),
                    child: Container(
                      //height: 500,
                      color: Colors.white10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 20),
                          // _buildHeadingWidget(),
                          _buildNameTextField(),
                          _userTypeSelectionWidget(),
                          //_buildMobileTextField(),
                          _buildCompanyNameTextField(),
                          const SizedBox(height: 10),
                          _buildLocationTextField(),
                          _buildCitySelectTextField(),
                          //const SizedBox(height: 150),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildSubmitButtonWidget(),
              const SizedBox(height: 25),
            ],
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
        valueListenable: isUserNameFieldValid,
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
                                  //isUserNameFieldValid.value = true;
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
        const SizedBox(height: 10),
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
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text("Your location (Optional)",
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 40.0, right: 20.0, top: 10.0),
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
              const SizedBox(width: 8),
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
                  const SizedBox(height: 20),
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
                          margin: const EdgeInsets.only(
                              left: 10.0, right: 20.0, top: 5),
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
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.only(left: 40, right: 20.0, top: 10.0),
                child: ChipsInput(
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
                      //labelPadding: const EdgeInsets.only(left: 5, right: 1, top: 1, bottom: 3),
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
                        city.toString(),
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
                            state.selectSuggestion(city);
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

  Widget _userTypeSelectionWidget() {
    return StatefulBuilder(builder: (thisLowerContext, innerSetState) {
      return Container(
        padding: const EdgeInsets.only(top: 5, left: 10, right: 30, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* InkWell(
              onTap: () {
                innerSetState(() => userType = "end_user");
                updateButtonState();
                setState(() {
                  showCompanyNameField = false;
                });
              },
              child: Container(
                margin:
                    const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: userType == "end_user"
                      ? AppColors.primaryColor.withOpacity(0.9)
                      : AppColors.bgColor2,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                padding:
                    const EdgeInsets.only(left: 5, right: 5, top: 8, bottom: 8),
                child: Text(
                  "End user/Investor",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: userType == "end_user"
                          ? Colors.white
                          : Colors.black87),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                innerSetState(() => userType = "dealer");
                updateButtonState();
                setState(() {
                  showCompanyNameField = false;
                });
              },
              child: Container(
                margin:
                    const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: userType == "dealer"
                      ? AppColors.primaryColor.withOpacity(0.9)
                      : AppColors.bgColor2,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                padding:
                    const EdgeInsets.only(left: 5, right: 5, top: 8, bottom: 8),
                child: Text(
                  "Dealer/Agent",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color:
                          userType == "dealer" ? Colors.white : Colors.black87),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                innerSetState(() => userType = "real_estate_company");
                updateButtonState();
                setState(() {
                  showCompanyNameField = true;
                  companyNameController.text = "";
                });
              },
              child: Container(
                margin:
                    const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: userType == "real_estate_company"
                      ? AppColors.primaryColor.withOpacity(0.9)
                      : AppColors.bgColor2,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                padding:
                    const EdgeInsets.only(left: 5, right: 5, top: 8, bottom: 8),
                child: Text(
                  "Real Estate Company",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: userType == "real_estate_company"
                          ? Colors.white
                          : Colors.black87),
                ),
              ),
            ),*/
            Padding(
              padding: const EdgeInsets.only(left: 35, top: 10),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  innerSetState(() => userType = "end_user");
                  //updateButtonState();
                  setState(() {
                    showCompanyNameField = false;
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
                        size: 28),
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
              padding: const EdgeInsets.only(left: 35, top: 10),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  innerSetState(() => userType = "investor");
                  //updateButtonState();
                  setState(() {
                    showCompanyNameField = false;
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
                        size: 28),
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
              padding: const EdgeInsets.only(left: 35, top: 10),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  innerSetState(() => userType = "dealer");
                  //updateButtonState();
                  setState(() {
                    showCompanyNameField = true;
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
                      size: 28,
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
              padding: const EdgeInsets.only(left: 35, top: 10),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  innerSetState(() => userType = "real_estate_company");
                  //updateButtonState();
                  setState(() {
                    showCompanyNameField = true;
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
                      size: 28,
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
                      .createUser(state.user);
                  await AppUtils.saveUser(state.user);
                  await AppUtils.setLoggedIn();
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.homeScreen);
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

  Future<void> goToHomeScreen(BuildContext context) async {
    BlocProvider.of<CompleteProfileBloc>(context).add(UpdateProfile(
        "",
        user?.userId ?? "",
        nameController.text,
        mobileController.text,
        locationController.text,
        userType ?? "",
        selectedCities.join(','),
        user?.defaultCity ?? "",
        companyNameController.text,
        "",
        "true"));
  }
}
