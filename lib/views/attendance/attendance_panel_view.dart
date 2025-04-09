import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/course_model.dart';
import '../../models/lesson_model.dart';
import '../../models/attendance_model.dart';
import '../../models/user.dart';
import '../../models/pending_user_model.dart';
import '../../providers/course_provider.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/pending_users_provider.dart';

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
        final hasRequiredRole = currentUser.hasAnyRole(['Admin', 'Abisarvik', 'Ükssarvik']);
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
                  data: (courses) => _buildDropdown<Course>(
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
                    data: (lessons) => _buildDropdown<Lesson>(
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
                    data: (pendingUsersResponse) {
                      if (pendingUsersResponse.pendingUsers.isEmpty) {
                        return const Center(
                          child: Text('No users found in this chatboard.'),
                        );
                      }

                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ListView.builder(
                          itemCount: pendingUsersResponse.pendingUsers.length,
                          itemBuilder: (context, index) {
                            final user = pendingUsersResponse.pendingUsers[index];
                            final status = _attendanceStatus[user.userId];
                            final isPresent = status == 'present';
                            final isAbsent = status == 'absent';
                            
                            return ListTile(
                              title: Text('${user.firstName} ${user.lastName}'),
                              subtitle: Text('Email: ${user.email}'),
                              selected: _selectedUser == user,
                              tileColor: isPresent 
                                ? Colors.green.withOpacity(0.1) 
                                : isAbsent 
                                  ? Colors.red.withOpacity(0.1) 
                                  : null,
                              trailing: isPresent 
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : isAbsent 
                                  ? const Icon(Icons.cancel, color: Colors.red)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedUser = user;
                                });
                              },
                            );
                          },
                        ),
                      );
                    },
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
                          onPressed: _isLoading ? null : () => _markAttendance('present'),
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
                          onPressed: _isLoading ? null : () => _markAttendance('absent'),
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

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String hint,
    required Function(T?) onChanged,
    required DropdownMenuItem<T> Function(T) itemBuilder,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      hint: Text(hint),
      items: items.map(itemBuilder).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _markAttendance(String status) async {
    if (_selectedLesson == null || _selectedUser == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(markAttendanceProvider({
        'lessonId': _selectedLesson!.id,
        'userId': _selectedUser!.userId,
        'status': status,
      }).future);

      setState(() {
        _attendanceStatus[_selectedUser!.userId] = status;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance marked as $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking attendance: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 