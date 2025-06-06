import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/comment_provider.dart';
import '../../providers/post_provider.dart' as post;
import 'package:intl/intl.dart';

class CommentView extends ConsumerStatefulWidget {
  final String postId;
  final String chatboardId;

  const CommentView({
    super.key,
    required this.postId,
    required this.chatboardId,
  });

  @override
  ConsumerState<CommentView> createState() => _CommentViewState();
}

class _CommentViewState extends ConsumerState<CommentView> {
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(commentServiceProvider).createComment(
        postId: widget.postId,
        content: _commentController.text.trim(),
      );

      if (mounted) {
        _commentController.clear();
        // Refresh comments list
        ref.refresh(commentsProvider(widget.postId));
        // Refresh the posts after adding a comment
        ref.invalidate(post.postsProvider(widget.chatboardId));
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to create comment';
        
        // Simplified error handling
        if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection and try again';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.postId));

    return Column(
      children: [
        Expanded(
          child: commentsAsync.when(
            data: (comments) => ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 8.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.content,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 4),
                        // Exact same implementation as in chatboard_view
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Roles above username
                                  if (comment.userRole != null)
                                    Wrap(
                                      spacing: 4.0,
                                      runSpacing: 4.0,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            comment.userRole!,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.blue,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 2),
                                  // Username below roles
                                  Text(
                                    comment.author,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Date on the right
                            Text(
                              DateFormat('MMM d, y').format(comment.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            error: (error, stackTrace) => Center(
              child: Text('Error: $error'),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isLoading ? null : _submitComment,
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 