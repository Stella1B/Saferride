import 'package:flutter/material.dart';
import 'Screens/sign_up.dart';
import 'Screens/OTP_verification.dart';
import 'Screens/sign_in.dart';
import 'Screens/profile_screen.dart';
import 'Screens/home_screen.dart'; // Import your home screen page
import 'Screens/welcome_page.dart'; // Import the WelcomePage

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
      // Start with the WelcomePage
      home: WelcomePage(),
      // Define routes for navigation
      routes: {
        '/signup': (context) => const SignUpPage(),
        '/verify_otp': (context) => const OTPVerificationPage(email: ''),
        '/signin': (context) => const SignInPage(),
        '/create_profile': (context) => const ProfileCreationPage(),
        '/home': (context) => const HomeScreen(),
        // Add more routes as needed
      },
    );
  }
}
