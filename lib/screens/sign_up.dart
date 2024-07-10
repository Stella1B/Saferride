// ignore_for_file: library_private_types_in_public_api

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
