import 'package:flutter/material.dart';

class ContactOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final VoidCallback onTap;

  const ContactOption({super.key, 
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
          children: <Widget>[
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
