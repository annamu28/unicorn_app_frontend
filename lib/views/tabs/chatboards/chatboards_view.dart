import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/chatboard_provider.dart';
import '../../../models/chatboard_model.dart';

class ChatboardsView extends ConsumerWidget {
  const ChatboardsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatboardsAsync = ref.watch(chatboardsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(chatboardsProvider.future),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: chatboardsAsync.when(
          data: (chatboards) => GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.0,
            ),
            itemCount: chatboards.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildAddChatboardBubble(context);
              }
              final chatboard = chatboards[index - 1];
              return _buildChatboardBubble(context, chatboard);
            },
          ),
          error: (error, stackTrace) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 100,
              child: Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  Widget _buildAddChatboardBubble(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/create-chatboard'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle,
              size: 40,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              'Add Chatboard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatboardBubble(BuildContext context, Chatboard chatboard) {
    return GestureDetector(
      onTap: () => context.push('/chatboard/${chatboard.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                chatboard.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                chatboard.description,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
