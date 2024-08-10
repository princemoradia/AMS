import 'package:ams/Bottom.dart';
import 'package:ams/SplashScreen.dart';
import 'package:ams/registration.dart';
import 'package:ams/continue.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  runApp(MyApp(camera: firstCamera, token: token));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;
  final String? token;
  const MyApp({Key? key, required this.camera, required this.token})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.black),
      ),
      // home: token != null ? AppBottomNav(token: token,camera: camera) : Registration(camera: camera),
      // home: Registration(camera: camera),
      // home: Continue(camera: camera,),
      home: SplashScreen(camera: camera,token: token,),
    );
  }
}

























// class CameraScreen extends StatefulWidget {
//   final CameraDescription camera;

//   const CameraScreen({Key? key, required this.camera}) : super(key: key);

//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     CameraDescription frontCamera = widget.camera;
//     for (CameraDescription camera in await availableCameras()) {
//       if (camera.lensDirection == CameraLensDirection.front) {
//         frontCamera = camera;
//         break;
//       }
//     }

//     _controller = CameraController(
//       frontCamera,
//       ResolutionPreset.medium,
//     );

//     try {
//       await _controller.initialize();
//       setState(() {}); // Trigger a rebuild after initialization
//     } catch (e) {
//       print('Error initializing camera: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Live Attendance Detection')),
//       body: _controller.value.isInitialized
//           ? Center(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ClipOval(
                
//                 child: SizedBox(
//                   width: 400,
//                   height: 400,
//                   child: CameraPreview(_controller))),
//             ),
//           )
//           : Center(child: CircularProgressIndicator()),
//     );
//   }
// }



   