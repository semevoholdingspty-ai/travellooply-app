import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/circle_model.dart';
import '../../services/location_service.dart';
import '../../services/firestore_service.dart';
import 'circle_chat_screen.dart';

class CirclesListScreen extends StatefulWidget {
  const CirclesListScreen({super.key});

  @override
  State<CirclesListScreen> createState() => _CirclesListScreenState();
}

class _CirclesListScreenState extends State<CirclesListScreen> {
  List<CircleModel> _circles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCircles();
  }

  Future<void> _loadCircles() async {
    setState(() => _isLoading = true);
    
    final locationService = context.read<LocationService>();
    final userLocation = locationService.currentGeoPoint;
    
    if (userLocation != null) {
      final circles = await FirestoreService.getNearbyCircles(
        userLocation: userLocation,
        radiusKm: 5.0,
      );
      
      setState(() {
        _circles = circles;
        _isLoading = false;
      });
    } else {
      // Use mock location if no GPS
      locationService.useMockLocation();
      final circles = await FirestoreService.getNearbyCircles(
        userLocation: locationService.currentGeoPoint!,
        radiusKm: 5.0,
      );
      
      setState(() {
        _circles = circles;
        _isLoading = false;
      });
    }
  }

  String _formatExpiresIn(DateTime expiresAt) {
    final duration = expiresAt.difference(DateTime.now());
    if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else {
      return '${duration.inMinutes}min';
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationService = context.watch<LocationService>();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.accent.withValues(alpha: 0.05), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active Circles', style: AppStyles.headingLarge),
                          const SizedBox(height: 4),
                          Text(
                            _isLoading ? 'Loading...' : '${_circles.length} circles nearby',
                            style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
              // Circles List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _circles.isEmpty
                        ? Center(
                            child: Text(
                              'No circles nearby',
                              style: AppStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _circles.length,
                            itemBuilder: (context, index) {
                              final circle = _circles[index];
                              final activityColor = ActivityTypes.getColor(circle.activityType);
                              final distance = locationService.distanceFromCurrent(
                                circle.centerLocation.latitude,
                                circle.centerLocation.longitude,
                              );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              activityColor.withValues(alpha: 0.15),
                              Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppStyles.cardRadius),
                          boxShadow: [AppStyles.cardShadow],
                          border: Border.all(
                            color: activityColor.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Activity Icon
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [activityColor, activityColor.withValues(alpha: 0.7)],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                      ActivityTypes.getIcon(circle.activityType),
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Circle Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${circle.activityType} Circle',
                                          style: AppStyles.headingSmall,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${circle.memberCount} members',
                                              style: AppStyles.bodySmall,
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                                            const SizedBox(width: 4),
                                            Text(
                                              distance != null ? LocationService.formatDistance(distance) : 'N/A',
                                              style: AppStyles.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Expires badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _formatExpiresIn(circle.expiresAt),
                                      style: AppStyles.bodySmall.copyWith(
                                        color: AppColors.warning,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Join Button
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CircleChatScreen(circle: circle),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: activityColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Join Circle',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
