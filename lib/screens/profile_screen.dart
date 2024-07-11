import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileCreationPage extends StatefulWidget {
  const ProfileCreationPage({super.key});

  @override
  _ProfileCreationPageState createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _nextOfKinController = TextEditingController();
  final TextEditingController _nextOfKinContactController = TextEditingController(); // Controller for next of kin contact

  void _createProfile() async {
    String name = _nameController.text;
    String bio = _bioController.text;
    String nextOfKin = _nextOfKinController.text;
    String nextOfKinContact = _nextOfKinContactController.text; // Get next of kin contact

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('bio', bio);
    await prefs.setString('nextOfKin', nextOfKin);
    await prefs.setString('nextOfKinContact', nextOfKinContact); // Save next of kin contact

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
              TextField(
                controller: _nextOfKinController,
                decoration: const InputDecoration(
                  labelText: 'Next of Kin',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nextOfKinContactController,
                decoration: const InputDecoration(
                  labelText: "Next of Kin's Contact",
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
