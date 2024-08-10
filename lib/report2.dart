import 'package:ams/cal.dart';
import 'package:flutter/material.dart';

class Report2 extends StatefulWidget {
  final token;
  const Report2({required this.token});

  @override
  State<Report2> createState() => _Report2State();
}

class _Report2State extends State<Report2> {
  List subject = ["TOC", "DM", "JAVA", ".net", "Android"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(8.0),
                child: InkWell(
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Cal(subject: subject[index], token: widget.token,)));
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                        child: Text(
                      subject[index],
                      style: TextStyle(fontFamily: "GBook", fontSize: 20),
                    )),
                  ),
                ),
              );
            },
            itemCount: subject.length,
          ),
        ),
      ),
    );
  }
}
