import 'package:ams/Report.dart';
import 'package:ams/profile2.dart';
import 'package:ams/report2.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class AppBottom2 extends StatefulWidget {
  final CameraDescription camera;
  final token;

  const AppBottom2({required this.camera, required this.token});

  @override
  State<AppBottom2> createState() => _AppBottom2State();
}

class _AppBottom2State extends State<AppBottom2> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _getPage(_currentIndex),
          ),
          Positioned(
            bottom: 10,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 65,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                ),
                child: BottomNavigationBar(
                  backgroundColor: Colors.black,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.grey.shade700,
                  selectedLabelStyle: TextStyle(fontFamily: "GB"),
                  unselectedLabelStyle: TextStyle(fontFamily: "GBook"),
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.calendar_month,
                        size: 28,
                      ),
                      label: 'Report',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.person,
                        size: 28,
                      ),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return Report2(token: widget.token);
      case 1:
        return Profile2(token: widget.token, camera: widget.camera);
      default:
        return Container();
    }
  }
}
