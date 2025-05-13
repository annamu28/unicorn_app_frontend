import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/course_model.dart';
import '../../../models/lesson_model.dart';
import '../../../models/attendance_model.dart';
import '../../../models/user.dart';
import '../../../models/pending_user_model.dart';
import '../../../providers/course_provider.dart';
import '../../../providers/lesson_provider.dart';
import '../../../providers/attendance_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/pending_users_provider.dart';
import 'widgets/custom_dropdown.dart';
import 'widgets/attendance_marker.dart';
import 'widgets/user_list.dart';

class AttendancePanelView extends ConsumerStatefulWidget {
  final String chatboardId;

  const AttendancePanelView({
    Key? key,
    required this.chatboardId,
  }) : super(key: key);

  @override
  _AttendancePanelViewState createState() => _AttendancePanelViewState();
}

class _AttendancePanelViewState extends ConsumerState<AttendancePanelView> {
  Course? _selectedCourse;
  Lesson? _selectedLesson;
  PendingUser? _selectedUser;
  bool _isLoading = false;
  Map<int, String> _attendanceStatus = {};

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final coursesAsync = ref.watch(coursesProvider);
    final lessonsAsync = ref.watch(lessonsProvider(_selectedCourse?.id));
    final chatboardUsersAsync = ref.watch(pendingUsersProvider(widget.chatboardId));

    return userAsync.when(
      data: (currentUser) {
        // Check if user has required roles
        final hasRequiredRole = currentUser.hasAnyRole(['Admin', 'Helper Unicorn', 'Head Unicorn']);
        if (!hasRequiredRole) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Attendance Panel'),
              centerTitle: true,
            ),
            body: const Center(
              child: Text('You do not have permission to view this page.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Attendance Panel'),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course selection
                const Text(
                  'Select Course',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                coursesAsync.when(
                  data: (courses) => CustomDropdown<Course>(
                    value: _selectedCourse,
                    items: courses,
                    hint: 'Select a course',
                    onChanged: (course) {
                      setState(() {
                        _selectedCourse = course;
                        _selectedLesson = null;
                        _attendanceStatus.clear();
                      });
                    },
                    itemBuilder: (course) => DropdownMenuItem(
                      value: course,
                      child: Text(course.name),
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('Error: $error'),
                ),
                const SizedBox(height: 24),

                // Lesson selection
                if (_selectedCourse != null) ...[
                  const Text(
                    'Select Lesson',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  lessonsAsync.when(
                    data: (lessons) => CustomDropdown<Lesson>(
                      value: _selectedLesson,
                      items: lessons,
                      hint: 'Select a lesson',
                      onChanged: (lesson) {
                        setState(() {
                          _selectedLesson = lesson;
                          _attendanceStatus.clear();
                        });
                      },
                      itemBuilder: (lesson) => DropdownMenuItem(
                        value: lesson,
                        child: Text(lesson.title),
                      ),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text('Error: $error'),
                  ),
                  const SizedBox(height: 24),
                ],

                // User selection
                if (_selectedLesson != null) ...[
                  const Text(
                    'Select User',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  chatboardUsersAsync.when(
                    data: (pendingUsersResponse) => UserList(
                      users: pendingUsersResponse.pendingUsers,
                      selectedUser: _selectedUser,
                      attendanceStatus: _attendanceStatus,
                      onUserSelected: (user) => setState(() => _selectedUser = user),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text('Error: $error'),
                  ),
                  const SizedBox(height: 24),
                ],

                // Mark attendance button
                if (_selectedLesson != null && _selectedUser != null) ...[
                  const Text(
                    'Mark Attendance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () {
                            final marker = AttendanceMarker(
                              ref: ref,
                              context: context,
                              selectedLesson: _selectedLesson,
                              selectedUser: _selectedUser,
                              attendanceStatus: _attendanceStatus,
                              setLoading: (loading) => setState(() => _isLoading = loading),
                              updateAttendanceStatus: (userId, status) => setState(() => _attendanceStatus[userId] = status),
                            );
                            marker.markAttendance('present');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Present'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () {
                            final marker = AttendanceMarker(
                              ref: ref,
                              context: context,
                              selectedLesson: _selectedLesson,
                              selectedUser: _selectedUser,
                              attendanceStatus: _attendanceStatus,
                              setLoading: (loading) => setState(() => _isLoading = loading),
                              updateAttendanceStatus: (userId, status) => setState(() => _attendanceStatus[userId] = status),
                            );
                            marker.markAttendance('Absent');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Absent'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
} 