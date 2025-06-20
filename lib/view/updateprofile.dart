import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:worker_task_management_system/model/user.dart';
import 'package:worker_task_management_system/myconfig.dart';

class UpdateProfilePage extends StatefulWidget {
  final User user;

  const UpdateProfilePage({super.key, required this.user});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController name, email, phone, address;
  File? _image;
  Uint8List? webImageBytes;

  // Initialize controllers with current user data
  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.user.userName);
    email = TextEditingController(text: widget.user.userEmail);
    phone = TextEditingController(text: widget.user.userPhone);
    address = TextEditingController(text: widget.user.userAddress);
  }

  // Show confirmation dialog before updating profile
  Future<void> _confirmAndUpdateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Update"),
        content: const Text("Are you sure you want to update your profile?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
        ],
      ),
    );

    if (confirm == true) {
      _updateProfile();
    }
  }

  // Send updated profile data (and image if available) to backend
  Future<void> _updateProfile() async {
    String? base64Image;

    try {
      if (_image != null) {
        final bytes = kIsWeb ? webImageBytes! : await _image!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      final res = await http.post(
        Uri.parse("${MyConfig.myurl}/wtms/php/update_profile.php"),
        body: {
          "worker_id": widget.user.userId ?? "",
          "full_name": name.text,
          "email": email.text,
          "phone": phone.text,
          "address": address.text,
          if (base64Image != null) "image": base64Image,
        },
      );

      final jsondata = jsonDecode(res.body);
      if (jsondata['status'] == 'success') {
        // Update local user object
        widget.user.userEmail = email.text;
        widget.user.userPhone = phone.text;
        widget.user.userAddress = address.text;
        if (base64Image != null) widget.user.userImage = base64Image;

        if (context.mounted) {
          // Show brief loading indicator then return success
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );

          await Future.delayed(const Duration(seconds: 1));

          if (context.mounted) {
            Navigator.pop(context); // close loading dialog
            Navigator.pop(context, true); // return to ProfilePage
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsondata['message'] ?? "Update failed"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // Builds a styled form input field with optional validation
  Widget _buildInputField(String label, TextEditingController controller,
      {bool enabled = true, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        validator: (v) {
          if (!enabled) return null;
          if (v == null || v.isEmpty) return 'Required';
          if (label == "Email" && !RegExp(r"^[^@]+@[^@]+\.[^@]+").hasMatch(v)) return 'Enter valid email';
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: !enabled,
          fillColor: enabled ? Colors.white : const Color.fromARGB(255, 240, 240, 240),
        ),
      ),
    );
  }

  // Handles image selection from gallery (web or mobile)
  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        webImageBytes = await pickedFile.readAsBytes();
      } else {
        _image = File(pickedFile.path);
      }
      setState(() {});
    }
  }

  // UI layout
  @override
  Widget build(BuildContext context) {
    ImageProvider<Object> profileImage;

    if (_image != null) {
      profileImage = kIsWeb && webImageBytes != null
          ? MemoryImage(webImageBytes!) as ImageProvider<Object>
          : FileImage(_image!) as ImageProvider<Object>;
    } else if (widget.user.userImage != null && widget.user.userImage!.isNotEmpty) {
      try {
        final decoded = base64Decode(widget.user.userImage!);
        profileImage = MemoryImage(decoded);
      } catch (e) {
        profileImage = const AssetImage("assets/images/profile.png");
      }
    } else {
      profileImage = const AssetImage("assets/images/profile.png");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 52, 119, 219),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile picture with image picker
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImage,
                ),
              ),
              const SizedBox(height: 20),
              // Form fields
              _buildInputField("Full Name", name, enabled: false),
              _buildInputField("Email", email),
              _buildInputField("Phone", phone),
              _buildInputField("Address", address, maxLines: 3),
              const SizedBox(height: 30),
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 52, 119, 219),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _confirmAndUpdateProfile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
