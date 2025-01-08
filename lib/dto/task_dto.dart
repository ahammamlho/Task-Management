import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String userId;
  final String title;
  final TaskCategory category;
  final DateTime startDate;
  final DateTime endDate;
  final TaskStatus status;
  final List<Comment> comments;
  final DateTime createdAt;
  final String? location;

  Task({
    String? id,
    required this.userId,
    required this.title,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.location,
    List<Comment>? comments,
    DateTime? createdAt,
  })  : this.id = id ?? const Uuid().v4(),
        this.comments = comments ?? [],
        this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'category': category.index,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.index,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      location: map['location'],
      category: TaskCategory.values[map['category']],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      status: TaskStatus.values[map['status']],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class Comment {
  final String id;
  final String text;
  final String userId;
  final DateTime createdAt;
  final List<String> imageUrls;

  Comment({
    String? id,
    required this.text,
    required this.userId,
    required this.createdAt,
    List<String>? imageUrls,
  })  : this.id = id ?? const Uuid().v4(),
        this.imageUrls = imageUrls ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      text: map['text'],
      userId: map['userId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

enum TaskStatus { pending, inProgress, completed, cancelled }

enum TaskCategory { ux, mobile, web, security }
