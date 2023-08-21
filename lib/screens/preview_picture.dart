import 'package:flutter/material.dart';
import 'package:property_feeds/constants/appConstants.dart';

class PreviewPictureScreen extends StatefulWidget {
  PreviewPictureScreen();

  @override
  _PreviewPictureScreenState createState() => _PreviewPictureScreenState();
}

class _PreviewPictureScreenState extends State<PreviewPictureScreen> {
  String? imagePath = "";
  List<String> pictures = [];
  late TransformationController controller;
  late TapDownDetails tabDownDetails;
  final _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;
  late PageController _pageController;
  late ScrollController scrollController;
  int activePosition = 0;

  _PreviewPictureScreenState();

  @override
  void initState() {
    controller = TransformationController();
    _pageController =
        PageController(/*viewportFraction: 0.0, */ initialPage: 0);

    scrollController = new ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //imagePath = ((ModalRoute.of(context)?.settings.arguments) as String) ?? "";
    pictures =
        ((ModalRoute.of(context)?.settings.arguments) as List<String>) ?? [];
    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            padding: EdgeInsets.only(top: 20, bottom: 20, right: 15),
            child: Row(
              children: [
                Container(
                  width: 25,
                  height: 25,
                  child: Image.asset(
                    "assets/picture_icon_transparent.png",
                    fit: BoxFit.cover,
                  ),
                ),
                Text(
                  "${pictures.length} Pictures",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(5),
            height: 37,
            width: 37,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              //color: AppColors.whiteLight,
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.black54,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.black54,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.black54,
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Container(
                      width: double.infinity,
                      child: PageView.builder(
                          itemCount: pictures.length,
                          pageSnapping: true,
                          controller: _pageController,
                          onPageChanged: (page) {
                            setState(() {
                              activePosition = page;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Container(
                                //margin: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                                child: pictures[index].isNotEmpty
                                    ? Container(
                                        width: double.infinity,
                                        //height: MediaQuery.of(context).size.height,
                                        child: (pictures[index] ?? "")
                                                .isNotEmpty
                                            ? GestureDetector(
                                                onDoubleTapDown: (d) =>
                                                    _doubleTapDetails = d,
                                                onDoubleTap: _handleDoubleTap,
                                                child: InteractiveViewer(
                                                    transformationController:
                                                        _transformationController,
                                                    maxScale: 10,
                                                    panEnabled: true,
                                                    scaleEnabled: true,
                                                    child: Container(
                                                        child: FadeInImage
                                                            .assetNetwork(
                                                      image: AppConstants
                                                              .imagesBaseUrl +
                                                          "/post_images/" +
                                                          pictures[index],
                                                      placeholder:
                                                          "assets/picture_placeholder.webp",
                                                      placeholderErrorBuilder:
                                                          (context, error,
                                                              stackTrace) {
                                                        return Image.asset(
                                                            "assets/picture_error.png",
                                                            fit: BoxFit.cover);
                                                      },
                                                      imageErrorBuilder:
                                                          (context, error,
                                                              stackTrace) {
                                                        return Image.asset(
                                                            "assets/picture_error.png",
                                                            fit: BoxFit.cover);
                                                      },
                                                      fit: BoxFit.cover,
                                                    ))))
                                            : Container())
                                    : Container());
                          }),
                    ),
                  ), /*Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                            width: double.infinity,
                            //height: MediaQuery.of(context).size.height,
                            child: (imagePath ?? "").isNotEmpty
                                ? GestureDetector(
                                    onDoubleTapDown: (d) =>
                                        _doubleTapDetails = d,
                                    onDoubleTap: _handleDoubleTap,
                                    child: InteractiveViewer(
                                      transformationController:
                                          _transformationController,
                                      maxScale: 10,
                                      panEnabled: true,
                                      scaleEnabled: true,
                                      child: Image.network(
                                        (imagePath ?? ""),
                                        fit: BoxFit.cover,
                                      ),
                                    ))
                                */ /*ExtendedImage.network(
                              AppConstants.imagesBaseUrl +
                                  "/post_images/" +
                                  (imagePath ?? ""),
                              fit: BoxFit.fitWidth,
                              mode: ExtendedImageMode.gesture,
                              initGestureConfigHandler: (state) {
                                return GestureConfig(
                                  minScale: 1,
                                  animationMinScale: 0.7,
                                  maxScale: 3.0,
                                  animationMaxScale: 3.5,
                                  speed: 1.0,
                                  inertialSpeed: 100.0,
                                  initialScale: 1.0,
                                  inPageView: false,
                                  initialAlignment: InitialAlignment.center,
                                );
                              },
                            )*/ /*
                                : Container()),
                      ),
                    ],
                  ),*/
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(8),
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    //color: AppColors.overlayButtonColor,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    "${activePosition + 1} of ${pictures.length}",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(8),
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    //color: AppColors.overlayButtonColor,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ]),
              /* Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.white,
                      size: 25,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails?.localPosition;
      // For a 3x zoom
      _transformationController.value = Matrix4.identity()
        ..translate(-position!.dx * 2, -position.dy * 2)
        ..scale(3.0);
      // Fox a 2x zoom
      // ..translate(-position.dx, -position.dy)
      // ..scale(2.0);
    }
  }
}
