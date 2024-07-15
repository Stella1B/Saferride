import 'package:flutter/material.dart';
import 'package:instaride/screens/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'contact_us_page.dart';
import 'activity.dart'; // Import ActivityPage
import 'promotions.dart'; // Import PromotionsScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'USER'; // Default value for user name
  String _userBio = ''; // Initialize user bio
  String _nextOfKin = ''; // Initialize next of kin name
  String _nextOfKinContact = ''; // Initialize next of kin contact

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Load profile data when the screen initializes
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('name') ?? 'USER';
    String bio = prefs.getString('bio') ?? '';
    String nextOfKin = prefs.getString('nextOfKin') ?? '';
    String nextOfKinContact = prefs.getString('nextOfKinContact') ?? '';

    setState(() {
      _userName = name;
      _userBio = bio;
      _nextOfKin = nextOfKin;
      _nextOfKinContact = nextOfKinContact;
    });
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
              Text(
                'Name: $_userName',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Bio: $_userBio',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Next of Kin: $_nextOfKin',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "Next of Kin's Contact: $_nextOfKinContact",
                style: const TextStyle(fontSize: 16),
              ),
              // Add more profile details as needed
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.warning),
            color: const Color.fromARGB(255, 167, 10, 10),
            onPressed: () {
              _showPanicDialog(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(_userName),
              currentAccountPicture: InkWell(
                onTap: () {
                  _showProfileDialog(context); // Show profile popup
                },
                child: const CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 33, 13, 36),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Color.fromARGB(255, 255, 138, 20),
                  ),
                ),
              ),
              accountEmail: null,
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('Promotions'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PromotionsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ActivityPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_emergency_rounded),
              title: const Text('Contact Us'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactUsPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.people,
                color: Color.fromARGB(255, 208, 211, 10),
              ),
              title: const Text(
                'View Profile',
                style: TextStyle(color: Color.fromARGB(255, 40, 42, 44)),
              ),
              onTap: () {
                _showProfileDialog(context); // Show profile popup
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Home Screen Content'),
      ),
    );
  }

  void _showPanicDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Family Button Pressed'),
          content: const Text('Are you sure you want to share ride details?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                // Handle the panic button action here
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
