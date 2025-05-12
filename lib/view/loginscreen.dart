import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:worker_task_management_system/view/mainscreen.dart';
import 'package:worker_task_management_system/model/user.dart';
import 'package:worker_task_management_system/myconfig.dart';
import 'package:worker_task_management_system/view/registerscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isChecked = false; //checkbox state for "remember me"

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCredentials(); // load stored credentials if any
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Screen",style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 52, 119, 219),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Image.asset(
            "assets/images/wtms.png", //app logo
            height: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration( //input fields
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
                    Row(
                      children: [
                        const Text("Remember Me"),
                        Checkbox(
                            value: isChecked,
                            onChanged: (value) {
                              setState(() {
                                isChecked = value!;
                              });
                              String email = emailController.text;
                              String password = passwordController.text;
                              if (isChecked) {
                                if (email.isEmpty && password.isEmpty) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text("Please fill all fields"),
                                    backgroundColor: Colors.red,
                                  ));
                                  isChecked = false;
                                  return;
                                }
                              }
                              storeCredentials(email, password, isChecked);
                            }),
                      ],
                    ),
                    ElevatedButton( //login button
                        onPressed: () {
                          loginUser(); //trigger login process
                        },
                        child: const Text("Login"))
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(  //navigate to register screen
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text("Register an account?")),
          const SizedBox(height: 10),
          GestureDetector(onTap: () {}, child: const Text("Forgot Password?")),
        ],
      )),
    );
  }

  void loginUser() { //login user by calling PHP API
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isEmpty && password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill all fields"),
        backgroundColor: Colors.red,
      ));
      return;
    }
    http.post(Uri.parse("${MyConfig.myurl}/wtms/php/login_worker.php"), body: {
      "email": email, //Send HTTP POST request to backend
      "password": password,
    }).then((response) {
        print(response.body);
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['status'] == 'success') {
          var userdata = jsondata['data'];
          User user = User.fromJson(userdata[0]); //create user model from JSON
          print(user.userName);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("Welcome ${user.userName}"),
            backgroundColor: Colors.green,
          ));
          Navigator.of(context).pop();  //close login screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainScreen(
                      user: user,
                    )),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed!"),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
  }

  Future<void> storeCredentials( //store credentials using shared pref
      String email, String password, bool isChecked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isChecked) {
      await prefs.setString('email', email);
      await prefs.setString('pass', password);
      await prefs.setBool('remember', isChecked);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Pref Stored Success!"),
        backgroundColor: Colors.green,
      ));
    } else { //remove saved credentials
      await prefs.remove('email');
      await prefs.remove('pass');
      await prefs.remove('remember');
      emailController.clear();
      passwordController.clear();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Pref Removed!"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> loadCredentials() async { //load saved credentials when the screen is initialized
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('pass');
    bool? isChecked = prefs.getBool('remember');
    if (email != null && password != null && isChecked != null) {
      emailController.text = email;
      passwordController.text = password;
      setState(() {
        this.isChecked = isChecked!;
      });
    } else {
      emailController.clear();
      passwordController.clear();
      isChecked = false;
      setState(() {});
    }
  }
}