import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = '';
  String _bio = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? '';
      _bio = prefs.getString('bio') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('INSTARIDE'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(_name.isNotEmpty ? _name : 'USER'),
              currentAccountPicture: InkWell(
                onTap: () {
                  // Navigate to profile page or show profile info
                  _showProfileDialog(context);
                },
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.green,
                  ),
                ),
              ),
              accountEmail: null,
            ),
            ListTile(
              leading: const Icon(Icons.loyalty),
              title: const Text('My Wallet'),
              onTap: () {
                // Handle the action
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('Promotions'),
              onTap: () {
                // Handle the action
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                Navigator.pushNamed(context, '/contact_us');
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pushNamed(context, '/contact_us');
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_support),
              title: const Text('Contact Us'),
              onTap: () {
                Navigator.pushNamed(context, '/contact_us');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: const Text('Panic Button', style: TextStyle(color: Colors.red)),
              onTap: () {
                _showPanicDialog(context);
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

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: $_name'),
              const SizedBox(height: 8),
              Text('Bio: $_bio'),
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

  void _showPanicDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Panic Button Pressed'),
          content: const Text('Are you sure you want to trigger the panic action?'),
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
