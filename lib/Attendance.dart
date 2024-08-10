import 'dart:async';
import 'dart:typed_data';
import 'package:ams/config.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Attendance extends StatefulWidget {
  final CameraDescription camera;
  final token;
  const Attendance({Key? key, required this.camera, required this.token})
      : super(key: key);

  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  bool _isSendingImage = false;

  late String userId;
  late String email;
  late String name;
  late String role;
  late String subject;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    print(jwtDecodedToken);
    userId = jwtDecodedToken['_id'];
    name = jwtDecodedToken['name'];
    email = jwtDecodedToken['email'];
    role = jwtDecodedToken['role'];
    subject = jwtDecodedToken['subject'];
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw 'No cameras found';
      }
      CameraDescription frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
      );
      await _controller.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
      if (_isCameraInitialized) {
        _startSendingImages();
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _startSendingImages() {
    _captureAndSendImage();
  }

  Future<void> _captureAndSendImage() async {
    try {
      _isSendingImage = true;
      XFile? imageFile = await _controller.takePicture();
      if (imageFile != null) {
        Uint8List bytes = await imageFile.readAsBytes();
        await _sendImageToAPI(bytes);
      } else {
        print('Failed to capture image');
        _isSendingImage = false;
      }
    } catch (e) {
      print('Error capturing image: $e');
      _isSendingImage = false;
    }
  }

  Future<void> _sendImageToAPI(Uint8List bytes) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.74.115:5000/face_recognition'),
      );
      var imageFile = http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: 'image.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(imageFile);

      var response = await request.send();
      if (response.statusCode == 200) {
        print('Image sent to API successfully');
        var jsonResponse = await http.Response.fromStream(response);
        var decodedResponse = json.decode(jsonResponse.body);

        print('Result: ${decodedResponse['result']}');
        print('Status: ${decodedResponse['status']}');

        if (decodedResponse['status'] == 'success') {
          print("Success");
          _showSuccessDialog(decodedResponse['result']);
        } else if (decodedResponse['status'] == 'unknown') {
          _showUnknownDialog();
          print("Unknown");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Unexpected status received: ${decodedResponse['status']}',
                style: TextStyle(color: Colors.red),
              ),
              action: SnackBarAction(
                  label: 'retry',
                  onPressed: () {
                    _captureAndSendImage();
                  }),
            ),
          );
          print('Unexpected status received: ${decodedResponse['status']}');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send image to API. Status code: ${response.statusCode}',
              style: TextStyle(color: Colors.red),
            ),
            action: SnackBarAction(
                  label: 'retry',
                  onPressed: () {
                    _captureAndSendImage();
                  }),
          ),
        );
        print(
            'Failed to send image to API. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error sending image to API: $e',
            style: TextStyle(color: Colors.red),
          ),
          action: SnackBarAction(
                  label: 'retry',
                  onPressed: () {
                    _captureAndSendImage();
                  }),
        ),
      );
      print('Error sending image to API: $e');
    } finally {
      _isSendingImage = false;
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            _captureAndSendImage();
            return true;
          },
          child: AlertDialog(
            title: Text('Mark Attendance'),
            content: Text(
              'Name: ${result['identity']}\nDistance: ${result['distance']}',
              style: TextStyle(fontFamily: "GBook"),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _markAttendanceAsPresent(result['identity']);
                },
                child: const Text('Mark as Present'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _captureAndSendImage();
                },
                child: const Text("Retake"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUnknownDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            _captureAndSendImage();
            return true;
          },
          child: AlertDialog(
            title: const Text('Unknown Person'),
            content: const Text(
              'Retry capturing image',
              style: TextStyle(fontFamily: "GBook"),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Retry capturing image
                  Navigator.of(context).pop();
                  _captureAndSendImage();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Attendance",
          style: TextStyle(fontFamily: "GB", fontSize: 28),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: _isCameraInitialized
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CameraPreview(_controller),
              ),
            )
          : Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            ),
    );
  }

  void _markAttendanceAsPresent(String detectedName) async {
    _captureAndSendImage();

    try {
      final url = Uri.parse(takeAttendance);
      final response = await http.post(
        url,
        body: {
          'studentName': detectedName,
          'facultyId': userId,
          'subject': subject,
          'status': 'present',
        },
      );

      if (response.statusCode == 200) {
        print('Attendance marked as present successfully');
        var jsonResponse = json.decode(response.body);
        print('Response: $jsonResponse');
      } else {
        print(
            'Failed to mark attendance as present. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking attendance as present: $e');
    }
  }
}








  // void _startSendingImages() {
  //   Timer.periodic(Duration(seconds: 2), (timer) {
  //     if (!_isSendingImage) {
  //       _captureAndSendImage();
  //     }
  //   });
  // }

  // Future<void> _captureAndSendImage() async {
  //   try {
  //     _isSendingImage = true;
  //     XFile? imageFile = await _controller.takePicture();
  //     if (imageFile != null) {
  //       Uint8List bytes = await imageFile.readAsBytes();
  //       await _sendImageToAPI(bytes);
  //     } else {
  //       print('Failed to capture image');
  //       _isSendingImage = false;
  //     }
  //   } catch (e) {
  //     print('Error capturing image: $e');
  //     _isSendingImage = false;
  //   }
  // }

  // Future<void> _sendImageToAPI(Uint8List bytes) async {
  //   try {
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('http://192.168.214.45:5000/face_recognition'),
  //     );
  //     var imageFile = http.MultipartFile.fromBytes(
  //       'image',
  //       bytes,
  //       filename: 'image.jpg',
  //       contentType: MediaType('image', 'jpeg'),
  //     );
  //     request.files.add(imageFile);

  //     var response = await request.send();
  //     if (response.statusCode == 200) {
  //       print('Image sent to API successfully');
  //       var jsonResponse = await http.Response.fromStream(response);
  //       var decodedResponse = json.decode(jsonResponse.body);

  //       print('Result: ${decodedResponse['result']}');
  //       print('Status: ${decodedResponse['status']}');

  //       if (decodedResponse['status'] == 'success') {
  //         print("Success");
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(
  //               'Status: ${decodedResponse['status']} Name: ${decodedResponse['result']['identity']} Distance: ${decodedResponse['result']['distance']}',
  //               style: TextStyle(fontFamily: "GBook"),
  //             ),
  //             duration: Duration(seconds: 5),
  //             backgroundColor: Colors.green,
  //           ),
  //         );
  //       } else if (decodedResponse['status'] == 'unknown') {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(
  //               'Status: ${decodedResponse['status']}',
  //               style: TextStyle(fontFamily: "GBook"),
  //             ),
  //             duration: Duration(seconds: 5),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //         print("Unknown");
  //       } else {
  //         print('Unexpected status received: ${decodedResponse['status']}');
  //       }
  //     } else {
  //       print(
  //           'Failed to send image to API. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error sending image to API: $e');
  //   } finally {
  //     _isSendingImage = false;
  //   }
  // }

