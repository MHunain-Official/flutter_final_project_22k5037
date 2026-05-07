import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_theme.dart';

// ISP: MapScreen only knows about map display — no place or weather logic
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();

  // Well-known travel destinations as sample markers
  final List<({LatLng coords, String name, String country})> _destinations = [
    (coords: const LatLng(-43.89, 170.48), name: 'Lake Tekapo', country: 'New Zealand'),
    (coords: const LatLng(36.40, 25.46), name: 'Santorini', country: 'Greece'),
    (coords: const LatLng(35.00, 135.78), name: 'Kyoto Temple', country: 'Japan'),
    (coords: const LatLng(51.19, -115.55), name: 'Banff National Park', country: 'Canada'),
    (coords: const LatLng(46.35, 13.73), name: 'Lake Bled', country: 'Slovenia'),
    (coords: const LatLng(51.51, -0.13), name: 'London', country: 'UK'),
  ];

  String? _selectedName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Map')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(20, 0),
              initialZoom: 2.5,
            ),
            children: [
              // OpenStreetMap tile layer (free, no API key needed)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_final_project_22k5037',
              ),
              MarkerLayer(
                markers: _destinations.map((d) {
                  return Marker(
                    point: d.coords,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedName = '${d.name}, ${d.country}');
                        _mapController.move(d.coords, 6);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.location_pin, color: Colors.white, size: 20),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          // Selected place tooltip
          if (_selectedName != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: AnimatedOpacity(
                opacity: _selectedName != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(children: [
                    const Icon(Icons.place, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedName!,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => setState(() => _selectedName = null),
                    ),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
