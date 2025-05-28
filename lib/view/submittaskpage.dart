import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:worker_task_management_system/model/user.dart';
import 'package:worker_task_management_system/model/work.dart';
import 'package:worker_task_management_system/myconfig.dart';

// Page to allow a user to submit work for a task
class SubmitTaskPage extends StatefulWidget {
  final User user; // Logged-in user
  final Work task; // Task to be submitted

  const SubmitTaskPage({
    Key? key,
    required this.user,
    required this.task,
  }) : super(key: key);

  @override
  _SubmitTaskPageState createState() => _SubmitTaskPageState();
}

class _SubmitTaskPageState extends State<SubmitTaskPage> {
  final TextEditingController _submissionController = TextEditingController();
  bool _isSubmitting = false; // Tracks if the submission is in progress

  // Function to handle the submission of a task
  Future<void> _submitTask() async {
    final workId = widget.task.workId;
    final workerId = widget.user.userId ?? '0';
    final submissionText = _submissionController.text.trim();

    // Validate the submission input
    if (submissionText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter submission text.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true); // Show loading spinner

    try {
      // Send POST request to submit work
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/wtms/php/submit_work.php"),
        body: {
          'work_id': workId,
          'worker_id': workerId,
          'submission_text': submissionText,
        },
      );

      final decoded = json.decode(response.body);
      setState(() => _isSubmitting = false);

      // If submission successful
      if (decoded['status'] == 'success') {
        Navigator.pop(context, true); // Return to task list and trigger refresh
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(decoded['message'] ?? 'Submission successful'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Submission failed response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(decoded['message'] ?? 'Submission failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      // Network or server error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Task', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 52, 119, 219),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the task title
            Text(
              'Task: ${widget.task.title}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Text field for entering submission text
            TextField(
              controller: _submissionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'What did you complete?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Submit button or loading spinner
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitTask,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
