import 'package:flutter/material.dart';
import 'package:management/screen/notif_screen.dart';
import 'package:management/screen/task_detail_screen.dart';
import 'package:management/sql/sql_database.dart';
import 'package:management/dto/task_dto.dart';
import 'package:management/utils/task_convert.dart';
import 'package:management/widget/add_task.dart';
import 'package:management/widget/task_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Task> allTasks = [];
  List<Task> filteredTasks = [];
  List<Task> tasks = [];
  TaskCategory? selectedCategoryFilter;
  TaskStatus? selectedStatusFilter;
  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String idUser = prefs.getString('idUser') ?? '';
    allTasks = await TaskDatabase.instance.getAllTasks(idUser);
    filteredTasks = allTasks;
    setState(() {
      tasks = allTasks;
    });
  }

  void filterTasks() {
    filteredTasks = allTasks.where((task) {
      bool matchesCategory = selectedCategoryFilter == null ||
          task.category == selectedCategoryFilter;
      bool matchesStatus =
          selectedStatusFilter == null || task.status == selectedStatusFilter;
      return matchesCategory && matchesStatus;
    }).toList();
    tasks = filteredTasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 80),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (context) => const AddTaskDialog(),
                            );
                            loadTasks();
                          },
                          icon: const Icon(Icons.add, color: Colors.black)),
                      const Text(
                        'Task',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsScreen()),
                            );
                          },
                          icon: const Icon(Icons.notifications_outlined,
                              color: Colors.black))
                    ],
                  ),
                  const Text(
                    'Task List',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          tasks = filteredTasks;
                        } else {
                          tasks = filteredTasks
                              .where((task) => task.title
                                  .toLowerCase()
                                  .contains(value.trim().toLowerCase()))
                              .toList();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: showFilterDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_list,
                                color: selectedCategoryFilter == null &&
                                        selectedStatusFilter == null
                                    ? null
                                    : Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Filter',
                                style: TextStyle(
                                  color: selectedCategoryFilter == null &&
                                          selectedStatusFilter == null
                                      ? null
                                      : Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TaskDetailScreen(task: tasks[index])),
                        );
                        loadTasks();
                      },
                      child: TaskCard(task: tasks[index]));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<TaskCategory?>(
              value: selectedCategoryFilter,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...TaskCategory.values.map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(getTaskCategoryString(category)),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  selectedCategoryFilter = value;
                  filterTasks();
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskStatus?>(
              value: selectedStatusFilter,
              decoration: const InputDecoration(labelText: 'Status'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...TaskStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(getTaskStatusString(status)),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  selectedStatusFilter = value;
                  filterTasks();
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedCategoryFilter = null;
                selectedStatusFilter = null;
                filterTasks();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear Filters'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
