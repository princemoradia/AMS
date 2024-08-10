

// import 'dart:convert';
// import 'dart:math';
// import 'package:ams/config.dart';
// import 'package:ams/login.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:jumping_dot/jumping_dot.dart';
// import 'package:http/http.dart' as http;

// class Registration extends StatefulWidget {
//   final CameraDescription camera;

//   const Registration({Key? key, required this.camera}) : super(key: key);
//   @override
//   _RegistrationState createState() => _RegistrationState();
// }

// class _RegistrationState extends State<Registration> {
//   String? selectedSubject;
//   String? selectedRole;
//   String? selectedYear;
//   var roleItems = ["Student", "Faculty"];
//   var subitems = ["TOC", "DM", "Android", "JAVA", ".net"];
//   var yearItems = ["1st Year", "2nd Year", "3rd Year", "4th Year"];

//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   TextEditingController nameController = TextEditingController();
//   bool _isNotValidate = false;
//   bool _isLoading = false;
//   bool _passwordVisible = false;

//   void togglePasswordVisibility() {
//     setState(() {
//       _passwordVisible = !_passwordVisible;
//     });
//   }

//   void registerUser() async {
//     if (emailController.text.isNotEmpty &&
//         passwordController.text.isNotEmpty &&
//         nameController.text.isNotEmpty &&
//         selectedRole != null) {
//       setState(() {
//         _isLoading = true;
//       });

//       var regBody = {
//         "email": emailController.text,
//         "password": passwordController.text,
//         "name": nameController.text,
//         "role": selectedRole,
//         if (selectedRole == "Student") "year": selectedYear,
//         if (selectedRole == "Faculty") "subject": selectedSubject,
//       };

//       try {
//         var response = await http.post(
//           Uri.parse(registration),
//           headers: {"Content-Type": "application/json"},
//           body: jsonEncode(regBody),
//         );

//         if (response.statusCode == 200) {
//           var jsonResponse = jsonDecode(response.body);
//           if (jsonResponse['status']) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => SignInPage(camera: widget.camera),
//               ),
//             );
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//               content: Text(jsonResponse['error'],style: TextStyle(color: Colors.red),),
              
//             ));
//           }
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Failed to register.',style: TextStyle(color: Colors.red),),
              
//             ),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: $e',style: TextStyle(color: Colors.red),),

//           ),
//         );
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } else if(nameController.text.isEmpty ||
//       emailController.text.isEmpty ||
//       passwordController.text.isEmpty || selectedRole == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('All fields are required',style: TextStyle(color: Colors.red),),
//       ),
//     );
//     return;
//   }

//     else {
//       setState(() {
//         _isNotValidate = true;
//       });
//     }
//   }



//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.brown.shade100,
//         body: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: SingleChildScrollView(
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset("assets/images/ams_register.png"),
//                   // SizedBox(height: 10),
//                   const Text(
//                     "Manage Users",
//                     style: TextStyle(fontSize: 34, fontFamily: "GB"),
//                   ),
//                   SizedBox(height: 10),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: TextField(
//                       keyboardType: TextInputType.emailAddress,
//                       style: TextStyle(
//                           fontFamily: "GBook", fontWeight: FontWeight.bold),
//                       controller: nameController,
//                       decoration: InputDecoration(
//                         prefixIcon: Icon(Icons.person),
//                         border: InputBorder.none,
//                         hintText: "Enter name",
//                         hintStyle: TextStyle(
//                             fontFamily: "GBook", fontWeight: FontWeight.bold),
//                         errorText: _isNotValidate ? "Name is required" : null,
//                       ),
//                       cursorColor: Colors.black,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: TextField(
//                       keyboardType: TextInputType.emailAddress,
//                       style: TextStyle(
//                           fontFamily: "GBook", fontWeight: FontWeight.bold),
//                       controller: emailController,
//                       decoration: InputDecoration(
//                         prefixIcon: Icon(Icons.email),
//                         border: InputBorder.none,
//                         hintText: "Enter email",
//                         hintStyle: TextStyle(
//                             fontFamily: "GBook", fontWeight: FontWeight.bold),
//                         errorText: _isNotValidate ? "Email is required" : null,
//                       ),
//                       cursorColor: Colors.black,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: TextField(
//                       style: TextStyle(
//                           fontFamily: "GBook", fontWeight: FontWeight.bold),
//                       controller: passwordController,
//                       obscureText: !_passwordVisible,
//                       decoration: InputDecoration(
//                         prefixIcon: Icon(Icons.password),
//                         suffixIcon: IconButton(
//                           icon: Icon(_passwordVisible
//                               ? Icons.visibility
//                               : Icons.visibility_off),
//                           onPressed: togglePasswordVisibility,
//                         ),
//                         border: InputBorder.none,
//                         hintText: "Enter password",
//                         hintStyle: TextStyle(
//                             fontFamily: "GBook", fontWeight: FontWeight.bold),
//                         errorText:
//                             _isNotValidate ? "Password is required" : null,
//                       ),
//                       cursorColor: Colors.black,
//                     ),
//                   ),
//                   SizedBox(
//                     height: 5,
//                   ),
//                   DropdownButton<String>(
//                     items: [
//                       DropdownMenuItem<String>(
//                         value: null,
//                         child: Text("Select role"),
//                       ),
//                       ...roleItems.map((String item) {
//                         return DropdownMenuItem<String>(
//                           value: item,
//                           child: Text(item),
//                         );
//                       }).toList(),
//                     ],
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         selectedRole = newValue;
//                         // Reset selected subject
//                         selectedSubject = null;
//                       });
//                     },
//                     value: selectedRole,
//                   ),
//                   SizedBox(height:5),
//                   if (selectedRole == "Faculty") ...[
//                     SizedBox(height: 5),
//                     DropdownButton<String>(
//                       items: [
//                         DropdownMenuItem<String>(
//                           value: null,
//                           child: Text("Select subject"),
//                         ),
//                         ...subitems.map((String item) {
//                           return DropdownMenuItem<String>(
//                             value: item,
//                             child: Text(item),
//                           );
//                         }).toList(),
//                       ],
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           selectedSubject = newValue;
//                         });
//                       },
//                       value: selectedSubject,
//                     ),
//                   ],
//                   SizedBox(height: 14),
//                   Container(
//                     width: 280,
//                     height: 65,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       color: Colors.black,
//                     ),
//                     child: _isLoading
//                         ? Center(
//                             child: JumpingDots(
//                               color: Colors.grey,
//                             ),
//                           )
//                         : TextButton(
//                             onPressed: () {
//                               registerUser();
//                             },
//                             child: Text(
//                               "Register",
//                               style: TextStyle(
//                                   fontFamily: "GBook", color: Colors.white),
//                             ),
//                           ),
//                   ),
//                   SizedBox(height: 10),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pushAndRemoveUntil(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => SignInPage(
//                                     camera: widget.camera,
//                                   )),
//                           (route) => false);
//                     },
//                     child: Text(
//                       "Already Registered? Log In",
//                       style: TextStyle(fontFamily: "GBook"),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// String generatePassword() {
//   String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
//   String lower = 'abcdefghijklmnopqrstuvwxyz';
//   String numbers = '1234567890';
//   String symbols = '!@#\$%^&*()<>,./';

//   String password = '';

//   int passLength = 20;

//   String seed = upper + lower + numbers + symbols;

//   List<String> list = seed.split('').toList();

//   Random rand = Random();

//   for (int i = 0; i < passLength; i++) {
//     int index = rand.nextInt(list.length);
//     password += list[index];
//   }
//   return password;
// }
