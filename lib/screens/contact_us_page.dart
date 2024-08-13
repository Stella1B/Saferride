import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  Future<void> _launchWhatsApp(BuildContext context) async {
    final Uri uri = Uri.parse('whatsapp://send?phone=256775314713');
    if (kDebugMode) {
      print('Attempting to launch: $uri');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      final Uri fallbackUri = Uri.parse('https://wa.me/256775314713');
      if (kDebugMode) {
        print('Attempting to launch fallback: $fallbackUri');
      }
      if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      } else {
        final Uri webFallbackUri = Uri.parse('https://web.whatsapp.com/send?phone=256775314713');
        if (kDebugMode) {
          print('Attempting to launch web fallback: $webFallbackUri');
        }
        if (await canLaunchUrl(webFallbackUri)) {
          await launchUrl(webFallbackUri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch WhatsApp. Number copied to clipboard.')),
          );
          await Clipboard.setData(const ClipboardData(text: '+256775314713'));
        }
      }
    }
  }

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'tinaamarion@gmail.com',
      queryParameters: {
        'subject': 'App Support',
        'body': 'Hello, I need help with...',
      },
    );
    if (kDebugMode) {
      print('Attempting to launch: $emailLaunchUri');
    }
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
    } else {
      await Clipboard.setData(const ClipboardData(text: 'tinaamarion@gmail.com'));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email address copied to clipboard')),
      );
    }
  }

  Future<void> _launchPhone(BuildContext context) async {
    final Uri uri = Uri.parse('tel:+256786230754');
    if (kDebugMode) {
      print('Attempting to launch: $uri');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await Clipboard.setData(const ClipboardData(text: '+256786230754'));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number copied to clipboard')),
      );
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
              onTap: () => _launchWhatsApp(context),
            ),
            const SizedBox(height: 10),
            ContactOption(
              icon: Icons.email,
              color: Colors.orange,
              title: 'Email',
              subtitle: 'Write to us',
              backgroundColor: Colors.orange.withOpacity(0.1),
              onTap: () => _launchEmail(context),
            ),
            const SizedBox(height: 10),
            ContactOption(
              icon: Icons.phone,
              color: Colors.blue,
              title: 'Call',
              subtitle: 'Speak to our agent',
              backgroundColor: Colors.blue.withOpacity(0.1),
              onTap: () => _launchPhone(context),
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
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.onTap,
  });

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
