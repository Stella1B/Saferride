import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:instaride/screens/search_screen.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class NavigationScreen extends StatefulWidget {
  final double lat;
  final double lng;

  const NavigationScreen({required this.lat, required this.lng, Key? key}) : super(key: key);

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final MapController _mapController = MapController();
  late LatLng _curLocation;
  LatLng? _searchedLocation;

  @override
  void initState() {
    super.initState();
    _curLocation = LatLng(widget.lat, widget.lng);
  }

  Future<LatLngBounds> getBounds() async {
    LatLng riderLocation = _curLocation;
    LatLng? destinationLocation = _searchedLocation;
    if (destinationLocation == null) {
      return LatLngBounds.fromPoints([
        LatLng(riderLocation.latitude - 0.01, riderLocation.longitude - 0.01),
        LatLng(riderLocation.latitude + 0.01, riderLocation.longitude + 0.01),
      ]);
    }
    double padding = 0.01;
    double minLat = math.min(riderLocation.latitude, destinationLocation.latitude);
    double minLng = math.min(riderLocation.longitude, destinationLocation.longitude);
    double maxLat = math.max(riderLocation.latitude, destinationLocation.latitude);
    double maxLng = math.max(riderLocation.longitude, destinationLocation.longitude);
    return LatLngBounds.fromPoints([
      LatLng(minLat - padding, minLng - padding),
      LatLng(maxLat + padding, maxLng + padding),
    ]);
  }

  Future<List<LatLng>> getRoute(LatLng start, LatLng? end) async {
    if (end == null) {
      return [start];
    }
    final apiKey = '5b3ce3597851110001cf62483c98c04e453d4af1b753d2066b16404f';
    final url = 'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      final List coordinates = data['features'][0]['geometry']['coordinates'];
      return coordinates.map((c) => LatLng(c[1], c[0])).toList();
    } else {
      throw Exception('Failed to load route');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Screen'),
      ),
      body: Column(
        children: [
          LocationSearch(
            onSelected: (LatLng location) {
              setState(() {
                _searchedLocation = location;
              });
            },
          ),
          Expanded(
            child: FutureBuilder<LatLngBounds>(
              future: getBounds(),
              builder: (context, boundsSnapshot) {
                if (boundsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (boundsSnapshot.hasError) {
                  return Center(child: Text('Error: ${boundsSnapshot.error}'));
                } else {
                  final bounds = boundsSnapshot.data!;
                  return FutureBuilder<List<LatLng>>(
                    future: getRoute(_curLocation, _searchedLocation),
                    builder: (context, routeSnapshot) {
                      if (routeSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (routeSnapshot.hasError) {
                        return Center(child: Text('Error: ${routeSnapshot.error}'));
                      } else {
                        final points = routeSnapshot.data!;
                        return FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            onTap: (_, __) {},
                            initialCenter: LatLng(_curLocation.latitude, _curLocation.longitude),
                            initialZoom: 13.0,
                            maxZoom: 18.0,
                            minZoom: 3.0,
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
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        "You",
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.orange,
                                          backgroundColor: Colors.white,
                                          fontWeight: FontWeight.bold,
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
                                if (_searchedLocation != null)
                                  Marker(
                                    width: 150.0,
                                    height: 150.0,
                                    point: _searchedLocation!,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Text(
                                          "Destination",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.orange,
                                            backgroundColor: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Icon(
                                          Icons.location_pin,
                                          color: Colors.deepPurple,
                                          size: 40.0,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            PolylineLayer(
                              polylines: [
                                if (_searchedLocation != null)
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
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
