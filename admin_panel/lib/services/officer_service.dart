import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/officer.dart';

class OfficerService {
  static final _col = FirebaseFirestore.instance.collection('officers');

  // Stream officers for dropdowns & tables
  static Stream<List<Officer>> streamOfficers() {
    return _col.orderBy('name').snapshots().map(
          (snap) =>
              snap.docs.map((d) => Officer.fromMap(d.id, d.data())).toList(),
        );
  }

  // ADD officer
  static Future<void> addOfficer(Officer officer) async {
    await _col.add(officer.toMap());
  }

  // UPDATE officer
  static Future<void> updateOfficer(Officer officer) async {
    await _col.doc(officer.id).update(officer.toMap());
  }

  // DELETE officer
  static Future<void> deleteOfficer(String id) async {
    await _col.doc(id).delete();
  }

  // ⚡ NEW: Fetch all officers ONCE (not stream)
  static Future<List<Officer>> getAllOfficersOnce() async {
    final snap = await _col.orderBy('name').get();
    return snap.docs.map((d) => Officer.fromMap(d.id, d.data())).toList();
  }
}
