import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_journal_service.dart';

class LocalJournalState {
  static List<Map<String, dynamic>> moodJournals = [];
  static List<Map<String, dynamic>> activityJournals = [];
  
  static Future<void> loadData(String email) async {
    moodJournals = await FirebaseJournalService.loadMoodJournals();
    activityJournals = await FirebaseJournalService.loadActivityJournals();
  }

  static Future<void> addMood(Map<String, dynamic> journal) async {
    moodJournals.insert(0, journal);
    await FirebaseJournalService.saveMoodJournal(journal);
  }

  static Future<void> addActivity(Map<String, dynamic> activity) async {
    activityJournals.insert(0, activity);
    await FirebaseJournalService.saveActivityJournal(activity);
  }

  // Legacy method to prevent breaking existing UI calls that haven't been updated yet.
  // We will update the UI to use addMood and addActivity directly.
  static Future<void> saveData(String email) async {
    // Do nothing for mass save, as we save individually now
  }
}
