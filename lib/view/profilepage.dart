import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:worker_task_management_system/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:worker_task_management_system/myconfig.dart';
import 'package:worker_task_management_system/view/mainscreen.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> { //controller for each profile field
  late TextEditingController idController;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  File? _image; //holds the locally selected profile image

  @override
  void initState() {
    super.initState(); //initialize controllers with existing user data
    idController = TextEditingController(text:widget.user.userId);
    nameController = TextEditingController(text: widget.user.userName);
    emailController = TextEditingController(text: widget.user.userEmail);
    phoneController = TextEditingController(text: widget.user.userPhone);
    addressController = TextEditingController(text: widget.user.userAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page",style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 52, 119, 219),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _selectImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : const AssetImage("assets/images/profile.png") as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoField("Worker ID", idController.text, controller: idController,enabled: false), //display workers info , id as false 
            _buildInfoField("Name", nameController.text, controller: nameController),
            _buildInfoField("Email", emailController.text, controller: emailController),
            _buildInfoField("Phone", phoneController.text, controller: phoneController),
            _buildInfoField("Address", addressController.text, controller: addressController, maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value, //helper to build a labeled textfield
      {TextEditingController? controller, bool enabled = true, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        enabled: controller != null ? enabled : false,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _selectImage() async {  //open image picker to choose a new profile picture
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() {  //validates inputs, send update request and handles response
  String fullName = nameController.text;
  String email = emailController.text;
  String phone = phoneController.text;
  String address = addressController.text;

  //email validation
  bool isValidEmail(String email) {
    return email.contains('@') &&
           email.contains('.') &&
           email.indexOf('@') < email.lastIndexOf('.');
  }

  if (fullName.isEmpty || email.isEmpty || phone.isEmpty || address.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Please fill all fields"),
      backgroundColor: Colors.red,
    ));
    return;
  }

  if (!isValidEmail(email)) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Please enter a valid email address"),
      backgroundColor: Colors.red,
    ));
    return;
  }

  http.post( //send POST request to update the profile on the server
    Uri.parse("${MyConfig.myurl}/wtms/php/update_profile.php"),
    body: {
      "id": widget.user.userId ?? "",
      "full_name": fullName,
      "email": email,
      "phone": phone,
      "address": address,
    },
  ).then((response) {
    print("Raw response: ${response.body}");

    //check for valid JSON status field
    if (response.statusCode == 200 && response.body.contains('status')) {
      Map<String, dynamic> jsondata = jsonDecode(response.body);

      if (jsondata['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
        ));

        setState(() { //Update the local user model
          widget.user.userName = fullName;
          widget.user.userEmail = email;
          widget.user.userPhone = phone;
          widget.user.userAddress = address;
        });

        Navigator.pushReplacement( // Navigate back to main screen with updated user
          context,
          MaterialPageRoute(builder: (context) => MainScreen(user: widget.user)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(jsondata['message'] ?? "Update failed"),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Invalid response from server"),
        backgroundColor: Colors.red,
      ));
    }
  }).catchError((error) {
    print("HTTP error: $error");
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Connection failed"),
      backgroundColor: Colors.red,
    ));
  });
}
}

