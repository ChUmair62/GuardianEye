import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/suspect.dart';

class SuspectService {
  static final _col = FirebaseFirestore.instance.collection('suspects');

  // Stream suspects for dropdowns & tables
  static Stream<List<Suspect>> streamSuspects() {
    return _col.orderBy('name').snapshots().map(
          (snap) =>
              snap.docs.map((d) => Suspect.fromMap(d.id, d.data())).toList(),
        );
  }

  // ADD suspect
  static Future<void> addSuspect(Suspect suspect) async {
    await _col.add(suspect.toMap());
  }

  // UPDATE suspect
  static Future<void> updateSuspect(Suspect suspect) async {
    await _col.doc(suspect.id).update(suspect.toMap());
  }

  // DELETE suspect
  static Future<void> deleteSuspect(String id) async {
    await _col.doc(id).delete();
  }

  // ⚡ NEW: Fetch suspects once (no stream)
  static Future<List<Suspect>> getAllSuspectsOnce() async {
    final snap = await _col.orderBy('name').get();
    return snap.docs.map((d) => Suspect.fromMap(d.id, d.data())).toList();
  }
}
