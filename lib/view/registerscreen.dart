import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:worker_task_management_system/myconfig.dart';
import 'package:worker_task_management_system/view/loginscreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  File? _image;
  Uint8List? webImageBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Screen", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 52, 119, 219),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _image != null
                            ? (kIsWeb ? MemoryImage(webImageBytes!) : FileImage(_image!)) as ImageProvider
                            : const AssetImage("assets/images/profile.png"),
                        child: _image == null
                            ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField("Your Name", nameController),
                    _buildTextField("Email", emailController, inputType: TextInputType.emailAddress),
                    _buildTextField("Password", passwordController, obscureText: true),
                    _buildTextField("Re-enter Password", confirmPasswordController, obscureText: true),
                    _buildTextField("Phone", phoneController, inputType: TextInputType.phone),
                    _buildTextField("Address", addressController, maxLines: 3),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        onPressed: registerUserDialog,
                        label: const Text("Register"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 52, 119, 219),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, int maxLines = 1, TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  void registerUserDialog() {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String phone = phoneController.text.trim();
    String address = addressController.text.trim();

    bool isValidEmail(String email) {
      return RegExp(r"^[^@]+@[^@]+\.[^@]+").hasMatch(email);
    }

    if ([name, email, password, confirmPassword, phone, address].any((element) => element.isEmpty)) {
      _showSnack("Please fill all fields", isError: true);
      return;
    }
    if (!isValidEmail(email)) {
      _showSnack("Please enter a valid email address", isError: true);
      return;
    }
    if (password.length < 6) {
      _showSnack("Password must be at least 6 characters", isError: true);
      return;
    }
    if (password != confirmPassword) {
      _showSnack("Passwords do not match", isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Register this account?"),
          content: const Text("Are you sure?"),
          actions: [
            TextButton(
              child: const Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
                registerUser();
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void registerUser() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;
    String phone = phoneController.text.trim();
    String address = addressController.text.trim();
    String? base64Image;

    if (_image != null) {
      final bytes = kIsWeb ? webImageBytes! : await _image!.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/wtms/php/register_worker.php"),
        body: {
          "name": name,
          "email": email,
          "password": password,
          "phone": phone,
          "address": address,
          if (base64Image != null) "image": base64Image,
        },
      );

      final jsondata = json.decode(response.body);
      if (jsondata['status'] == 'success') {
        _showSnack("Success!", isError: false);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      } else {
        _showSnack("Failed to register: ${jsondata['message'] ?? 'Unknown error'}", isError: true);
      }
    } catch (e) {
      _showSnack("Error: $e", isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        webImageBytes = await pickedFile.readAsBytes();
      } else {
        _image = File(pickedFile.path);
      }
      setState(() {}); // Update UI after selecting image
    }
  }
}
