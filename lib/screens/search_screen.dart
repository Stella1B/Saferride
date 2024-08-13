import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class LocationSearch extends StatefulWidget {
  final void Function(LatLng) onSelected;

  const LocationSearch({super.key, required this.onSelected});

  @override
  _LocationSearchState createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  final TextEditingController _typeAheadController = TextEditingController();

  Future<List<Suggestion>> getSuggestions(String query) async {
    if (query.isEmpty) {
      return [];
    }

    const apiKey = '5b3ce3597851110001cf62483c98c04e453d4af1b753d2066b16404f';
    final url =
        'https://api.openrouteservice.org/geocode/search?api_key=$apiKey&text=$query&size=5&boundary.country=UGA';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> features = data['features'];

      return features
          .map((feature) => Suggestion(
                feature['properties']['label'],
                LatLng(
                  feature['geometry']['coordinates'][1],
                  feature['geometry']['coordinates'][0],
                ),
              ))
          .toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TypeAheadFormField<Suggestion>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _typeAheadController,
              decoration: const InputDecoration(
                labelText: 'Where to?',
              ),
            ),
            suggestionsCallback: (pattern) async {
              return await getSuggestions(pattern);
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion.name),
              );
            },
            onSuggestionSelected: (suggestion) {
              widget.onSelected(suggestion.latLng);
              print('Selected location: ${suggestion.name}');
              print(
                  'Coordinates: ${suggestion.latLng.latitude}, ${suggestion.latLng.longitude}');
            },
            noItemsFoundBuilder: (context) => const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No locations found.'),
            ),
          ),
        ],
      ),
    );
  }
}

class Suggestion {
  final String name;
  final LatLng latLng;

  Suggestion(this.name, this.latLng);
}

void main() => runApp(MaterialApp(
    home: Scaffold(body: LocationSearch(onSelected: (LatLng latLng) {}))));

