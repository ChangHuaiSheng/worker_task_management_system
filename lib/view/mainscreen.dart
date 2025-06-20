import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:worker_task_management_system/view/profilepage.dart';
import 'package:worker_task_management_system/view/submissionhistoryscreen.dart';
import 'package:worker_task_management_system/view/tasklistpage.dart';
import 'package:worker_task_management_system/view/loginscreen.dart';
import 'package:worker_task_management_system/view/registerscreen.dart';
import 'package:worker_task_management_system/model/user.dart';

class MainScreen extends StatefulWidget {
  final User user;

  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _navigateTo(int index) {
    Widget page;
    switch (index) {
      case 0:
        page = MainScreen(user: widget.user);
        break;
      case 1:
        page = TaskListPage(user: widget.user);
        break;
      case 2:
        page = SubmissionHistoryScreen(user: widget.user);
        break;
      case 3:
        page = ProfilePage(user: widget.user);
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object> profileImage;
    if (widget.user.userImage != null && widget.user.userImage!.isNotEmpty) {
      try {
        profileImage = MemoryImage(base64Decode(widget.user.userImage!));
      } catch (_) {
        profileImage = const AssetImage("assets/images/profile.png");
      }
    } else {
      profileImage = const AssetImage("assets/images/profile.png");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Screen", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 52, 119, 219),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showLogoutConfirmation(context),
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),

      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 52, 119, 219),
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profileImage,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.user.userName ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
                _navigateTo(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text("Tasks"),
              onTap: () {
                Navigator.pop(context);
                _navigateTo(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Submission History"),
              onTap: () {
                Navigator.pop(context);
                _navigateTo(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                _navigateTo(3);
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () => _showLogoutConfirmation(context),
            ),
          ],
        ),
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

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _navigateTo(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Tasks",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.user.userId == "0") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Add new product screen later"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        backgroundColor: const Color.fromARGB(255, 52, 119, 219),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
