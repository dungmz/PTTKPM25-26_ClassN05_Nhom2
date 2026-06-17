class ChatMessage {
  final int id;
  final int conversationId;
  final int senderId;
  final String? messageText;
  final String messageType; // 'text', 'job_share'
  final int? jobId;
  final String? jobTitle;
  final String? jobCompany;
  final bool isMe;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.messageText,
    required this.messageType,
    this.jobId,
    this.jobTitle,
    this.jobCompany,
    required this.isMe,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: _toInt(json['id']),
      conversationId: _toInt(json['conversation_id']),
      senderId: _toInt(json['sender_id']),
      messageText: json['message_text'],
      messageType: json['message_type'] ?? 'text',
      jobId: json['job_id'] != null ? _toInt(json['job_id']) : null,
      jobTitle: json['job_title'],
      jobCompany: json['job_company'],
      isMe: json['is_me'] == true || json['is_me'] == 1,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
    );
  }

  static int _toInt(dynamic val) {
    if (val is int) return val;
    if (val is String) return int.tryParse(val) ?? 0;
    if (val is double) return val.toInt();
    return 0;
  }
}

class ChatConversation {
  final int id;
  final DateTime updatedAt;
  final ChatUser otherUser;
  final LastMessage? lastMessage;

  ChatConversation({
    required this.id,
    required this.updatedAt,
    required this.otherUser,
    this.lastMessage,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: _toInt(json['id']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString()) 
          : DateTime.now(),
      otherUser: ChatUser.fromJson(json['other_user'] ?? {}),
      lastMessage: json['last_message'] != null
          ? LastMessage.fromJson(json['last_message'])
          : null,
    );
  }

  static int _toInt(dynamic val) {
    if (val is int) return val;
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }
}

class ChatUser {
  final int id;
  final String name;
  final String? avatar;

  ChatUser({required this.id, required this.name, this.avatar});

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: _toInt(json['id']),
      name: json['name'] ?? 'Người dùng',
      avatar: json['avatar'],
    );
  }

  static int _toInt(dynamic val) {
    if (val is int) return val;
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }
}

class LastMessage {
  final String? text;
  final String type;
  final DateTime createdAt;

  LastMessage({this.text, required this.type, required this.createdAt});

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      text: json['text'],
      type: json['type'] ?? 'text',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
    );
  }
}
