import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bikeDetailsController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  File? _image;
  String? _uid;
  bool _profileCreated = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _uid = user.uid;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String name = prefs.getString('name') ?? '';
      String bikeDetails = prefs.getString('bikeDetails') ?? '';
      String number = prefs.getString('number') ?? '';
      String imagePath = prefs.getString('image') ?? '';

      setState(() {
        _nameController.text = name;
        _bikeDetailsController.text = bikeDetails;
        _numberController.text = number;
        if (imagePath.isNotEmpty) {
          _image = File(imagePath);
        }
        _profileCreated = name.isNotEmpty; // Check if profile is created
      });
    } else {
      // Handle user not authenticated
      // Redirect to login or show a message
    }
  }

  Future<void> _createProfile() async {
    if (_uid == null) {
      // Handle user not authenticated
      return;
    }

    String name = _nameController.text;
    String bikeDetails = _bikeDetailsController.text;
    String number = _numberController.text;
    String imagePath = _image?.path ?? '';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('bikeDetails', bikeDetails);
    await prefs.setString('number', number);
    await prefs.setString('image', imagePath);

    CollectionReference riders = FirebaseFirestore.instance.collection('riders');
    await riders.doc(_uid).set({
      'name': name,
      'bikeDetails': bikeDetails,
      'number': number,
      'imagePath': imagePath,
      'role': 'rider', // Automatic role assignment
    });

    setState(() {
      _profileCreated = true;
    });

    Navigator.pushReplacementNamed(context, '/qr_rider');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
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
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage: _image != null ? FileImage(_image!) : null,
            child: _image == null
                ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                : null,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _bikeDetailsController,
          decoration: const InputDecoration(
            labelText: 'Bike Details',
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
        ElevatedButton(
          onPressed: _createProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 37, 13, 33), // Button color
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
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          backgroundImage: _image != null ? FileImage(_image!) : null,
          child: _image == null
              ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
              : null,
        ),
        const SizedBox(height: 20),
        Text(
          'Name: ${_nameController.text}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        Text(
          'Bike Details: ${_bikeDetailsController.text}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Text(
          'Number: ${_numberController.text}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
