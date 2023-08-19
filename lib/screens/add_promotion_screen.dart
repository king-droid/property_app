import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:property_feeds/blocs/promotion/promotion_bloc.dart';
import 'package:property_feeds/blocs/promotion/promotion_event.dart';
import 'package:property_feeds/blocs/promotion/promotion_state.dart';
import 'package:property_feeds/components/custom_elevated_button.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/constants/appConstants.dart';
import 'package:property_feeds/models/promotion.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/provider/user_provider.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:provider/provider.dart';

typedef FileSelectCallback = void Function(int);

class AddPromotionScreen extends StatefulWidget {
  @override
  AddPromotionScreenState createState() {
    return new AddPromotionScreenState();
  }
}

class AddPromotionScreenState extends State<AddPromotionScreen> {
  FocusNode titleFocusNode = new FocusNode();
  FocusNode contentFocusNode = new FocusNode();
  bool _isLoading = false;
  late ScrollController scrollController;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  ValueNotifier<bool> isTitleFieldValid = ValueNotifier(true);
  ValueNotifier<bool> isDescriptionFieldValid = ValueNotifier(true);

  List<String?> _images = [];
  User? user;
  String? mode = "add";
  String? selectedCity = "";
  int selectedCityIndex = -1;
  Promotion? promotion;
  final globalKey = GlobalKey<ScaffoldState>();
  List<String>? cities = [];

