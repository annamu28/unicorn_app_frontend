import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../providers/post_provider.dart';

class PostsTab extends ConsumerWidget {
  final String chatboardId;

  const PostsTab({
    super.key,
    required this.chatboardId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider(chatboardId));

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(
            child: Text('No posts yet. Be the first to post!'),
          );
        }

        // Sort posts by creation date (earliest first)
        final sortedPosts = List.from(posts)..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: sortedPosts.length,
          itemBuilder: (context, index) {
            final post = sortedPosts[index];
            final formattedDate = DateFormat('MMM d, y').format(post.createdAt);

            return GestureDetector(
              onTap: () {
                context.push('/post/${chatboardId}/${post.id}');
              },
              child: Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: ListTile(
                  title: Text(post.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.content,
                        maxLines: 30,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Roles above username
                                if (post.author.roles.isNotEmpty)
                                  Wrap(
                                    spacing: 4.0,
                                    runSpacing: 4.0,
                                    children: post.author.roles.map<Widget>((role) => Container(
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
                                // Username and role below roles
                                Row(
                                  children: [
                                    Text(
                                      post.author.username,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (post.userRole != null) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          post.userRole!,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.comment_outlined,
                                size: 16,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${post.commentCount ?? 0}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formattedDate,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      error: (error, _) => Center(
        child: Text('Error: $error'),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
} 