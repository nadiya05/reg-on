import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final int userId;
  final String token;
  final String userAvatarUrl;
  final String adminAvatarUrl;

  ChatPage({
    required this.userId,
    required this.token,
    required this.userAvatarUrl,
    required this.adminAvatarUrl,
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

 @override
void initState() {
  super.initState();

  chatService = ChatService(
    apiBase: 'http://10.0.2.2:8000/api',
    pusherKey: 'c7b0ab0b586f80a296fe',
    cluster: 'ap1',
  );

  chatService.startChat(widget.token); // <--- WAJIB BIAR ADA DEFAULT MESSAGE

  _loadMessages();

  chatService.initPusher(
    userId: widget.userId,
    onMessage: (ChatMessage msg) {
      setState(() => messages.add(msg));
      _scrollToBottomSoft();
    },
  );
}


  Future<void> _loadMessages() async {
    try {
      final list = await chatService.fetchMessages(widget.token);

      setState(() {
        messages = list;
        loading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottomHard());
    } catch (e) {
      print("ERROR load messages: $e");
      setState(() => loading = false);
    }
  }

  void _scrollToBottomHard() {
    if (!_scroll.hasClients) return;
    _scroll.jumpTo(_scroll.position.maxScrollExtent);
  }

  void _scrollToBottomSoft() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent + 100,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

Future<void> _send() async {
  final text = _controller.text.trim();
  if (text.isEmpty) return;

  _controller.clear();

  final temp = ChatMessage(
    id: DateTime.now().millisecondsSinceEpoch,
    userId: widget.userId,
    sender: 'user',
    message: text,
    avatar: widget.userAvatarUrl,         // ✅ WAJIB ADA SEKARANG
    createdAt: DateTime.now().toString(), // ✅ harus String
  );

  setState(() => messages.add(temp));
  _scrollToBottomSoft();

  await chatService.sendMessage(widget.token, text);
}

  @override
  void dispose() {
    chatService.dispose();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ========================== UI BUILDER ========================== //

  Widget _buildHeader() {
    return Container(
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
            backgroundImage: NetworkImage(widget.adminAvatarUrl),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'MinLoh',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'Admin Lohbener',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
  final isUser = msg.sender == 'user';

  return Container(
    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser)
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(msg.avatar),
          ),

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
                child: Text(
                  msg.message,
                  style: TextStyle(fontSize: 15),
                ),
              ),

              SizedBox(height: 4),

              Text(
                msg.createdAt, // LANGSUNG PAKAI STRING DARI API
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),

        if (isUser) SizedBox(width: 8),

        if (isUser)
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(msg.avatar),
          ),
      ],
    ),
  );
}

  // ========================== BUILD ========================== //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            // LIST PESAN
            Expanded(
              child: loading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scroll,
                      padding: EdgeInsets.only(top: 8, bottom: 12),
                      itemCount: messages.length,
                      itemBuilder: (_, i) => _buildMessageBubble(messages[i]),
                    ),
            ),

            // INPUT BOX
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
                        maxLines: 4,
                        minLines: 1,
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
