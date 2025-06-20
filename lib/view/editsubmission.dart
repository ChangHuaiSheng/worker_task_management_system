import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:worker_task_management_system/myconfig.dart';

class EditSubmissionScreen extends StatefulWidget {
  final Map submission;

  const EditSubmissionScreen({super.key, required this.submission});

  @override
  State<EditSubmissionScreen> createState() => _EditSubmissionScreenState();
}

class _EditSubmissionScreenState extends State<EditSubmissionScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.submission['submission_text']); // Prefill with current text
  }

  // Confirm dialog before updating the submission
  void _confirmUpdate() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Submission text cannot be empty"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Update"),
        content: const Text("Are you sure you want to save changes to your submission?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _updateSubmission();
    }
  }

  // Sends update request to the server and handles response
  void _updateSubmission() async {
    // Show a loading dialog while submitting
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      var res = await http.post(
        Uri.parse("${MyConfig.myurl}/wtms/php/edit_submission.php"),
        body: {
          "submission_id": widget.submission['id'].toString(),
          "updated_text": _controller.text,
        },
      );

      await Future.delayed(const Duration(seconds: 1)); // Simulated delay

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      var jsondata = jsonDecode(res.body);
      if (jsondata['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Submission updated."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return success to previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsondata['message'] ?? "Update failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle and display any errors
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar
      appBar: AppBar(
        title: const Text("Edit Submission"),
        backgroundColor: const Color.fromARGB(255, 52, 119, 219),
        foregroundColor: Colors.white,
      ),

      // Form UI
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Submission title display
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.edit_note, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.submission['title'] ?? 'No Title',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Editable text field
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                labelText: "Edit your submission",
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirmUpdate,
                icon: const Icon(Icons.save),
                label: const Text("Save"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 52, 119, 219),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
