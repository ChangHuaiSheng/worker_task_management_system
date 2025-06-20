import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:worker_task_management_system/model/user.dart';
import 'package:worker_task_management_system/view/updateprofile.dart';
import 'package:worker_task_management_system/view/tasklistpage.dart';
import 'package:worker_task_management_system/view/submissionhistoryscreen.dart';
import 'package:worker_task_management_system/view/mainscreen.dart';
import 'package:worker_task_management_system/view/loginscreen.dart';
import 'package:worker_task_management_system/myconfig.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUpdatedProfile(); // Load latest user profile from backend
  }

  // Handles bottom navigation tap
  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    // Navigate to corresponding page based on selected index
    Widget targetPage;
    switch (index) {
      case 0:
        targetPage = MainScreen(user: widget.user);
        break;
      case 1:
        targetPage = TaskListPage(user: widget.user);
        break;
      case 2:
        targetPage = SubmissionHistoryScreen(user: widget.user);
        break;
      case 3:
      default:
        targetPage = ProfilePage(user: widget.user);
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => targetPage),
    );
  }

  // Fetch latest user profile data from server
  Future<void> _fetchUpdatedProfile() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse("${MyConfig.myurl}/wtms/php/get_profile.php"),
        body: {"worker_id": widget.user.userId ?? ""},
      );

      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        final updatedUser = data['data'];
        setState(() {
          widget.user.userName = updatedUser['full_name'];
          widget.user.userEmail = updatedUser['email'];
          widget.user.userPhone = updatedUser['phone'];
          widget.user.userAddress = updatedUser['address'];
          widget.user.userImage = updatedUser['image'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Failed to load profile"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profile: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine which profile image to show
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
      // App Bar
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 52, 119, 219),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      // Drawer menu (navigation + logout)
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
              padding: const EdgeInsets.only(top: 50, bottom: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profileImage,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.user.userName ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildDrawerItem(Icons.home, "Home", () => _onItemTapped(0)),
            _buildDrawerItem(Icons.assignment, "Tasks", () => _onItemTapped(1)),
            _buildDrawerItem(Icons.history, "Submission History", () => _onItemTapped(2)),
            _buildDrawerItem(Icons.person, "Profile", () => _onItemTapped(3)),
            const Spacer(),
            const Divider(),
            _buildDrawerItem(Icons.logout, "Logout", () {
              // Logout confirmation dialog
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

      // Body: displays profile details or a loading indicator
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundImage: profileImage,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.user.userName ?? '',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildField("Worker ID", widget.user.userId ?? ""),
                          _buildField("Email", widget.user.userEmail ?? ""),
                          _buildField("Phone", widget.user.userPhone ?? ""),
                          _buildField("Address", widget.user.userAddress ?? ""),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Button to navigate to profile update screen
                  ElevatedButton.icon(
                    onPressed: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UpdateProfilePage(user: widget.user),
                        ),
                      );
                      if (updated == true) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Profile updated successfully!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                        _fetchUpdatedProfile(); // Refresh after update
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profile"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 52, 119, 219),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF3477DB),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // Reusable drawer item
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap,
      {Color iconColor = Colors.black, Color textColor = Colors.black}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }

  // Helper to build a display row for profile fields
  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
