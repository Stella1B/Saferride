import 'package:boda/screens/home_screen.dart';
import 'package:boda/screens/rider_screen.dart'; // Import the rider's screen
import 'package:boda/screens/sign_up.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch the user's UID
      User? user = _auth.currentUser;
      if (user != null) {
        String uid = user.uid;
        
        // Check if the user is in the 'riders' collection
        DocumentSnapshot riderDoc = await _firestore.collection('riders').doc(uid).get();
        if (riderDoc.exists) {
          // User is a rider
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (BuildContext context) => const HomePage()),
          );
        } else {
          // Check if the user is in the 'users' collection
          DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
          if (userDoc.exists) {
            // User is a regular user
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (BuildContext context) => const HomeScreen()),
            );
          } else {
            // User is not found in either collection
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User not found in database')),
            );
            await _auth.signOut(); // Sign out if user is not found
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else {
        message = e.message ?? 'An unknown error occurred';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unknown error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: const Color.fromARGB(255, 37, 13, 33), // Dark purple app bar
      ),
      backgroundColor: const Color.fromARGB(255, 235, 231, 227), // Light background
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
                      labelStyle: TextStyle(color: Color.fromARGB(255, 31, 13, 34)), // Dark text
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 31, 13, 34)), // Dark text
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 37, 13, 33), // Dark button
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(color: Colors.white), // White text
                    ),
                  ),
                  const SizedBox(height: 20),
                  signUpOption(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row signUpOption(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Do not have an account?',
          style: TextStyle(color: Color(0xffbe4a21)),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (BuildContext context) => const SignUpPage()),
            );
          },
          child: const Text(
            ' SignUp',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
