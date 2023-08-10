import 'dart:io';

import 'package:flutter/material.dart';

class PreviewLocalImageScreen extends StatefulWidget {
  PreviewLocalImageScreen();

  @override
  _PreviewLocalImageScreenState createState() =>
      _PreviewLocalImageScreenState();
}

class _PreviewLocalImageScreenState extends State<PreviewLocalImageScreen> {
  String? imagePath = "";
  late TransformationController controller;
  late TapDownDetails tabDownDetails;

  _PreviewLocalImageScreenState();

  @override
  void initState() {
    controller = TransformationController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    imagePath = ((ModalRoute
        .of(context)
        ?.settings
        .arguments) as String) ?? "";
    return Scaffold(
      body: Container(
        color: Colors.black87,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: MediaQuery
                    .of(context)
                    .size
                    .height,
                child: (imagePath ?? "").isNotEmpty
                    ? GestureDetector(
                    onDoubleTapDown: (details) {
                      tabDownDetails = details;
                    },
                    onDoubleTap: () {
                      final positions = tabDownDetails.localPosition;
                      const double scale = 5;
                      final x = (positions.dx)! * (scale - 1);
                      final y = (positions.dy)! * (scale - 1);
                      final zooomed = Matrix4.identity()
                        ..translate(x, y)
                        ..scale(scale);
                      final value = controller.value.isIdentity()
                          ? zooomed
                          : Matrix4.identity();
                      controller.value = value;
                    },
                    child: InteractiveViewer(
                      clipBehavior: Clip.none,
                      transformationController: controller,
                      maxScale: 10,
                      panEnabled: true,
                      child: Image.file(
                        File(imagePath ?? ""),
                      ),
                    ))
                /*ExtendedImage.file(
                        File(imagePath ?? ""),
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
          ],
        ),
      ),
    );
  }
}
