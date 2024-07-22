import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instaride/firebase_options.dart';
import 'Screens/sign_up.dart';
import 'Screens/OTP_verification.dart';
import 'Screens/sign_in.dart';
import 'Screens/profile_screen.dart';
import 'Screens/home_screen.dart'; // Import your home screen page
import 'Screens/navigation_screen.dart'; // Import the navigation screen
import 'screens/welcome_page.dart';

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
      title: 'Instaride',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome':(context) => const WelcomePage(),
        '/signup': (context) => const SignUpPage(),
        '/verify_otp': (context) => const OTPVerificationPage(email: '',),
        '/signin': (context) => const SignInPage(),
        '/create_profile': (context) => const ProfileCreationPage(),
        '/home': (context) => const HomeScreen(), // Route to your home screen
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
