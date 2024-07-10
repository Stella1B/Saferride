import 'package:flutter/material.dart';

class ProfileCreationPage extends StatefulWidget {
  const ProfileCreationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileCreationPageState createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  void _createProfile() {
    // Perform profile creation logic here (e.g., save data to backend)
    // ignore: unused_local_variable
    String name = _nameController.text;
    // ignore: unused_local_variable
    String bio = _bioController.text;

    // Example: Replace with actual backend API call to create user profile
    // After successful profile creation, navigate to home screen
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createProfile,
                child: const Text('Create Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
