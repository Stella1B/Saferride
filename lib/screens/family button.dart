import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instaride/firebase_options.dart';

void main() async {
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
      title: 'Family safety',
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
        title: const Text('Family safety'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Create sample data
            NextOfKin nextOfKin = NextOfKin(name: 'John Doe', phone: '0778411732');
            Client client = Client(name: 'Jane Smith', phone: '+0987654321', nextOfKin: nextOfKin);
            Rider rider = Rider(name: 'Mike Johnson', phone: '+1122334455', bikeDetails: 'Honda CBR 250R');

            // Match rider to client
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
  // Logic to match the rider to the client
  print('Matching ${rider.name} to ${client.name}');

  // After matching, send message to the next of kin
  sendMessageToNextOfKin(client.nextOfKin, rider);
}

void sendMessageToNextOfKin(NextOfKin nextOfKin, Rider rider) {
  String message = 'Dear ${nextOfKin.name},\n\n'
      'Your relative has been matched with a rider. Here are the rider details:\n'
      'Name: ${rider.name}\n'
      'Phone: ${rider.phone}\n'
      'Bike: ${rider.bikeDetails}';

  // Simulate sending SMS
  sendSMS(nextOfKin.phone, message);
}

void sendSMS(String phone, String message) {
  // Mock function to simulate sending an SMS
  print('Sending SMS to $phone:');
  print(message);
}
