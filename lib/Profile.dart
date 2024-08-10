import 'dart:convert';

import 'package:ams/cal.dart';
import 'package:ams/config.dart';
import 'package:ams/login.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  final CameraDescription camera;

  final token;
  const Profile({super.key, required this.token, required this.camera});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final qactions = const QuickActions();

  bool _isNotValidate = false;
  bool _isLoading = false;
  late SharedPreferences prefs;
  bool _passwordVisible = false;

  late String userId;
  late String email;
  late String name;
  late String role;
  late String subject;
  List? user;
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    print(jwtDecodedToken);
    userId = jwtDecodedToken['_id'];
    name = jwtDecodedToken['name'];
    email = jwtDecodedToken['email'];
    role = jwtDecodedToken['role'];
    subject = jwtDecodedToken['subject'];
  }

  Future<void> clearData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
    prefs.remove('email');
    prefs.remove('name');
    prefs.remove('role');
    prefs.remove('subject');
    prefs.remove('token');
  }

  void sendResetPasswordRequest(String email, String password) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      var reqBody = {
        "email": email,
        "password": password,
      };

      try {
        var response = await http.post(
          Uri.parse(resetPassword),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody),
        );

        if (response.statusCode == 200) {
          // Reset password request sent successfully
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status']) {
            // Password updated successfully
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  jsonResponse['success'],
                  style: TextStyle(color: Colors.green),
                ),
              ),
            );
            Navigator.pop(context);
          } else {
            // Handle error from backend
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  jsonResponse['error'],
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
          }
        } else {
          // Handle HTTP errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to send reset password request',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }
      } catch (e) {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (email.isEmpty && password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'All fields are required',
          style: TextStyle(color: Colors.red),
        ),
      ));
      Navigator.pop(context);
    } else {
      setState(() {
        _isNotValidate = true;
      });
    }
  }

  void _showResetPasswordBottomSheet() {
    TextEditingController resetEmailController = TextEditingController();
    TextEditingController resetPasswordController = TextEditingController();
    bool _passwordVisibleBottomSheet = false;

    void togglePasswordVisibilityBottomSheet() {
      setState(() {
        _passwordVisibleBottomSheet = !_passwordVisibleBottomSheet;
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        style: TextStyle(fontFamily: "GBook"),
                        controller: resetEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: Icon(Icons.email),
                          hintStyle: TextStyle(
                              fontFamily: "GBook", color: Colors.black),
                          labelStyle: TextStyle(fontFamily: "GBook"),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        style: TextStyle(fontFamily: "GBook"),
                        controller: resetPasswordController,
                        obscureText: !_passwordVisibleBottomSheet,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.password),
                          suffixIcon: IconButton(
                            icon: Icon(_passwordVisibleBottomSheet
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _passwordVisibleBottomSheet =
                                    !_passwordVisibleBottomSheet;
                              });
                            },
                          ),
                          labelText: 'Reset Password',
                          hintText: 'Password',
                          hintStyle: TextStyle(
                              fontFamily: "GBook", color: Colors.black),
                          labelStyle: TextStyle(fontFamily: "GBook"),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: 280,
                        height: 65,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextButton(
                          onPressed: () {
                            sendResetPasswordRequest(resetEmailController.text,
                                resetPasswordController.text);
                          },
                          child: Text(
                            "Reset",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "GBook",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(fontFamily: "GB", fontSize: 28),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                CircleAvatar(
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                  radius: 50,
                  backgroundColor: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Welcome, ${name}",
                    style: const TextStyle(fontSize: 26, fontFamily: "GB"),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                    width: MediaQuery.of(context).size.width / 0.2,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.yellow.shade100,
                    ),
                    child: Center(
                        child: Text(
                      "Email: ${email}",
                      style: TextStyle(fontFamily: "GB", fontSize: 20),
                    ))),
                SizedBox(
                  height: 15,
                ),
                Container(
                    width: MediaQuery.of(context).size.width / 0.2,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.yellow.shade100,
                    ),
                    child: Center(
                        child: Text(
                      "Role: ${role}",
                      style: TextStyle(fontFamily: "GB", fontSize: 20),
                    ))),
                SizedBox(
                  height: 15,
                ),
                Container(
                    width: MediaQuery.of(context).size.width / 0.2,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.yellow.shade100,
                    ),
                    child: Center(
                        child: Text(
                      "Subejct: ${subject}",
                      style: TextStyle(fontFamily: "GB", fontSize: 20),
                    ))),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  width: 280,
                  height: 65,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black),
                  child: TextButton(
                    onPressed: () async {
                      await clearData();

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignInPage(
                                    camera: widget.camera,
                                  )));
                    },
                    child: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.white, fontFamily: "GBook"),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                InkWell(
                    highlightColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      _showResetPasswordBottomSheet();
                    },
                    child: Text(
                      "Forgot password?",
                      style: TextStyle(fontFamily: "GBook"),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
