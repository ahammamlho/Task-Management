import 'package:flutter/material.dart';
import 'package:management/screen/dashboard_screen.dart';
import 'package:management/screen/profile_screen.dart';
import 'package:management/screen/task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;

  List<Widget> screens = [
    DashboardScreen(),
    TaskScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        body: Column(
      children: [
        Expanded(child: screens[_currentIndex]),
        BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Colors.blue,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ],
    ));
  }
}
