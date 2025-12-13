import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../models/chat_message.dart';

class ChatService {
  final String apiBase;
  final String pusherKey;
  final String cluster;

  late PusherChannelsFlutter pusher;
  bool _connected = false;
  String? _currentChannel;

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

  // =============== REALTIME PUSHER ===============
  Future<void> initPusher({
    required int userId,
    required Function(ChatMessage) onMessage,
  }) async {
    if (_connected) return; 
    _connected = true;

    pusher = PusherChannelsFlutter.getInstance();

    await pusher.init(
      apiKey: pusherKey,
      cluster: cluster,

      onEvent: (event) {
        print("🔵 EVENT MASUK: ${event.eventName}");
        print(event.data);

        if (event.eventName.endsWith('message.sent')) {
          final data = jsonDecode(event.data!);
          final msg = ChatMessage.fromJson(data);
          onMessage(msg);
        }
      },

      onSubscriptionSucceeded: (channel, data) {
        print("🟢 SUBSCRIBED → $channel");
      },

      onConnectionStateChange: (current, previous) {
        print("🟡 STATE → $current");
      },

      onError: (msg, code, ex) {
        print("🔴 PUSHER ERROR → $msg | $ex");
      },
    );

    await pusher.connect();

    _currentChannel = "chat.$userId";

    await pusher.subscribe(channelName: _currentChannel!);
    print("🟠 SUBSCRIBE CALLED: $_currentChannel");
  }

  // ========== DISPOSE UNTUK CEGAH MEMORY LEAK ==========
  void dispose() {
    try {
      if (_currentChannel != null) {
        pusher.unsubscribe(channelName: _currentChannel!);
      }
      pusher.disconnect();
      print("🔻 PUSHER DISCONNECTED");
    } catch (e) {
      print("Dispose error: $e");
    }
  }

  // =========== GET PROFILE USER =================
  Future<Map<String, dynamic>> getProfile(String token) async {
    final url = Uri.parse('$apiBase/me');
    final res = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    return jsonDecode(res.body);
  }

  // =========== START CHAT USER =================
  Future<void> startChat(String token) async {
    final url = Uri.parse("$apiBase/chat/start");

    await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }
}
