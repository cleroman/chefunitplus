import '../core/errors/error_handler.dart';
import '../models/message.dart';
import 'api_client.dart';

class ChatService {
  final ApiClient _api;
  ChatService(this._api);

  dynamic _data(Map<String, dynamic> r) => r['data'] ?? r['conversation'];
  List<dynamic> _list(Map<String, dynamic> r) {
    final d = _data(r);
    if (d is List) return d;
    return [];
  }

  Future<List<Conversation>> listConversations() async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('/chat/conversations');
      return _list(r)
          .map((e) => Conversation.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }, context: 'ChatService.listConversations');
  }

  Future<List<Message>> getMessages(String conversationId) async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('/chat/conversations/$conversationId/messages');
      return _list(r)
          .map((e) => Message.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }, context: 'ChatService.getMessages');
  }

  Future<Message> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    return ErrorHandler.guard(() async {
      final r = await _api.post(
        '/chat/conversations/$conversationId/messages',
        body: {'content': content},
      );
      final d = _data(r);
      if (d is Map<String, dynamic>) return Message.fromJson(d);
      return Message.fromJson(r);
    }, context: 'ChatService.sendMessage');
  }

  Future<Conversation> createConversation({
    required String participantId,
  }) async {
    return ErrorHandler.guard(() async {
      final r = await _api.post(
        '/chat/conversations',
        body: {'participantId': participantId},
      );
      final d = _data(r);
      if (d is Map<String, dynamic>) return Conversation.fromJson(d);
      return Conversation.fromJson(r);
    }, context: 'ChatService.createConversation');
  }
}