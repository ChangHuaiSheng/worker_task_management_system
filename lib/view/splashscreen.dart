import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker_task_management_system/view/mainscreen.dart';
import 'package:worker_task_management_system/model/user.dart';
import 'package:worker_task_management_system/myconfig.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
     Future.delayed(const Duration(seconds: 3), () { //delay splash screen for 3 seconds before checking login status
       loadUserCredentials(); //attempts auto-login or redirect to guest view
     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [  //splash screen design
              Colors.blue.shade900,
              Colors.blue.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/wtms.png", scale: 3.5), //images and loading indicator
              SizedBox(height: 20),
              const CircularProgressIndicator(
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadUserCredentials() async { //Load user credentials from shared pref to auto-login
    print("HELLOOO");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = (prefs.getString('email')) ?? ''; //retrieve saved email,password and remember-me flag
    String password = (prefs.getString('pass')) ?? '';
    bool rem = (prefs.getBool('remember')) ?? false;

    print("EMAIL: $email");
    print("PASSWORD: $password");
    print("ISCHECKED: $rem");
    if (rem == true) { //if remember me is checked, it will try to login automatically
      http.post(Uri.parse("${MyConfig.myurl}/wtms/php/login_worker.php"), body: {
        "email": email,
        "password": password,
      }).then((response) {
        print(response.body);
        if (response.statusCode == 200) {
          var jsondata = json.decode(response.body);
          if (jsondata['status'] == 'success') {
            var userdata = jsondata['data']; //parse user data and navigate to main screen with user session
            User user = User.fromJson(userdata[0]);
            print(user.userName);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(user: user)),
            );
          } else {  //invalid credentials = proceed as guest
            User user = User(
              userId: "0",
              userName: "Guest",
              userEmail: "",
              userPhone: "",
              userAddress: "",
              userPassword: "",
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(user: user)),
            );
          }
        }
      });
    } else { // remember-me is false = launch as guest
      User user = User(
        userId: "0",
        userName: "Guest",
        userEmail: "",
        userPhone: "",
        userAddress: "",
        userPassword: "",
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(user: user)),
      );
    }
  }
}