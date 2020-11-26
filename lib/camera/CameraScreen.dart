import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera/model/content.dart';
import 'package:flutter_camera/model/result.dart';
import 'package:flutter_camera/ui/document.dart';
import 'package:flutter_camera/ui/processing.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'ConfirmationScreen.dart';


class CameraScreen extends StatefulWidget {
  final bool self;

  const CameraScreen({Key key, @required this.self}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  String imagePath;

  int flashMode;

  @override
  void initState() {
    super.initState();
    flashMode = 0;
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {

        setState(() {
            selectedCameraIdx = 0;
        });

        _initCameraController(cameras[selectedCameraIdx]).then((void v) {});

      } else {
        print("No cameras available");
      }

    }).catchError((err){
      print('Error: $err.code\nError Message: $err.message');
    });
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }

    controller = CameraController(cameraDescription, ResolutionPreset.ultraHigh, enableAudio: false);

    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      print(e.description);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Carregando',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    return Transform.scale(
      scale: controller.value.aspectRatio / deviceRatio,
      child: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: CameraPreview(controller),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SizedBox.expand(
            child: Container(
              child: _cameraPreviewWidget(),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 50, horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 120,
              padding: EdgeInsets.all(20.0),
              color: Color.fromRGBO(0, 0, 0, .3),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(width: 90.0,),
                      ButtonTheme(
                        height: 70,
                        child: RaisedButton(
                          shape: CircleBorder(
                              side: BorderSide(color: Colors.transparent)),
                          onPressed: _takeSnapshot,
                          color: Colors.white,
                          textColor: Colors.white,
                          elevation: 1,
                        ),
                      ),
                      SizedBox(width: 90.0,),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _takePicture() async {
    if (!controller.value.isInitialized) {
      return null;
    }

    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      final Directory extDir = await getTemporaryDirectory();
      final String dirPath = '${extDir.path}/Pitures';
      await new Directory(dirPath).create(recursive: true);
      final String path = '$dirPath/${DateTime.now()}.jpg';

      await controller.takePicture(path);

      return path;
    } on CameraException catch (e) {
      return null;
    }
  }

  _takeSnapshot() {
    _takePicture().then((String path) async {

      bool result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ConfirmationScreen(path)),
      );

      final picture = File(path);


      if(result){


        MaterialPageRoute loading = MaterialPageRoute(builder: (context) => Processing());

        Navigator.push(context, loading);

        String string = "";
        final bytes = picture.readAsBytesSync();
        string = base64.encode(bytes);
        //Navigator.pop(context, string);

        Content content = new Content(
          "CNH",
          "@file/jpeg",
          string
        );

        Response response = await post("http://zionapi.onset.com.br/api/sync/",
            body: jsonEncode(content.toJson()),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8'
            });

        Navigator.pop(context, loading);

        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Document(response.body)),
        );

      }

      picture.delete();
    });
  }
}
