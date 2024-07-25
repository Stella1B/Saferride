import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileCreationPage extends StatefulWidget {
  const ProfileCreationPage({super.key});

  @override
  _ProfileCreationPageState createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _nextOfKinController = TextEditingController();
  final TextEditingController _nextOfKinContactController = TextEditingController();

  bool _profileCreated = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('name') ?? '';
    String number = prefs.getString('number') ?? '';
    String nextOfKin = prefs.getString('nextOfKin') ?? '';
    String nextOfKinContact = prefs.getString('nextOfKinContact') ?? '';

    setState(() {
      _nameController.text = name;
      _numberController.text = number;
      _nextOfKinController.text = nextOfKin;
      _nextOfKinContactController.text = nextOfKinContact;
      _profileCreated = name.isNotEmpty;
    });           
  }

  void _createProfile() async {
    String name = _nameController.text;
    String number = _numberController.text;
    String nextOfKin = _nextOfKinController.text;
    String nextOfKinContact = _nextOfKinContactController.text;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('number', number);
    await prefs.setString('nextOfKin', nextOfKin);
    await prefs.setString('nextOfKinContact', nextOfKinContact);

    setState(() {
      _profileCreated = true;
    });

    Navigator.pushReplacementNamed(context, '/verify_otp');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      backgroundColor: const Color.fromARGB(255, 235, 231, 227), // Light orange background
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
        Image.asset(
          'assets/boda.webp', // Replace with your actual image asset path
          width: 100, // Adjust width as needed
          height: 100, // Adjust height as needed
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Username',
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _numberController,
          decoration: const InputDecoration(
            labelText: 'Number',
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
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 37, 13, 33), // Orange button
          ),
          child: const Text(
            'Create Profile',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/boda.webp', // Replace with your actual image asset path
          width: 100, // Adjust width as needed
          height: 100, // Adjust height as needed
        ),
        const SizedBox(height: 20),
        Text(
          'Name: ${_nameController.text}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        Text(
          'Number: ${_numberController.text}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Text(
          'Next of Kin: ${_nextOfKinController.text}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Text(
          "Next of Kin's Contact: ${_nextOfKinContactController.text}",
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}



