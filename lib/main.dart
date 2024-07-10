import 'package:flutter/material.dart';
import 'Screens/sign_up.dart';
import 'Screens/OTP_verification.dart';
import 'Screens/sign_in.dart';
import 'Screens/profile_screen.dart';
import 'Screens/home_screen.dart'; // Import your home screen page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instaride',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/signup',
      routes: {
        '/signup': (context) => SignUpPage(),
        '/verify_otp': (context) => const OTPVerificationPage(email: '',),
        '/signin': (context) => SignInPage(),
        '/create_profile': (context) => ProfileCreationPage(),
        '/home': (context) => const HomeScreen(), // Route to your home screen
        // Add more routes as needed
      },
    );
  }
}
