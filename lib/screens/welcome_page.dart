import 'dart:async';
import 'package:boda/screens/sign_up.dart';
import 'package:flutter/material.dart';
import 'profile_screen.dart'; // Replace with the path to your SignUpPage

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    // Delay navigation to SignUpPage after 2 seconds
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
    MaterialPageRoute(builder: (context) => const SignUpPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 12, 37), // Dark purple background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo or image goes here
            Image.asset(
              'assets/boda.webp', // Replace with your logo image asset path
              width: 150,
              height: 150,
              // Adjust width and height as needed
            ),
            const SizedBox(height: 30),
            const Text(
              'SAFERRIDE',
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
