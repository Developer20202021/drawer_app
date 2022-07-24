import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

late List _cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraController _controller;

  @override
  void initState() {
    _controller = CameraController(_cameras[0], ResolutionPreset.max);

    _controller.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((e) {});

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var image;
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Container(
              width: 400,
              height: 500,
              child:  _controller == null?
                          Center(child:Text("Loading Camera...")):
                                !_controller!.value.isInitialized?
                                  Center(
                                    child: CircularProgressIndicator(),
                                  ):
                                  CameraPreview(_controller!),
            ),
                     ElevatedButton.icon( //image capture button
                    onPressed: () async{
                        try {
                          if(_controller != null){ //check if contrller is not null
                              if(_controller!.value.isInitialized){ //check if controller is initialized
                                  image = await _controller!.takePicture(); //capture image
                                  setState(() {
                                    //update UI
                                  });
                              }
                          }
                        } catch (e) {
                            print(e); //show error
                        }
                    },
                    icon: Icon(Icons.camera),
                    label: Text("Capture"),
                  ),

                  Container( //show captured image
                     padding: EdgeInsets.all(30),
                     child: image == null?
                           Text("No image captured"):
                           Image.file(File(image!.path), height: 300,), 
                           //display captured image
                  )
          ],
        ),
      ),
    );
  }
}
