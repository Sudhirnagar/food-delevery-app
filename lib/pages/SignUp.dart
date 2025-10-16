import 'package:feedyou/pages/bottom_nav_bar.dart';
import 'package:feedyou/pages/login.dart';
import 'package:feedyou/service/database.dart';
import 'package:feedyou/service/shared_pref.dart';
import 'package:feedyou/widget/widget_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String name = "", email = "", password = "";

  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  // Error in original code: SharedPreferences me userId save nahi ho raha tha
  // Isliye Details screen me id null aa rahi thi

  registration() async {
    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        // Firebase Authentication me signup
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful")),
        );

        // Generate unique ID for user
        String Id = randomAlphaNumeric(10);

        // Save user info in Firestore
        Map<String, dynamic> addUserInfo = {
          "name": nameController.text,
          "Email": emailController.text,
          "wallet": "0",
          "Id": Id,
        };
        await DatabaseMethods().addUserDetail(addUserInfo, Id);

        // ✅ FIX: Save user info in SharedPreferences
        // Pehle ye part missing tha, isliye Details me id null aa rahi thi
        await SharedPreferenceHelper().saveUserId(Id);
        await SharedPreferenceHelper().saveUserName(nameController.text);
        await SharedPreferenceHelper().saveUserEmail(emailController.text);

        // Navigate to BottomNavBar
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBar()),
          (Route<dynamic> route) => false,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password is too weak')),
          );
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email is already registered')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.message}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
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
                  ])),
            ),
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
              child: Text(""),
            ),
            Container(
              margin: EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                        child: Image.asset(
                      "assets/images/logo.png",
                      width: MediaQuery.of(context).size.width / 4,
                      fit: BoxFit.cover,
                    )),
                    SizedBox(height: 50.0),
                    Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.only(left: 20.0, right: 20.0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 1.9,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: Form(
                          key: _formkey,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(height: 30.0),
                                Text(
                                  "Sign Up",
                                  style: AppWidget.HeadlineTextFeildStyle(),
                                ),
                                SizedBox(height: 30.0),
                                TextFormField(
                                  controller: nameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please Enter your name';
                                    }
                                  },
                                  decoration: InputDecoration(
                                      hintText: 'Name',
                                      hintStyle:
                                          AppWidget.SemiBoldTextFeildStyle(),
                                      prefixIcon: Icon(Icons.person_outline)),
                                ),
                                SizedBox(height: 30.0),
                                TextFormField(
                                  controller: emailController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please Enter your Email";
                                    }
                                  },
                                  decoration: InputDecoration(
                                      hintText: 'Email',
                                      hintStyle:
                                          AppWidget.SemiBoldTextFeildStyle(),
                                      prefixIcon: Icon(Icons.email_outlined)),
                                ),
                                SizedBox(height: 30.0),
                                TextFormField(
                                  controller: passwordController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please Enter your password";
                                    }
                                  },
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      hintText: 'Password',
                                      hintStyle:
                                          AppWidget.SemiBoldTextFeildStyle(),
                                      prefixIcon:
                                          Icon(Icons.password_outlined)),
                                ),
                                SizedBox(height: 85.0),
                                GestureDetector(
                                  onTap: () async {
                                    if (_formkey.currentState!.validate()) {
                                      setState(() {
                                        email = emailController.text;
                                        name = nameController.text;
                                        password = passwordController.text;
                                      });
                                      registration();
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
                                        "Sign Up",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.0,
                                            fontFamily: 'Poppins1',
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 70.0),
                    GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => LogIn()));
                        },
                        child: Text(
                          "Already have an account? Log in",
                          style: AppWidget.SemiBoldTextFeildStyle(),
                        ))
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
