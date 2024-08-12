import 'package:boda/screens/family%20button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'navigation_screen.dart'; // Assuming you have this screen implemented
import 'contact_us_page.dart';
import 'notifications.dart';
import 'promotions.dart';
import 'sign_up.dart';
// Make sure this is implemented properly

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

  DateTime? _lastShakeTime;
  int _shakeCount = 0;
  final int _shakeThreshold = 15;
  final int _maxShakes = 5;
  final Duration _shakeWindow = Duration(seconds: 10);
  double? _previousAcceleration;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _getCurrentLocation();
    _listenToShake();
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
    print('Distress Signal Response: ${response.statusCode}');
  }


  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignUpPage()));
  }

  void _showFamilyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Scan QR Code'),
          ),
          body: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.4,
              child: MobileScanner(
                controller: MobileScannerController(
                  detectionSpeed: DetectionSpeed.noDuplicates,
                  returnImage: true,
                ),
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final data = parseQRData(barcodes.first.rawValue ?? "");
                    Navigator.of(context).pop(); // Close the scanner dialog

                    // Display the scanned info in a dialog on the home screen
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Scanned Information'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['info']), // Display the extracted information
                              if (data['image'] != null) ...[
                                const SizedBox(height: 16),
                                Image.network(
                                  data['image'],
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text('Failed to load image');
                                  },
                                ),
                              ],
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SAFERRIDE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded),
            color: const Color.fromARGB(255, 167, 10, 10),
            onPressed: _curLocation != null ? () =>
                _sendDistressSignal(_curLocation!) : null,
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
              title: 'Family Button',
              iconColor: Color.fromARGB(255, 20, 211, 10),
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
              icon: Icons.qr_code_rounded,
              title: 'Scanner',

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
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
    required VoidCallback onTap,
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
              Text(
                  'Number: $_userNumber', style: const TextStyle(fontSize: 16)),
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

  void _listenToShake() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      final currentAcceleration = sqrt(
          pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));

      if (_previousAcceleration != null) {
        final accelerationChange = (currentAcceleration -
            _previousAcceleration!).abs();

        if (accelerationChange > _shakeThreshold) {
          final now = DateTime.now();

          if (_lastShakeTime == null ||
              now.difference(_lastShakeTime!) > _shakeWindow) {
            _shakeCount = 0;
          }

          _shakeCount++;
          _lastShakeTime = now;

          if (_shakeCount >= _maxShakes) {
            _sendDistressSignal(_curLocation!);
            _shakeCount = 0;
          }
        }
      }

      _previousAcceleration = currentAcceleration;
    });
  }


  void showInfoDialog(BuildContext context, data) {
    var info;
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Rider Information'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: info.entries.map((e) => Text('${e.key}: ${e.value}'))
                  .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Map<String, dynamic> parseQRData(String s) {
    print('Raw QR Data: $s'); // Debugging: Print the raw data

    try {
      if (s.startsWith('{') && s.endsWith('}')) {
        // It's likely JSON
        final parsedData = jsonDecode(s);

        // Extract relevant information
        String extractedInfo = parsedData['info'] ?? 'No info available';
        String? imageUrl = parsedData['image'] ?? null;

        return {
          'info': extractedInfo,
          'image': imageUrl,
        };
      } else {
        // It's plain text or something else, return it as info and no image
        return {
          'info': s,
          'image': null,
        };
      }
    } catch (e) {
      print('Error: $e'); // Debugging: Print the error message

      // Return an error message and no image
      return {
        'info': 'Failed to parse QR data',
        'image': null,
      };
    }
  }


}
