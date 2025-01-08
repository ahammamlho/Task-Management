import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:management/dto/user_dto.dart';
import 'package:management/screen/task_detail_screen.dart';
import 'package:management/sql/sql_database.dart';
import 'package:management/dto/task_dto.dart';
import 'package:management/widget/task_card.dart';
import 'package:management/widget/task_card_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isLoading = true;
  List<Task> allTasks = [];
  List<Task> tasks = [];
  Map<TaskStatus, double> counts = {};
  User? user;
  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void getUserData(String idUser) async {
    final tmp = await TaskDatabase.instance.getUserById(idUser);
    setState(() {
      user = tmp;
    });
  }

  Future<void> loadTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String idUser = prefs.getString('idUser') ?? '';
    getUserData(idUser);
    final tmp = await TaskDatabase.instance.getAllTasks(idUser);
    setState(() {
      tasks = tmp;
      allTasks = tasks;
      counts = getTaskStatusCount(tasks);
      isLoading = false;
    });
  }

  Map<TaskStatus, double> getTaskStatusCount(List<Task> tasks) {
    return {
      TaskStatus.inProgress:
          tasks.where((t) => t.status == TaskStatus.inProgress).length /
              tasks.length,
      TaskStatus.pending:
          tasks.where((t) => t.status == TaskStatus.pending).length /
              tasks.length,
      TaskStatus.cancelled:
          tasks.where((t) => t.status == TaskStatus.cancelled).length /
              tasks.length,
      TaskStatus.completed:
          tasks.where((t) => t.status == TaskStatus.completed).length /
              tasks.length,
    };
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
        child: !isLoading
            ? Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Dashbord',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: PieChart(
                      PieChartData(sections: [
                        PieChartSectionData(
                            value: counts[TaskStatus.completed],
                            color: Colors.green,
                            title: "${counts[TaskStatus.completed]! * 100}%"),
                        PieChartSectionData(
                            value: counts[TaskStatus.pending],
                            color: Colors.orange,
                            title: "${counts[TaskStatus.pending]! * 100}%"),
                        PieChartSectionData(
                            value: counts[TaskStatus.cancelled],
                            color: Colors.red,
                            title: "${counts[TaskStatus.cancelled]! * 100}%"),
                        PieChartSectionData(
                            value: counts[TaskStatus.inProgress],
                            color: Colors.blue,
                            title: "${counts[TaskStatus.inProgress]! * 100}%"),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      actions('Completed', Colors.green, () {
                        setState(() {
                          tasks = allTasks
                              .where(
                                  (task) => task.status == TaskStatus.completed)
                              .toList();
                        });
                      }),
                      actions('pending', Colors.orange, () {
                        setState(() {
                          tasks = allTasks
                              .where(
                                  (task) => task.status == TaskStatus.pending)
                              .toList();
                        });
                      }),
                      actions('cancelled', Colors.red, () {
                        setState(() {
                          tasks = allTasks
                              .where(
                                  (task) => task.status == TaskStatus.cancelled)
                              .toList();
                        });
                      }),
                      actions('inProgress', Colors.blue, () {
                        setState(() {
                          tasks = allTasks
                              .where((task) =>
                                  task.status == TaskStatus.inProgress)
                              .toList();
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                            child: tasks[index].status != TaskStatus.pending
                                ? TaskCardDashboard(
                                    task: tasks[index], user: user!)
                                : TaskCard(task: tasks[index]));
                      },
                    ),
                  ),
                ],
              )
            : Container(),
      ),
    );
  }

  Widget actions(String title, Color color, onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
