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

import 'family button.dart'; // Make sure this file is correctly imported

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

  void showFamilyDialog(BuildContext context) {
    if (scannedRiderDetails.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: scannedRiderDetails.entries.map((e) => Text('${e.key}: ${e.value}')).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                handleFamilyButton(context); // Trigger the action to send the message
              },
              child: Text('Confirm'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('No Rider Details'),
          content: Text('Please scan a rider QR code first.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void handleFamilyButton(BuildContext context) {
    if (scannedRiderDetails.isNotEmpty) {
      NextOfKin nextOfKin = NextOfKin(name: 'John Doe', phone: '+256786230754');
      Client client = Client(name: 'Jane Smith', phone: '256786230754', nextOfKin: nextOfKin);
      Rider rider = Rider(
        name: scannedRiderDetails['Name'] ?? 'Unknown',
        phone: scannedRiderDetails['Phone'] ?? 'Unknown',
        bikeDetails: scannedRiderDetails['Bike'] ?? 'Unknown',
      );
      matchRiderToClient(client, rider);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('No Rider Details'),
          content: Text('Please scan a rider QR code first.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void matchRiderToClient(Client client, Rider rider) {
    sendMessageToNextOfKin(client.nextOfKin, rider);
  }

  Future<void> sendMessageToNextOfKin(NextOfKin nextOfKin, Rider rider) async {
    Position position = await getCurrentLocation();
    String locationUrl = "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

    String message = 'Dear ${nextOfKin.name},\n\n'
        'Your relative has been matched with a rider. Here are the rider details:\n'
        'Name: ${rider.name}\n'
        'Phone: ${rider.phone}\n'
        'Bike: ${rider.bikeDetails}\n\n'
        'Current location: $locationUrl';

    await sendWhatsAppMessage(message, nextOfKin.phone);
  }

  Future<void> sendWhatsAppMessage(String message, String phoneNumber) async {
    final String apiUrl = 'https://api.whatsapp.com/send';
    final Uri uri = Uri.parse('$apiUrl?phone=${phoneNumber.replaceAll('+', '')}&text=${Uri.encodeComponent(message)}');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        print('WhatsApp message sent successfully');
      } else {
        print('Failed to send WhatsApp message. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending WhatsApp message: $e');
    }
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
              icon: Icons.people,
              title: 'Family button',
              iconColor: const Color.fromARGB(255, 208, 211, 10),
              textColor: const Color.fromARGB(255, 40, 42, 44),
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
              icon: Icons.qr_code_scanner,
              title: 'scanner',
              onTap: () {
                showFamilyDialog(context);
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
              Text('Next of Kin Contact: $_nextOfKinContact', style: const TextStyle(fontSize: 16)),
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

// Ensure that this class is correctly implemented
class Rider {
  final String name;
  final String phone;
  final String bikeDetails;

  Rider({required this.name, required this.phone, required this.bikeDetails});
}

// Ensure that this class is correctly implemented
class NextOfKin {
  final String name;
  final String phone;

  NextOfKin({required this.name, required this.phone});
}

// Ensure that this class is correctly implemented
class Client {
  final String name;
  final String phone;
  final NextOfKin nextOfKin;

  Client({required this.name, required this.phone, required this.nextOfKin});
}

// Sample matchRiderToClient implementation
Future<void> matchRiderToClient(Client client, Rider rider) async {
  // Implementation of the function to match rider and client
}
