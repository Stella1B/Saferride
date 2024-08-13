import 'dart:convert'; // Import for jsonEncode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class GenerateCodePage extends StatefulWidget {
  const GenerateCodePage({super.key});

  @override
  State<GenerateCodePage> createState() => _GenerateCodePageState();
}

class _GenerateCodePageState extends State<GenerateCodePage> {
  String? qrData;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('name') ?? '';
    String bikeDetails = prefs.getString('bikeDetails') ?? '';
    String number = prefs.getString('number') ?? '';
    String imageUrl = prefs.getString('imageUrl') ?? ''; // Assuming you store image URL

    // Prepare JSON data
    Map<String, dynamic> data = {
      'name': name,
      'bikeDetails': bikeDetails,
      'number': number,
      'image': imageUrl, // Add image URL to the data
    };

    // Convert data to JSON string
    String jsonData = jsonEncode(data);

    setState(() {
      qrData = jsonData;
    });

    // Save QR code data to SharedPreferences
    await prefs.setString('qrCodeData', jsonData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (qrData == null)
              const Center(child: CircularProgressIndicator())
            else
              PrettyQr(
                data: qrData!,
                size: 200, // Adjust size as needed
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/rider_screen');
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
