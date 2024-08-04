// ignore_for_file: unused_import

import 'package:boda/screens/contact_us_page.dart';
import 'package:boda/screens/family%20button.dart';
import 'package:boda/screens/navigation_screen.dart';
import 'package:boda/screens/notifications.dart';
import 'package:boda/screens/promotions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:boda/screens/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  String _userNumber = '';
  String _nextOfKin = '';
  String _nextOfKinContact = '';
  LatLng? _curLocation;
  bool _locationLoaded = false;
  List<LatLng> _routePoints = [];
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        _isLoggedIn = true;
      });

      await _loadProfileData();
      await _getCurrentLocation();
      await _loadRoutePoints();
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignUpPage()));
    }
  }

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('name');
    String? number = prefs.getString('number');
    String? nextOfKin = prefs.getString('nextOfKin');
    String? nextOfKinContact = prefs.getString('nextOfKinContact');

    if (name != null && number != null && nextOfKin != null && nextOfKinContact != null) {
      setState(() {
        _userName = name;
        _userNumber = number;
        _nextOfKin = nextOfKin;
        _nextOfKinContact = nextOfKinContact;
      });
    } else {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _userName = data['name'];
          _userNumber = data['number'];
          _nextOfKin = data['nextOfKin'];
          _nextOfKinContact = data['nextOfKinContact'];
        });

        await prefs.setString('name', _userName);
        await prefs.setString('number', _userNumber);
        await prefs.setString('nextOfKin', _nextOfKin);
        await prefs.setString('nextOfKinContact', _nextOfKinContact);
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _curLocation = LatLng(position.latitude, position.longitude);
        _locationLoaded = true;
      });
    } catch (e) {
      print('Failed to get current location: $e');
    }
  }

  Future<void> _loadRoutePoints() async {
    List<LatLng> routePoints = [
      const LatLng(37.7749, -122.4194),
      const LatLng(37.7749, -122.5194),
      const LatLng(37.8749, -122.4194),
    ];
    setState(() {
      _routePoints = routePoints;
    });
  }

  Future<void> _sendDistressSignal(LatLng location) async {
    final url = Uri.parse('https://one-client.onrender.com/distress');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'type': 'client',
      'coordinates': {
        'lat': location.latitude,
        'long': location.longitude,
      }
    });

    final response = await http.post(url, headers: headers, body: body);
    print('Distress Signal Response: ${response.statusCode}');
  }

  void _shareLocationWithSafeBoda(LatLng location) {
    if (kDebugMode) {
      print('Sharing location: ${location.latitude}, ${location.longitude}');
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Shared'),
          content: const Text('Your location has been shared.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignUpPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SAFERRIDE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning),
            color: const Color.fromARGB(255, 167, 10, 10),
            onPressed: _curLocation != null ? () => _sendDistressSignal(_curLocation!) : null,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _locationLoaded
          ? NavigationScreen(
              lat: _curLocation!.latitude,
              lng: _curLocation!.longitude,
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_userName),
            currentAccountPicture: InkWell(
              onTap: () => _showProfileDialog(context),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Colors.green),
              ),
            ),
            accountEmail: null,
          ),
          _buildDrawerItem(
            icon: Icons.card_giftcard,
            title: 'Promotions',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PromotionsScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.scanner,
            title: 'Scan code',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ScanCodePage()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsPage()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.contact_emergency_rounded,
            title: 'Contact Us',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ContactUsPage()));
            },
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.people,
            title: 'Family Button',
            iconColor: const Color.fromARGB(255, 208, 211, 10),
            textColor: const Color.fromARGB(255, 40, 42, 44),
            onTap: () => _showFamilyDialog(context),
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.black54,
    Color textColor = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: $_userName', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text('Number: $_userNumber',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text('Next of Kin: $_nextOfKin',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text('Next of Kin Contact: $_nextOfKinContact',
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showFamilyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Family Button'),
          content: const Text('Family Button details go here.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
