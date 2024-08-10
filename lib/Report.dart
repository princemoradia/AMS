import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:ams/config.dart';
import 'package:intl/intl.dart' as intl;
import 'package:open_file/open_file.dart';

class Cal extends StatefulWidget {
  final token;
  const Cal({@required this.token, Key? key}) : super(key: key);

  @override
  State<Cal> createState() => _CalState();
}

class _CalState extends State<Cal> {
  late String userId;
  late CalendarController _calendarController;
  List<Map<String, dynamic>>? items;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
    _fetchAttendanceData();
    _calendarController = CalendarController();
  }

  void _fetchAttendanceData() async {
    try {
      final response = await http.get(
        Uri.parse('$showAttendance?facultyId=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final attendanceData = data['data']['data'];
          if (attendanceData is List) {
            setState(() {
              items = List<Map<String, dynamic>>.from(attendanceData);
            });
          } else {
            print('Invalid attendance data format: $attendanceData');
          }
        } else {
          print('Failed to fetch attendance data: ${data['error']}');
        }
      } else {
        print(
            'Failed to fetch attendance data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching attendance data: $error');
    }
  }




  Future<void> _generateCSVWithDateRange(DateTime startDate, DateTime endDate) async {
    try {
      if (items == null) {
        print('No data to download.');
        return;
      }
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
        status = await Permission.storage.status;
        if (!status.isGranted) {
          print('Permission to access storage denied.');
          return;
        }
      }

      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        print('Error: External storage directory is null.');
        return;
      }

      final filePath = '${directory.path}/attendance_report.csv';
      File file = File(filePath);

      Map<String, List<String>> studentNamesByDate = {};

      items!.forEach((item) {
        DateTime createdAt = DateTime.parse(item['createdAt']);
        if (createdAt.isAfter(startDate) && createdAt.isBefore(endDate) || createdAt.isAtSameMomentAs(startDate) || createdAt.isAtSameMomentAs(endDate)) {
          String date = intl.DateFormat('dd-MM-yyyy').format(createdAt);
          String studentName = item['studentName'];
          studentNamesByDate.putIfAbsent(date, () => []);
          studentNamesByDate[date]!.add(studentName);
        }
      });

      Map<String, int> studentPresenceCount = {};
      int totalDays = endDate.difference(startDate).inDays + 1;
      int serialNo = 1;

      studentNamesByDate.forEach((date, studentNames) {
        studentNames.forEach((studentName) {
          studentPresenceCount[studentName] = (studentPresenceCount[studentName] ?? 0) + 1;
        });
      });

      List<List<dynamic>> csvData = [];
      csvData.add(['Sr. No','Date', 'Student Name', 'Percentage Present']);
      studentPresenceCount.forEach((studentName, presenceCount) {
        double presencePercentage = (presenceCount / totalDays) * 100;
        csvData.add([serialNo++,'${intl.DateFormat('dd-MM-yyyy').format(startDate)} - ${intl.DateFormat('dd-MM-yyyy').format(endDate)}' ,studentName, presencePercentage.toStringAsFixed(2) ]);
      });

      String csv = const ListToCsvConverter().convert(csvData);
      await file.writeAsString(csv);

      print('CSV file saved at: $filePath');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Report saved at: $filePath',
            style: TextStyle(fontFamily: "GBook", color: Colors.green),
          ),
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () async {
              OpenFile.open(filePath);
            },
          ),
        ),
      );
    } catch (e) {
      print('Error downloading CSV: $e');
    }
  }


  void _showDateRangeDialog() async {
    DateTime? startDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue, // Head color
            ),
          ),
          child: child!,
        );
      },
      helpText: 'Select Start Date',
      cancelText: 'Cancel',
      confirmText: 'Select',
    );

    if (startDate != null) {
      DateTime? endDate = await showDatePicker(
        context: context,
        initialDate: startDate,
        firstDate: startDate,
        lastDate: DateTime(2025),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.blue, // Head color
              ),
            ),
            child: child!,
          );
        },
        helpText: 'Select End Date',
        cancelText: 'Cancel',
        confirmText: 'Select',
      );

      if (endDate != null) {
        _generateCSVWithDateRange(startDate, endDate);
      }
    }
  }











  // Future<void> _downloadCSV() async {
  //   print("Hello");
  //   try {
  //     if (items == null) {
  //       print('No data to download.');
  //       return;
  //     }
  //     var status = await Permission.storage.status;
  //     if (!status.isGranted) {
  //       await Permission.storage.request();
  //       status = await Permission.storage.status;
  //       if (!status.isGranted) {
  //         print('Permission to access storage denied.');
  //         return;
  //       }
  //     }

  //     final directory = await getExternalStorageDirectory();
  //     if (directory == null) {
  //       print('Error: External storage directory is null.');
  //       return;
  //     }

  //     final filePath = '${directory.path}/attendance_report.csv';
  //     File file = File(filePath);

  //     Map<String, List<String>> studentNamesByDate = {};

  //     items!.forEach((item) {
  //       String date = intl.DateFormat('dd-MM-yyyy')
  //           .format(DateTime.parse(item['createdAt']));
  //       String studentName = item['studentName'];
  //       studentNamesByDate.putIfAbsent(date, () => []);
  //       studentNamesByDate[date]!.add(studentName);
  //     });

  //     List<List<dynamic>> csvData = [];
  //     studentNamesByDate.forEach((date, studentNames) {
  //       csvData.add([date]);
  //       studentNames.forEach((studentName) {
  //         csvData.add(['', '', '', studentName]);
  //       });
  //     });

  //     String csv = const ListToCsvConverter().convert(csvData);
  //     await file.writeAsString(csv);

  //     print('CSV file saved at: $filePath');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //           content: Text(
  //             'Report saved at: $filePath',
  //             style: TextStyle(fontFamily: "GBook", color: Colors.green),
  //           ),
  //           duration: Duration(seconds: 3),
  //           action: SnackBarAction(
  //               label: 'Open',
  //               onPressed: () async {
  //                 OpenFile.open(filePath);
  //               })),
  //     );
  //   } catch (e) {
  //     print('Error downloading CSV: $e');
  //   }
  // }


  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Calendar",
            style: TextStyle(fontFamily: "GB"),
          ),
          actions: [
            IconButton(
              onPressed: _showDateRangeDialog,
              icon: CircleAvatar(
                  backgroundColor: Colors.black,
                  child: FaIcon(
                    FontAwesomeIcons.arrowDown,
                    color: Colors.white,
                  )),
              tooltip: "Report",
            ),
          ],
        ),
        body: Center(
          child: _buildCalendar(),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    if (items == null) {
      return CircularProgressIndicator();
    }

    return SfCalendar(
      controller: _calendarController,
      view: CalendarView.month,
      firstDayOfWeek: 1,
      dataSource: TaskDataSource(items!),
      monthViewSettings: MonthViewSettings(
        showAgenda: true,
      ),
      headerStyle: CalendarHeaderStyle(
        textStyle: TextStyle(fontFamily: "GBook"),
      ),
      todayTextStyle: TextStyle(fontFamily: "GBook"),
      appointmentTextStyle: TextStyle(fontFamily: "GBook"),
      weekNumberStyle:
          WeekNumberStyle(textStyle: TextStyle(fontFamily: "GBook")),
      viewHeaderStyle: ViewHeaderStyle(
        dayTextStyle: TextStyle(fontFamily: "GBook"),
        dateTextStyle: TextStyle(fontFamily: "GBook"),
      ),
    );
  }
}

