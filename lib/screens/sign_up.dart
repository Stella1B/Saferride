import 'package:flutter/material.dart';
import 'OTP_verification.dart'; // Import your OTP verification page

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signUp() {
    // Perform sign-up logic here (e.g., validate input, create new user)
    // ignore: unused_local_variable
    String username = _usernameController.text;
    String email = _emailController.text;
    // ignore: unused_local_variable
    String password = _passwordController.text;

    // Example: Replace with actual backend API call to create user
    // Upon successful sign-up, send OTP to user
    _sendOTP(email);
  }

  void _sendOTP(String email) {
    // Simulate sending OTP (in real app, this should call a backend API)
    // For demo purposes, navigate to OTP verification page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPVerificationPage(email: email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      backgroundColor: const Color.fromARGB(255, 235, 231, 227), // Light orange background
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/boda.webp', // Replace with your actual image asset path
                  width: 100, // Adjust width as needed
                  height: 100, // Adjust height as needed
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 31, 13, 34)),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 31, 15, 34)),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 33, 15, 37)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 37, 13, 33), // Orange button
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(color: Color.fromARGB(255, 254, 253, 254)), // Dark purple text
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
