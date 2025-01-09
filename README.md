# Task Management Mobile App

A Flutter mobile application for managing tasks with authentication, real-time tracking, and notifications.

## Features

- User Authentication
- Task Management (Create, Read, Update, Delete)
- Task Status Tracking
- Task Comments with Image Attachments
- Push Notifications
- Local Data Storage (SQLite, shared_preferences)

## Project Structure

```
lib/
├── dto/
│   ├── notification_dto.dart
│   ├── task_dto.dart
│   └── user_dto.dart
│
├── screens/
│   ├── dashboard_screen.dart
│   ├── home_screen.dart
│   │── login_screen.dart
│   │── signup_screen.dart
│   │── add_task_screen.dart
│   │── task_detail_screen.dart
│   │── task_list_screen.dart
│   ├── notif_screen.dart
│   └── profile_screen.dart
│
│
├── sql/
│   └── sql_database.dart
│
├── utils/
│   ├── task_service.dart
│   ├── password_hash.dart
│   └── notification.dart
│
├── widgets/
│   ├── task_card.dart
│   └── task_card_dashboard.dart
│
└── main.dart

```

## Database Schema

```
users (id, email, password, fullName, username)
tasks (id, userId, title, category, startDate, endDate, status, location)
comments (id, taskId, text, userId, createdAt)
notifications (id, userId, body, launchDate, isRead)
```

## Dependencies

```yaml
dependencies:
  sqflite: ^2.4.1
  uuid: ^4.5.1
  path: ^1.9.0
  bcrypt: ^1.1.3
  shared_preferences: ^2.3.5
  image_picker: ^1.1.2
  intl: ^0.19.0
  geolocator: ^13.0.2
  geocoding: ^3.0.0
  flutter_local_notifications: ^18.0.1
  timezone: ^0.10.0
  fl_chart: ^0.65.0
```

## Setup

1- Clone repository:

```
git clone https://github.com/ahammamlho/Task-Management
```

2- Install dependencies:

```
flutter pub get
```

3- Run app:

```
flutter run
```

4- Login Credentials:

```
Email: test.user@example.com
Password: 123456
```
