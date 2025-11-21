import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/micro_event_model.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';
import '../../services/firestore_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  String _selectedType = 'Coffee';
  int _duration = 30;
  int _maxParticipants = 5;
  bool _isCreating = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final locationService = context.read<LocationService>();

    if (authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to create events')),
      );
      return;
    }

    if (locationService.currentGeoPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not available')),
      );
      return;
    }

    setState(() => _isCreating = true);

    final event = MicroEventModel(
      id: 'event_${DateTime.now().millisecondsSinceEpoch}',
      creatorId: authService.currentUser!.id,
      type: _selectedType,
      description: _descriptionController.text.trim(),
      maxParticipants: _maxParticipants,
      participantIds: [authService.currentUser!.id],
      startTime: DateTime.now().add(const Duration(hours: 1)),
      endTime: DateTime.now().add(Duration(hours: 1, minutes: _duration)),
      location: locationService.currentGeoPoint!,
      status: 'upcoming',
    );

    final eventId = await FirestoreService.createEvent(event);

    setState(() => _isCreating = false);

    if (eventId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Micro-Event'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event Type', style: AppStyles.headingSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ActivityTypes.all.map((type) {
                  final isSelected = _selectedType == type;
                  final color = ActivityTypes.getColor(type);
                  return FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedType = type);
                    },
                    backgroundColor: Colors.white,
                    selectedColor: color.withValues(alpha: 0.2),
                    checkmarkColor: color,
                    labelStyle: TextStyle(
                      color: isSelected ? color : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? color : AppColors.divider,
                      width: isSelected ? 2 : 1,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text('Description', style: AppStyles.headingSmall),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'What\'s your event about?',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text('Duration: $_duration minutes', style: AppStyles.headingSmall),
              Slider(
                value: _duration.toDouble(),
                min: 20,
                max: 60,
                divisions: 4,
                label: '$_duration min',
                activeColor: AppColors.accent,
                onChanged: (value) {
                  setState(() => _duration = value.toInt());
                },
              ),
              const SizedBox(height: 16),
              Text('Max Participants: $_maxParticipants', style: AppStyles.headingSmall),
              Slider(
                value: _maxParticipants.toDouble(),
                min: 2,
                max: 10,
                divisions: 8,
                label: '$_maxParticipants',
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() => _maxParticipants = value.toInt());
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _createEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isCreating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create Event',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
