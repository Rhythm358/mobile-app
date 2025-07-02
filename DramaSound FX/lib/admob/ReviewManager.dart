import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewManager {
  static const String keyAppLaunchCount = 'app_launch_count';
  static const String keySoundPlayCount = 'sound_play_count';
  static const String keyLastPromptDate = 'last_prompt_date';
  static const String keyPromptCount = 'prompt_count';

  static Future<void> requestReview(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    int appLaunchCount = prefs.getInt(keyAppLaunchCount) ?? 0;
    int soundPlayCount = prefs.getInt(keySoundPlayCount) ?? 0;
    String? lastPromptDate = prefs.getString(keyLastPromptDate);
    int promptCount = prefs.getInt(keyPromptCount) ?? 0;

    // 初回プロンプトの条件を満たす場合
    if (appLaunchCount >= 10 && soundPlayCount >= 50 && promptCount < 1) {
      await _showReviewPrompt(context);
      await prefs.setInt(keyPromptCount, promptCount + 1);
      await prefs.setString(keyLastPromptDate, DateTime.now().toString());
    }

    // 再度プロンプトの条件を満たす場合
    if (promptCount >= 1 &&
        _isEligibleForNextPrompt(lastPromptDate) &&
        soundPlayCount >= 100 &&
        promptCount < 3) {
      await _showReviewPrompt(context);
      await prefs.setString(keyLastPromptDate, DateTime.now().toString());
      if (promptCount >= 2) {
        await prefs.setBool('review_prompt_disabled', true);
      } else {
        await prefs.setInt(keyPromptCount, promptCount + 1);
      }
    }
  }

  static Future<void> _showReviewPrompt(BuildContext context) async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  static bool _isEligibleForNextPrompt(String? lastPromptDate) {
    if (lastPromptDate == null) return false;
    final lastPromptDateTime = DateTime.parse(lastPromptDate);
    final now = DateTime.now();
    final diff = now.difference(lastPromptDateTime);
    return diff.inDays >= 14; // 2週間以上経過しているか
  }

  static Future<void> showStatusDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    int appLaunchCount = prefs.getInt(keyAppLaunchCount) ?? 0;
    int soundPlayCount = prefs.getInt(keySoundPlayCount) ?? 0;
    String? lastPromptDate = prefs.getString(keyLastPromptDate);
    int promptCount = prefs.getInt(keyPromptCount) ?? 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Review Status'),
          content: Text(
            'App Launch Count: $appLaunchCount\n'
            'Sound Play Count: $soundPlayCount\n'
            'Last Prompt Date: $lastPromptDate\n'
            'Prompt Count: $promptCount',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
