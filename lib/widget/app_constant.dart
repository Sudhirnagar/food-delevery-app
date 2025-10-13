import 'package:flutter_dotenv/flutter_dotenv.dart';

String publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
String SecretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? '';
