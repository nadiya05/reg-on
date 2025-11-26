import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../models/chat_message.dart';

class ChatService {
  final String apiBase;
  final String pusherKey;
  final String cluster;
  late PusherChannelsFlutter pusher;

  ChatService({
    required this.apiBase,
    required this.pusherKey,
    required this.cluster,
  });

  // ================= LOAD MESSAGE =================
  Future<List<ChatMessage>> fetchMessages(String token) async {
    final res = await http.get(
      Uri.parse('$apiBase/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final data = jsonDecode(res.body);

    if (data == null || data['data'] == null) return [];

    return (data['data'] as List)
        .map((m) => ChatMessage.fromJson(m))
        .toList();
  }

  // ================ SEND MESSAGE ==================
  Future<void> sendMessage(String token, String text) async {
    await http.post(
      Uri.parse('$apiBase/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: {'message': text},
    );
  }

  // ================ START CHAT ==================
  Future<void> startChat(String token) async {
    await http.post(
      Uri.parse('$apiBase/start-chat'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  // ================ PUSHER ==================
  Future<void> initPusher({
    required int userId,
    required Function(ChatMessage) onMessage,
  }) async {
    pusher = PusherChannelsFlutter.getInstance();

    await pusher.init(
      apiKey: pusherKey,
      cluster: cluster,
      onEvent: (event) {
        final data = jsonDecode(event.data);
        onMessage(ChatMessage.fromJson(data));
      },
    );

    await pusher.subscribe(channelName: 'chat.$userId');
    await pusher.connect();
  }

  void dispose() {
    pusher.disconnect();
  }
}
