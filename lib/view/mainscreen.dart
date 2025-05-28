import 'package:flutter/material.dart';
import 'package:worker_task_management_system/view/loginscreen.dart';
import 'package:worker_task_management_system/model/user.dart';
import 'package:worker_task_management_system/view/registerscreen.dart';
import 'package:worker_task_management_system/view/profilepage.dart';
import 'package:worker_task_management_system/view/tasklistpage.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Screen", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 52, 119, 219),
        leading: IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)),
            );
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.login, color: Colors.white))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome ${widget.user.userName}",
              style: const TextStyle(fontSize: 24, color: Colors.blue),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskListPage(user: widget.user)),
                );
              },
              icon: const Icon(Icons.task),
              label: const Text("View My Tasks"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.user.userId == "0") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Add new product screen later"),
            ));
          }
        },
        backgroundColor: const Color.fromARGB(255, 52, 119, 219),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
