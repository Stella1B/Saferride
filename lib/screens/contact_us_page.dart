import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'contact_option.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  void _launchWhatsApp() async {
    const url = 'https://wa.me/+256775314713'; // Replace with your WhatsApp number
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchEmail() async {
    const url = 'tinaamarion@gmail.com'; // Replace with your email address
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchPhone() async {
    const url = 'tel:+256786230754'; // Replace with your phone number
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
// TODO Implement this library.