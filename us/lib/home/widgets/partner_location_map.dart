import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Ensure you have this in pubspec
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class PartnerLocationMap extends StatefulWidget {
  const PartnerLocationMap({super.key});

  @override
  State<PartnerLocationMap> createState() => _PartnerLocationMapState();
}

class _PartnerLocationMapState extends State<PartnerLocationMap> {
  LatLng _myLocation = const LatLng(51.509364, -0.128928); // Default: London
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Get location
    Position position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _myLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Map
            FlutterMap(
              options: MapOptions(
                initialCenter: _myLocation,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    // My Location
                    Marker(
                      point: _myLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.person_pin_circle_rounded,
                        color: Colors.redAccent,
                        size: 40,
                      ),
                    ),
                    // Partner Location (Mocked for UI demo)
                    Marker(
                      point: LatLng(
                        _myLocation.latitude + 0.005,
                        _myLocation.longitude + 0.005,
                      ),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.pinkAccent,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Loading Overlay
            if (_isLoading)
              Container(
                color: Colors.white.withOpacity(0.8),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.pinkAccent),
                ),
              ),

            // Label
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Partner's Location",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
