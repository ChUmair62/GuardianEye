import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/interview.dart';

class InterviewService {
  static final _col =
      FirebaseFirestore.instance.collection('interviews');

  /// Stream all interviews
  static Stream<List<Interview>> streamInterviews() {
    return _col.orderBy('timestamp', descending: true).snapshots().map(
          (snap) => snap.docs
              .map((d) => Interview.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  /// Add Interview
  static Future<void> addInterview(Interview interview) async {
    await _col.add(interview.toMap());
  }

  /// Update Interview
  static Future<void> updateInterview(Interview interview) async {
    await _col.doc(interview.id).update(interview.toMap());
  }

  /// Delete Interview
  static Future<void> deleteInterview(String id) async {
    await _col.doc(id).delete();
  }

  /// Get all for dropdown names (OFFICERS/SUSPECTS)
  static Future<Map<String, String>> getAllOfficersOnce() async {
    final snap = await FirebaseFirestore.instance.collection('officers').get();
    return {for (var d in snap.docs) d.id: d['name']};
  }

  static Future<Map<String, String>> getAllSuspectsOnce() async {
    final snap = await FirebaseFirestore.instance.collection('suspects').get();
    return {for (var d in snap.docs) d.id: d['name']};
  }
}
