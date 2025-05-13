import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/questionnaire_model.dart';
import '../../../providers/questionnaire_provider.dart';
import '../../../providers/user_provider.dart';

class QuestionnaireView extends ConsumerStatefulWidget {
  final int questionnaireId;

  const QuestionnaireView({
    Key? key,
    required this.questionnaireId,
  }) : super(key: key);

  @override
  _QuestionnaireViewState createState() => _QuestionnaireViewState();
}

class _QuestionnaireViewState extends ConsumerState<QuestionnaireView> {
  final Map<String, dynamic> _answers = {};
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final questionnaireAsync = ref.watch(questionnaireProvider(widget.questionnaireId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Questionnaire'),
        centerTitle: true,
      ),
      body: questionnaireAsync.when(
        data: (questionnaire) {
          if (questionnaire == null) {
            return const Center(
              child: Text('Questionnaire not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questionnaire.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  questionnaire.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                ...questionnaire.questions.map((question) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: _buildQuestionWidget(question),
                  );
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            // Validate required questions
                            final missingRequired = questionnaire.questions
                                .where((q) => q.required && !_answers.containsKey(q.id.toString()))
                                .toList();

                            if (missingRequired.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please answer all required questions: ${missingRequired.map((q) => q.text).join(", ")}',
                                  ),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _isSubmitting = true;
                            });

                            try {
                              // TODO: Submit answers
                              await Future.delayed(const Duration(seconds: 1)); // Simulated API call

                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Questionnaire submitted successfully'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error submitting questionnaire: $e'),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isSubmitting = false;
                                });
                              }
                            }
                          },
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Submit'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildQuestionWidget(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (question.required)
          const Text(
            '(Required)',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        const SizedBox(height: 8),
        if (question.type == 'TEXT')
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your answer',
            ),
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                _answers[question.id.toString()] = value;
              });
            },
          )
        else if (question.type == 'SINGLE_CHOICE')
          Column(
            children: question.options.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _answers[question.id.toString()],
                onChanged: (value) {
                  setState(() {
                    _answers[question.id.toString()] = value;
                  });
                },
              );
            }).toList(),
          )
        else if (question.type == 'MULTIPLE_CHOICE')
          Column(
            children: question.options.map((option) {
              final selectedOptions = (_answers[question.id.toString()] as List<String>?) ?? [];
              return CheckboxListTile(
                title: Text(option),
                value: selectedOptions.contains(option),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedOptions.add(option);
                    } else {
                      selectedOptions.remove(option);
                    }
                    _answers[question.id.toString()] = selectedOptions;
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }
} 