import 'dart:async';
import 'package:ams/continue.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  final CameraDescription camera;
  final token;
  SplashScreen({super.key, required this.camera, required this.token});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 6000), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Continue(
                    camera: widget.camera,
                    token: widget.token
                  )));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset("assets/lottie/lottie4.json"),
        ],
      ),
    )));
  }
}
