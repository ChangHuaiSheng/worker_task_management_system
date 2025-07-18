import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:worker_task_management_system/view/loginscreen.dart';
import 'package:worker_task_management_system/view/profilepage.dart';
import 'package:worker_task_management_system/view/submissionhistoryscreen.dart';
import 'package:worker_task_management_system/view/mainscreen.dart';
import 'package:worker_task_management_system/view/submittaskpage.dart';
import 'package:worker_task_management_system/model/user.dart';
import 'package:worker_task_management_system/model/work.dart';
import 'package:worker_task_management_system/myconfig.dart';

class TaskListPage extends StatefulWidget {
  final User user;

  const TaskListPage({Key? key, required this.user}) : super(key: key);

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<dynamic> tasks = [];
  bool isLoading = true;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final userId = widget.user.userId;

    if (userId == null || userId == '0') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid user ID. Cannot load tasks.',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      });
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/wtms/php/get_works.php"),
        body: {'worker_id': userId},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          tasks = decoded is List ? decoded : [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load tasks. Status code: ${response.statusCode}');
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      });
      setState(() {
        isLoading = false;
      });
    }
  }

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
      MaterialPageRoute(builder: (_) => page),
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
        title: const Text('My Tasks', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 52, 119, 219),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3477DB), Color(0xFF4E9CFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profileImage,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.user.userName ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, "Home", () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen(user: widget.user)));
            }),
            _buildDrawerItem(Icons.assignment, "Tasks", () {
              Navigator.pop(context);
            }),
            _buildDrawerItem(Icons.history, "Submission History", () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SubmissionHistoryScreen(user: widget.user)));
            }),
            _buildDrawerItem(Icons.person, "Profile", () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfilePage(user: widget.user)));
            }),
            const Spacer(),
            const Divider(),
            _buildDrawerItem(Icons.logout, "Logout", () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // close dialog
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
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
            }, iconColor: Colors.red, textColor: Colors.red),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? const Center(child: Text("No tasks found."))
              : ListView.builder(
                  itemCount: tasks.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    final taskMap = tasks[index];
                    final workTask = Work.fromJson(taskMap);
                    final isCompleted = workTask.status == 'success' || workTask.status == 'completed';

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: isCompleted ? const Color(0xFFE0E0E0) : Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Row(
                          children: [
                            Icon(
                              isCompleted ? Icons.task : Icons.insert_drive_file,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                workTask.title ?? 'No Title',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted ? Colors.grey : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(workTask.description ?? 'No Description'),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.date_range, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text("Due: ${workTask.dueDate ?? 'N/A'}"),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text("Status: ${workTask.status ?? 'unknown'}"),
                              ],
                            ),
                          ],
                        ),
                        onTap: isCompleted
                            ? null
                            : () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SubmitTaskPage(
                                      user: widget.user,
                                      task: workTask,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _loadTasks();
                                }
                              },
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF3477DB),
        unselectedItemColor: Colors.grey,
        onTap: _navigateTo,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap,
      {Color iconColor = Colors.black, Color textColor = Colors.black}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }
}
