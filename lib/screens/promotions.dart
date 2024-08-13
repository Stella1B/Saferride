import 'dart:async'; // Import to use Timer
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PromotionsScreen(),
    );
  }
}

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  _PromotionsScreenState createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  final PageController _pageController = PageController();
  final List<Widget> _pages = [
    PromotionPage(
      imagePath: 'assets/car.jpg',
      title: '35% Discount for You!',
      subtitle: 'On your next 10 trips',
      details: const {
        'Maximum Discount': 'UGX 600',
        'Expiry Date': '13 August 2024',
        'Trips Remaining': '10/10',
      },
      buttonText: 'Claim Now',
      onButtonPressed: () {
        // Handle button press
      },
      backgroundColor: Colors.lightBlue.shade50,
      titleStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
      subtitleStyle: const TextStyle(fontSize: 18, color: Colors.blueGrey),
      detailLabelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      detailValueStyle: const TextStyle(color: Colors.black54),
      buttonColor: Colors.blueAccent,
    ),
    PromotionPage(
      imagePath: 'assets/logo1.jpg',
      title: '25% Off on Bike Rentals',
      subtitle: 'For the next 5 rentals',
      details: const {
        'Maximum Discount': 'UGX 300',
        'Expiry Date': '20 August 2024',
        'Rentals Remaining': '5/5',
      },
      buttonText: 'Got It',
      onButtonPressed: () {
        // Handle button press
      },
      backgroundColor: Colors.yellow.shade50,
      titleStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.orange),
      subtitleStyle: const TextStyle(fontSize: 16, color: Colors.deepOrange),
      detailLabelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      detailValueStyle: const TextStyle(color: Colors.black54),
      buttonColor: Colors.orange,
    ),
    PromotionPage(
      imagePath: 'assets/scooter.jpg',
      title: '15% Off on Scooter Rentals',
      subtitle: 'For the next 3 rentals',
      details: const {
        'Maximum Discount': 'UGX 150',
        'Expiry Date': '25 August 2024',
        'Rentals Remaining': '3/3',
      },
      buttonText: 'Enjoy',
      onButtonPressed: () {
        // Handle button press
      },
      backgroundColor: Colors.green.shade50,
      titleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
      subtitleStyle: const TextStyle(fontSize: 16, color: Colors.greenAccent),
      detailLabelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      detailValueStyle: const TextStyle(color: Colors.black54),
      buttonColor: Colors.green,
    ),
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_pageController.page! + 1).toInt() % _pages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Handle back button action
          },
        ),
        title: const Text('Promotions'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        children: _pages,
      ),
    );
  }
}

class PromotionPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final Map<String, String> details;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final Color backgroundColor;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final TextStyle detailLabelStyle;
  final TextStyle detailValueStyle;
  final Color buttonColor;

  const PromotionPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.details,
    required this.buttonText,
    required this.onButtonPressed,
    this.backgroundColor = Colors.white,
    this.titleStyle = const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
    this.subtitleStyle = const TextStyle(fontSize: 16, color: Colors.black54),
    this.detailLabelStyle = const TextStyle(fontWeight: FontWeight.bold),
    this.detailValueStyle = const TextStyle(),
    this.buttonColor = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    imagePath,
                    height: 150, // Reduced height for smaller image
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                title,
                style: titleStyle,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                subtitle,
                style: subtitleStyle,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            for (var entry in details.entries)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: detailLabelStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.value,
                    style: detailValueStyle,
                  ),
                  const Divider(),
                ],
              ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'Ride and Earn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 235, 151, 66),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Earn up to 35% discount on every ride with Faras',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 15, 14, 14),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
                onPressed: onButtonPressed,
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
