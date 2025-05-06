import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/post_provider.dart';
import '../comment/comment_view.dart';

class PostView extends ConsumerWidget {
  final String postId;
  final String chatboardId;

  const PostView({
    super.key,
    required this.postId,
    required this.chatboardId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider(chatboardId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        centerTitle: true,
      ),
      body: postsAsync.when(
        data: (posts) {
          final post = posts.firstWhere(
            (p) => p.id.toString() == postId,
            orElse: () => throw Exception('Post not found'),
          );

          return Column(
            children: [
              // Post content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post.content,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (post.author.roles.isNotEmpty)
                                    Wrap(
                                      spacing: 4.0,
                                      runSpacing: 4.0,
                                      children: post.author.roles.map((role) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          role,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      )).toList(),
                                    ),
                                  const SizedBox(height: 2),
                                  Text(
                                    post.author.username,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              DateFormat('MMM d, y').format(post.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Comments section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Expanded comment view
              Expanded(
                child: CommentView(
                  postId: postId,
                  chatboardId: chatboardId,
                ),
              ),
            ],
          );
        },
        error: (error, _) => Center(
          child: Text('Error: $error'),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
} 