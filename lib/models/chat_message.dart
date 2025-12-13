class ChatMessage {
  final int id;
  final int userId;
  final String sender;
  final String message;
  final String avatar;
  final String createdAt;

  ChatMessage({
  required this.id,
  required this.userId,
  required this.sender,
  required this.message,
  required this.avatar,
  required this.createdAt,
});
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      userId: json['user_id'],
      sender: json['sender'],
      message: json['message'],
      avatar: json['avatar'],       
      createdAt: json['created_at'], 
    );
  }
}
