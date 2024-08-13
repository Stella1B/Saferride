import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final LatLng _curLocation = const LatLng(0.333, 32.556);
  Map? _storedCoordinates;
  LatLng? _incomingLocation;
  late Future<List<LatLng>> _routeFuture;
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  bool _isDistressCallActive = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _routeFuture = getRoute(_curLocation, _incomingLocation);

    // Initialize the AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      upperBound: 1,
    );

    // Define the animation for blinking
    _colorAnimation = ColorTween(begin: Colors.red, end: Colors.transparent).animate(_animationController);

    // Start fetching distressed coordinates
    _fetchDistressedCoordinates();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _fetchDistressedCoordinates() async {
    print('Fetching distressed coordinates...');
    while (true) {
      try {
        final response = await http.get(Uri.parse('https://one-client.onrender.com/findDistressed'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('Response: $data');
          if (data.containsKey('lat')) {
            setState(() {
              _storedCoordinates = data;
              _isDistressCallActive = true;
              _animationController.repeat(reverse: true); // Start blinking
              _playAlarm(); // Play alarm sound
            });
            _showDistressDialog();
            break;
          }
        } else {
          print('Failed to load distressed coordinates');
        }
      } catch (error) {
        print('Error fetching distressed coordinates: $error');
      }
      await Future.delayed(const Duration(seconds: 5)); // Delay to avoid rapid looping
    }
  }

  void _playAlarm() async {
    try {
      // Play the alarm sound
      await _audioPlayer.setSource(AssetSource('alarm.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop the alarm sound
      await _audioPlayer.resume();
      print('Alarm is playing'); // Debug statement
    } catch (e) {
      print('Error playing alarm sound: $e');
    }
  }

  void _stopAlarm() async {
    try {
      await _audioPlayer.stop();
      print('Alarm stopped');
    } catch (e) {
      print('Error stopping alarm sound: $e');
    }
  }

  Future<void> _showDistressDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Distress Call'),
          content: const Text("Hello. One of our clients is in danger and you might be the only one to help. Please reach out in any way possible."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                viewLocation();
                Navigator.of(context).pop();
              },
              child: const Text('View Location'),
            ),
          ],
        );
      },
    );
  }

void viewLocation() {
  if (_storedCoordinates != null && _storedCoordinates!.containsKey('lat') && _storedCoordinates!.containsKey('long')) {
    LatLng distressLocation = LatLng(
      double.parse(_storedCoordinates!['lat']),
      double.parse(_storedCoordinates!['long']),
    );
    setState(() {
      _incomingLocation = distressLocation;
      _routeFuture = getRoute(_curLocation, _incomingLocation);
    });
    fitMapToBounds();
  } else {
    print('Invalid or missing coordinates in the response');
  }
}

Future<LatLngBounds> getBounds() async {
  LatLng riderLocation = _curLocation;
  LatLng? newMapLocation = _incomingLocation;

  double padding = 0.01;
  double minLat = math.min(riderLocation.latitude, newMapLocation?.latitude ?? riderLocation.latitude);
  double minLng = math.min(riderLocation.longitude, newMapLocation?.longitude ?? riderLocation.longitude);
  double maxLat = math.max(riderLocation.latitude, newMapLocation?.latitude ?? riderLocation.latitude);
  double maxLng = math.max(riderLocation.longitude, newMapLocation?.longitude ?? riderLocation.longitude);

  return LatLngBounds(
    LatLng(minLat - padding, minLng - padding),
    LatLng(maxLat + padding, maxLng + padding),
  );
}

Future<void> fitMapToBounds() async {
  if (_incomingLocation != null) {
    final bounds = await getBounds();
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(20),
      ),
    );
  } else {
    print('No incoming location to fit bounds');
  }
}

  Future<List<LatLng>> getRoute(LatLng start, LatLng? end) async {
    if (end == null) {
      return [start];
    }
    final apiKey = '5b3ce3597851110001cf62483c98c04e453d4af1b753d2066b16404f';
    final url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> coordinates = data['features'][0]['geometry']['coordinates'];
      return coordinates.map((c) => LatLng(c[1], c[0])).toList();
    } else {
      throw Exception('Failed to load route');
    }
  }

  void _resetState() {
    setState(() {
      _incomingLocation = null;
      _isDistressCallActive = false;
      _routeFuture = getRoute(_curLocation, _incomingLocation);
    });
    _animationController.stop(); // Stop blinking
    _stopAlarm(); // Stop alarm sound
    fitMapToBounds();
  }

  void _logout() {
    Navigator.of(context).pushReplacementNamed('/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            return GestureDetector(
              onTap: _fetchDistressedCoordinates,
              child: Text(
                'SAFERRIDE',
                style: TextStyle(
                  color: _isDistressCallActive ? _colorAnimation.value : const Color.fromARGB(255, 48, 47, 47),
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List<LatLng>>(
        future: _routeFuture,
        builder: (context, routeSnapshot) {
          if (routeSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (routeSnapshot.hasError) {
            return Center(child: Text('Error: ${routeSnapshot.error}'));
          } else {
            fitMapToBounds();
            final points = routeSnapshot.data!;
            return FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _curLocation,
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 150.0,
                      height: 150.0,
                      point: _curLocation,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'You',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 30.0,
                          ),
                        ],
                      ),
                    ),
                    if (_incomingLocation != null)
                      Marker(
                        width: 150.0,
                        height: 150.0,
                        point: _incomingLocation!,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 50.0,
                        ),
                      ),
                  ],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: points,
                      strokeWidth: 5.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetState,
        tooltip: 'Reset',
        backgroundColor: Colors.red,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
