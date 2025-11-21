import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../constants/app_constants.dart';
import '../../services/location_service.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../events/create_event_screen.dart';

class MapRadarScreenUpdated extends StatefulWidget {
  const MapRadarScreenUpdated({super.key});

  @override
  State<MapRadarScreenUpdated> createState() => _MapRadarScreenUpdatedState();
}

class _MapRadarScreenUpdatedState extends State<MapRadarScreenUpdated> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
    });
  }

  Future<void> _initializeMap() async {
    final locationService = context.read<LocationService>();
    
    // Request location permission and get current location
    await locationService.getCurrentLocation();
    
    if (locationService.currentPosition == null) {
      // Use mock location for demo
      locationService.useMockLocation();
    }

    // Start location tracking
    locationService.startTracking();

    // Load nearby circles and create markers
    await _loadNearbyCircles();
  }

  Future<void> _loadNearbyCircles() async {
    final locationService = context.read<LocationService>();
    if (locationService.currentGeoPoint == null) return;

    final circlesData = await FirestoreService.getNearbyCircles(
      userLocation: locationService.currentGeoPoint!,
      radiusKm: 5.0,
    );

    setState(() {
      _markers.clear();
      _circles.clear();

      // Add user marker
      if (locationService.currentPosition != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('user_location'),
            position: LatLng(
              locationService.currentPosition!.latitude,
              locationService.currentPosition!.longitude,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: const InfoWindow(title: 'You are here'),
          ),
        );
      }

      // Add circle markers
      for (var circle in circlesData) {
        final color = ActivityTypes.getColor(circle.activityType);
        
        _markers.add(
          Marker(
            markerId: MarkerId(circle.id),
            position: LatLng(
              circle.centerLocation.latitude,
              circle.centerLocation.longitude,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(_getHueFromColor(color)),
            infoWindow: InfoWindow(
              title: '${circle.activityType} Circle',
              snippet: '${circle.memberCount} members',
            ),
          ),
        );

        _circles.add(
          Circle(
            circleId: CircleId(circle.id),
            center: LatLng(
              circle.centerLocation.latitude,
              circle.centerLocation.longitude,
            ),
            radius: circle.radius,
            fillColor: color.withValues(alpha: 0.2),
            strokeColor: color,
            strokeWidth: 2,
          ),
        );
      }
    });
  }

  double _getHueFromColor(Color color) {
    // Convert Color to HSL hue for marker color
    if (color == AppColors.activityColors['Explore']) return BitmapDescriptor.hueViolet;
    if (color == AppColors.activityColors['Coffee']) return BitmapDescriptor.hueOrange;
    if (color == AppColors.activityColors['Nightlife']) return BitmapDescriptor.hueViolet;
    if (color == AppColors.activityColors['Eat']) return BitmapDescriptor.hueGreen;
    return BitmapDescriptor.hueRed;
  }

  @override
  Widget build(BuildContext context) {
    final locationService = context.watch<LocationService>();
    final authService = context.watch<AuthService>();

    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          locationService.currentPosition != null
              ? GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      locationService.currentPosition!.latitude,
                      locationService.currentPosition!.longitude,
                    ),
                    zoom: 14.0,
                  ),
                  markers: _markers,
                  circles: _circles,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.primaryGradient,
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Loading map...',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
          
          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [AppStyles.cardShadow],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.primaryGradient),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authService.currentUser?.username ?? 'Traveler',
                            style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_circles.length} circles nearby',
                            style: AppStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadNearbyCircles,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // FAB for creating events
          Positioned(
            right: 16,
            bottom: 80,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateEventScreen()),
                );
              },
              backgroundColor: AppColors.accent,
              icon: const Icon(Icons.add),
              label: const Text('Create Event', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
