import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noiseguard/features/maps/widgets/location_detail_sheet.dart';

// Dark Map Style JSON
const String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]
''';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late GoogleMapController _mapController;
  bool _showHeatmap = false;

  final LatLng _initialPosition = const LatLng(23.0225, 72.5714); // Ahmedabad

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController.setMapStyle(_darkMapStyle);
  }

  void _showLocationDetails(String locationName, double dbLevel, String source, bool isViolation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LocationDetailSheet(
        locationName: locationName,
        dbLevel: dbLevel,
        source: source,
        isViolation: isViolation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final markers = {
      Marker(
        markerId: const MarkerId('loc1'),
        position: const LatLng(23.0225, 72.5714),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        onTap: () => _showLocationDetails('SG Highway', 65.0, 'Traffic', false),
      ),
      Marker(
        markerId: const MarkerId('loc2'),
        position: const LatLng(23.0300, 72.5800),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        onTap: () => _showLocationDetails('Maninagar', 85.0, 'Construction', true),
      ),
      Marker(
        markerId: const MarkerId('loc3'),
        position: const LatLng(23.0100, 72.5600),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onTap: () => _showLocationDetails('Navrangpura', 95.0, 'DJ', true),
      ),
    };

    // Mock heatmap circles
    final heatmapCircles = {
      Circle(
        circleId: const CircleId('heat1'),
        center: const LatLng(23.0225, 72.5714),
        radius: 500,
        fillColor: Colors.green.withOpacity(0.4),
        strokeWidth: 0,
      ),
      Circle(
        circleId: const CircleId('heat2'),
        center: const LatLng(23.0300, 72.5800),
        radius: 600,
        fillColor: Colors.orange.withOpacity(0.4),
        strokeWidth: 0,
      ),
      Circle(
        circleId: const CircleId('heat3'),
        center: const LatLng(23.0100, 72.5600),
        radius: 400,
        fillColor: Colors.red.withOpacity(0.5),
        strokeWidth: 0,
      ),
    };

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 12.0,
            ),
            markers: _showHeatmap ? {} : markers,
            circles: _showHeatmap ? heatmapCircles : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          
          // Top Floating Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2A2A3C)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Device: ESP32-Alpha',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Live Area Monitoring',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA3E635).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mic, color: Color(0xFFA3E635), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '65 dB',
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFFA3E635),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'heatmap_toggle',
            backgroundColor: const Color(0xFF1E1E2C),
            onPressed: () {
              setState(() {
                _showHeatmap = !_showHeatmap;
              });
            },
            child: Icon(
              _showHeatmap ? Icons.map : Icons.layers,
              color: const Color(0xFFA3E635),
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'my_location',
            backgroundColor: const Color(0xFFA3E635),
            onPressed: () {
              _mapController.animateCamera(
                CameraUpdate.newLatLngZoom(_initialPosition, 14),
              );
            },
            child: const Icon(
              Icons.my_location,
              color: Color(0xFF1E1E2C),
            ),
          ),
        ],
      ),
    );
  }
}
