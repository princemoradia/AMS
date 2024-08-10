// import 'package:ams/Bottom.dart';
// import 'package:ams/login.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';

// class Continue extends StatelessWidget {
//   final CameraDescription camera;
//   final token;
//   const Continue({Key? key, required this.camera, required this.token})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Lottie.asset("assets/lottie/lottie2.json"),
//             AnimatedTextKit(
//               animatedTexts: [
//                 TyperAnimatedText('Unlock attendance with just a glance',
//                     textStyle: TextStyle(fontFamily: "GB", fontSize: 16),
//                     speed: Duration(milliseconds: 100)),
//               ],
//               totalRepeatCount: 1,
//             ),
//             SizedBox(height: 80),
//             Container(
//               width: 280,
//               height: 65,
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: TextButton(
//                 onPressed: () {
//                   token != null
//                       ? Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => AppBottomNav(
//                                   camera: camera, token: this.token)))
//                       : Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) =>
//                                   SignInPage(camera: camera)));
//                 },
//                 child: Text(
//                   "Continue",
//                   style: TextStyle(color: Colors.white, fontFamily: "GBook"),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:ams/AdminPage.dart';
import 'package:ams/Bottom.dart';
import 'package:ams/BottomStudent.dart';
import 'package:ams/login.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lottie/lottie.dart';

class Continue extends StatelessWidget {
  final CameraDescription camera;
  final token;
  const Continue({Key? key, required this.camera, required this.token})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("assets/lottie/lottie2.json"),
            AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText('Unlock attendance with just a glance',
                    textStyle: TextStyle(fontFamily: "GB", fontSize: 16),
                    speed: Duration(milliseconds: 100)),
              ],
              totalRepeatCount: 1,
            ),
            SizedBox(height: 80),
            Container(
              width: 280,
              height: 65,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton(
                onPressed: () async {
                  if (token != null) {
                    
                    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
                    String? role = decodedToken['role'];

                    if (role == 'Student') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppBottom2(camera: camera, token: token),
                        ),
                      );
                    } else if(role == 'admin'){
                       Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Admin(token: token,camera: camera,),
                        ),
                      );
                    }
                    else if (role == 'Faculty') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppBottomNav(camera: camera, token: token),
                        ),
                      );
                    }
                  } else {
                    
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignInPage(camera: camera),
                      ),
                    );
                  }
                },
                child: Text(
                  "Continue",
                  style: TextStyle(color: Colors.white, fontFamily: "GBook"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
