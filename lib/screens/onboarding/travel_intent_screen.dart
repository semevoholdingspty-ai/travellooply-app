import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import 'activity_preferences_screen.dart';

class TravelIntentScreen extends StatefulWidget {
  const TravelIntentScreen({super.key});

  @override
  State<TravelIntentScreen> createState() => _TravelIntentScreenState();
}

class _TravelIntentScreenState extends State<TravelIntentScreen> {
  String? selectedIntent;

  final List<Map<String, dynamic>> intents = [
    {'title': 'Explore', 'icon': Icons.explore, 'color': AppColors.activityColors['Explore']},
    {'title': 'Socialize', 'icon': Icons.people, 'color': AppColors.activityColors['Socialize']},
    {'title': 'Eat', 'icon': Icons.restaurant, 'color': AppColors.activityColors['Eat']},
    {'title': 'Walk', 'icon': Icons.directions_walk, 'color': AppColors.activityColors['Walk']},
    {'title': 'Nightlife', 'icon': Icons.nightlife, 'color': AppColors.activityColors['Nightlife']},
    {'title': 'Chill', 'icon': Icons.weekend, 'color': AppColors.activityColors['Chill']},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  'What brings you here?',
                  style: AppStyles.headingLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Select your main travel intent',
                  style: AppStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                // Intent Cards
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: intents.length,
                    itemBuilder: (context, index) {
                      final intent = intents[index];
                      final isSelected = selectedIntent == intent['title'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIntent = intent['title'] as String;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      intent['color'] as Color,
                                      (intent['color'] as Color).withValues(alpha: 0.7),
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : Colors.white,
                            borderRadius: BorderRadius.circular(AppStyles.cardRadius),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : AppColors.divider,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? (intent['color'] as Color).withValues(alpha: 0.4)
                                    : AppColors.shadow,
                                blurRadius: isSelected ? 12 : 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                intent['icon'] as IconData,
                                size: 48,
                                color: isSelected ? Colors.white : intent['color'] as Color,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                intent['title'] as String,
                                style: AppStyles.headingSmall.copyWith(
                                  fontSize: 18,
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: selectedIntent != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ActivityPreferencesScreen(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      disabledBackgroundColor: AppColors.divider,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
