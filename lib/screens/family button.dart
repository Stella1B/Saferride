import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instaride/firebase_options.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

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
        child: ElevatedButton(
          onPressed: () {
            NextOfKin nextOfKin = NextOfKin(name: 'John Doe', phone: '+256786230754');
            Client client = Client(name: 'Jane Smith', phone: '256987654321', nextOfKin: nextOfKin);
            Rider rider = Rider(name: 'Mike Johnson', phone: '2561122334455', bikeDetails: 'Honda CBR 250R');
            matchRiderToClient(client, rider);
          },
          child: const Text('Match Rider to Client'),
        ),
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
  String encodedMessage = Uri.encodeComponent(message);
  String whatsappUrl = "https://wa.me/${phoneNumber.replaceAll('+', '')}?text=$encodedMessage";

  if (await canLaunch(whatsappUrl)) {
    await launch(whatsappUrl);
  } else {
    print('Could not launch WhatsApp. URL: $whatsappUrl');
  }
}
