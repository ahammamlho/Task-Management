import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:management/dto/task_dto.dart';
import 'package:management/sql/sql_database.dart';
import 'package:management/utils/task_convert.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  TaskDetailScreen({required this.task});
  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task task;
  late TaskStatus initStatus;
  String _currentCity = "--";

  @override
  void initState() {
    super.initState();
    task = widget.task;
    initStatus = task.status;
    print(task.toMap());
  }

  Future<void> _getCurrentCity() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition();

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentCity = place.locality ?? "Unknown city";
        });
      }
    } catch (e) {
      setState(() {
        _currentCity = "Error fetching city: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        padding: const EdgeInsets.only(top: 60),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFFD5D9E5),
              Color(0xFFA9B8E5),
              Color(0xFF9DAFE5),
              Color(0xFFB3C1E3),
              Color(0xFFCBDBE5),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_sharp),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('Task Details'),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () => _showDeleteDialog(),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildStatus(),
                      _buildDates(),
                      if (task.status != TaskStatus.pending) _buildComments(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF4F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            getTaskCategoryString(task.category),
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF4F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status :', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          DropdownButtonFormField<TaskStatus>(
            value: initStatus,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: TaskStatus.values.map((status) {
              bool isDisabled = (task.status == TaskStatus.completed ||
                  task.startDate.isAfter(DateTime.now()) ||
                  (task.status == TaskStatus.inProgress &&
                      status == TaskStatus.pending));

              return DropdownMenuItem(
                value: status,
                enabled: !isDisabled,
                child: Text(
                  getTaskStatusString(status),
                  style: TextStyle(
                    color: isDisabled ? Colors.grey : Colors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: (newStatus) async {
              if (newStatus != null && newStatus != task.status) {
                _showChangeStatusDialog(newStatus);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showChangeStatusDialog(TaskStatus newStatus) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Status'),
        content: Text(
            'Are you sure you want to change status to ${getTaskStatusString(newStatus)}?'),
        actions: [
          TextButton(
            onPressed: () => {Navigator.pop(context)},
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _getCurrentCity();
              final updatedTask = Task(
                  id: task.id,
                  userId: task.userId,
                  title: task.title,
                  category: task.category,
                  startDate: task.startDate,
                  endDate: task.endDate,
                  status: newStatus,
                  comments: task.comments,
                  location: _currentCity);

              await TaskDatabase.instance.updateTask(updatedTask);
              setState(() {
                task = updatedTask;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Status has been changed'),
                    backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildDates() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF4F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Timeline', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.blue),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Start Date'),
                  Text(formatDateToString(task.startDate)),
                  Text(formatTime(task.startDate)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.calendar_today, color: Colors.grey),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('End Date'),
                  Text(formatDateToString(task.endDate)),
                  Text(formatTime(task.endDate)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComments() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF4F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Comments:', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          if (task.comments.isEmpty) const Text('pas comment'),
          ...task.comments.map((comment) => _buildCommentItem(comment)),
          const SizedBox(height: 30),
          addComment(task)
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment.text),
          const SizedBox(height: 4),
          if (comment.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: comment.imageUrls.map((url) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.file(
                      File(url),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                formatDateWithTime(comment.createdAt),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await TaskDatabase.instance.deleteTask(task.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget addComment(Task task) {
    final TextEditingController commentController = TextEditingController();
    List<String> selectedImages = [];

    return StatefulBuilder(builder: (context, setState) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Comment',
                border: const OutlineInputBorder(),
                suffixIcon: selectedImages.length < 3
                    ? IconButton(
                        icon: const Icon(
                          Icons.attach_file,
                        ),
                        onPressed: () async {
                          final image = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            setState(() {
                              selectedImages.add(image.path);
                            });
                          }
                        },
                      )
                    : null,
              ),
            ),
            if (selectedImages.isNotEmpty)
              SizedBox(
                height: 100,
                width: double.infinity,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Image.file(
                            File(selectedImages[index]),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 16,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedImages.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.isNotEmpty) {
                      final comment = Comment(
                        text: commentController.text,
                        userId: 'currentUserId', // Replace with actual user
                        createdAt: DateTime.now(),
                        imageUrls: selectedImages,
                      );

                      await TaskDatabase.instance.addComment(task.id, comment);
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            )
          ],
        ),
      );
    });
  }
}
