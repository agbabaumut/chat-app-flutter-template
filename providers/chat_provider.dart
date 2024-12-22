import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../services/openai_service.dart';
import 'package:uuid/uuid.dart';

final openAIServiceProvider = Provider<OpenAIService>((ref) {
  const apiKey = 'OPENAI_API_KEY'; 
  return OpenAIService(apiKey: apiKey);
});

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final openAIService = ref.watch(openAIServiceProvider);
  return ChatNotifier(openAIService);
});

class ChatState {
  final List<types.Message> messages;
  final bool isLoading;

  ChatState({required this.messages, required this.isLoading});

  ChatState copyWith({
    List<types.Message>? messages,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final OpenAIService _openAIService;
  final uuid = const Uuid();

  ChatNotifier(this._openAIService)
      : super(ChatState(messages: [], isLoading: false));

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = types.TextMessage(
      author: const types.User(id: 'user'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: uuid.v4(),
      text: text,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    try {
      final reply = await _openAIService.sendMessage(text);
      final aiMessage = types.TextMessage(
        author: const types.User(id: 'ai'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: uuid.v4(),
        text: reply,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (e) {
      final errorMessage = types.TextMessage(
        author: const types.User(id: 'ai'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: uuid.v4(),
        text: 'Error: ${e.toString()}',
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
      );
    }
  }
}
