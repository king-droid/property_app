import 'package:flutter/material.dart';
import 'package:property_feeds/constants/appColors.dart';

class PreviewPictureScreen extends StatefulWidget {
  PreviewPictureScreen();

  @override
  _PreviewPictureScreenState createState() => _PreviewPictureScreenState();
}

class _PreviewPictureScreenState extends State<PreviewPictureScreen> {
  String? imagePath = "";
  late TransformationController controller;
  late TapDownDetails tabDownDetails;
  final _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;

  _PreviewPictureScreenState();

  @override
  void initState() {
    controller = TransformationController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    imagePath = ((ModalRoute.of(context)?.settings.arguments) as String) ?? "";
    return Scaffold(
      /* appBar: AppBar(
        leading: const BackButton(color: AppColors.white),
        backgroundColor: Colors.black87,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),*/
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: Colors.black54,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                        width: double.infinity,
                        //height: MediaQuery.of(context).size.height,
                        child: (imagePath ?? "").isNotEmpty
                            ? GestureDetector(
                                onDoubleTapDown: (d) => _doubleTapDetails = d,
                                onDoubleTap: _handleDoubleTap,
                                child: InteractiveViewer(
                                  transformationController:
                                      _transformationController,
                                  maxScale: 10,
                                  panEnabled: true,
                                  scaleEnabled: true,
                                  child: Image.network(
                                    (imagePath ?? ""),
                                    fit: BoxFit.contain,
                                  ),
                                ))
                            /*ExtendedImage.network(
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
                        )*/
                            : Container()),
                  ),
                ],
              ),
            ),
            Align(
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
            ),
          ],
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
