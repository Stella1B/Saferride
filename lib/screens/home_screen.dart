import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:instaride/Screens/navigation_screen.dart';
import 'package:instaride/screens/activity.dart';
import 'package:instaride/screens/contact_us_page.dart';
import 'package:instaride/screens/notifications.dart';
import 'package:instaride/screens/promotions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'USER';
  String _userBio = '';
  String _nextOfKin = '';
  String _nextOfKinContact = '';
  LatLng? _curLocation;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _getCurrentLocation();
    _loadRoutePoints();
  }

  Future<void> _loadProfileData() async {
    try {
      setState(() {
        _userName = 'John Doe';
        _userBio = 'Software Engineer';
        _nextOfKin = 'Jane Doe';
        _nextOfKinContact = '+123456789';
      });
    } catch (e) {
      print('Failed to load profile data: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _curLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Failed to get current location: $e');
    }
  }

  Future<void> _loadRoutePoints() async {
    List<LatLng> routePoints = [
      LatLng(37.7749, -122.4194),
      LatLng(37.7749, -122.5194),
      LatLng(37.8749, -122.4194),
    ];
    setState(() {
      _routePoints = routePoints;
    });
  }

  void _handlePanicButton() {
    if (_curLocation != null) {
      _shareLocationWithSafeBoda(_curLocation!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to share location. Please try again.')),
      );
    }
  }

  void _shareLocationWithSafeBoda(LatLng location) {
    print('Sharing location: ${location.latitude}, ${location.longitude}');
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Shared'),
          content: const Text('Your location has been shared '),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('INSTARIDE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning),
            color: const Color.fromARGB(255, 167, 10, 10),
            onPressed: _handlePanicButton,
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const PromotionsScreen()));
              },
            ),
            _buildDrawerItem(
              icon: Icons.history,
              title: 'History',
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ActivityPage()));
              },
            ),
            _buildDrawerItem(
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const NotificationsPage()));
              },
            ),
            _buildDrawerItem(
              icon: Icons.contact_emergency_rounded,
              title: 'Contact Us',
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ContactUsPage()));
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
          ],
        ),
      ),
      body: _curLocation == null
          ? const Center(child: CircularProgressIndicator())
          : NavigationScreen(
              lat: _curLocation!.latitude,
              lng: _curLocation!.longitude,
            ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.black54,
    Color textColor = Colors.black87
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
              Text('Bio: $_userBio', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text('Next of Kin: $_nextOfKin', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text("Next of Kin's Contact: $_nextOfKinContact",
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
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
                // Handle sharing ride details
              },
            ),
          ],
        );
      },
    );
  }
}

