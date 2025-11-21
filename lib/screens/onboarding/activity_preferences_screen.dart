import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import 'social_vibe_screen.dart';

class ActivityPreferencesScreen extends StatefulWidget {
  const ActivityPreferencesScreen({super.key});

  @override
  State<ActivityPreferencesScreen> createState() => _ActivityPreferencesScreenState();
}

class _ActivityPreferencesScreenState extends State<ActivityPreferencesScreen> {
  final Set<String> selectedActivities = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.accent.withValues(alpha: 0.1), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 24),
                Text('What are your interests?', style: AppStyles.headingLarge),
                const SizedBox(height: 12),
                Text(
                  'Select all activities you enjoy (at least 3)',
                  style: AppStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: ActivityTypes.all.map((activity) {
                      final isSelected = selectedActivities.contains(activity);
                      return FilterChip(
                        label: Text(activity),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedActivities.add(activity);
                            } else {
                              selectedActivities.remove(activity);
                            }
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: ActivityTypes.getColor(activity).withValues(alpha: 0.2),
                        checkmarkColor: ActivityTypes.getColor(activity),
                        labelStyle: TextStyle(
                          color: isSelected ? ActivityTypes.getColor(activity) : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? ActivityTypes.getColor(activity) : AppColors.divider,
                          width: isSelected ? 2 : 1,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: selectedActivities.length >= 3
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SocialVibeScreen(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Continue (${selectedActivities.length}/3)',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
