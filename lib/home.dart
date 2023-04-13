import 'dart:html';
import 'package:camera/camera.dart';
import 'package:face_detection/utils_scanner.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:flutter/cupertino.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isWorking = false;
  CameraController? cameraController;
  FaceDetector? faceDetector;
  Size? size;
  List<Face>? faceList;
  CameraDescription? description;
  CameraLensDirection cameraDirection = CameraLensDirection.front;

  initCamera() async {
    description = await UtilsScanner.getCamera(cameraDirection);

    cameraController = CameraController(description!, ResolutionPreset.medium);

    faceDetector = FirebaseVision.instance.faceDetector(
        const FaceDetectorOptions(
            enableClassification: true,
            minFaceSize: 0.1,
            mode: FaceDetectorMode.fast));

    await cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      }

      cameraController!.startImageStream((imageFromStream) => {
            if (!isWorking)
              {
                isWorking = true,
              }
          });
    });
  }

  dynamic scanResults;

  performDetectionOnStreamFrames(CameraImage cameraImage) async {
    UtilsScanner.detect(
            image: cameraImage,
            detectInImage: faceDetector!.processImage,
            imageRotation: description!.sensorOrientation)
        .then((dynamic results) {
      setState(() {
        scanResults = results;
      });
    }).whenComplete(() {
      isWorking = false;
    });
  }

  @override
  void initState() {
    super.initState();

    initCamera();
  }

  @override
  void dispose() {
    super.dispose();

    cameraController?.dispose();
    faceDetector!.close();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
