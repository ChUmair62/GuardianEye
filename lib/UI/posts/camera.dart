import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../services/google_drive_service.dart';
import '../../utils/speech_service.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> with WidgetsBindingObserver {
  List<CameraDescription> cameras = [];
  CameraController? controller;
  bool isRecording = false;
  bool isBusy = false;
  bool isProcessing = false;

  Duration recordingDuration = Duration.zero;
  Timer? timer;
  String currentTime = '';
  String userEmail = '';

  final SpeechService _speechService = SpeechService();
  String _liveText = '';

  @override
  void initState() {
    super.initState();
    setupCameraController();
    getUserEmail();
    startClock();
    initSpeechToText();
  }

  Future<void> initSpeechToText() async {
    await _speechService.initSpeech();
    _speechService.setOnSpeechUpdate((finalText, interimText) {
      setState(() {
        _liveText = interimText;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    stopTimer();
    super.dispose();
  }

  Future<void> setupCameraController() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        controller = CameraController(
          cameras.first,
          ResolutionPreset.medium, // 720p
          enableAudio: true,
        );
        await controller?.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  void getUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      userEmail = user?.email ?? 'Guest';
    });
  }

  void startClock() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          currentTime =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        });
      }
    });
  }

  // ---------------------------
  // GENERATE INTERVIEW ID
  // ---------------------------
  Future<String> _generateInterviewId() async {
    final ref =
        FirebaseFirestore.instance.collection("config").doc("interviewCounter");

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);

      int current = snapshot.exists ? snapshot["count"] : 0;
      int next = current + 1;

      transaction.set(ref, {"count": next});

      String id = next.toString().padLeft(5, '0');
      return "INT-$id";
    });
  }

  Future<void> startRecording() async {
    if (controller == null || !controller!.value.isInitialized) return;

    try {
      await controller!.startVideoRecording();
      await Future.delayed(Duration(milliseconds: 300));
_speechService.startListening();
print("🎤 STT started when recording started");
      setState(() {
        isRecording = true;
        recordingDuration = Duration.zero;
        startTimer();
      });
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  Future<void> stopRecording() async {
    if (isProcessing || controller == null) return;
    if (!controller!.value.isRecordingVideo) return;

    setState(() => isProcessing = true);

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final XFile videoFile = await controller!.stopVideoRecording();
      _speechService.stopListening();
print("🎤 Final transcript: ${_speechService.finalTranscript}");

      // Generate Interview ID
      final interviewId = await _generateInterviewId();

      final now = DateTime.now();

      // Location
      final position = await _getLocation();
      final lat = position?.latitude;
      final lng = position?.longitude;

      // Metadata JSON
      final metadata = {
        "interviewId": interviewId,
        "officer_email": userEmail,
        "officer_uid": FirebaseAuth.instance.currentUser?.uid,
        "timestamp": now.toIso8601String(),
        "location": {"lat": lat, "lng": lng},
      };

      // Transcript
      final transcriptText = _speechService.finalTranscript;

      // Read video bytes
      final Uint8List videoBytes =
          await File(videoFile.path).readAsBytes();

      // UPLOAD FULL WORKFLOW
      final result =
          await DriveService.instance.uploadInterviewFullFlow(
        videoBytes: videoBytes,
        transcriptText: transcriptText,
        metadataJson: metadata,
        interviewId: interviewId,
      );

      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Interview $interviewId uploaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to upload interview')),
        );
      }

      setState(() {
        isRecording = false;
        stopTimer();
      });
    } catch (e, st) {
      print('❌ Error stopping video: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving video: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  Future<Position?> _getLocation() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();

      if (!enabled) return null;

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return null;

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return pos;
    } catch (e) {
      print("Location error: $e");
      return null;
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        recordingDuration += const Duration(seconds: 1);
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
    recordingDuration = Duration.zero;
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller == null || !controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : buildCameraUI(),
    );
  }

  Widget buildCameraUI() {
    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(child: CameraPreview(controller!)),

          Positioned(
            top: 16,
            left: 16,
            child: Text(
              'User: $userEmail',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                backgroundColor: Colors.black54,
              ),
            ),
          ),

          Positioned(
            top: 40,
            left: 16,
            child: Text(
              'Time: $currentTime',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                backgroundColor: Colors.black54,
              ),
            ),
          ),

          if (isRecording)
            Positioned(
              top: 64,
              left: 16,
              child: Text(
                'Recording: ${_formatDuration(recordingDuration)}',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),

          Positioned(
            bottom: 130,
            left: 16,
            right: 16,
            child: Text(
              _liveText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                backgroundColor: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Start/Stop Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: isProcessing || isBusy
                    ? null
                    : () async {
                        setState(() => isBusy = true);

                        if (isRecording) {
                          await stopRecording();
                        } else {
                          await startRecording();
                        }

                        setState(() => isBusy = false);
                      },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRecording ? Colors.red : Colors.white,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: isBusy
                        ? const CircularProgressIndicator(color: Colors.red)
                        : Icon(
                            isRecording
                                ? Icons.stop
                                : Icons.fiber_manual_record,
                            size: 40,
                            color: isRecording
                                ? Colors.white
                                : Colors.redAccent,
                          ),
                  ),
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 20,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back,
                    color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
