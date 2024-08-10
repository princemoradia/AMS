import 'package:ams/Attendance.dart';
import 'package:ams/Profile.dart';
import 'package:ams/Report.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class AppBottomNav extends StatefulWidget {
  final CameraDescription camera;
  final token;
  const AppBottomNav({required this.camera, required this.token});
  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Attendance(camera: widget.camera,token: widget.token,),
      Cal(token: widget.token,),
      Profile(token: widget.token,camera: widget.camera,),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 80,
            child: _pages[_currentIndex],
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
                        Icons.check_circle,
                        size: 28,
                      ),
                      label: 'Attendance',
                    ),
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
                    // BottomNavigationBarItem(
                    //   icon: Icon(Icons.person),
                    //   label: 'Profile',
                    // ),
                    // // BottomNavigationBarItem(
                    //   icon: Icon(Icons.scanner),
                    //   label: 'Scan',
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
