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
import 'package:property_feeds/blocs/post/post_bloc.dart';
import 'package:property_feeds/blocs/post/post_event.dart';
import 'package:property_feeds/blocs/post/post_state.dart';
import 'package:property_feeds/components/custom_elevated_button.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/constants/appConstants.dart';
import 'package:property_feeds/models/post.dart';
import 'package:property_feeds/models/user.dart';
import 'package:property_feeds/provider/user_provider.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:provider/provider.dart';

typedef FileSelectCallback = void Function(int);

class AddPostScreen extends StatefulWidget {
  @override
  AddPostScreenState createState() {
    return new AddPostScreenState();
  }
}

class AddPostScreenState extends State<AddPostScreen> {
  FocusNode titleFocusNode = new FocusNode();
  FocusNode locationFocusNode = new FocusNode();
  FocusNode priceFocusNode = new FocusNode();
  FocusNode sizeFocusNode = new FocusNode();
  FocusNode contentFocusNode = new FocusNode();
  bool _isLoading = false;
  late ScrollController scrollController;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();
  final sizeController = TextEditingController();
  ValueNotifier<bool> isTitleFieldValid = ValueNotifier(true);
  ValueNotifier<bool> isDescriptionFieldValid = ValueNotifier(true);
  ValueNotifier<bool> isLocationFieldValid = ValueNotifier(true);

  int selectedCityIndex = -1;
  String requirementType = "";
  String selectedSizeType = "Sq. Yard";
  String selectedPrizeType = "Total Price";
  String selectedCity = "";
  List<String?> _images = [];
  List<String> categories = ["Buy", "Sell", "Rent"];
  User? user;
  String? mode = "add";
  Post? post;

  List<String> sizeList = [
    "Sq. Yard",
    "Sq. Gaj",
    "Sq. Meter",
    "Sq. Foot",
    "Marla",
    "Kanal",
    "Acre",
    "Bigha",
    "Hectare",
  ];

  List<String> priceList = [
    "Total Price",
    "Per Sq. Yard",
    "Per Sq. Gaj",
    "Per Sq. Meter",
    "Per Sq. Foot"
  ];

  final globalKey = GlobalKey<ScaffoldState>();
  List<String>? cities = [];

  @override
  void initState() {
    scrollController = new ScrollController(
      initialScrollOffset: 0.0,
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      cities = (user?.interestedCities ?? "").split(',');
      if (mode == "edit" && post != null) {
        titleController.text = post?.postTitle ?? "";
        descriptionController.text = post?.postDescription ?? "";
        locationController.text = post?.propertyLocation ?? "";
        selectedCity = post?.propertyCity ?? "";
        selectedCityIndex = cities!.indexOf(selectedCity);
        requirementType = post?.requirementType ?? "";
        selectedSizeType = post?.propertySizeType ?? "";
        selectedPrizeType = post?.propertyPriceType ?? "";
        priceController.text = post?.propertyPrice ?? "";
        sizeController.text = post?.propertySize ?? "";
        _images = (post?.postPic ?? "").trim().isNotEmpty
            ? (post?.postPic ?? "").split(',')
            : [];
      }
      setState(() {});
      BlocProvider.of<PostBloc>(context).add(InitialEvent());
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
    post = (ModalRoute.of(context)!.settings.arguments as Map)["post"] as Post?;
    user = Provider.of<UserProvider>(context, listen: false).userData;
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            if (mode == "edit" && post != null) {
              Navigator.pop(context, post);
            } else {
              Navigator.pop(context);
            }
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
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(mode == "edit" ? "Update Post" : "New Post",
            style: TextStyle(color: AppColors.primaryColor, fontSize: 16)),
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          /*InkWell(
            onTap: () {
              //_showSearchCityDialog();
            },
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(8),
              //color: Colors.blue,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Icon(
                        Icons.location_pin,
                        color: AppColors.primaryColor,
                        size: 15.0,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.only(right: 5),
                        child: Text(
                          (selectedCity ?? "").trim(),
                          maxLines: 2,
                          textAlign: TextAlign.end,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.black54, fontSize: 11),
                        ),
                      ),
                    ),
                  ]),
            ),
          )*/
        ],
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
                padding: /* kIsWeb
                    ? EdgeInsets.only(
                        left: (MediaQuery.of(context).size.width / 5),
                        right: (MediaQuery.of(context).size.width / 5),
                        top: 20,
                        bottom: 25)
                    :*/
                    EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 25),
                color: AppColors.white,
                //height: MediaQuery.of(context).size.height,
                child: IgnorePointer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildCitySelectionWidget(),
                      _buildCategorySelectionWidget(),
                      _buildTitleWidget(),
                      _buildContentWidget(),
                      _buildLocationWidget(),
                      //_buildOtherDetailsSeparator(),
                      _buildAttachmentWidget(),
                      //_buildSizeWidget(),
                      //_buildPriceWidget(),
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

