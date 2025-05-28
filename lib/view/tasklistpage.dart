import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'submittaskpage.dart';
import 'package:worker_task_management_system/model/user.dart';
import 'package:worker_task_management_system/model/work.dart';
import 'package:worker_task_management_system/myconfig.dart';

// This widget displays a list of tasks assigned to a specific user (worker)
class TaskListPage extends StatefulWidget {
  final User user;

  const TaskListPage({Key? key, required this.user}) : super(key: key);

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<dynamic> tasks = [];      // List to hold fetched task data
  bool isLoading = true;         // Flag to indicate loading state

  @override
  void initState() {
    super.initState();
    _loadTasks();               // Fetch tasks when the page is initialized
  }

  // Function to fetch tasks for the current user
  Future<void> _loadTasks() async {
    final userId = widget.user.userId;

    // Validate the user ID before making the API call
    if (userId == null || userId == '0') {
      print("Invalid user ID: $userId");
      WidgetsBinding.instance.addPostFrameCallback((_) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text(
              'Invalid user ID. Cannot load tasks.',
               style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        });
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Try to load tasks from the backend
    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/wtms/php/get_works.php"),
        body: {'worker_id': userId},
      );

      print("API Response: ${response.body}");

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
      print("Error loading tasks: $e");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 52, 119, 219),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          // Show loading spinner while data is being fetched
          ? const Center(child: CircularProgressIndicator())
          // Show message if no tasks are found
          : tasks.isEmpty
              ? const Center(child: Text("No tasks found."))
              // Display list of tasks
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final taskMap = tasks[index];
                    final workTask = Work.fromJson(taskMap); // Convert map to Work object

                    // Determine if the task is already completed
                    final isCompleted = workTask.status == 'success' || workTask.status == 'completed';

                    return Card(
                      margin: const EdgeInsets.all(10),
                      color: isCompleted ? Colors.grey[200] : Colors.white, // Grey out completed tasks
                      child: ListTile(
                        title: Text(
                          workTask.title ?? 'No Title',
                          style: TextStyle(
                            color: isCompleted ? Colors.grey : Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(workTask.description ?? 'No Description'),
                            Text("Due: ${workTask.dueDate ?? 'N/A'}"),
                            Text("Status: ${workTask.status ?? 'unknown'}"),
                          ],
                        ),
                        // Disable tap if task is completed
                        onTap: isCompleted
                            ? null
                            : () async {
                                // Navigate to submission page
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SubmitTaskPage(
                                      user: widget.user,
                                      task: workTask,
                                    ),
                                  ),
                                );

                                // If submission was successful, refresh the task list
                                if (result == true) {
                                  _loadTasks();
                                }
                              },
                      ),
                    );
                  },
                ),
    );
  }
}

