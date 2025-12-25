import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/UI/posts/user_details.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart'; // ✅ Realtime DB

class VideoList extends StatefulWidget {
  const VideoList({super.key});

  @override
  State<VideoList> createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  List<Map<String, dynamic>> videoList = [];
  Set<String> uploadedFiles = {}; // ✅ Tracks uploaded files

  @override
  void initState() {
    super.initState();
    requestPermissions();
    loadVideosAndMetadata();
  }

  Future<void> requestPermissions() async {
    var status = await Permission.storage.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission is required.')),
      );
    }
  }

  Future<void> loadVideosAndMetadata() async {
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final userDirectories = appDirectory.listSync().whereType<Directory>();

    List<Map<String, dynamic>> tempList = [];

    for (var userDir in userDirectories) {
      final files = userDir.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith('.mp4')) {
          final videoFile = file;
          final jsonFilePath = p.setExtension(videoFile.path, '.json');
          final jsonFile = File(jsonFilePath);

          Map<String, dynamic> metadata = {};
          if (await jsonFile.exists()) {
            final jsonString = await jsonFile.readAsString();
            metadata = jsonDecode(jsonString);
          }

          tempList.add({
            'video': videoFile,
            'metadata': metadata,
          });
        }
      }
    }

    setState(() {
      videoList = tempList;
    });
  }

  void showMetadataDialog(File videoFile, Map<String, dynamic> metadata) {
    final timestamp = metadata['timestamp'] ?? 'Unknown';
    final email = metadata['email'] ?? 'Unknown';
    final latitude = metadata['location']?['latitude'];
    final longitude = metadata['location']?['longitude'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Metadata'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserDetailsPage(initialEmail: email),
                    ),
                  );
                },
                child: Text(
                  'Email: $email',
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text('Timestamp: $timestamp'),
              const SizedBox(height: 8),
              if (latitude != null && longitude != null)
                InkWell(
                  onTap: () => openMap(latitude, longitude),
                  child: Text(
                    'Location: $latitude, $longitude',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              else
                const Text('Location: Not Available'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void openMap(double latitude, double longitude) async {
    final geoUri = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude(Label)');
    final fallbackUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    try {
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map on this device.')),
        );
      }
    } catch (e) {
      print('Error launching map: $e');
    }
  }

  Future<void> uploadToFirebase(File videoFile, Map<String, dynamic> metadata) async {
    final fileName = p.basename(videoFile.path);
    final jsonFilePath = p.setExtension(videoFile.path, '.json');
    final jsonFile = File(jsonFilePath);

    try {
      final storage = FirebaseStorage.instance;
      final database = FirebaseDatabase.instance.ref();

      final videoRef = storage.ref().child('videos/$fileName');
      final metadataRef = storage.ref().child('videos/${p.setExtension(fileName, '.json')}');

      // Upload video
      final videoTask = await videoRef.putFile(videoFile);
      final videoUrl = await videoTask.ref.getDownloadURL();

      // Upload JSON metadata
      if (await jsonFile.exists()) {
        await metadataRef.putFile(jsonFile);
      }

      // ✅ Save metadata + URL in Realtime Database
      await database.child('uploads/${p.withoutExtension(fileName)}').set({
        'downloadUrl': videoUrl,
        'metadata': metadata,
      });

      setState(() {
        uploadedFiles.add(fileName);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Uploaded: $fileName')),
      );
    } catch (e) {
      print('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Upload failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recorded Videos')),
      body: videoList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: videoList.length,
              itemBuilder: (context, index) {
                final videoData = videoList[index];
                final videoFile = videoData['video'] as File;
                final metadata = videoData['metadata'] as Map<String, dynamic>;
                final filename = p.basename(videoFile.path);
                final isUploaded = uploadedFiles.contains(filename);

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.videocam),
                    title: Text(filename),
                    subtitle: Text(metadata['email'] ?? 'No email'),
                    trailing: isUploaded
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('Upload'),
                            onPressed: () => uploadToFirebase(videoFile, metadata),
                          ),
                    onTap: () => showMetadataDialog(videoFile, metadata),
                  ),
                );
              },
            ),
    );
  }
}
