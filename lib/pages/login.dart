import 'package:feedyou/pages/SignUp.dart';
import 'package:feedyou/pages/bottom_nav_bar.dart';
import 'package:feedyou/pages/forgotPassword.dart';
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
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // If login successful
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Login Successful",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBar()),
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = '';

      // --- ERROR 1: Typo in your original code ---
      // You wrote 'user-not-fount', correct is 'user-not-found'
      if (e.code == 'user-not-found') {
        message = "No user found for that email.";
      }
      // --- ERROR 2: Correct error code ---
      else if (e.code == 'wrong-password') {
        message = "Wrong password provided.";
      } else {
        message = "Login failed. Try again.";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message, style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            // --- Top gradient background ---
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.5,
              decoration: BoxDecoration(
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

            // --- Bottom white container ---
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 2.5),
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
            ),

            // --- Main content ---
            Container(
              margin: EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // --- Logo ---
                    Center(
                      child: Image.asset(
                        "assets/images/logo.png",
                        width: MediaQuery.of(context).size.width / 4,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 50.0),

                    // --- Card containing form ---
                    Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: Form(
                          key:
                              _formKey, // --- ERROR 3: Missing Form in original code ---
                          child: Column(
                            children: [
                              SizedBox(height: 30.0),
                              Text(
                                "Login",
                                style: AppWidget.HeadlineTextFeildStyle(),
                              ),
                              SizedBox(height: 30.0),

                              // --- Email field ---
                              TextFormField(
                                controller: useremailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter email';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    hintText: 'Email',
                                    hintStyle:
                                        AppWidget.SemiBoldTextFeildStyle(),
                                    prefixIcon: Icon(Icons.email_outlined)),
                              ),
                              SizedBox(height: 30.0),

                              // --- Password field ---
                              TextFormField(
                                controller: userpasswordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter password';
                                  }
                                  return null;
                                },
                                obscureText: true,
                                decoration: InputDecoration(
                                    hintText: 'Password',
                                    hintStyle:
                                        AppWidget.SemiBoldTextFeildStyle(),
                                    prefixIcon: Icon(Icons.password_outlined)),
                              ),
                              SizedBox(height: 20.0),

                              // --- Forgot Password text ---
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ForgotPassword(),
                                    ),
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
                              SizedBox(height: 80.0),

                              // --- Login button ---
                              GestureDetector(
                                onTap: () {
                                  // --- Only login if form is valid ---
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
                                        EdgeInsets.symmetric(vertical: 8.0),
                                    width: 200,
                                    decoration: BoxDecoration(
                                        color: Color(0Xffff5722),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Center(
                                        child: Text(
                                      "LOGIN",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontFamily: 'Poppins1',
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 70.0),

                    // --- Navigate to Signup ---
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Signup()),
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
