import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'submittaskpage.dart';
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

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final userId = widget.user.userId;

    if (userId == null || userId == '0') {
      print("Invalid user ID: $userId");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid user ID. Cannot load tasks.')),
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
          SnackBar(content: Text('Error: $e')),
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
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? const Center(child: Text("No tasks found."))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final taskMap = tasks[index];
                    final workTask = Work.fromJson(taskMap);

                    final isCompleted = workTask.status == 'success' || workTask.status == 'completed';

                    return Card(
                      margin: const EdgeInsets.all(10),
                      color: isCompleted ? Colors.grey[200] : Colors.white,
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
                                  _loadTasks(); // Reload tasks on return
                                }
                              },
                      ),
                    );
                  },
                ),
    );
  }
}
