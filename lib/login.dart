import 'dart:convert';
import 'package:ams/AdminPage.dart';
import 'package:ams/Bottom.dart';
import 'package:ams/BottomStudent.dart';
import 'package:ams/config.dart';
// import 'package:ams/registration.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;

class SignInPage extends StatefulWidget {
  final CameraDescription camera;

  const SignInPage({Key? key, required this.camera}) : super(key: key);
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isNotValidate = false;
  bool _isLoading = false;
  late SharedPreferences prefs;
  bool _passwordVisible = false;
  String? selectedRole;
  String? selectedSubject;
  var roleItems = ["Student", "Faculty", "admin"];
  var subitems = ["TOC", "DM", "Android", "JAVA", ".net"];

  void togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void loginUser() async {
    if (emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        selectedRole != null) {
      setState(() {
        _isLoading = true;
      });
      var reqBody = {
        "email": emailController.text,
        "password": passwordController.text,
        "role": selectedRole,
      };
      if (selectedRole == "Faculty") {
        reqBody["subject"] = selectedSubject;
      }
      try {

        var endPoint = '';
        if (selectedRole == 'Student') {
          endPoint = slogin;
        } else {
          endPoint = login;
        }
        var response = await http.post(
          Uri.parse(endPoint),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody),
        );
        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status']) {
            var userType = jsonResponse['role'];
            if (userType != null) {
              if (userType == 'Student') {
                var myToken = jsonResponse['token'];
                prefs.setString('token', myToken);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AppBottom2(camera: widget.camera, token: myToken),
                  ),
                  (route) => false,
                );
              } else if (userType == 'Faculty') {
                var myToken = jsonResponse['token'];
                prefs.setString('token', myToken);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AppBottomNav(camera: widget.camera, token: myToken),
                  ),
                  (route) => false,
                );
              } else if (userType == 'admin') {
                var myToken = jsonResponse['token'];
                prefs.setString('token', myToken);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Admin(
                              token: myToken,
                              camera: widget.camera,
                            )),
                    (route) => false);
              } else {
                setState(() {
                  _isLoading = false;
                });
                SnackBar(
                    content: Text(
                  "Unknown user type: $userType",
                  style: TextStyle(fontFamily: "GBook", color: Colors.red),
                ));
              }
            } else {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'User type not provided in response.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              );
              print('User type not provided in response.');
            }
          } else {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Authentication failed: ${jsonResponse['message']}',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
            print('Authentication failed: ${jsonResponse['message']}');
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'User doest not exists',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
          print('HTTP Error: ${response.statusCode}');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
        print('Error: $e');
      }
    } else if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'All fields are requried',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    } else {
      setState(() {
        _isNotValidate = true;
      });
    }
  }

  // void _showResetPasswordBottomSheet() {
  //   TextEditingController resetEmailController = TextEditingController();
  //   TextEditingController resetPasswordController = TextEditingController();
  //   bool _passwordVisibleBottomSheet = false;

  //   void togglePasswordVisibilityBottomSheet() {
  //     setState(() {
  //       _passwordVisibleBottomSheet = !_passwordVisibleBottomSheet;
  //     });
  //   }

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return SingleChildScrollView(
  //             child: Padding(
  //               padding: EdgeInsets.only(
  //                 bottom: MediaQuery.of(context).viewInsets.bottom,
  //               ),
  //               child: Container(
  //                 padding: EdgeInsets.all(20),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.stretch,
  //                   children: [
  //                     Text(
  //                       'Reset Password',
  //                       style: TextStyle(
  //                         fontSize: 24,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                     SizedBox(height: 20),
  //                     TextField(
  //                       style: TextStyle(fontFamily: "GBook"),
  //                       controller: resetEmailController,
  //                       keyboardType: TextInputType.emailAddress,
  //                       decoration: InputDecoration(
  //                         labelText: 'Email',
  //                         hintText: 'Enter your email',
  //                         prefixIcon: Icon(Icons.email),
  //                         hintStyle: TextStyle(
  //                             fontFamily: "GBook", color: Colors.black),
  //                         labelStyle: TextStyle(fontFamily: "GBook"),
  //                       ),
  //                     ),
  //                     SizedBox(height: 20),
  //                     TextField(
  //                       style: TextStyle(fontFamily: "GBook"),
  //                       controller: resetPasswordController,
  //                       obscureText: !_passwordVisibleBottomSheet,
  //                       decoration: InputDecoration(
  //                         prefixIcon: Icon(Icons.password),
  //                         suffixIcon: IconButton(
  //                           icon: Icon(_passwordVisibleBottomSheet
  //                               ? Icons.visibility
  //                               : Icons.visibility_off),
  //                           onPressed: () {
  //                             setState(() {
  //                               _passwordVisibleBottomSheet =
  //                                   !_passwordVisibleBottomSheet;
  //                             });
  //                           },
  //                         ),
  //                         labelText: 'Reset Password',
  //                         hintText: 'Password',
  //                         hintStyle: TextStyle(
  //                             fontFamily: "GBook", color: Colors.black),
  //                         labelStyle: TextStyle(fontFamily: "GBook"),
  //                       ),
  //                     ),
  //                     SizedBox(height: 20),
  //                     Container(
  //                       width: 280,
  //                       height: 65,
  //                       decoration: BoxDecoration(
  //                         color: Colors.black,
  //                         borderRadius: BorderRadius.circular(20),
  //                       ),
  //                       child: TextButton(
  //                         onPressed: () {
  //                           sendResetPasswordRequest(resetEmailController.text,
  //                               resetPasswordController.text);
  //                         },
  //                         child: Text(
  //                           "Reset",
  //                           style: TextStyle(
  //                             color: Colors.white,
  //                             fontFamily: "GBook",
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // void sendResetPasswordRequest(String email, String password) async {
  //   if (email.isNotEmpty && password.isNotEmpty) {
  //     setState(() {
  //       _isLoading = true;
  //     });

  //     var reqBody = {
  //       "email": email,
  //       "password": password,
  //     };

  //     try {
  //       var response = await http.post(
  //         Uri.parse(resetPassword),
  //         headers: {"Content-Type": "application/json"},
  //         body: jsonEncode(reqBody),
  //       );

  //       if (response.statusCode == 200) {
  //         // Reset password request sent successfully
  //         var jsonResponse = jsonDecode(response.body);
  //         if (jsonResponse['status']) {
  //           // Password updated successfully
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text(
  //                 jsonResponse['success'],
  //                 style: TextStyle(color: Colors.green),
  //               ),
  //             ),
  //           );
  //           Navigator.pop(context);
  //         } else {
  //           // Handle error from backend
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text(
  //                 jsonResponse['error'],
  //                 style: TextStyle(color: Colors.red),
  //               ),
  //             ),
  //           );
  //         }
  //       } else {
  //         // Handle HTTP errors
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(
  //               'Failed to send reset password request',
  //               style: TextStyle(color: Colors.red),
  //             ),
  //           ),
  //         );
  //       }
  //     } catch (e) {
  //       // Handle other errors
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             'Error: $e',
  //             style: TextStyle(color: Colors.red),
  //           ),
  //         ),
  //       );
  //     } finally {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   } else if (email.isEmpty && password.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text(
  //         'All fields are required',
  //         style: TextStyle(color: Colors.red),
  //       ),
  //     ));
  //     Navigator.pop(context);
  //   } else {
  //     setState(() {
  //       _isNotValidate = true;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.yellow.shade100,
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/ams_login.png"),
                  // SizedBox(height: 10),
                  const Text(
                    "Login",
                    style: TextStyle(fontSize: 34, fontFamily: "GB"),
                  ),
                  SizedBox(height: 5),
                  DropdownButton<String>(
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text("Select role"),
                      ),
                      ...roleItems.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRole = newValue;
                        selectedSubject = null;
                      });
                    },
                    value: selectedRole,
                  ),
                  // SizedBox(height: 5),
                  // if (selectedRole == "Faculty")
                  //   DropdownButton<String>(
                  //     items: [
                  //       DropdownMenuItem<String>(
                  //         value: null,
                  //         child: Text("Select subject"),
                  //       ),
                  //       ...subitems.map((String item) {
                  //         return DropdownMenuItem<String>(
                  //           value: item,
                  //           child: Text(item),
                  //         );
                  //       }).toList(),
                  //     ],
                  //     onChanged: (String? newValue) {
                  //       setState(() {
                  //         selectedSubject = newValue;
                  //       });
                  //     },
                  //     value: selectedSubject,
                  //   ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontFamily: "GBook",
                        fontWeight: FontWeight.bold,
                      ),
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.email,
                          color: Colors.black,
                        ),
                        border: InputBorder.none,
                        hintText: "Enter email",
                        hintStyle: TextStyle(
                          fontFamily: "GBook",
                          fontWeight: FontWeight.bold,
                        ),
                        // errorText: _isNotValidate ? "Email required" : "",
                        errorStyle: TextStyle(fontFamily: "GBook"),
                      ),
                      cursorColor: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(245, 245, 245, 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      style: TextStyle(
                        fontFamily: "GBook",
                        fontWeight: FontWeight.bold,
                      ),
                      controller: passwordController,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.password,
                          color: Colors.black,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(_passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: togglePasswordVisibility,
                        ),
                        border: InputBorder.none,
                        hintText: "Enter password",
                        hintStyle: TextStyle(
                          fontFamily: "GBook",
                          fontWeight: FontWeight.bold,
                        ),
                        // errorText: _isNotValidate ? "Password required" : null,
                        errorStyle: TextStyle(fontFamily: "GBook"),
                      ),
                      cursorColor: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: 280,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _isLoading
                        ? JumpingDots(
                            color: Colors.grey,
                          )
                        : TextButton(
                            onPressed: () {
                              loginUser();
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "GBook",
                              ),
                            ),
                          ),
                  ),
                  // SizedBox(
                  //   height: 5,
                  // ),
                  // InkWell(
                  //     highlightColor: Colors.transparent,
                  //     focusColor: Colors.transparent,
                  //     splashColor: Colors.transparent,
                  //     onTap: () {
                  //       _showResetPasswordBottomSheet();
                  //     },
                  //     child: Text(
                  //       "Forgot password?",
                  //       style: TextStyle(fontFamily: "GBook"),
                  //     )),
                ],
              ),
            ),
          ),
        ),
        // bottomNavigationBar: GestureDetector(
        //   onTap: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => Registration(camera: widget.camera),
        //       ),
        //     );
        //   },
        //   child: Container(
        //     height: 30,
        //     color: Colors.black,
        //     child: Center(
        //       child: Text(
        //         "Create a new Account..! Sign Up",
        //         style: TextStyle(fontFamily: "GBook"),
        //       ).text.white.makeCentered(),
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
