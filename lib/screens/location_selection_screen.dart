import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:sundial/services/daily_solar_data_service.dart';
import 'package:sundial/models/daily_solar_data.dart';
import 'package:sundial/functions/solar_api.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({Key? key}) : super(key: key);

  @override
  _LocationSelectionScreenState createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  LatLng? _selectedLocation;
  DateTimeRange? _selectedDateRange;
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedLocationName;

  static const String _mapStyle = ''' [
  {
    'elementType': 'geometry',
    'stylers': [
      {'color': '#242f3e'}
    ]
  },
  {
    'elementType': 'labels.text.fill',
    'stylers': [
      {'color': '#746855'}
    ]
  },
  {
    'elementType': 'labels.text.stroke',
    'stylers': [
      {'color': '#242f3e'}
    ]
  },
  {
    'featureType': 'administrative',
    'elementType': 'geometry',
    'stylers': [
      {'visibility': 'off'}
    ]
  },
  {
    'featureType': 'administrative.locality',
    'elementType': 'labels.text.fill',
    'stylers': [
      {'color': '#d59563'}
    ]
  },
  {
    'featureType': 'poi',
    'stylers': [
      {'visibility': 'off'}
    ]
  },
  {
    'featureType': 'poi',
    'elementType': 'labels.text.fill',
    'stylers': [
      {'color': '#d59563'}
    ]
  },
  {
    'featureType': 'poi.park',
    'elementType': 'geometry',
    'stylers': [
      {'color': '#263c3f'}
    ]
  },
  {
    'featureType': 'poi.park',
    'elementType': 'labels.text.fill',
    'stylers': [
      {'color': '#6b9a76'}
    ]
  },
  {
    'featureType': 'road',
    'elementType': 'geometry',
    'stylers': [
      {'color': '#38414e'}
    ]
  },
  {
    'featureType': 'road',
    'elementType': 'geometry.stroke',
    'stylers': [
      {'color': '#212a37'}
    ]
  },
  {
    'featureType': 'road',
    'elementType': 'labels.text.fill',
    'stylers': [
      {'color': '#9ca5b3'}
    ]
  },
  {
    'featureType': 'road.highway',
    'elementType': 'geometry',
    'stylers': [
      {'color': '#746855'}
    ]
  },
  {
    'featureType': 'road.highway',
    'elementType': 'geometry.stroke',
    'stylers': [
      {'color': '#1f2835'}
    ]
  },
  {
    'featureType': 'road.highway',
    'elementType': 'labels.text.fill',
    'stylers': [
      {'color': '#f3d19c'}
    ]
  },
  {
    'featureType': 'transit',
    'elementType': 'geometry',
    'stylers': [
      {'color': '#2f3948'}
    ]
  },
  {
    'featureType': 'transit.station',
    'elementType': 'labels.text.fill',
    'stylers': [
      {'color': '#d59563'}
    ]
  },
  {
    'featureType': 'water',
    'elementType': 'geometry',
    'stylers': [
      {'color': '#17263c'}
    ]
  },
  {
    'featureType': 'water',
    'elementType': 'labels.text.fill',
    'stylers': [
      {'color': '#515c6d'}
    ]
  },
  {
    'featureType': 'water',
    'elementType': 'labels.text.stroke',
    'stylers': [
      {'color': '#17263c'}
    ]
  }
] ''';

  
  final String googleApiKey = "AIzaSyDI_pjx6Apfy9FsoFHTDJRWVX2xv9Ay28E";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Setup'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(0, 0),
                zoom: 2,
              ),
            onMapCreated: (controller) {
              _mapController = controller;
              controller.setMapStyle(_mapStyle);
            },
            onTap: (latLng) async {
              setState(() {
                _selectedLocation = latLng;
              });
              await _getPlaceNameFromCoordinates(latLng);
            },
              markers: _selectedLocation == null
                  ? {}
                  : {
                      Marker(
                        markerId: const MarkerId('selected-location'),
                        position: _selectedLocation!,
                      ),
                    },
            ),
          ),
          Positioned(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            child: GooglePlaceAutoCompleteTextField(
              textEditingController: _searchController,
              googleAPIKey: googleApiKey,
              inputDecoration: const InputDecoration(
                hintText: "Search Location",
                border: OutlineInputBorder(),
              ),
              debounceTime: 800,
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (Prediction prediction) async {
                if (prediction.lat != null && prediction.lng != null) {
                  final lat = double.parse(prediction.lat!);
                  final lng = double.parse(prediction.lng!);
                  final latLng = LatLng(lat, lng);
                  setState(() {
                    _selectedLocation = latLng;
                    _selectedLocationName = prediction.description;
                  });
                  _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
                }
              },
              itemClick: (Prediction prediction) {
                _searchController.text = prediction.description ?? "";
                _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: prediction.description?.length ?? 0));
              },
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: Column(
              children: [
                if (_selectedLocationName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('Selected Location: $_selectedLocationName'),
                  ),
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(90.0)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(90.0)),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                        ),
                        onPressed: _selectDateRange,
                        child: Text(
                          _selectedDateRange == null
                              ? 'Select Date Range'
                              : '${_selectedDateRange!.start.toLocal().toString().split(' ')[0]} - ${_selectedDateRange!.end.toLocal().toString().split(' ')[0]}',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(90.0)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(90.0)),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                        ),
                        onPressed: _selectedLocation != null && _selectedDateRange != null
                            ? _saveLocationAndDateRange
                            : null,
                        child: const Text('Save Location and Date Range'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Future<void> _getPlaceNameFromCoordinates(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          _selectedLocationName = "${placemark.street}, ${placemark.locality}, ${placemark.country}";
        });
      } else {
        setState(() {
          _selectedLocationName = "Unknown location";
        });
      }
    } catch (e) {
      setState(() {
        _selectedLocationName = "Error getting location name";
      });
      print("Error getting place name: $e");
    }
  }

  void _saveLocationAndDateRange() async {
    if (_selectedLocation != null && _selectedDateRange != null) {
      final dailySolarDataService = DailySolarDataService();
      final startDate = _selectedDateRange!.start;
      final endDate = _selectedDateRange!.end;

      for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
        final currentDate = startDate.add(Duration(days: i));
        try {
          final solarData = await SolarApi.fetchSolar(
            _selectedLocation!.latitude,
            _selectedLocation!.longitude,
          );

          if (solarData != null && solarData['parsed'] != null) {
            final parsedSolarEvents = solarData['parsed'] as Map<String, DateTime>;

            final dailyData = DailySolarData(
              date: currentDate,
              latitude: _selectedLocation!.latitude,
              longitude: _selectedLocation!.longitude,
              locationName: _selectedLocationName,
              sunrise: parsedSolarEvents['sunrise'] != null ? TimeOfDay.fromDateTime(parsedSolarEvents['sunrise']!) : null,
              sunset: parsedSolarEvents['sunset'] != null ? TimeOfDay.fromDateTime(parsedSolarEvents['sunset']!) : null,
              solarNoon: parsedSolarEvents['solar_noon'] != null ? TimeOfDay.fromDateTime(parsedSolarEvents['solar_noon']!) : null,
              astronomicalTwilightBegin: parsedSolarEvents['astronomical_twilight_begin'] != null ? TimeOfDay.fromDateTime(parsedSolarEvents['astronomical_twilight_begin']!) : null,
              astronomicalTwilightEnd: parsedSolarEvents['astronomical_twilight_end'] != null ? TimeOfDay.fromDateTime(parsedSolarEvents['astronomical_twilight_end']!) : null,
              nauticalTwilightBegin: parsedSolarEvents['nautical_twilight_begin'] != null ? TimeOfDay.fromDateTime(parsedSolarEvents['nautical_twilight_begin']!) : null,
              nauticalTwilightEnd: parsedSolarEvents['nautical_twilight_end'] != null ? TimeOfDay.fromDateTime(parsedSolarEvents['nautical_twilight_end']!) : null,
            );
          } else {
            print('Failed to fetch solar data for ${currentDate.toLocal()}');
          }
        } catch (e) {
          print('Error saving solar data for ${currentDate.toLocal()}: $e');
        }
      }

      Navigator.pop(context, {
        'location': _selectedLocation,
        'dateRange': _selectedDateRange,
        'locationName': _selectedLocationName,
      });
    }
  }
}
