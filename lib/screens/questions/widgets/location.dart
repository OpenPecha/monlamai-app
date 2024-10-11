import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:permission_handler/permission_handler.dart';

class LocationPage extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) setFormData;

  const LocationPage(
      {required this.formData, required this.setFormData, super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  bool loadingLocation = false;

  @override
  void initState() {
    super.initState();
    cityController.text = widget.formData['city'] ?? '';
    countryController.text = widget.formData['country'] ?? '';
  }

  void handleInputChange(String name, String value) {
    widget.setFormData({...widget.formData, name: value});
  }

  Future<void> handleUseCurrentLocation() async {
    TextInput.finishAutofillContext();
    print('handleUseCurrentLocation');
    try {
      setState(() {
        loadingLocation = true;
      });
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled, show dialog to enable location
        bool enable = await Geolocator.openLocationSettings();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("permission $permission");
          if (!mounted) return;
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Location permission denied'),
                  content: Text(
                      'Please enable location permission to use this feature'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          openAppSettings();
                        },
                        child: Text('OK'))
                  ],
                );
              });
        }
      }
      if (permission == LocationPermission.deniedForever) {
        print("permanently denied");
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Location permission denied'),
              content:
                  Text('Please enable location permission to use this feature'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      openAppSettings();
                    },
                    child: Text('OK'))
              ],
            );
          },
        );
      }

      Position position = await Geolocator.getCurrentPosition();
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final city = data['address']['city'] ??
            data['address']['town'] ??
            data['address']['village'];
        final country = data['address']['country'];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            cityController.text = city ?? '';
            countryController.text = country ?? '';
            loadingLocation = false;
          });
        });

        widget.setFormData(
            {...widget.formData, 'city': city, 'country': country});
      } else {
        throw Exception('Failed to fetch location data');
      }
    } catch (error) {
      print('Error in handleUseCurrentLocation: $error');
      if (mounted) {
        setState(() {
          loadingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Where do you live?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 24),
          AutofillGroup(
              child: Column(
            children: [
              _buildInputField(
                  'City',
                  cityController,
                  (value) => handleInputChange('city', value),
                  AutofillHints.addressCity),
              SizedBox(height: 16),
              _buildInputField(
                  'Country',
                  countryController,
                  (value) => handleInputChange('country', value),
                  AutofillHints.countryName),
              SizedBox(height: 16),
            ],
          )),
          InkWell(
            onTap: handleUseCurrentLocation,
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  "Use current location",
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
                SizedBox(width: 8),
                if (loadingLocation)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      Function(String) onChanged, String autofillHint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          autofillHints: [autofillHint],
          onChanged: onChanged,
          onTap: () {
            TextInput.finishAutofillContext();
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search',
            helperStyle: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