  @override
  void initState() {
    scrollController = new ScrollController(
      initialScrollOffset: 0.0,
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      cities = (user?.interestedCities ?? "").split(',');
      if (mode == "edit" && promotion != null) {
        titleController.text = promotion?.promotionTitle ?? "";
        descriptionController.text = promotion?.promotionDescription ?? "";
        selectedCity = promotion?.promotionCity ?? "";
        selectedCityIndex = cities!.indexOf(selectedCity ?? "");
        _images = (promotion?.promotionPic ?? "").trim().isNotEmpty
            ? (promotion?.promotionPic ?? "").split(',')
            : [];
      }
      setState(() {});
      BlocProvider.of<PromotionBloc>(context).add(InitialEvent());
    });
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mode =
        (ModalRoute.of(context)!.settings.arguments as Map)["mode"] as String?;
    promotion = (ModalRoute.of(context)!.settings.arguments as Map)["promotion"]
        as Promotion?;
    user = Provider.of<UserProvider>(context, listen: false).userData;
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            /*if (mode == "edit" && promotion != null) {
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }*/
            Navigator.pop(context);
          },
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(8),
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.overlayButtonColor,
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 18,
              ),
            ),
          ),
        ),
        /*actions: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              decoration: BoxDecoration(
                color: AppColors.overlayButtonColor,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Container(
                child: Icon(
                  Icons.done_sharp,
                  color: Colors.black,
                  size: 25,
                ),
              ),
            ),
          ),
        ],*/
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(mode == "edit" ? "Update Promotion" : "New Promotion",
            style: TextStyle(color: AppColors.primaryColor, fontSize: 16)),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: SingleChildScrollView(
            controller: scrollController,
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Container(
                padding: kIsWeb
                    ? EdgeInsets.only(left: 25, right: 25, top: 5, bottom: 25)
                    /*EdgeInsets.only(
                        left: (MediaQuery.of(context).size.width / 5),
                        right: (MediaQuery.of(context).size.width / 5),
                        top: 20,
                        bottom: 25)*/
                    : EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 25),
                color: AppColors.white,
                //height: MediaQuery.of(context).size.height,
                child: IgnorePointer(
                  child: Column(
                    children: <Widget>[
                      _buildCitySelectionWidget(),
                      _buildTitleWidget(),
                      _buildContentWidget(),
                      //_buildOtherDetailsSeparator(),
                      _buildAttachmentWidget(),
                      _buildSubmitCTAWidget(),
                    ],
                  ),
                  ignoring: _isLoading,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildCitySelectionWidget() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text("Select city",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontSize: 18.0)
                  /* TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.headingsColor,
                  fontFamily: "Montserrat-Light",
                  fontSize: 14.0,
                ),*/
                  ),
            ),
            const SizedBox(width: 5),
            /*Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "(Where you want property to be posted)",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: AppColors.headingsColor,
                  fontFamily: "Montserrat-Light",
                  fontSize: 12.0,
                ),
              ),
            ),*/
          ],
        ),
        const SizedBox(height: 10),
        StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.only(left: 0.0, bottom: 15),
            child: Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.start,
                children: List.generate(
                  (cities ?? []).length,
                  (index) {
                    return InkWell(
                      onTap: () {
                        selectedCity = cities![index] ?? "";
                        setState(() {
                          selectedCityIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 5, right: 5, top: 5, bottom: 5),
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: index == selectedCityIndex
                                  ? AppColors.primaryColor
                                  : AppColors.subTitleColor),
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        padding: const EdgeInsets.only(
                            left: 7, right: 7, top: 5, bottom: 5),
                        child: Text(
                          cities![index] ?? "",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  color: index == selectedCityIndex
                                      ? AppColors.primaryColor
                                      : AppColors.subTitleColor,
                                  fontSize: 13),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  _buildAttachmentWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          child: new Text("Promotional Banner",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontSize: 18.0)),
        ),
        _images.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      _pickAttachment();
                    },
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 10.0),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            new BorderRadius.all(const Radius.circular(5)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 0,
                              spreadRadius: 0.5),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              child: Image.asset("assets/picture_icon.png",
                                  fit: BoxFit.fitWidth),
                            ),
                            Text('Choose Picture',
                                style: TextStyle(
                                    fontFamily: "Roboto_Bold",
                                    color: AppColors.subTitleColor,
                                    fontSize: 14)),
                            /* onPressed: () {
                                  //_pickAttachment();
                                }),*/
                          ],
                        ),
                      ),
                    ),
                  ),
                  /*const SizedBox(width: 15),
                  Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text(
                          'This picture will be shown as banner in promotion',
                          style: TextStyle(
                              fontFamily: "Roboto_Regular",
                              color: AppColors.buttonTextColorLight,
                              fontSize: 12))),*/
                ],
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                //color: AppColors.primaryColor,
                margin: EdgeInsets.only(top: 5, left: 0, right: 1, bottom: 1),
                child: InkWell(
                  onTap: () {
                    _showPictureOptions(0);
                  },
                  child: Center(
                    child: _images[0] != null
                        ? (_images[0] ?? "").startsWith("/data")
                            ? Image.file(
                                File(_images[0] ?? ""),
                                fit: BoxFit.fill,
                                //width: 110,
                              )
                            : FadeInImage.assetNetwork(
                                image: AppConstants.imagesBaseUrl +
                                    "/promotion_images/" +
                                    (_images[0] ?? ""),
                                fit: BoxFit.fill,
                                placeholder: "assets/picture_loading.gif",
                              )
                        : Container(),
                  ),
                ))
      ],
    );
  }

  _pickAttachment() {
    FocusScope.of(context).requestFocus();
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.camera_alt),
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
              Divider(
                color: AppColors.bgColorLight,
                height: 1.0,
              ),
              new ListTile(
                leading: new Icon(Icons.photo_library),
                title: new Text(
                  'Choose from gallery',
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
  }

  _showPictureOptions(int index) {
    FocusScope.of(context).requestFocus();
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.image,
                  color: AppColors.primaryColor,
                ),
                title: Text(
                  'View Picture',
                  style: TextStyle(
                      fontFamily: "Roboto_Bold",
                      color: AppColors.textColor,
                      fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                      context, AppRoutes.previewLocalImageScreen,
                      arguments: _images[index] ?? "");
                },
              ),
              Divider(
                color: Colors.grey.withOpacity(0.3),
                height: 10.0,
              ),
              /*ListTile(
                leading: Icon(
                  Icons.edit,
                  color: AppColors.primaryColor,
                ),
                title: Text(
                  'Update Picture',
                  style: TextStyle(
                      fontFamily: "Roboto_Bold",
                      color: AppColors.textColor,
                      fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAttachment();
                },
              ),
              Divider(
                color: Colors.grey.withOpacity(0.3),
                height: 10.0,
              ),*/
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: AppColors.primaryColor,
                ),
                title: Text(
                  'Delete Picture',
                  style: TextStyle(
                      fontFamily: "Roboto_Bold",
                      color: AppColors.textColor,
                      fontSize: 16),
                ),
                onTap: () {
                  setState(() {
                    _images.clear();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  late final Permission _permission;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  Future<PermissionStatus> requestPermission(Permission permission) async {
    final status = await permission.request();

    _permissionStatus = status;
    return _permissionStatus;
  }

  Future getImageFromCamera() async {
    final picker = ImagePicker();
    final pickedImage =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 95);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _images.add(pickedImageFile.path);
    });
    //if (await requestPermission(Permission.manageExternalStorage).isGranted) {
    /*try {
      XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
      _image = File(image?.path ?? "");

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
        setState(() {
          imageCache.clear();
          _image = result;
          //_buttonActive = true;
        });
      }
    } catch (e) {}
    */ // } else {}
  }

  Future getImageFromGallery() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    File? selImage = File(image?.path ?? "");
    File? croppedFile = await ImageCropper().cropImage(
        sourcePath: selImage.path ?? "",
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                //CropAspectRatioPreset.ratio3x2,
                //CropAspectRatioPreset.original,
                //CropAspectRatioPreset.ratio4x3,
                //CropAspectRatioPreset.ratio16x9
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
      Directory targetDir = Directory(dir.absolute.path + "/post");
      if (await targetDir.exists() == false) {
        targetDir.create();
      }
      final targetPath =
          targetDir.path + "/${DateTime.now().microsecondsSinceEpoch}.jpg";
      var result;
      try {
        result = await FlutterImageCompress.compressAndGetFile(
          croppedFile.absolute.path,
          targetPath,
          minWidth: 640,
          minHeight: 960,
          quality: 95,
        );
      } on UnsupportedError catch (e) {
        print(e);
        result = croppedFile;
      }
      setState(() {
        imageCache.clear();
        _images.add(result.path);
        //_buttonActive = true;
      });
    }
  }

  void _clearImage() {
    setState(() {
      //_image = null;
    });
  }

  _buildOtherDetailsSeparator() {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: 1,
              color: Colors.black12,
            ),
          ),
          Expanded(
            flex: 0,
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 10, right: 10),
              child: Text(
                "Promotion Banner",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.headingsColor,
                  fontFamily: "Montserrat-Light",
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 1,
              color: Colors.black12,
            ),
          ),
        ],
      ),
    );
  }

  void addPromotion(BuildContext context) {
    FocusScope.of(context).requestFocus();
    FocusScope.of(context).requestFocus();

    setState(() {
      _isLoading = true;
    });

    /*ApiHelper.addPromotion(titleController.text, contentController.text, _image)
        .then((result) {
      setState(() {
        _isLoading = false;
      });
      if (result.status == "success") {
        */ /*final snackBar = SnackBar(content: Text(result.message));
        globalKey.currentState.showSnackBar(snackBar);*/ /*
        Navigator.pop(context, "refresh_posts");
      } else {
        final snackBar = SnackBar(content: Text(result.message));
        //globalKey.currentState.showSnackBar(snackBar);
        //Scaffold.of(context).showSnackBar(snackBar);
      }
    }).catchError((onError) {
      setState(() {
        _isLoading = false;
      });
      final snackBar = SnackBar(content: Text(onError.toString()));
      //Scaffold.of(context).showSnackBar(snackBar);
      //globalKey.currentState.showSnackBar(snackBar);
    });*/
  }

  _buildTitleWidget() {
    return ValueListenableBuilder(
        valueListenable: isTitleFieldValid,
        builder: (BuildContext context, bool isValid, Widget? child) {
          return Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: new Text("Title",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontSize: 18.0)),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 5.0),
                alignment: Alignment.center,
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Expanded(
                      child: TextField(
                        controller: titleController,
                        onChanged: (value) {
                          if (value.length > 0) {
                            isTitleFieldValid.value = true;
                          }
                        },
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor),
                        onSubmitted: (String value) {
                          FocusScope.of(context).requestFocus(contentFocusNode);
                          titleFocusNode.unfocus();
                        },
                        obscureText: false,
                        focusNode: titleFocusNode,
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          isDense: true,
                          fillColor: Colors.white,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: isValid
                                    ? AppColors.subTitleColor
                                    : AppColors.red,
                                width: 0.9),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: isValid
                                      ? AppColors.subTitleColor
                                      : AppColors.red,
                                  width: 0.4)),
                          hintText: 'Enter title',
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 5.0, left: 5),
                child: new Text(
                  "Example: New launch of Premium low-rise floors",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black54.withOpacity(0.4),
                    fontFamily: "Montserrat-Light",
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          );
        });
  }

  _buildContentWidget() {
    return ValueListenableBuilder(
        valueListenable: isDescriptionFieldValid,
        builder: (BuildContext context, bool isValid, Widget? child) {
          return Column(
            children: [
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.centerLeft,
                child: new Text("Description",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontSize: 18.0)),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 5.0),
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    Scrollbar(
                      child: new SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        reverse: true,
                        child: SizedBox(
                          child: TextField(
                            controller: descriptionController,
                            onChanged: (value) {
                              if (value.length > 0) {
                                isDescriptionFieldValid.value = true;
                              }
                            },
                            focusNode: contentFocusNode,
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: "Montserrat-Regular",
                                fontWeight: FontWeight.w500,
                                color: AppColors.textColor),
                            maxLines: 7,
                            maxLength: 2000,
                            obscureText: false,
                            textInputAction: TextInputAction.newline,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              fillColor: Colors.white,
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: isValid
                                        ? AppColors.subTitleColor
                                        : AppColors.red,
                                    width: 0.9),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: isValid
                                        ? AppColors.subTitleColor
                                        : AppColors.red,
                                    width: 0.4),
                              ),
                              border: InputBorder.none,
                              hintText: 'Write your promotion details here',
                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  _buildSubmitCTAWidget() {
    return MediaQuery.of(context).viewInsets.bottom == 0.0
        ? BlocConsumer<PromotionBloc, PromotionState>(
            builder: (context, state) {
              if (state is Initial) {
                return _buildSubmitBtn();
              } else if (state is Loading) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.only(
                        left: 35.0, right: 35.0, top: 35.0, bottom: 10),
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryColor,
                    ),
                  ),
                );
              } else {
                return _buildSubmitBtn();
              }
            },
            listener: (context, state) async {
              if (state is PromotionAdded) {
                if (state.result ?? false) {
                  Navigator.of(context).pop(state.data);
                }
              } else if (state is Error) {
                AppUtils.showToast(state.error ?? "");
              }
            },
          )
        : Container();
  }

  _buildSubmitBtn() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 40.0),
      alignment: Alignment.center,
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: /*_isLoading
                      ? Request_Loader()
                      : */
                CustomElevatedButton(
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
                if (mode == "edit") {
                  BlocProvider.of<PromotionBloc>(context).add(UpdatePromotion(
                      promotion?.promotionId ?? "",
                      user?.userId ?? "",
                      titleController.text,
                      descriptionController.text,
                      selectedCity ?? "",
                      _images));
                } else {
                  BlocProvider.of<PromotionBloc>(context).add(AddPromotion(
                      user?.userId ?? "",
                      titleController.text,
                      descriptionController.text,
                      selectedCity ?? "",
                      _images));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  bool validateForm() {
    bool formStatus = true;
    if ((selectedCity ?? "").isEmpty) {
      AppUtils.showSnackBar(context, "Please select city you want to post");
      scrollController.animateTo(scrollController.initialScrollOffset,
          duration: Duration(milliseconds: 600), curve: Curves.ease);
      formStatus = false;
    } else if (titleController.text.isEmpty) {
      AppUtils.showSnackBar(context, "Please write title");
      isTitleFieldValid.value = false;
      formStatus = false;
    } else if (descriptionController.text.isEmpty) {
      AppUtils.showSnackBar(context, "Please write description");
      isDescriptionFieldValid.value = false;
      formStatus = false;
    } else if (_images.isEmpty) {
      AppUtils.showSnackBar(context, "Please add promotion banner");
      formStatus = false;
    }
    return formStatus;
  }
}
