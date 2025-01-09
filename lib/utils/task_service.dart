import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management/dto/task_dto.dart';

String formatDateToString(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}

String formatTime(DateTime date) {
  return "at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
}

String formatDateWithTime(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
}

String getTaskStatusString(TaskStatus status) {
  switch (status) {
    case TaskStatus.pending:
      return 'Pending';
    case TaskStatus.inProgress:
      return 'In Progress';
    case TaskStatus.completed:
      return 'Completed';
    case TaskStatus.cancelled:
      return 'Canceled';
    default:
      return 'Unknown';
  }
}

String getTaskCategoryString(TaskCategory category) {
  switch (category) {
    case TaskCategory.ux:
      return 'UX Solutions';
    case TaskCategory.mobile:
      return 'Mobile Development';
    case TaskCategory.web:
      return 'Web Development';
    case TaskCategory.security:
      return 'Security';
    default:
      return 'Unknown';
  }
}

Color getTaskStatusColor(TaskStatus status) {
  switch (status) {
    case TaskStatus.pending:
      return Colors.orange;
    case TaskStatus.inProgress:
      return Colors.blue;
    case TaskStatus.completed:
      return Colors.green;
    case TaskStatus.cancelled:
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String formatTimeRange(DateTime startDate, DateTime endDate) {
  final start = DateFormat('h:mm a').format(startDate);
  final end = DateFormat('h:mm a').format(endDate);

  final totalDays = startDate.difference(endDate).inDays.abs();
  final spendDays = startDate.difference(DateTime.now()).inDays.abs();

  return '$start - $end (${spendDays.abs()}/${totalDays.abs()})';
}
