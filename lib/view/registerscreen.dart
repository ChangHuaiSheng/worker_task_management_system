import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:worker_task_management_system/myconfig.dart';
import 'package:worker_task_management_system/view/loginscreen.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //controller for form fields
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  File? _image;  //image variables
  Uint8List? webImageBytes;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Register Screen",style: TextStyle(color: Colors.white),),
          backgroundColor: const Color.fromARGB(255, 52, 119, 219),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
            child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [ //profile image picker container
                    GestureDetector(
                      onTap: () {
                        showSelectionDialog();
                      },
                      child: Container(
                        height: 300,
                        width: 400,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: _image == null
                              ? const AssetImage("assets/images/camera.png")
                              : _buildProfileImage(),
                          fit: BoxFit.cover,
                        )),
                      ),
                    ),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Your Name",
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: "Password",
                      ),
                      obscureText: true,
                    ),
                    TextField(
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: "Re-enter Password",
                      ),
                      obscureText: true,
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: "Phone",
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: "Address",
                      ),
                      keyboardType: TextInputType.text,
                      maxLines: 5,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                        width: 400,
                        child: ElevatedButton(
                          onPressed: registerUserDialog,
                          child: const Text("Register"),
                        ))
                  ],
                ),
              ),
            ),
          ),
        )));
  }

  void registerUserDialog() { //dialog box for confirm registration
    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String phone = phoneController.text;
    String address = addressController.text;

    //email format check (contains '@' and '.')
    bool isValidEmail(String email) {
      return email.contains('@') && email.contains('.') && email.indexOf('@') < email.lastIndexOf('.');
    }

    if (name.isEmpty ||  //validation check
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        phone.isEmpty ||
        address.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ));
      return;
    }

    if (!isValidEmail(email)) { //email format validation check
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter a valid email address"),
        backgroundColor: Colors.red,
      ));
    return;
    }

     
    if (password.length < 6) { // Password length validation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters"),
        backgroundColor: Colors.red,
      ));
    return;
    }
    if (password != confirmPassword) { //password validation check
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Passwords do not match"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    showDialog( //confirmation dialog
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
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void registerUser() { //API call to register user
    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String phone = phoneController.text;
    String address = addressController.text;

    http.post(Uri.parse("${MyConfig.myurl}/wtms/php/register_worker.php"),
        body: {
          "name": name,
          "email": email,
          "password": password,
          "phone": phone,
          "address": address,
        }).then((response) {
      print(response.body);
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Success!"),
            backgroundColor: Colors.green,
          ));
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed to register"),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
  }

  void showSelectionDialog() { //show dialog to pick image source
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            title: const Text(
              "Select from",
              style: TextStyle(),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _selectFromCamera();
                    },
                    child: const Text("From Camera")),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _selectfromGallery();
                    },
                    child: const Text("From Gallery"))
              ],
            ));
      },
    );
  }

  Future<void> _selectFromCamera() async { // capture image using camera
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      if (kIsWeb) {
        // Read image bytes for web.
        webImageBytes = await pickedFile.readAsBytes();
      }
      setState(() {});
    } else {
      print('No image selected.');
    }
  }

  Future<void> _selectfromGallery() async { //select image from gallery
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      setState(() {});
    }
  }

  ImageProvider _buildProfileImage() {
    if (_image != null) {
      if (kIsWeb) {
        // For web, use MemoryImage.
        return MemoryImage(webImageBytes!);
      } else {
        // For mobile, convert XFile to File.
        return FileImage(File(_image!.path));
      }
    }
    return const AssetImage('assets/images/profile.png');
  }
}