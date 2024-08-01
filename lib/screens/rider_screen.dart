import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final MapController _mapController = MapController();
  final LatLng _curLocation = const LatLng(0.333, 32.556);
  Map? _storedCoordinates;
  LatLng? _incomingLocation;
  late Future<List<LatLng>> _routeFuture;

  void _fetchDistressedCoordinates() async {
    print('going to fetch');
    while (true) {
      try {
        final response = await http
            .get(Uri.parse('https://one-client.onrender.com/findDistressed'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('Response: $data');
          if (data.containsKey('lat')) {
            setState(() {
              _storedCoordinates = data;
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
      await Future.delayed(
          const Duration(seconds: 2)); // Adding a delay to avoid rapid looping
    }
  }

  @override
  void initState() {
    super.initState();
    _routeFuture = getRoute(_curLocation, _incomingLocation);
  }

  Future<void> _showDistressDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Distress Call'),
          content: const Text(
              "Hello. One of our clients is in danger and you might be the only one to help. Please reach out in any way possible."),
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
    if (_storedCoordinates != null) {
      LatLng distressLocation = LatLng(
        double.parse(_storedCoordinates!['lat']!),
        double.parse(_storedCoordinates!['long']!),
      );
      setState(() {
        _incomingLocation = distressLocation;
        _routeFuture = getRoute(_curLocation, _incomingLocation);
      });
      fitMapToBounds();
    }
  }

  Future<LatLngBounds> getBounds() async {
    LatLng riderLocation = _curLocation;
    LatLng? newMapLocation = _incomingLocation;

    double padding = 0.01;
    double minLat = math.min(riderLocation.latitude,
        newMapLocation?.latitude ?? riderLocation.latitude);
    double minLng = math.min(riderLocation.longitude,
        newMapLocation?.longitude ?? riderLocation.longitude);
    double maxLat = math.max(riderLocation.latitude,
        newMapLocation?.latitude ?? riderLocation.latitude);
    double maxLng = math.max(riderLocation.longitude,
        newMapLocation?.longitude ?? riderLocation.longitude);

    return LatLngBounds(
      LatLng(minLat - padding, minLng - padding),
      LatLng(maxLat + padding, maxLng + padding),
    );
  }

  Future<void> fitMapToBounds() async {
    final bounds = await getBounds();
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
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
      final List<dynamic> coordinates =
          data['features'][0]['geometry']['coordinates'];
      return coordinates.map((c) => LatLng(c[1], c[0])).toList();
    } else {
      throw Exception('Failed to load route');
    }
  }

  void _resetState() {
    setState(() {
      _incomingLocation = null;
      _routeFuture = getRoute(_curLocation, _incomingLocation);
    });
    fitMapToBounds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _fetchDistressedCoordinates,
          child: const Text('Rider App'),
        ),
        centerTitle: true,
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
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 150.0,
                        height: 150.0,
                        point: _curLocation,
                        child: Container(
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "You",
                                  style: TextStyle(
                                    fontSize: 19.0,
                                    color: Colors.red,
                                    backgroundColor: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.location_pin,
                                color: Colors.green,
                                size: 40.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_incomingLocation != null)
                        Marker(
                          width: 150.0,
                          height: 150.0,
                          point: _incomingLocation!,
                          child: Container(
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Client",
                                    style: TextStyle(
                                        fontSize: 19.0,
                                        backgroundColor: Colors.white,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold)),
                                Icon(Icons.location_pin,
                                    color: Colors.red, size: 40.0),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_incomingLocation != null)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: points,
                          strokeWidth: 4.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                ],
              );
            }
          }),
    );
  }
}
