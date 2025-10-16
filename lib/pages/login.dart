import 'package:feedyou/pages/SignUp.dart';
import 'package:feedyou/pages/bottom_nav_bar.dart';
import 'package:feedyou/pages/forgotPassword.dart';
import 'package:feedyou/service/shared_pref.dart'; // added SharedPreferences helper
import 'package:feedyou/widget/widget_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "";

  final _formKey = GlobalKey<FormState>();

  TextEditingController useremailController = TextEditingController();
  TextEditingController userpasswordController = TextEditingController();

  _userLogin() async {
    try {
      // Sign in with Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Save the user id in SharedPreferences
      String uid = userCredential.user!.uid;
      await SharedPreferenceHelper().saveUserId(uid);

      // Login successful message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Login Successful",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to BottomNavBar
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBar()),
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        message = "Wrong password provided.";
      } else {
        message = "Login failed. Try again.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontSize: 18)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            // Top gradient background
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFff5c30),
                    Color(0xFFe74b1a),
                  ],
                ),
              ),
            ),
            // Bottom white container
            Container(
              margin:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.5),
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
            ),
            // Main content
            Container(
              margin: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Logo
                    Center(
                      child: Image.asset(
                        "assets/images/logo.png",
                        width: MediaQuery.of(context).size.width / 4,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 50.0),
                    // Form Card
                    Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 30.0),
                              Text(
                                "Login",
                                style: AppWidget.HeadlineTextFeildStyle(),
                              ),
                              const SizedBox(height: 30.0),
                              // Email
                              TextFormField(
                                controller: useremailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter email';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    hintText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined)),
                              ),
                              const SizedBox(height: 30.0),
                              // Password
                              TextFormField(
                                controller: userpasswordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter password';
                                  }
                                  return null;
                                },
                                obscureText: true,
                                decoration: const InputDecoration(
                                    hintText: 'Password',
                                    prefixIcon: Icon(Icons.password_outlined)),
                              ),
                              const SizedBox(height: 20.0),
                              // Forgot Password
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ForgotPassword()),
                                  );
                                },
                                child: Container(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    "Forgot Password?",
                                    style: AppWidget.SemiBoldTextFeildStyle(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 80.0),
                              // Login button
                              GestureDetector(
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      email = useremailController.text.trim();
                                      password =
                                          userpasswordController.text.trim();
                                    });
                                    _userLogin();
                                  }
                                },
                                child: Material(
                                  elevation: 5.0,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8.0),
                                    width: 200,
                                    decoration: BoxDecoration(
                                        color: const Color(0Xffff5722),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: const Center(
                                        child: Text(
                                      "LOGIN",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 70.0),
                    // Navigate to Signup
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const Signup()),
                        );
                      },
                      child: Text(
                        "Don't have an account? Sign up",
                        style: AppWidget.SemiBoldTextFeildStyle(),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
