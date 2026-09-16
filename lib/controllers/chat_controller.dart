import 'package:flutter/foundation.dart';

import '../core/errors/error_handler.dart';
import '../models/message.dart';
import '../services/chat_service.dart';

class ChatController extends ChangeNotifier {
  final ChatService _service;
  ChatController(this._service);

  bool _loading = false;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;
  String? get errorMessage => _error;

  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;

  Map<String, List<Message>> _messages = {};
  List<Message> messagesFor(String conversationId) =>
      _messages[conversationId] ?? [];

  // ============================================================
  // CHARGEMENT
  // ============================================================
  Future<void> loadConversations({bool refresh = false}) async {
    if (!refresh && _loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _service.listConversations();
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'ChatController.loadConversations');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMessages(String conversationId,
      {bool refresh = false}) async {
    _error = null;
    try {
      final msgs = await _service.getMessages(conversationId);
      _messages[conversationId] = msgs;
      notifyListeners();
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'ChatController.loadMessages');
      notifyListeners();
    }
  }

  // ============================================================
  // ENVOI
  // ============================================================
  Future<bool> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return false;
    _error = null;
    try {
      final msg = await _service.sendMessage(
        conversationId: conversationId,
        content: content.trim(),
      );
      final list = _messages[conversationId] ?? [];
      list.add(msg);
      _messages[conversationId] = list;
      notifyListeners();
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'ChatController.sendMessage');
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // NOUVELLE CONVERSATION
  // ============================================================
  Future<Conversation?> startConversation({
    required String participantId,
  }) async {
    _error = null;
    try {
      final conv = await _service.createConversation(
        participantId: participantId,
      );
      await loadConversations(refresh: true);
      return conv;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'ChatController.startConversation');
      notifyListeners();
      return null;
    }
  }

  void reset() {
    _conversations = [];
    _messages = {};
    _error = null;
    _loading = false;
    notifyListeners();
  }
}