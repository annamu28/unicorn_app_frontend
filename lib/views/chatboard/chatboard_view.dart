import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../models/chatboard_model.dart';
import '../../../providers/chatboard_provider.dart';
import '../../../providers/post_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../views/comment/comment_view.dart';
import '../../../providers/authentication_provider.dart';
import '../tabs/teacher_tab/teacher_tab.dart';
import 'widgets/posts_tab.dart';

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
      print('Fetching chatboard with ID: ${widget.chatboardId}');
      // Convert the string ID to an integer
      final chatboardId = int.tryParse(widget.chatboardId);
      if (chatboardId == null) {
        print('Invalid chatboard ID: ${widget.chatboardId}');
        if (mounted) {
          setState(() {
            chatboardTitle = 'Invalid ID';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid chatboard ID'),
              backgroundColor: Colors.red,
            ),
          );
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              context.pop();
            }
          });
        }
        return;
      }
      
      final chatboard = await ref.read(chatboardProvider(widget.chatboardId).future);
      
      if (chatboard != null && mounted) {
        print('Chatboard found: ${chatboard.title} (ID: ${chatboard.id})');
        setState(() {
          chatboardTitle = chatboard.title;
        });
      } else if (mounted) {
        print('Chatboard not found or access denied');
        setState(() {
          chatboardTitle = 'Access Denied';
        });
        // Show a snackbar to inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You do not have access to this chatboard or it does not exist'),
            backgroundColor: Colors.red,
          ),
        );
        // Navigate back after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.pop();
          }
        });
      }
    } catch (e) {
      print('Error fetching chatboard title: $e');
      if (mounted) {
        setState(() {
          chatboardTitle = 'Error';
        });
        // Show a snackbar to inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading chatboard: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // Navigate back after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.pop();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authenticationProvider);
    final postsAsync = ref.watch(postsProvider(widget.chatboardId));
    final userAsync = ref.watch(userProvider);
    
    // If the chatboard title is 'Access Denied', show a loading indicator
    // The _fetchChatboardTitle method will handle navigation back
    if (chatboardTitle == 'Access Denied') {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return userAsync.when(
      data: (user) {
        final isSpecialRole = user.hasAnyRole(['Admin', 'Helper Unicorn', 'Head Unicorn']);
        print('User roles: ${user.roles}');
        print('Is special role: $isSpecialRole');

        return postsAsync.when(
          data: (posts) {
            // Sort posts by creation date (earliest first)
            final sortedPosts = List.from(posts)..sort((a, b) => a.createdAt.compareTo(b.createdAt));

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
                body: SafeArea(
                  child: isSpecialRole 
                    ? Column(
                        children: [
                          Expanded(
                            child: TabBarView(
                              children: [
                                PostsTab(chatboardId: widget.chatboardId),
                                TeacherTab(chatboardId: widget.chatboardId),
                              ],
                            ),
                          ),
                        ],
                      )
                    : PostsTab(chatboardId: widget.chatboardId),
                ),
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
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text('Error loading user info: $error'),
        ),
      ),
    );
  }
}

