import 'package:flutter/material.dart';
import 'package:management/dto/user_dto.dart';
import 'package:management/screen/login_screen.dart';
import 'package:management/sql/sql_database.dart';
import 'package:management/utils/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String idUser = prefs.getString('idUser') ?? '';
    final tmp = await TaskDatabase.instance.getUserById(idUser);
    setState(() {
      user = tmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: user != null
          ? Container(
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        const Text(
                          'Profile',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.black,
                          ),
                          onPressed: () => _showLogoutDialog(context),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                      child: Text(
                        user!.fullName[0].toUpperCase(),
                        style:
                            const TextStyle(fontSize: 32, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ProfileItem(
                      icon: Icons.person,
                      title: 'Full Name',
                      value: user!.fullName,
                    ),
                    ProfileItem(
                      icon: Icons.account_circle,
                      title: 'Username',
                      value: user!.username,
                    ),
                    ProfileItem(
                      icon: Icons.email,
                      title: 'Email',
                      value: user!.email,
                    ),
                  ],
                ),
              ),
            )
          : Container(),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();

              await prefs.setString('idUser', '');
              await NotificationService.cancelNotificationByUser(
                  idUser: user?.id ?? "");
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  ProfileItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.black)),
              Text(value,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
}
