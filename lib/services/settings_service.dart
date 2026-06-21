import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('darkMode') ?? false;
  }

  static Future<void> setDailyReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dailyReminder', value);
  }

  static Future<bool> getDailyReminder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('dailyReminder') ?? true;
  }

  static Future<void> setMoodReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('moodReminder', value);
  }

  static Future<bool> getMoodReminder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('moodReminder') ?? true;
  }

  static Future<void> setStreakAlert(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('streakAlert', value);
  }

  static Future<bool> getStreakAlert() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('streakAlert') ?? false;
  }

  static Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', value);
  }

  static Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('soundEnabled') ?? true;
  }

  static Future<void> setProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImage', path);
  }

  static Future<String?> getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profileImage');
  }
}
