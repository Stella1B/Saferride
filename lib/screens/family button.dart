import 'dart:core';
import 'package:boda/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

Map<String, String> scannedRiderDetails = {};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Safety',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Safety'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScanCodePage()),
                );
              },
              child: const Text('Scan Rider QR Code'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => handleFamilyButton(context),
              child: const Text('Family Button'),
            ),
          ],
        ),
      ),
    );
  }
}

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({super.key});

  @override
  State<ScanCodePage> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  Map<String, String> parseQRData(String data) {
    final lines = data.split('\n');
    final map = <String, String>{};
    for (var line in lines) {
      final parts = line.split(': ');
      if (parts.length == 2) {
        map[parts[0]] = parts[1];
      }
    }
    return map;
  }

  void showInfoDialog(BuildContext context, Map<String, String> info) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rider Information'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: info.entries.map((e) => Text('${e.key}: ${e.value}')).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                scannedRiderDetails = data;
                Navigator.of(context).popUntil((route) => route.isFirst);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showInfoDialog(context, data);
                  showConfirmationDialog(context);
                });
              }
            },
          ),
        ),
      ),
    );
  }

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: scannedRiderDetails.entries.map((e) => Text('${e.key}: ${e.value}')).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              handleFamilyButton(context); // Trigger the action to send the message
            },
            child: Text('Confirm'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

void handleFamilyButton(BuildContext context) {
  if (scannedRiderDetails.isNotEmpty) {
    NextOfKin nextOfKin = NextOfKin(name: 'John Doe', phone: '+256786230754');
    Client client = Client(name: 'Jane Smith', phone: '256987654321', nextOfKin: nextOfKin);
    Rider rider = Rider(
      name: scannedRiderDetails['Name'] ?? 'Unknown',
      phone: scannedRiderDetails['Phone'] ?? 'Unknown',
      bikeDetails: scannedRiderDetails['Bike'] ?? 'Unknown',
    );
    matchRiderToClient(client, rider);
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('No Rider Details'),
        content: Text('Please scan a rider QR code first.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class Rider {
  final String name;
  final String phone;
  final String bikeDetails;

  Rider({required this.name, required this.phone, required this.bikeDetails});
}

class NextOfKin {
  final String name;
  final String phone;

  NextOfKin({required this.name, required this.phone});
}

class Client {
  final String name;
  final String phone;
  final NextOfKin nextOfKin;

  Client({required this.name, required this.phone, required this.nextOfKin});
}

void matchRiderToClient(Client client, Rider rider) {
  sendMessageToNextOfKin(client.nextOfKin, rider);
}

void sendMessageToNextOfKin(NextOfKin nextOfKin, Rider rider) async {
  Position position = await getCurrentLocation();
  String locationUrl = "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

  String message = 'Dear ${nextOfKin.name},\n\n'
      'Your relative has been matched with a rider. Here are the rider details:\n'
      'Name: ${rider.name}\n'
      'Phone: ${rider.phone}\n'
      'Bike: ${rider.bikeDetails}\n\n'
      'Current location: $locationUrl';

  await sendWhatsAppMessage(message, nextOfKin.phone);
}

Future<Position> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied');
  }

  return await Geolocator.getCurrentPosition();
}

Future<void> sendWhatsAppMessage(String message, String phoneNumber) async {
  final Uri uri = Uri.parse('https://api.whatsapp.com/send?phone=${phoneNumber.replaceAll('+', '')}&text=${Uri.encodeComponent(message)}');

  if (await canLaunch(uri.toString())) {
    await launch(uri.toString());
  } else {
    throw 'Could not launch $uri';
  }
}
