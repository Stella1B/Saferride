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

  bool _profileCreated = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Load profile data if available
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('name') ?? '';
    String bio = prefs.getString('bio') ?? '';
    String nextOfKin = prefs.getString('nextOfKin') ?? '';
    String nextOfKinContact = prefs.getString('nextOfKinContact') ?? '';

    setState(() {
      _nameController.text = name;
      _bioController.text = bio;
      _nextOfKinController.text = nextOfKin;
      _nextOfKinContactController.text = nextOfKinContact;
      _profileCreated = name.isNotEmpty; // Check if profile data is available
    });
  }

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

    setState(() {
      _profileCreated = true;
    });

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _profileCreated ? _buildProfileView() : _buildProfileCreationForm(),
        ),
      ),
    );
  }

  Widget _buildProfileCreationForm() {
    return Column(
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
    );
  }

  Widget _buildProfileView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Name: ${_nameController.text}',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        Text(
          'Bio: ${_bioController.text}',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Text(
          'Next of Kin: ${_nextOfKinController.text}',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Text(
          "Next of Kin's Contact: ${_nextOfKinContactController.text}",
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
