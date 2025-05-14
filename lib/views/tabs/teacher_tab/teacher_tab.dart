import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/user.dart';
import '../../../providers/user_provider.dart';
import '../../panels/attendance/attendance_panel_view.dart';
import '../../panels/verification/verification_view.dart';
import '../../panels/questionnaire/questionnaire_panel_view.dart';

class TeacherTab extends ConsumerWidget {
  final String chatboardId;

  const TeacherTab({
    Key? key,
    required this.chatboardId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      data: (user) {
        // Check if user has required roles
        final hasRequiredRole = user.hasAnyRole(['Admin', 'Helper Unicorn', 'Head Unicorn']);
        if (!hasRequiredRole) {
          return const Center(
            child: Text('You do not have permission to view this tab.'),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teacher Panel',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.verified_user),
                    title: const Text('Verification'),
                    subtitle: const Text('Verify student submissions'),
                    onTap: () {
                      context.push('/chatboard/$chatboardId/verification');
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.people_outline),
                    title: const Text('Attendance'),
                    subtitle: const Text('Manage student attendance'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AttendancePanelView(
                            chatboardId: chatboardId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.quiz),
                    title: const Text('Questionnaires'),
                    subtitle: const Text('Manage questionnaires'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => QuestionnairePanelView(
                            chatboardId: chatboardId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Statistics section
                const SizedBox(height: 24),
                Text(
                  'Class Statistics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Icon(Icons.how_to_reg),
                              const SizedBox(height: 8),
                              const Text('Attendance Rate'),
                              Text(
                                '95%',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Icon(Icons.assignment_turned_in),
                              const SizedBox(height: 8),
                              const Text('Completion Rate'),
                              Text(
                                '87%',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
} 