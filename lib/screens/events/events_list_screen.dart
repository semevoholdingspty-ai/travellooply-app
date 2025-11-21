import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final List<Map<String, dynamic>> mockEvents = [
    {
      'title': 'Coffee Meetup at Central Cafe',
      'type': 'Coffee',
      'time': 'Today, 3:00 PM',
      'duration': '30 min',
      'participants': 3,
      'maxParticipants': 5,
      'distance': '0.4 km',
    },
    {
      'title': 'Photography Walk in Old Town',
      'type': 'Photography',
      'time': 'Today, 5:30 PM',
      'duration': '60 min',
      'participants': 4,
      'maxParticipants': 8,
      'distance': '0.7 km',
    },
    {
      'title': 'Dinner at Local Restaurant',
      'type': 'Eat',
      'time': 'Today, 7:00 PM',
      'duration': '90 min',
      'participants': 5,
      'maxParticipants': 10,
      'distance': '0.6 km',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withValues(alpha: 0.05), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nearby Events', style: AppStyles.headingLarge),
                          const SizedBox(height: 4),
                          Text(
                            '${mockEvents.length} happening now',
                            style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.accentGradient),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: mockEvents.length,
                  itemBuilder: (context, index) {
                    final event = mockEvents[index];
                    final eventColor = ActivityTypes.getColor(event['type'] as String);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppStyles.cardRadius),
                          boxShadow: [AppStyles.cardShadow],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [eventColor, eventColor.withValues(alpha: 0.7)],
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                      ActivityTypes.getIcon(event['type'] as String),
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event['title'] as String,
                                          style: AppStyles.headingSmall.copyWith(color: Colors.white),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time, size: 14, color: Colors.white),
                                            const SizedBox(width: 4),
                                            Text(
                                              event['time'] as String,
                                              style: AppStyles.bodySmall.copyWith(color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildInfoChip(Icons.timer, event['duration'] as String),
                                      _buildInfoChip(
                                        Icons.people,
                                        '${event['participants']}/${event['maxParticipants']}',
                                      ),
                                      _buildInfoChip(Icons.location_on, event['distance'] as String),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 44,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: eventColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Join Event',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: AppStyles.bodySmall),
        ],
      ),
    );
  }
}
