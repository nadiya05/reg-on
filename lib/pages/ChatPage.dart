import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final int userId;
  final String token;
  final String userAvatarUrl;
  final String adminAvatarUrl;
  final String userName;
  final String adminName;

  ChatPage({
    required this.userId,
    required this.token,
    required this.userAvatarUrl,
    required this.adminAvatarUrl,
    required this.userName,
    required this.adminName,
    super.key,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatService chatService;
  List<ChatMessage> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  bool loading = true;

  // Profile
  String userAvatar = "";
  String adminAvatar = "";
  String userName = "";
  String adminName = "";
  bool profileLoaded = false;

  @override
  void initState() {
    super.initState();

    chatService = ChatService(
      apiBase: 'http://10.0.2.2:8000/api',
      pusherKey: 'c7b0ab0b586f80a296fe',
      cluster: 'ap1',
    );

    _loadProfile();
    _initRealtime();
    _loadMessages();
  }

  // ===============================
  // LOAD PROFILE USER + ADMIN
  // ===============================
  Future<void> _loadProfile() async {
    try {
      final data = await chatService.getProfile(widget.token);

      if (!mounted) return;

      setState(() {
        userAvatar = data['avatar'] ?? widget.userAvatarUrl;
        adminAvatar = data['admin_avatar'] ?? widget.adminAvatarUrl;
        userName = data['name'] ?? widget.userName;
        adminName = data['admin_name'] ?? widget.adminName;
        profileLoaded = true;
      });
    } catch (e) {
      print("ERROR load profile: $e");
      if (!mounted) return;
      setState(() => profileLoaded = true);
    }
  }

  // ===============================
  // AVATAR HANDLER
  // ===============================
  String _avatarOrFallback(String? url) {
    if (url == null || url.isEmpty) {
      return "http://10.0.2.2:8000/storage/default/profile.png";
    }

    if (url.startsWith("http")) return url;

    return "http://10.0.2.2:8000/storage/$url";
  }

  // ===============================
  // LOAD MESSAGES
  // ===============================
  Future<void> _loadMessages() async {
    try {
      final data = await chatService.fetchMessages(widget.token);

      if (!mounted) return;
      setState(() {
        messages = data;
        loading = false;
      });

      // Safety fallback: jika server belum membuat chat awal (belum pernah chat sama sekali),
      // panggil startChat. Backend di-design untuk hanya membuat chat awal jika BELUM PERNAH chat.
      if (messages.isEmpty) {
        try {
          await chatService.startChat(widget.token);
          final refreshed = await chatService.fetchMessages(widget.token);
          if (!mounted) return;
          setState(() {
            messages = refreshed;
          });
        } catch (e) {
          print("startChat fallback failed: $e");
        }
      }

      _scrollToBottomHard();
    } catch (e) {
      print("Error loading messages: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  // ===============================
  // INIT PUSHER
  // ===============================
  void _initRealtime() async {
    try {
      await chatService.initPusher(
        userId: widget.userId,
        onMessage: (ChatMessage msg) {
          if (!mounted) return;

          bool exist = messages.any((m) => m.id == msg.id);
          if (!exist) {
            setState(() => messages.add(msg));
            _scrollToBottomSoft();
          }
        },
      );
    } catch (e) {
      print("Error init pusher: $e");
    }
  }

  // ===============================
  // SCROLL CONTROL
  // ===============================
  void _scrollToBottomHard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        try {
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
        } catch (e) {
          // ignore
        }
      }
    });
  }

  void _scrollToBottomSoft() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        try {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent + 120,
            duration: Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        } catch (e) {
          // ignore
        }
      }
    });
  }

  // ===============================
  // SEND MESSAGE
  // ===============================
  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    final temp = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: widget.userId,
      sender: 'user',
      message: text,
      avatar: _avatarOrFallback(
        userAvatar.isNotEmpty ? userAvatar : widget.userAvatarUrl,
      ),
      createdAt: DateTime.now().toIso8601String(),
    );

    setState(() => messages.add(temp));
    _scrollToBottomSoft();

    try {
      await chatService.sendMessage(widget.token, text);
    } catch (e) {
      print("Error sending: $e");
      // optionally: show SnackBar if send fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim pesan')),
        );
      }
    }
  }

  // ===============================
  // CHAT BUBBLE UI
  // ===============================
  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.sender == 'user';

    final senderAvatar = isUser
        ? _avatarOrFallback(
            msg.avatar.isNotEmpty
                ? msg.avatar
                : (userAvatar.isNotEmpty ? userAvatar : widget.userAvatarUrl),
          )
        : _avatarOrFallback(
            msg.avatar.isNotEmpty
                ? msg.avatar
                : (adminAvatar.isNotEmpty ? adminAvatar : widget.adminAvatarUrl),
          );

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(radius: 18, backgroundImage: NetworkImage(senderAvatar)),
          if (!isUser) SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: isUser ? Color(0xFFDAEDFF) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(msg.message, style: TextStyle(fontSize: 15)),
                ),
                SizedBox(height: 4),
                Text(msg.createdAt,
                    style: TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
          if (isUser) SizedBox(width: 8),
          if (isUser)
            CircleAvatar(radius: 18, backgroundImage: NetworkImage(senderAvatar)),
        ],
      ),
    );
  }

  // ===============================
  // DISPOSE
  // ===============================
  @override
  void dispose() {
    try {
      chatService.dispose();
    } catch (e) {
      // ignore
    }
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ===============================
  // MAIN UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    if (!profileLoaded) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: EdgeInsets.fromLTRB(12, 22, 12, 16),
              decoration: BoxDecoration(
                color: Color(0xFF0077B6),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  CircleAvatar(
                    radius: 22,
                    backgroundImage:
                        NetworkImage(_avatarOrFallback(adminAvatar)),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adminName.isNotEmpty ? adminName : widget.adminName,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      Text('Admin Lohbener',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            // LIST CHAT
            Expanded(
              child: loading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scroll,
                      padding: EdgeInsets.only(top: 8, bottom: 12),
                      itemCount: messages.length,
                      itemBuilder: (_, i) => KeyedSubtree(
                        key: ValueKey(messages[i].id),
                        child: _buildMessageBubble(messages[i]),
                      ),
                    ),
            ),

            // INPUT
            Container(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Tulis pesan...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: "sendBtn",
                    mini: true,
                    backgroundColor: Color(0xFF0077B6),
                    onPressed: _send,
                    child: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}