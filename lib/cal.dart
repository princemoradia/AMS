import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:ams/config.dart';
import 'package:intl/intl.dart' as intl;

class Cal extends StatefulWidget {
  final String subject;
  final String token;
  const Cal({Key? key, required this.subject, required this.token})
      : super(key: key);

  @override
  State<Cal> createState() => _CalState();
}

class _CalState extends State<Cal> {
  late String userName;
  late String minPercentage;
  late CalendarController _calendarController;
  List<Map<String, dynamic>>? items;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userName = jwtDecodedToken['name'];
    _fetchStudentAttendanceData();
    _calendarController = CalendarController();
  }

  void _fetchStudentAttendanceData() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$showStudentAttendance?studentname=$userName&&subject=${widget.subject}'),
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true) {
          final attendanceData = jsonData['data']['data'];
          if (attendanceData is List) {
            setState(() {
              items = List<Map<String, dynamic>>.from(attendanceData);
            });
          } else {
            print('Invalid attendance data format: $attendanceData');
          }
        } else {
          print('Failed to fetch attendance data: ${jsonData['error']}');
        }
      } else {
        print(
            'Failed to fetch attendance data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching attendance data: $error');
    }
  }

  Future<void> _generateCSVWithDateRange(
      DateTime startDate, DateTime endDate) async {
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
        if (createdAt.isAfter(startDate) && createdAt.isBefore(endDate) ||
            createdAt.isAtSameMomentAs(startDate) ||
            createdAt.isAtSameMomentAs(endDate)) {
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
          studentPresenceCount[studentName] =
              (studentPresenceCount[studentName] ?? 0) + 1;
        });
      });

      List<List<dynamic>> csvData = [];
      csvData.add(['Sr. No', 'Date', 'Student Name', 'Percentage Present']);
      studentPresenceCount.forEach((studentName, presenceCount) {
        double presencePercentage = (presenceCount / totalDays) * 100;
        csvData.add([
          serialNo++,
          '${intl.DateFormat('dd-MM-yyyy').format(startDate)} - ${intl.DateFormat('dd-MM-yyyy').format(endDate)}',
          studentName,
          presencePercentage.toStringAsFixed(2)
        ]);
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

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Calendar for ${widget.subject}',
            style: const TextStyle(fontFamily: "GB"),
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
        ));
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
      monthViewSettings: const MonthViewSettings(
        showAgenda: true,
      ),
      headerStyle: const CalendarHeaderStyle(
        textStyle: TextStyle(fontFamily: "GBook"),
      ),
      todayTextStyle: const TextStyle(fontFamily: "GBook"),
      appointmentTextStyle: const TextStyle(fontFamily: "GBook"),
      weekNumberStyle:
          const WeekNumberStyle(textStyle: TextStyle(fontFamily: "GBook")),
      viewHeaderStyle: const ViewHeaderStyle(
        dayTextStyle: TextStyle(fontFamily: "GBook"),
        dateTextStyle: TextStyle(fontFamily: "GBook"),
      ),
    );
  }
}

class TaskDataSource extends CalendarDataSource {
  TaskDataSource(List<Map<String, dynamic>> source) {
    appointments = <Appointment>[];
    source.forEach((task) {
      DateTime utcTime = DateTime.parse(task['createdAt']);
      DateTime istStartTime = utcTime.toLocal();
      DateTime? istEndTime = istStartTime.add(const Duration(hours: 1));

      appointments?.add(Appointment(
        color: Colors.black,
        startTime: istStartTime,
        endTime: istEndTime,
        subject: task['status'],
      ));
    });
  }
}













// class TaskDataSource extends CalendarDataSource {
//   TaskDataSource(List<Map<String, dynamic>> source) {
//     Map<DateTime, List<String>> appointmentsMap = {};

//     source.forEach((task) {
//       DateTime utcTime = DateTime.parse(task['createdAt']);
//       DateTime istStartTime =
//           utcTime.toLocal(); // Convert UTC time to local time (IST)
//       DateTime istEndTime = istStartTime.add(
//           Duration(hours: 1)); // Assuming each appointment lasts for 1 hour
//     });

//     appointments = appointmentsMap.entries.map((entry) {
//       DateTime date = entry.key;
//       List<String> studentNames = entry.value;
//       String subject = studentNames.join(', ');

//       return Appointment(
//         color: Colors.black,
//         startTime: istSt,
//         endTime: date.add(Duration(hours: 1)),
//         subject: subject,
//       );
//     }).toList();
//   }

// }