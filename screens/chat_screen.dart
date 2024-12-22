import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
      ),
      body: chatState.isLoading && chatState.messages.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ChatUI(
              messages: chatState.messages,
              onSendPressed: (partialText) {
                ref.read(chatProvider.notifier).sendMessage(partialText.text);
              },
              user: const types.User(
                id: 'user',
              ),
              // Customize the theme if needed
              theme: const DefaultChatTheme(
                primaryColor: Colors.blue,
                userAvatarNameColors: [],
              ),
            ),
    );
  }
}