  _buildCategorySelectionWidget() {
    return StatefulBuilder(builder: (context, innerSetState) {
      return Column(children: [
        /*Container(
          alignment: Alignment.centerLeft,
          child: Text(
            "Requirement Type",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.headingsColor,
              fontFamily: "Montserrat-Light",
              fontSize: 14.0,
            ),
          ),
        ),*/
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5, top: 1),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    requirementType = "buy";
                    _images = [];
                  });
                  sizeController.text = "";
                  priceController.text = "";
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        requirementType == "buy"
                            ? Icons.radio_button_on
                            : Icons.radio_button_off,
                        color: AppColors.primaryColor,
                        size: 25),
                    Container(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        "Buying",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, top: 1),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  setState(() => requirementType = "sell");
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        requirementType == "sell"
                            ? Icons.radio_button_on
                            : Icons.radio_button_off,
                        color: AppColors.primaryColor,
                        size: 25),
                    Container(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        "Selling",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, top: 1),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    requirementType = "rent";
                    _images = [];
                  });
                  sizeController.text = "";
                  priceController.text = "";
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        requirementType == "rent"
                            ? Icons.radio_button_on
                            : Icons.radio_button_off,
                        color: AppColors.primaryColor,
                        size: 25),
                    Container(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        "Rent",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ]);
    });
  }

  _buildCitySelectionWidget() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select city",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontSize: 18.0),
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
    return requirementType == "sell" || requirementType == "rent"
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(
                              left: 0, top: 20, bottom: 1),
                          child: new Text(
                            "Pictures (Optional)",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontSize: 18.0),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(left: 5),
                            child: Text(
                              'You can add upto 5 pictures',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: Colors.black54, fontSize: 11),
                            )),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _pickAttachment();
                    },
                    child: Container(
                      margin:
                          const EdgeInsets.only(left: 5, top: 25, bottom: 1),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.overlayButtonColor,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Icon(Icons.add, color: Colors.black54),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /* Container(
                    height: 45,
                    margin: const EdgeInsets.only(top: 10.0),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          new BorderRadius.all(const Radius.circular(5)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black54.withOpacity(.2),
                            blurRadius: 1,
                            spreadRadius: 0.2),
                      ],
                    ),
                    child: ActionChip(
                        avatar: Icon(Icons.add, color: AppColors.headingsColor),
                        backgroundColor: AppColors.cardBgColor,
                        padding: EdgeInsets.only(left: 0, right: 0),
                        label: Text('Add Pictures',
                            style: TextStyle(
                                fontFamily: "Roboto_Bold",
                                color: AppColors.buttonTextColor,
                                fontSize: 14)),
                        onPressed: () {
                          _pickAttachment();
                        }),
                  ),
                  const SizedBox(width: 15),*/
                ],
              ),
              /*GestureDetector(
                onTap: () {
                  _pickAttachment();
                },
                child: Container(
                  height: 100,
                  width: MediaQuery.sizeOf(context).width,
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
                      ],
                    ),
                  ),
                ),
              ),*/
              Container(
                width: MediaQuery.sizeOf(context).width,
                //color: AppColors.bgColorLight,
                /*decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.all(const Radius.circular(5)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 0,
                        spreadRadius: 0.5),
                  ],
                ),*/
                margin: EdgeInsets.only(top: 15, right: 1, bottom: 1),
                child: _images.isNotEmpty
                    ? Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.start,
                        children: [
                            for (int i = 0; i < _images.length; i++)
                              (_images[i] ?? "").isNotEmpty
                                  ? InkWell(
                                      onTap: () {
                                        _showPictureOptions(i);
                                      },
                                      child: Container(
                                        width: 70,
                                        height: 70,
                                        margin: EdgeInsets.all(5),
                                        //color: Colors.blueAccent,
                                        child: Center(
                                          child: _images[i] != null
                                              ? (_images[i] ?? "")
                                                      .startsWith("/data")
                                                  ? Image.file(
                                                      File(_images[i] ?? ""),
                                                      fit: BoxFit.cover,
                                                      width: 70,
                                                      height: 70,
                                                    )
                                                  : FadeInImage.assetNetwork(
                                                      image: AppConstants
                                                              .imagesBaseUrl +
                                                          "/post_images/" +
                                                          (_images[i] ?? ""),
                                                      fit: BoxFit.cover,
                                                      width: 70,
                                                      height: 70,
                                                      placeholder:
                                                          "assets/picture_loading.gif",
                                                    )
                                              : Container(),
                                        ),
                                      ),
                                    )
                                  : Container(),
                            /*GestureDetector(
                              onTap: () {
                                _pickAttachment();
                              },
                              child: Container(
                                height: 70,
                                width: 70,
                                margin: EdgeInsets.all(5),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: new BorderRadius.all(
                                      const Radius.circular(5)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 0,
                                        spreadRadius: 0.5),
                                  ],
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 25,
                                        height: 25,
                                        child: Icon(Icons.add,
                                            color: Colors.black26),
                                      ),
                                      Text('Add',
                                          style: TextStyle(
                                              fontFamily: "Roboto_Bold",
                                              color: AppColors.subTitleColor,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ),*/
                          ])
                    : Container(),
              ),
            ],
          )
        : Container();
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
                color: AppColors.bgColor3,
                height: 10.0,
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
                    _images.removeAt(index);
                    //file = null;
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
    return requirementType == "sell" || requirementType == "rent"
        ? Container(
            margin: EdgeInsets.only(top: 30, bottom: 10),
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
                      "Add Pictures (Optional)",
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
          )
        : Container();
  }

  void addPost(BuildContext context) {
    FocusScope.of(context).requestFocus();
    FocusScope.of(context).requestFocus();

    setState(() {
      _isLoading = true;
    });

    /*ApiHelper.addPost(titleController.text, contentController.text, _image)
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
                child: new Text(
                  "Title",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontSize: 18.0),
                ),
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
                            fontFamily: "Montserrat-Regular",
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
                  requirementType == "sell"
                      ? "Example: 100 Sq. yard plot for sale"
                      : requirementType == "buy"
                          ? "Example: 100 Sq. yard plot required"
                          : "Example: 2BHK floor/flat plot for rent",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black54.withOpacity(0.4),
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

  _buildLocationWidget() {
    return ValueListenableBuilder(
        valueListenable: isLocationFieldValid,
        builder: (BuildContext context, bool isValid, Widget? child) {
          return Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                //padding: const EdgeInsets.only(left: 10.0),
                child: new Text(
                  requirementType == "buy"
                      ? "Preferred Location/Nearby"
                      : "Location/Landmark",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontSize: 18.0),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10.0),
                alignment: Alignment.center,
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Expanded(
                      child: TextField(
                        controller: locationController,
                        onChanged: (value) {
                          if (value.length > 0) {
                            isLocationFieldValid.value = true;
                          }
                        },
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor),
                        onSubmitted: (String value) {
                          locationFocusNode.unfocus();
                        },
                        obscureText: false,
                        focusNode: locationFocusNode,
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
                          hintText: 'Enter location or nearby landmark',
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
            ],
          );
        });
  }

  _buildPriceWidget() {
    return requirementType == "sell"
        ? Column(
            children: [
              //const SizedBox(height: 10),
              /*Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 10.0),
          child: new Text(
            "Price (Optional)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.headingsColor,
              fontFamily: "Montserrat-Light",
              fontSize: 14.0,
            ),
          ),
        ),*/
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(top: 10.0),
                alignment: Alignment.center,
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: priceController,
                        //onChanged: (value) => updateButtonState(),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor),
                        onSubmitted: (String value) {
                          /* FocusScope.of(context)
                                .requestFocus(contentFocusNode);*/
                          priceFocusNode.unfocus();
                        },
                        obscureText: false,
                        focusNode: priceFocusNode,
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.left,
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          //prefixText: "Rs.  ",
                          prefixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(width: 5),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Rs.",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "Montserrat-Regular",
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textColor)),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                          prefixStyle: TextStyle(
                              fontSize: 15,
                              fontFamily: "Montserrat-Regular",
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor),
                          counterText: "",
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              right: 13, top: 13, bottom: 13, left: 13),
                          fillColor: Colors.white,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.primaryColor, width: 0.9),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.primaryColor, width: 0.4),
                          ),
                          hintText: 'Property price',
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    Expanded(flex: 0, child: _buildCustomPrizeTypeWidget()),
                  ],
                ),
              ),
            ],
          )
        : Container();
  }

  _buildSizeWidget() {
    return requirementType == "sell"
        ? Column(
            children: [
              const SizedBox(height: 10),
              /*Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 10.0),
          child: new Text(
            "Price (Optional)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.headingsColor,
              fontFamily: "Montserrat-Light",
              fontSize: 14.0,
            ),
          ),
        ),*/
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(top: 10.0),
                alignment: Alignment.center,
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: sizeController,
                        //onChanged: (value) => updateButtonState(),
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: "Montserrat-Regular",
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor),
                        onSubmitted: (String value) {
                          /* FocusScope.of(context)
                                .requestFocus(contentFocusNode);*/
                          sizeFocusNode.unfocus();
                        },
                        obscureText: false,
                        focusNode: sizeFocusNode,
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.left,
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(13),
                          counterText: "",
                          isDense: true,
                          fillColor: Colors.white,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.primaryColor, width: 0.9),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.primaryColor, width: 0.4),
                          ),
                          hintText: 'Property Size',
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    Expanded(flex: 0, child: _buildCustomSizeTypeWidget()),
                  ],
                ),
              ),
            ],
          )
        : Container();
  }

  _buildCustomSizeTypeWidget() {
    return Container(
      margin: EdgeInsets.only(left: 5),
      padding: EdgeInsets.all(9),
      decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.primaryColor, width: 0.4),
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: DropdownButton(
        underline: Container(),
        isDense: true,
        dropdownColor: Colors.white,
        icon: Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.arrow_drop_down_sharp,
            size: 20,
            color: Colors.black54,
          ),
        ),
        elevation: 2,
        style: TextStyle(
            fontSize: 16, color: Colors.black54, fontWeight: FontWeight.bold),
        value: selectedSizeType,
        items: sizeList.map((String sizeType) {
          return DropdownMenuItem<String>(
            value: sizeType,
            child: Container(
              child: Text(sizeType ?? "",
                  maxLines: 2,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600)),
            ),
          );
        }).toList(),
        onChanged: (var newValue) {
          setState(() {
            selectedSizeType = newValue!;
          });
        },
      ),
    );
  }

  _buildCustomPrizeTypeWidget() {
    return Container(
      margin: EdgeInsets.only(left: 5),
      padding: EdgeInsets.all(9),
      decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.primaryColor, width: 0.4),
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: DropdownButton(
        underline: Container(),
        isDense: true,
        dropdownColor: Colors.white,
        icon: Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.arrow_drop_down_sharp,
            size: 20,
            color: Colors.black54,
          ),
        ),
        elevation: 2,
        style: TextStyle(
            fontSize: 16, color: Colors.black54, fontWeight: FontWeight.bold),
        value: selectedPrizeType,
        items: priceList.map((String sizeType) {
          return DropdownMenuItem<String>(
            value: sizeType,
            child: Container(
              child: Text(sizeType ?? "",
                  maxLines: 2,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600)),
            ),
          );
        }).toList(),
        onChanged: (var newValue) {
          setState(() {
            selectedPrizeType = newValue!;
          });
        },
      ),
    );
  }

  _buildSubmitCTAWidget() {
    return MediaQuery.of(context).viewInsets.bottom == 0.0
        ? BlocConsumer<PostBloc, PostState>(
            builder: (context, state) {
              if (state is Initial) {
                return _buildSubmitBtn();
              } else if (state is Loading) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.only(
                        left: 35.0, right: 35.0, top: 30.0, bottom: 10),
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
              if (state is PostAdded) {
                if (state.result ?? false) {
                  Navigator.of(context).pop(state.user);
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
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
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
                  BlocProvider.of<PostBloc>(context).add(UpdatePost(
                      post?.postId ?? "",
                      requirementType ?? " ",
                      user?.userId ?? "",
                      selectedCity ?? "",
                      titleController.text,
                      descriptionController.text,
                      locationController.text,
                      _images,
                      sizeController.text ?? "",
                      selectedSizeType ?? "",
                      priceController.text ?? "",
                      selectedPrizeType ?? ""));
                } else {
                  BlocProvider.of<PostBloc>(context).add(AddPost(
                      requirementType ?? " ",
                      user?.userId ?? "",
                      selectedCity ?? "",
                      titleController.text,
                      descriptionController.text,
                      locationController.text,
                      _images,
                      sizeController.text ?? "",
                      selectedSizeType ?? "",
                      priceController.text ?? "",
                      selectedPrizeType ?? ""));
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
    } else if ((requirementType ?? "").isEmpty) {
      AppUtils.showSnackBar(
          context, "Please choose if you want to buy, sell or rent");
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
    } else if (locationController.text.isEmpty) {
      AppUtils.showSnackBar(context, "Please write location of property");
      isLocationFieldValid.value = false;
      formStatus = false;
    }
    return formStatus;
  }
}
