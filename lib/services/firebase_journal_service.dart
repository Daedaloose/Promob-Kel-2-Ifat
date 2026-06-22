import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseJournalService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> saveMoodJournal(Map<String, dynamic> journalData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.email)
        .collection('moodJournals')
        .doc(journalData['id']);

    final dataToSave = Map<String, dynamic>.from(journalData);
    if (dataToSave['moodColor'] is Color) dataToSave['moodColor'] = (dataToSave['moodColor'] as Color).value;
    if (dataToSave['tagColor'] is Color) dataToSave['tagColor'] = (dataToSave['tagColor'] as Color).value;
    if (dataToSave['tagTextColor'] is Color) dataToSave['tagTextColor'] = (dataToSave['tagTextColor'] as Color).value;

    await docRef.set(dataToSave);
  }

  static Future<void> saveActivityJournal(Map<String, dynamic> journalData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.email)
        .collection('activityJournals')
        .doc(journalData['id']);

    final dataToSave = Map<String, dynamic>.from(journalData);
    if (dataToSave['color'] is Color) dataToSave['color'] = (dataToSave['color'] as Color).value;

    await docRef.set(dataToSave);
  }

  static Future<List<Map<String, dynamic>>> loadMoodJournals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(user.email)
        .collection('moodJournals')
        .orderBy('id', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final map = doc.data();
      if (map['moodColor'] != null) map['moodColor'] = Color(map['moodColor'] as int);
      if (map['tagColor'] != null) map['tagColor'] = Color(map['tagColor'] as int);
      if (map['tagTextColor'] != null) map['tagTextColor'] = Color(map['tagTextColor'] as int);
      if (map['images'] != null) {
        map['images'] = List<String>.from(map['images']);
      } else {
        map['images'] = <String>[];
      }
      return map;
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> loadActivityJournals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(user.email)
        .collection('activityJournals')
        .orderBy('id', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final map = doc.data();
      if (map['color'] != null) map['color'] = Color(map['color'] as int);
      return map;
    }).toList();
  }
}
