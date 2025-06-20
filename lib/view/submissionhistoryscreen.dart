import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:worker_task_management_system/view/loginscreen.dart';
import 'package:worker_task_management_system/view/profilepage.dart';
import 'package:worker_task_management_system/view/tasklistpage.dart';
import 'package:worker_task_management_system/view/editsubmission.dart';
import 'package:worker_task_management_system/view/mainscreen.dart';
import 'package:worker_task_management_system/model/user.dart';
import 'package:worker_task_management_system/myconfig.dart';

class SubmissionHistoryScreen extends StatefulWidget {
  final User user;

  const SubmissionHistoryScreen({super.key, required this.user});

  @override
  State<SubmissionHistoryScreen> createState() => _SubmissionHistoryScreenState();
}

class _SubmissionHistoryScreenState extends State<SubmissionHistoryScreen> {
  List<Map<String, dynamic>> submissions = [];
  bool loading = true;
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadSubmissions(); // Load submission data on screen load
  }

  // Loads submission history from the server
  void _loadSubmissions() async {
    final workerId = widget.user.userId ?? "";
    if (workerId.isEmpty) {
      setState(() => loading = false);
      return;
    }

    try {
      final res = await http.post(
        Uri.parse("${MyConfig.myurl}/wtms/php/get_submissions.php"),
        body: {"worker_id": workerId},
      );

      final jsondata = jsonDecode(res.body);
      if (jsondata['status'] == 'success') {
        setState(() {
          submissions = List<Map<String, dynamic>>.from(jsondata['data']);
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print("Submission error: $e");
      setState(() => loading = false);
    }
  }

  // Handle bottom navigation bar tab switching
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
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    // Prepare profile image for drawer header
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
        title: const Text("Submission History", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 52, 119, 219),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      // Drawer navigation with profile and links to pages
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
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TaskListPage(user: widget.user)));
            }),
            _buildDrawerItem(Icons.history, "Submission History", () {
              Navigator.pop(context);
            }),
            _buildDrawerItem(Icons.person, "Profile", () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfilePage(user: widget.user)));
            }),
            const Spacer(),
            const Divider(),
            // Logout with confirmation dialog
            _buildDrawerItem(Icons.logout, "Logout", () {
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

      // Display loading, empty message, or submission list
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : submissions.isEmpty
              ? const Center(child: Text("No submissions found."))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    var s = submissions[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Row(
                          children: [
                            const Icon(Icons.description, color: Color(0xFF3477DB)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                s['title'] ?? 'No Title',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text("Submitted: ${s['submitted_at'] ?? ''}", style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(s['submission_text'] ?? '', style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        // Tap to edit submission
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => EditSubmissionScreen(submission: s)),
                          ).then((value) {
                            if (value == true) _loadSubmissions(); // reload after edit
                          });
                        },
                      ),
                    );
                  },
                ),

      // Bottom navigation bar
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

  // Drawer item builder helper
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap,
      {Color iconColor = Colors.black, Color textColor = Colors.black}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }
}
