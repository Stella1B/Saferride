import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    _currentUser = FirebaseAuth.instance.currentUser;

    if (_currentUser != null) {
      // Fetch profile data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        setState(() {
          _nameController.text = userData['name'] ?? '';
          _numberController.text = userData['number'] ?? '';
          _nextOfKinController.text = userData['nextOfKin'] ?? '';
          _nextOfKinContactController.text = userData['nextOfKinContact'] ?? '';
          _profileCreated = true;
        });
      } else {
        setState(() {
          _profileCreated = false;
        });
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _createProfile() async {
    String name = _nameController.text;
    String number = _numberController.text;
    String nextOfKin = _nextOfKinController.text;
    String nextOfKinContact = _nextOfKinContactController.text;

    if (_currentUser != null) {
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).set({
        'name': name,
        'number': number,
        'nextOfKin': nextOfKin,
        'nextOfKinContact': nextOfKinContact,
        'userId': _currentUser!.uid,
      });

      setState(() {
        _profileCreated = true;
      });

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      backgroundColor: const Color.fromARGB(255, 235, 231, 227),
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
          'assets/boda.webp',
          width: 100,
          height: 100,
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
            backgroundColor: const Color.fromARGB(255, 37, 13, 33),
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
          'assets/boda.webp',
          width: 100,
          height: 100,
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
