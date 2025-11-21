import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class SocialVibeScreen extends StatefulWidget {
  const SocialVibeScreen({super.key});

  @override
  State<SocialVibeScreen> createState() => _SocialVibeScreenState();
}

class _SocialVibeScreenState extends State<SocialVibeScreen> {
  String? selectedVibe;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.background],
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
                Text('Your Social Vibe?', style: AppStyles.headingLarge),
                const SizedBox(height: 12),
                Text(
                  'How do you like to socialize?',
                  style: AppStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 40),
                ...SocialVibes.all.map((vibe) {
                  final isSelected = selectedVibe == vibe;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedVibe = vibe;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: AppColors.primaryGradient,
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
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : AppColors.shadow,
                              blurRadius: isSelected ? 12 : 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                SocialVibes.getIcon(vibe),
                                size: 32,
                                color: isSelected ? Colors.white : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vibe,
                                    style: AppStyles.headingSmall.copyWith(
                                      color: isSelected ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    SocialVibes.getDescription(vibe),
                                    style: AppStyles.bodySmall.copyWith(
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.9)
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Colors.white, size: 28),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: selectedVibe != null
                        ? () {
                            // Navigate to home screen after onboarding
                            Navigator.pushNamed(context, '/email-verification');
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Start Exploring',
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
