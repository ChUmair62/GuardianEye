import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class SOSService {
  static Future<void> sendSOSAlert() async {
    final user = FirebaseAuth.instance.currentUser;
    final username = user?.email ?? 'Unknown User';

    print("👤 Logged in user: $username");

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print("📍 Location service enabled: $serviceEnabled");
      if (!serviceEnabled) {
        print("❌ Location service is disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      print("🔒 Location permission: $permission");
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print("🔄 Requested location permission: $permission");
        if (permission == LocationPermission.deniedForever ||
            permission == LocationPermission.denied) {
          print("❌ Location permission denied.");
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print("📍 Position: ${position.latitude}, ${position.longitude}");

      // ✅ Enhanced error handling for Firestore write
      try {
        await FirebaseFirestore.instance.collection('sos_alerts').add({
          'username': username,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': FieldValue.serverTimestamp(),
        });

        print("✅ SOS Alert successfully sent to Firestore.");
      } catch (firestoreError, stackTrace) {
        print("❌ Firestore write error: $firestoreError");
        print("📄 Stack trace: $stackTrace");
      }
    } catch (e, st) {
      print("❌ Error in sendSOSAlert: $e");
      print("📄 Stack trace: $st");
    }
  }
}

