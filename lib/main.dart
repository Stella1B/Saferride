import 'package:boda/firebase_options.dart';
import 'package:boda/screens/qr_rider.dart';
import 'package:boda/screens/rider_screen.dart';
import 'package:boda/screens/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Screens/sign_up.dart';
import 'Screens/sign_in.dart';
import 'Screens/profile_screen.dart';
import 'Screens/home_screen.dart'; // Import your home screen page

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
      debugShowCheckedModeBanner: false,
      title: 'Saferride',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/signup': (context) => const SignUpPage(),
        '/signin': (context) => const SignInPage(), // Ensure this route is defined
        '/create_profile': (context) => const ProfileCreationPage(),
        '/home': (context) => const HomeScreen(), // Route to your home screen
        '/qr_rider':(context)=> const GenerateCodePage(),
        '/rider_screen':(context)=>const HomePage(),
       '/navigation': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, double>;
          return NavigationScreen(lat: args['lat']!, lng: args['lng']!);
        },

        // Add more routes as needed
      },
    );
  }
}

class NavigationScreen extends StatelessWidget {
  final double lat;
  final double lng;

  const NavigationScreen({Key? key, required this.lat, required this.lng}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
      ),
      body: Center(
        child: Text('Latitude: $lat, Longitude: $lng'),
      ),
    );
  }
}
