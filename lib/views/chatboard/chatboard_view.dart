import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../models/chatboard_model.dart';
import '../../../providers/chatboard_provider.dart';
import '../../../providers/post_provider.dart';
import '../../../views/comment/comment_view.dart';
import '../../../providers/authentication_provider.dart';

class ChatboardView extends ConsumerStatefulWidget {
  final String chatboardId;

  const ChatboardView({
    super.key,
    required this.chatboardId,
  });

  @override
  ConsumerState<ChatboardView> createState() => _ChatboardViewState();
}

class _ChatboardViewState extends ConsumerState<ChatboardView> {
  String? chatboardTitle;
  
  @override
  void initState() {
    super.initState();
    _fetchChatboardTitle();
  }

  Future<void> _fetchChatboardTitle() async {
    try {
      final response = await ref.read(chatboardServiceProvider).getChatboards();
      final chatboard = response.firstWhere(
        (board) => board.id.toString() == widget.chatboardId,
        orElse: () => throw Exception('Chatboard not found'),
      );
      setState(() {
        chatboardTitle = chatboard.title;
      });
    } catch (e) {
      print('Error fetching chatboard title: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authenticationProvider);
    final postsAsync = ref.watch(postsProvider(widget.chatboardId));
    
    return postsAsync.when(
      data: (posts) {
        final userRoles = posts.isNotEmpty 
          ? posts.firstWhere(
              (post) => post.userId == authState.userInfo?['id'],
              orElse: () => posts.first,
            ).author.roles
          : [];
        
        print('Current user roles from posts: $userRoles');
        final isSpecialRole = userRoles.contains('peasarvik') || 
                             userRoles.contains('abisarvik') || 
                             userRoles.contains('Admin');

        return DefaultTabController(
          length: isSpecialRole ? 2 : 1,
          child: Scaffold(
            appBar: AppBar(
              title: Text(chatboardTitle ?? 'Loading...'),
              bottom: PreferredSize(
                preferredSize: isSpecialRole ? const Size.fromHeight(48.0) : const Size.fromHeight(0),
                child: isSpecialRole 
                  ? const TabBar(
                      labelColor: Colors.black,
                      tabs: [
                        Tab(text: 'Posts'),
                        Tab(text: 'Teacher'),
                      ],
                    )
                  : Container(),
              ),
            ),
            body: isSpecialRole 
              ? TabBarView(
                  children: [
                    _PostsTab(chatboardId: widget.chatboardId),
                    _TeacherTab(chatboardId: widget.chatboardId),
                  ],
                )
              : _PostsTab(chatboardId: widget.chatboardId),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.push('/add-post/${widget.chatboardId}');
              },
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

class _PostsTab extends ConsumerWidget {
  final String chatboardId;

  const _PostsTab({required this.chatboardId});

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

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
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
                            child: Row(
                              children: [
                                Text(
                                  post.author.username,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (post.author.roles.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  ...post.author.roles.map((role) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Container(
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
                                    ),
                                  )).toList(),
                                ],
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

class _TeacherTab extends ConsumerWidget {
  final String chatboardId;

  const _TeacherTab({required this.chatboardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
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
                // Add verification functionality
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Attendance'),
              subtitle: const Text('Manage student attendance'),
              onTap: () {
                // Add attendance management functionality
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Questionnaires'),
              subtitle: const Text('Create and manage questionnaires'),
              onTap: () {
                // Add questionnaire functionality
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
    );
  }
}

