class NotificationModel {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String? body;
  final int? refId;
  final String? refType;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.body,
    this.refId,
    this.refType,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String?,
      refId: json['ref_id'] as int?,
      refType: json['ref_type'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
