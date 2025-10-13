import 'package:feedyou/pages/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:feedyou/pages/onboard.dart';
import 'package:feedyou/widget/app_constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the .env file from project root
  await dotenv.load(fileName: 'assets/.env');

  // Now set Stripe key
  Stripe.publishableKey = publishableKey;

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FeedYou',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: Wallet(),
    );
  }
}