class TaskDataSource extends CalendarDataSource {
  TaskDataSource(List<Map<String, dynamic>> source) {
    Map<DateTime, List<String>> appointmentsMap = {};

    source.forEach((task) {
      DateTime utcTime = DateTime.parse(task['createdAt']);
      DateTime date = utcTime.toLocal(); // Convert UTC time to local time (IST)
      appointmentsMap[date] ??= [];
      appointmentsMap[date]!.add(task['studentName']);
    });

    appointments = appointmentsMap.entries.map((entry) {
      DateTime date = entry.key;
      List<String> studentNames = entry.value;
      String subject = studentNames.join(', ');

      return Appointment(
        color: Colors.black,
        startTime: date,
        endTime: date.add(Duration(hours: 1)),
        subject: subject,
      );
    }).toList();
  }
}



































































































  // csv

//   Future<void> _downloadCSV() async {
//   try {
//     if (items == null) {
//       print('No data to download.');
//       return;
//     }
//     var status = await Permission.storage.status;
//     if (!status.isGranted) {
//       await Permission.storage.request();
//       status = await Permission.storage.status;
//       if (!status.isGranted) {
//         print('Permission to access storage denied.');
//         return;
//       }
//     }

//     final directory = await getExternalStorageDirectory();
//     if (directory == null) {
//       print('Error: External storage directory is null.');
//       return;
//     }

//     final filePath = '${directory.path}/attendance_report.csv';
//     File file = File(filePath);

//     List<List<dynamic>> csvData = [
//       ['Student Name', 'Faculty Name', 'Subject', 'Date']
//     ];

//     items!.forEach((item) {
//       csvData.add([
//         item['studentName'],
//         item['facultyId']['name'],
//         item['subject'],
//         item['createdAt']
//       ]);
//     });

//     String csv = const ListToCsvConverter().convert(csvData);

//     await file.writeAsString(csv);

//     print('CSV file saved at: $filePath');

//     // You can add code here to show a confirmation message or UI
//     // indicating successful download.
//   } catch (e) {
//     print('Error downloading CSV: $e');
//   }
// }

  // Future<void> _downloadCSV() async {
  //   try {
  //     if (items == null) {
  //       print('No data to download.');
  //       return;
  //     }
  //     var status = await Permission.storage.status;
  //     if (!status.isGranted) {
  //       await Permission.storage.request();
  //       status = await Permission.storage.status;
  //       if (!status.isGranted) {
  //         print('Permission to access storage denied.');
  //         return;
  //       }
  //     }

  //     final directory = await getExternalStorageDirectory();
  //     if (directory == null) {
  //       print('Error: External storage directory is null.');
  //       return;
  //     }

  //     final filePath = '${directory.path}/attendance_report.csv';
  //     File file = File(filePath);

  //     List<List<dynamic>> csvData = [
  //       ['Student Name', 'Faculty Name', 'Subject', 'Date']
  //     ];

  //     items!.forEach((item) {
  //       // Parse UTC timestamp string
  //       DateTime utcDateTime = DateTime.parse(item['createdAt']);

  //       // Convert UTC to local time (IST)
  //       DateTime istDateTime = utcDateTime.toLocal();

  //       // Format local time to IST string
  //       String istDateString =
  //           intl.DateFormat('yyyy-MM-dd HH:mm:ss').format(istDateTime);

  //       csvData.add([
  //         item['studentName'],
  //         item['facultyId']['name'],
  //         item['subject'],
  //         istDateString, // Use IST date string
  //       ]);
  //     });

  //     String csv = const ListToCsvConverter().convert(csvData);

  //     await file.writeAsString(csv);

  //     print('CSV file saved at: $filePath');

  //     // You can add code here to show a confirmation message or UI
  //     // indicating successful download.
  //   } catch (e) {
  //     print('Error downloading CSV: $e');
  //   }
  // }
