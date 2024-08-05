import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ContactUsPage(),
    );
  }
}

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  Future<void> _launchWhatsApp() async {
    final Uri uri = Uri.parse('https://wa.me/+256775314713'); // Replace with your WhatsApp number
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  Future<void> _launchEmail() async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: 'tinaamarion@gmail.com', // Replace with your email address
      query: 'subject=App Support&body=Hello, I need help with...', // Add subject and body if needed
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  Future<void> _launchPhone() async {
    final Uri uri = Uri.parse('tel:+256786230754'); // Replace with your phone number
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'WE ARE HAPPY TO HELP',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ContactOption(
              icon: Icons.phone_android,
              color: Colors.green,
              title: 'WhatsApp',
              subtitle: '24/7, fastest support',
              backgroundColor: Colors.green.withOpacity(0.1),
              onTap: _launchWhatsApp,
            ),
            const SizedBox(height: 10),
            ContactOption(
              icon: Icons.email,
              color: Colors.orange,
              title: 'Email',
              subtitle: 'Write to us',
              backgroundColor: Colors.orange.withOpacity(0.1),
              onTap: _launchEmail,
            ),
            const SizedBox(height: 10),
            ContactOption(
              icon: Icons.phone,
              color: Colors.blue,
              title: 'Call',
              subtitle: 'Speak to our agent',
              backgroundColor: Colors.blue.withOpacity(0.1),
              onTap: _launchPhone,
            ),
          ],
        ),
      ),
    );
  }
}

class ContactOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final VoidCallback onTap;

  const ContactOption({
    Key? key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 30.0,
            ),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
