import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boda/screens/contact_us_page.dart';
import 'package:boda/screens/notifications.dart';
import 'package:boda/screens/promotions.dart';
import 'package:boda/screens/sign_up.dart';

import 'package:boda/screens/navigation_screen.dart';

import 'family button.dart';

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

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _getCurrentLocation();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('name') ?? '';
      _userNumber = prefs.getString('number') ?? '';
      _nextOfKin = prefs.getString('nextOfKin') ?? '';
      _nextOfKinContact = prefs.getString('nextOfKinContact') ?? '';
    });
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
    print(response.statusCode);
    print('$response');
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignUpPage()));
  }

  void _showFamilyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Family Button Pressed'),
          content: const Text('Are you sure you want to share ride details?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                _shareRideDetails(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _shareRideDetails(BuildContext context) {
    Rider rider = Rider(
      name: 'Mike Johnson',
      phone: '+1122334455',
      bikeDetails: 'Honda CBR 250R',
    );

    NextOfKin nextOfKin = NextOfKin(
      name: 'John Doe',
      phone: '+256786230754',
    );

    Client client = Client(name: _userName, phone: _userNumber, nextOfKin: nextOfKin);

    matchRiderToClient(client, rider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ride details shared successfully')),
    );
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
            onPressed: () => _sendDistressSignal(_curLocation!),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: Drawer(
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
              onTap: () {
                _showFamilyDialog(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _locationLoaded
          ? NavigationScreen(
        lat: _curLocation!.latitude,
        lng: _curLocation!.longitude,
      )
          : const Center(child: CircularProgressIndicator()),
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
              Text('Number: $_userNumber', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text('Next of Kin: $_nextOfKin', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text("Next of Kin's Contact: $_nextOfKinContact", style: const TextStyle(fontSize: 16)),
            ],
          ),
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
}

class Rider {
  final String name;
  final String phone;
  final String bikeDetails;

  Rider({required this.name, required this.phone, required this.bikeDetails});
}

class NextOfKin {
  final String name;
  final String phone;

  NextOfKin({required this.name, required this.phone});
}

class Client {
  final String name;
  final String phone;
  final NextOfKin nextOfKin;

  Client({required this.name, required this.phone, required this.nextOfKin});
}

void matchRiderToClient(Client client, Rider rider) {
  // Implement the logic to match rider with client
  print('Client ${client.name} matched with rider ${rider.name}');
}
