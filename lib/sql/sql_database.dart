import 'package:management/dto/notification_dto.dart';
import 'package:management/dto/task_dto.dart';
import 'package:management/dto/user_dto.dart';
import 'package:management/utils/bcrypt.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class TaskDatabase {
  static final TaskDatabase instance = TaskDatabase._init();
  static Database? _database;

  TaskDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
     CREATE TABLE users (
       id TEXT PRIMARY KEY,
       email TEXT NOT NULL,
       hashPassword TEXT NOT NULL,
       fullName TEXT NOT NULL,
       username TEXT NOT NULL
     )
   ''');

    await db.execute('''
     CREATE TABLE notifications (
      id TEXT PRIMARY KEY,
      userId TEXT NOT NULL,
      notificationId INTEGER NOT NULL,
      body TEXT NOT NULL,
      launchDate TEXT NOT NULL,
      isRead INTEGER DEFAULT 0
    )
   ''');

    await db.execute('''
     CREATE TABLE tasks (
       id TEXT PRIMARY KEY,
       userId TEXT NOT NULL,
       title TEXT NOT NULL,
       category INTEGER NOT NULL,
       startDate TEXT NOT NULL,
       endDate TEXT NOT NULL,
       location TEXT,
       status INTEGER NOT NULL,
       createdAt TEXT NOT NULL
     )
   ''');

    await db.execute('''
     CREATE TABLE comments (
       id TEXT PRIMARY KEY,
       taskId TEXT NOT NULL,
       text TEXT NOT NULL,
       userId TEXT NOT NULL,
       createdAt TEXT NOT NULL,
       FOREIGN KEY (taskId) REFERENCES tasks (id)
     )
   ''');

    await db.execute('''
     CREATE TABLE comment_images (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       commentId TEXT NOT NULL,
       imageUrl TEXT NOT NULL,
       FOREIGN KEY (commentId) REFERENCES comments (id)
     )
   ''');
  }

  Future<void> insertInitialData() async {
    final db = await database;

    final usersCount =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users'));

    if (usersCount == 0) {
      final List<User> dummyUsers = [
        User(
          email: 'test.user@example.com',
          hashPassword: PasswordHash.hashPassword('123456'),
          fullName: 'John Doe',
          username: 'john_doe',
        ),
      ];
      for (var user in dummyUsers) {
        await insertUser(user);
      }
    }
  }

  Future<void> insertDefaultTasks(String idUser) async {
    final db = await database;

    final tasks =
        await db.query('tasks', where: 'userId = ?', whereArgs: [idUser]);
    if (tasks.isEmpty) {
      final List<Task> dummyTasks = [
        Task(
            id: const Uuid().v4(),
            userId: idUser,
            title: 'Design UI Mockups',
            category: TaskCategory.ux,
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 3)),
            status: TaskStatus.pending,
            location: ""),
        Task(
            id: const Uuid().v4(),
            userId: idUser,
            title: 'Mobile App Development',
            category: TaskCategory.mobile,
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 7)),
            status: TaskStatus.pending,
            location: ""),
      ];
      final List<NotificationDto> dummyNotifications = [
        NotificationDto(
          userId: idUser,
          notificationId: DateTime.now().millisecondsSinceEpoch % 2147483647,
          body:
              'Task ${dummyTasks[0].title} is close to its estimated completion time',
          // launchDate: dummyTasks[0].endDate,
          launchDate: DateTime.now().add(const Duration(seconds: 30)),
          isRead: 0,
        ),
        NotificationDto(
          userId: idUser,
          notificationId: DateTime.now().millisecondsSinceEpoch % 2147483647,
          body:
              'Task ${dummyTasks[1].title} is close to its estimated completion time',
          // launchDate: dummyTasks[2].endDate,
          launchDate: DateTime.now().add(const Duration(seconds: 35)),
          isRead: 0,
        ),
      ];

      for (var task in dummyTasks) {
        await insertTask(task);
      }

      for (var notif in dummyNotifications) {
        await insertNotifocation(notif);
      }
    }
  }

  Future<String> insertUser(User user) async {
    final db = await database;
    await db.insert('users', {
      'id': user.id,
      'email': user.email,
      'hashPassword': user.hashPassword,
      'fullName': user.fullName,
      'username': user.username,
    });
    return user.id;
  }

  Future<int> insertNotifocation(NotificationDto noti) async {
    final db = await database;
    await db.insert('notifications', {
      'id': noti.id,
      'userId': noti.userId,
      'notificationId': noti.notificationId,
      'body': noti.body,
      'launchDate': noti.launchDate.toIso8601String(),
      'isRead': 0,
    });
    return noti.notificationId;
  }

  Future<String> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', {
      'id': task.id,
      "userId": task.userId,
      'title': task.title,
      'category': task.category.index,
      'startDate': task.startDate.toIso8601String(),
      'endDate': task.endDate.toIso8601String(),
      'status': task.status.index,
      'createdAt': task.createdAt.toIso8601String(),
    });

    for (var comment in task.comments) {
      await insertComment(comment, task.id);
    }

    return task.id;
  }

  Future<void> insertComment(Comment comment, String taskId) async {
    final db = await database;
    await db.insert('comments', {
      'id': comment.id,
      'taskId': taskId,
      'text': comment.text,
      'userId': comment.userId,
      'createdAt': comment.createdAt.toIso8601String(),
    });

    for (var imageUrl in comment.imageUrls) {
      await db.insert('comment_images', {
        'commentId': comment.id,
        'imageUrl': imageUrl,
      });
    }
  }

  Future<List<NotificationDto>> getAllNotifications(String userId) async {
    final db = await database;
    final notiMaps = await db
        .query('notifications', where: 'userId = ?', whereArgs: [userId]);

    return Future.wait(notiMaps.map((noti) async {
      return NotificationDto(
        userId: userId,
        notificationId: noti['notificationId'] as int,
        body: noti['body'] as String,
        launchDate: DateTime.parse(noti['launchDate'] as String),
        isRead: noti['isRead'] as int,
      );
    }));
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final db = await database;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<Task> getTask(String id) async {
    final db = await database;
    final taskMaps = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    final comments = await getTaskComments(id);

    return Task(
      id: taskMaps.first['id'] as String,
      userId: taskMaps.first['userId'] as String,
      title: taskMaps.first['title'] as String,
      category: TaskCategory.values[taskMaps.first['category'] as int],
      startDate: DateTime.parse(taskMaps.first['startDate'] as String),
      endDate: DateTime.parse(taskMaps.first['endDate'] as String),
      status: TaskStatus.values[taskMaps.first['status'] as int],
      comments: comments,
      createdAt: DateTime.parse(taskMaps.first['createdAt'] as String),
    );
  }

  Future<List<Comment>> getTaskComments(String taskId) async {
    final db = await database;
    final commentMaps =
        await db.query('comments', where: 'taskId = ?', whereArgs: [taskId]);

    return Future.wait(commentMaps.map((commentMap) async {
      final imageUrls = await db.query(
        'comment_images',
        columns: ['imageUrl'],
        where: 'commentId = ?',
        whereArgs: [commentMap['id']],
      );

      return Comment(
        id: commentMap['id'] as String,
        text: commentMap['text'] as String,
        userId: commentMap['userId'] as String,
        createdAt: DateTime.parse(commentMap['createdAt'] as String),
        imageUrls: imageUrls.map((img) => img['imageUrl'] as String).toList(),
      );
    }));
  }

  Future<List<Task>> getAllTasks(String userId) async {
    final db = await database;
    final taskMaps = await db.query('tasks',
        where: 'userId = ?', whereArgs: [userId], orderBy: 'createdAt DESC');

    return Future.wait(taskMaps.map((taskMap) async {
      final comments = await getTaskComments(taskMap['id'] as String);

      return Task(
        id: taskMap['id'] as String,
        userId: taskMap['userId'] as String,
        title: taskMap['title'] as String,
        location: taskMap['location'] as String?,
        category: TaskCategory.values[taskMap['category'] as int],
        startDate: DateTime.parse(taskMap['startDate'] as String),
        endDate: DateTime.parse(taskMap['endDate'] as String),
        status: TaskStatus.values[taskMap['status'] as int],
        comments: comments,
        createdAt: DateTime.parse(taskMap['createdAt'] as String),
      );
    }));
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final userMaps = await db.query('users');

    return userMaps.map((map) => User.fromMap(map)).toList();
  }

  Future<User> getUserById(String id) async {
    final db = await database;
    final user = await db.query('users', where: 'id = ?', whereArgs: [id]);

    return User.fromMap(user[0]);
  }

  Future<void> addComment(String taskId, Comment comment) async {
    final db = await database;

    await db.transaction((txn) async {
      String commentId = comment.id;
      await txn.insert('comments', {
        'id': commentId,
        'taskId': taskId,
        'text': comment.text,
        'userId': comment.userId,
        'createdAt': comment.createdAt.toIso8601String(),
      });

      for (String imageUrl in comment.imageUrls) {
        await txn.insert('comment_images', {
          'commentId': commentId,
          'imageUrl': imageUrl,
        });
      }
    });
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
        'tasks',
        {
          'status': task.status.index,
          'location': task.location,
        },
        where: 'id = ?',
        whereArgs: [task.id]);
  }

  Future<void> deleteTask(String taskId) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.rawDelete('''
     DELETE FROM comment_images 
     WHERE commentId IN (
       SELECT id FROM comments WHERE taskId = ?
     )
   ''', [taskId]);

      await txn.delete('comments', where: 'taskId = ?', whereArgs: [taskId]);

      await txn.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
    });
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
