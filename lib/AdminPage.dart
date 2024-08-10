import 'dart:convert';
import 'dart:math';

import 'package:ams/config.dart';
import 'package:ams/login.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Admin extends StatefulWidget {
  final CameraDescription camera;
  final token;
  Admin({required this.token, required this.camera});
  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  late String userId;
  late String email;
  late String name;
  late String role;

  String? selectedSubject;
  String? selectedRole;
  String? selectedYear;
  var roleItems = ["Student", "Faculty"];
  var subitems = ["TOC", "DM", "Android", "JAVA", ".net"];
  var yearItems = ["1st Year", "2nd Year", "3rd Year", "4th Year"];

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool _isNotValidate = false;
  bool _isLoading = false;
  bool _passwordVisible = false;

  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
    name = jwtDecodedToken['name'];
    email = jwtDecodedToken['email'];
    role = jwtDecodedToken['role'];
    print(jwtDecodedToken);
  }

  Future<void> clearData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
    prefs.remove('email');
    prefs.remove('name');
    prefs.remove('role');
    prefs.remove('token');
  }

  void togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  void registerUser() async {
    if (emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        selectedRole != null) {
      setState(() {
        _isLoading = true;
      });

      var regBody = {
        "email": emailController.text,
        "password": passwordController.text,
        "name": nameController.text,
        "role": selectedRole,
        if (selectedRole == "Student") "year": selectedYear,
        if (selectedRole == "Faculty") "subject": selectedSubject,
      };

      try {
        var endPoint = '';
        if (selectedRole == 'Student') {
          endPoint = sregister;
        } else {
          endPoint = registration;
        }
        var response = await http.post(
          Uri.parse(endPoint),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody),
        );

        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status']) {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => SignInPage(camera: widget.camera),
            //   ),
            // );
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
              "Registered Sucessfully",
              style: TextStyle(color: Colors.green),
            )));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                jsonResponse['error'],
                style: TextStyle(color: Colors.red),
              ),
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to register.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }
      } catch (e) {
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
    } else if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'All fields are required',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
      return;
    } else {
      setState(() {
        _isNotValidate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.brown.shade50,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              clearData();
                              print("logging out");

                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignInPage(
                                            camera: widget.camera,
                                          )));
                            },
                            child: Icon(
                              Icons.logout,
                              size: 30,
                            ))),
                  ),
                  Text(
                    "Welcome, ${name}",
                    style: TextStyle(
                        fontFamily: "GB", color: Colors.blue, fontSize: 20),
                  ),
                  Image.asset("assets/images/ams_register.png"),
                  // SizedBox(height: 10),
                  const Text(
                    "Manage Users",
                    style: TextStyle(fontSize: 34, fontFamily: "GB"),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                          fontFamily: "GBook", fontWeight: FontWeight.bold),
                      controller: nameController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        border: InputBorder.none,
                        hintText: "Enter name",
                        hintStyle: TextStyle(
                            fontFamily: "GBook", fontWeight: FontWeight.bold),
                        errorText: _isNotValidate ? "Name is required" : null,
                      ),
                      cursorColor: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                          fontFamily: "GBook", fontWeight: FontWeight.bold),
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        border: InputBorder.none,
                        hintText: "Enter email",
                        hintStyle: TextStyle(
                            fontFamily: "GBook", fontWeight: FontWeight.bold),
                        errorText: _isNotValidate ? "Email is required" : null,
                      ),
                      cursorColor: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      style: TextStyle(
                          fontFamily: "GBook", fontWeight: FontWeight.bold),
                      controller: passwordController,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.password),
                        suffixIcon: IconButton(
                          icon: Icon(_passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: togglePasswordVisibility,
                        ),
                        border: InputBorder.none,
                        hintText: "Enter password",
                        hintStyle: TextStyle(
                            fontFamily: "GBook", fontWeight: FontWeight.bold),
                        errorText:
                            _isNotValidate ? "Password is required" : null,
                      ),
                      cursorColor: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
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
                        // Reset selected subject
                        selectedSubject = null;
                      });
                    },
                    value: selectedRole,
                  ),
                  SizedBox(height: 5),
                  if (selectedRole == "Faculty") ...[
                    SizedBox(height: 5),
                    DropdownButton<String>(
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text("Select subject"),
                        ),
                        ...subitems.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSubject = newValue;
                        });
                      },
                      value: selectedSubject,
                    ),
                  ],
                  SizedBox(height: 14),
                  Container(
                    width: 280,
                    height: 65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black,
                    ),
                    child: _isLoading
                        ? Center(
                            child: JumpingDots(
                              color: Colors.grey,
                            ),
                          )
                        : TextButton(
                            onPressed: () {
                              registerUser();
                            },
                            child: Text(
                              "Register",
                              style: TextStyle(
                                  fontFamily: "GBook", color: Colors.white),
                            ),
                          ),
                  ),
                  SizedBox(height: 10),
                  // GestureDetector(
                  //   onTap: () {
                  //     Navigator.pushAndRemoveUntil(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => SignInPage(
                  //                   camera: widget.camera,
                  //                 )),
                  //         (route) => false);
                  //   },
                  //   child: Text(
                  //     "Already Registered? Log In",
                  //     style: TextStyle(fontFamily: "GBook"),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String generatePassword() {
  String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  String lower = 'abcdefghijklmnopqrstuvwxyz';
  String numbers = '1234567890';
  String symbols = '!@#\$%^&*()<>,./';

  String password = '';

  int passLength = 20;

  String seed = upper + lower + numbers + symbols;

  List<String> list = seed.split('').toList();

  Random rand = Random();

  for (int i = 0; i < passLength; i++) {
    int index = rand.nextInt(list.length);
    password += list[index];
  }
  return password;
}
