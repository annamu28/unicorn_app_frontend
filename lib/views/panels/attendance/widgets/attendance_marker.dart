import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/lesson_model.dart';
import '../../../../models/pending_user_model.dart';
import '../../../../providers/attendance_provider.dart';

class AttendanceMarker {
  final WidgetRef ref;
  final BuildContext context;
  final Lesson? selectedLesson;
  final PendingUser? selectedUser;
  final Map<int, String> attendanceStatus;
  final Function(bool) setLoading;
  final Function(int, String) updateAttendanceStatus;

  AttendanceMarker({
    required this.ref,
    required this.context,
    required this.selectedLesson,
    required this.selectedUser,
    required this.attendanceStatus,
    required this.setLoading,
    required this.updateAttendanceStatus,
  });

  Future<void> markAttendance(String status) async {
    if (selectedLesson == null || selectedUser == null) {
      return;
    }

    setLoading(true);
    try {
      await ref.read(markAttendanceProvider({
        'lessonId': selectedLesson!.id,
        'userId': selectedUser!.userId,
        'status': status,
      }).future);

      updateAttendanceStatus(selectedUser!.userId, status);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance marked as $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking attendance: $e')),
      );
    } finally {
      setLoading(false);
    }
  }
} 