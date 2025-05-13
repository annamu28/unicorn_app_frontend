import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/course_model.dart';
import '../../../models/lesson_model.dart';
import '../../../models/questionnaire_model.dart';
import '../../../providers/course_provider.dart';
import '../../../providers/lesson_provider.dart';
import '../../../providers/questionnaire_provider.dart';
import '../../../providers/user_provider.dart';
import 'questionnaire_view.dart';

class QuestionnairePanelView extends ConsumerStatefulWidget {
  final String chatboardId;

  const QuestionnairePanelView({
    Key? key,
    required this.chatboardId,
  }) : super(key: key);

  @override
  _QuestionnairePanelViewState createState() => _QuestionnairePanelViewState();
}

class _QuestionnairePanelViewState extends ConsumerState<QuestionnairePanelView> {
  Course? _selectedCourse;
  Lesson? _selectedLesson;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final coursesAsync = ref.watch(coursesProvider);
    final lessonsAsync = ref.watch(lessonsProvider(_selectedCourse?.id));
    final questionnairesAsync = ref.watch(questionnairesProvider(_selectedLesson?.id));

    return userAsync.when(
      data: (currentUser) {
        // Check if user has required roles
        final hasRequiredRole = currentUser.hasAnyRole(['Admin', 'Helper Unicorn', 'Head Unicorn']);
        if (!hasRequiredRole) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Questionnaire Panel'),
              centerTitle: true,
            ),
            body: const Center(
              child: Text('You do not have permission to view this page.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Questionnaire Panel'),
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

                // Questionnaires list
                if (_selectedLesson != null) ...[
                  const Text(
                    'Available Tests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: questionnairesAsync.when(
                      data: (questionnaires) {
                        if (questionnaires.isEmpty) {
                          return const Center(
                            child: Text('No tests available for this lesson.'),
                          );
                        }

                        return ListView.builder(
                          itemCount: questionnaires.length,
                          itemBuilder: (context, index) {
                            final questionnaire = questionnaires[index];
                            return Card(
                              child: ListTile(
                                title: Text(questionnaire.title),
                                subtitle: Text(questionnaire.description),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => QuestionnaireView(
                                          questionnaireId: questionnaire.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Activate'),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(child: Text('Error: $error')),
                    ),
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
} 