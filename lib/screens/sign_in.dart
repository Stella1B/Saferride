import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signIn() {
    // Perform sign-in logic here (e.g., validate credentials)
    // ignore: unused_local_variable
    String email = _emailController.text;
    // ignore: unused_local_variable
    String password = _passwordController.text;

    // Example: Replace with actual backend API call to authenticate user
    // Upon successful sign-in, navigate to profile creation page
    Navigator.pushReplacementNamed(context, '/create_profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: const Color.fromARGB(255, 37, 13, 33), // Orange app bar
      ),
      backgroundColor: const Color.fromARGB(255, 235, 231, 227), // Light orange background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/boda.webp', // Replace with your actual image asset path
              width: 100, // Adjust width as needed
              height: 100, // Adjust height as needed
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 31, 13, 34)), // Dark purple text
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 31, 13, 34)), // Dark purple text
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 37, 13, 33), // Orange button
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(color: Colors.white), // White text
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
