import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _adStatements = [
    'Enjoy 20% off on your next ride!',
    'Get a free upgrade on premium services.',
    'Refer a friend and both get a discount!',
    'Heyyy, start your day with a saferride',
    'Do not worry about rain',
  ];
  Timer? _timer;
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_scrollController.hasClients) {
        _scrollPosition += 1;
        if (_scrollPosition > _scrollController.position.maxScrollExtent) {
          _scrollPosition = 0.0;
        }
        _scrollController.jumpTo(_scrollPosition);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications Page'),
        backgroundColor: Color.fromARGB(255, 248, 139, 37),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildFeatureCard(
                  context,
                  title: 'Panic Button',
                  description: 'Quickly alert emergency services with our panic button. Safety is just a tap away!',
                  icon: Icons.warning,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  context,
                  title: 'Family Button',
                  description: 'Keep your loved ones connected and informed. Use the family button for quick updates and alerts.',
                  icon: Icons.family_restroom,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  context,
                  title: 'Good Service',
                  description: 'Experience top-notch service with our dedicated team. We are committed to providing you with the best.',
                  icon: Icons.thumb_up,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                _buildAdTicker(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Icon(
          icon,
          color: color,
          size: 40,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(description),
        onTap: () {
          // Handle tap if needed
        },
      ),
    );
  }

  Widget _buildAdTicker() {
    return SizedBox(
      height: 60, // Adjust height as needed
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _adStatements.length * 2, // Duplicate items for infinite effect
        itemBuilder: (context, index) {
          final adIndex = index % _adStatements.length;
          return Container(
            width: 300, // Adjust width as needed
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 4.0,
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _adStatements[adIndex],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
