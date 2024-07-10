import 'package:flutter/material.dart';
// ignore: unused_import
import 'profile_screen.dart';
import 'contact_us_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              accountName: const Text('USER'),
              currentAccountPicture: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  ProfileCreationPage()),
                  );
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
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactUsPage()),
                );
                // Handle the action
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactUsPage()),
                );
                // Handle the action
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_support),
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
// TODO Implement this library.