import 'package:flutter/material.dart';
import 'package:management/dto/task_dto.dart';
import 'package:management/dto/user_dto.dart';
import 'package:management/utils/task_service.dart';

class TaskCardDashboard extends StatelessWidget {
  final Task task;
  final User user;

  const TaskCardDashboard({required this.task, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF4F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.blue,
                    child: Text(
                      user.fullName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user.username,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: getTaskStatusColor(task.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  getTaskStatusString(task.status),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(formatTimeRange(task.startDate, task.endDate)),
          const SizedBox(height: 15),
          Text(
            task.title.length > 20
                ? '${task.title.substring(0, 20)}...'
                : task.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
              ),
              const SizedBox(width: 5),
              Text(
                task.location ?? "",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              actions(
                  "Accept", Icons.done, Colors.green[200], Colors.greenAccent),
              actions(
                  "Reject", Icons.cancel, Colors.red[200], Colors.redAccent),
              actions("Call", Icons.call, Colors.blue[200], Colors.blueAccent),
              actions("Map", Icons.map, Colors.deepPurple[200],
                  Colors.deepPurpleAccent),
            ],
          )
        ],
      ),
    );
  }

  Widget actions(String title, IconData icon, Color? bg, Color iconColor) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 2),
            Text(title),
          ],
        ));
  }
}
