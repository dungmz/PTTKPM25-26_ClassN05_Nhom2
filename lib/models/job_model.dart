class JobModel {
  final int id;
  final String title;
  final String company;
  final String logo;
  final String salary;
  final String location;
  final String type;
  final String shift;
  final List<String> skills;
  final int matchScore;
  final String description;
  final List<String> requirements;
  final List<String> benefits;

  const JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.logo,
    required this.salary,
    required this.location,
    required this.type,
    required this.shift,
    required this.skills,
    required this.matchScore,
    required this.description,
    required this.requirements,
    required this.benefits,
  });
}

class ChatModel {
  final int id;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String initials;
  final String bgColor;
  final String textColor;

  const ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.initials,
    required this.bgColor,
    required this.textColor,
  });
}

class NotificationModel {
  final int id;
  final String iconName;
  final String bgColor;
  final String iconColor;
  final String title;
  final String body;
  final String time;
  final bool isUnread;

  const NotificationModel({
    required this.id,
    required this.iconName,
    required this.bgColor,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    required this.isUnread,
  });
}