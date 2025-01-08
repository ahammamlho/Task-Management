import 'package:uuid/uuid.dart';

class NotificationDto {
  final String id;
  final int notificationId;
  final String userId;
  final String body;
  final DateTime launchDate;
  final int isRead;

  NotificationDto({
    String? id,
    required this.userId,
    required this.notificationId,
    required this.body,
    required this.launchDate,
    this.isRead = 0,
  }) : this.id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'notificationId': notificationId,
      'body': body,
      'launchDate': launchDate.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory NotificationDto.fromMap(Map<String, dynamic> map) {
    return NotificationDto(
      id: map['id'],
      notificationId: map['notificationId'],
      userId: map['userId'],
      body: map['body'],
      launchDate: DateTime.parse(map['launchDate']),
      isRead: map['isRead'],
    );
  }
}
