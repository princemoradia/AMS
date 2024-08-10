class AttendanceReport {
  final String id;
  final String userId;
  final UserAttendance userAttendance;
  final String createdAt;
  final String updatedAt;

  AttendanceReport({
    required this.id,
    required this.userId,
    required this.userAttendance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceReport.fromJson(Map<String, dynamic> json) {
    return AttendanceReport(
      id: json['_id'],
      userId: json['userId'],
      userAttendance: UserAttendance.fromJson(json['userAttendance']),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class UserAttendance {
  final String label;
  final String id;
  final String createdAt;
  final String updatedAt;

  UserAttendance({
    required this.label,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserAttendance.fromJson(Map<String, dynamic> json) {
    return UserAttendance(
      label: json['label'],
      id: json['_id'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
