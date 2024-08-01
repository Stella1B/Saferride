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

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
             Navigator.of(context).pop();// Handle back button action
          },
        ),
        title: const Text('Promotions'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Image.asset(
                'assets/car.webp', // Ensure you have added your image to assets
                height: 100,
                width: 150,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: PromotionText(
                text: '35% discount for you',
                fontSize: 24,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: PromotionText(
                text: 'To your next 10 trips',
                fontSize: 16,
                
              ),
            ),
            const SizedBox(height: 32),
            const PromotionDetailColumn(
              label: 'Maximum discount',
              value: 'UGX 600',
            ),
            const Divider(),
            const PromotionDetailColumn(
              label: 'Expiry date',
              value: '20 July 2024',
            ),
            const Divider(),
            const PromotionDetailColumn(
              label: 'Trips',
              value: '10/10',
            ),
            const Divider(),
            const SizedBox(height: 32),
            const Center(
              child: PromotionText(
                text: 'Ride and Earn',
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: PromotionText(
                text: 'Earn up to 35% discount on every ride with Faras',
                fontSize: 16,
                color: Color.fromARGB(255, 15, 14, 14),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
                onPressed: () {
                   Navigator.of(context).pop();// Handle OK button action
                },
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PromotionText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;

  const PromotionText({
    Key? key,
    required this.text,
    this.fontSize = 16,
    this.color = Colors.black,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.left,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
    );
  }
}

class PromotionDetailColumn extends StatelessWidget {
  final String label;
  final String value;

  const PromotionDetailColumn({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }
}
