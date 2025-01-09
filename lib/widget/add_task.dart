import 'package:flutter/material.dart';
import 'package:management/dto/notification_dto.dart';
import 'package:management/dto/task_dto.dart';
import 'package:management/sql/sql_database.dart';
import 'package:management/utils/notification.dart';
import 'package:management/utils/task_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController titleController = TextEditingController();
  TaskCategory selectedCategory = TaskCategory.ux;
  final now = DateTime.now();
  late DateTime startDate;
  late DateTime endDate;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    getUserId();
    startDate = now;
    endDate = now.add(const Duration(days: 7));
  }

  late String idUser;
  Future<void> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    idUser = prefs.getString('idUser') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                border: const OutlineInputBorder(),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isError ? Colors.red : Colors.grey,
                  ),
                ),
                errorText: isError ? 'Title cannot be empty' : null,
              ),
              onChanged: (value) {
                setState(() {
                  isError = value.isEmpty;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskCategory>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: TaskCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(getTaskCategoryString(category)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Start Date: ${formatDateToString(startDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await pickDateTime(context, startDate);
                if (picked != null) {
                  setState(() {
                    startDate = picked;
                    endDate = picked.add(const Duration(days: 1));
                  });
                }
              },
            ),
            ListTile(
              title: Text('End Date: ${formatDateToString(endDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await pickDateTime(context, startDate);
                if (picked != null) {
                  setState(() {
                    endDate = picked;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (titleController.text.isEmpty) {
              setState(() {
                isError = true;
              });
              return;
            }
            final newTask = Task(
              title: titleController.text,
              userId: idUser,
              category: selectedCategory,
              startDate: startDate,
              endDate: endDate,
              status: TaskStatus.pending,
            );
            await TaskDatabase.instance.insertTask(newTask);

            final newNotifica = NotificationDto(
              userId: idUser,
              notificationId:
                  DateTime.now().millisecondsSinceEpoch % 2147483647,
              body:
                  'Task ${titleController.text} is close to its estimated completion time',
              launchDate: endDate,
              isRead: 0,
            );
            final idNotif =
                await TaskDatabase.instance.insertNotifocation(newNotifica);
            await NotificationService.scheduleNotification(
              id: newNotifica.notificationId,
              title: "Approaching Deadline",
              body: newNotifica.body,
              scheduledDate: newNotifica.launchDate,
            );
            Navigator.pop(context);
          },
          child: const Text('Add Task'),
        ),
      ],
    );
  }

  Future<DateTime?> pickDateTime(
      BuildContext context, DateTime initialDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: DateTime(initialDate.year + 1, 12, 31),
    );

    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (time == null) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
}
