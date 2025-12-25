import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecordingsPage extends StatefulWidget {
  const RecordingsPage({super.key});

  @override
  State<RecordingsPage> createState() => _RecordingsPageState();
}

class _RecordingsPageState extends State<RecordingsPage> {
  List<FileSystemEntity>? videoFiles;

  @override
  void initState() {
    super.initState();
    loadVideoFiles();
  }

  /// ✅ Load all saved MP4 recordings (ignore JSON metadata)
  Future<void> loadVideoFiles() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('No user is logged in');
      return;
    }

    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final Directory userDirectory = Directory('${appDirectory.path}/$userId');

    if (!await userDirectory.exists()) {
      await userDirectory.create(recursive: true);
    }

    final List<FileSystemEntity> files = userDirectory.listSync();

    // ✅ Only get .mp4 videos, skip .json files
    final videos = files
        .where((file) =>
            file.path.endsWith('.mp4') && !file.path.endsWith('.json.mp4'))
        .toList();

    // Sort newest first
    videos.sort(
      (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
    );

    setState(() {
      videoFiles = videos;
    });
  }

  /// ✅ Delete selected video file (and related .json metadata if exists)
  Future<void> deleteVideo(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();

      final jsonPath = path.replaceAll('.mp4', '.json');
      final jsonFile = File(jsonPath);
      if (await jsonFile.exists()) {
        await jsonFile.delete();
      }

      loadVideoFiles();
    }
  }

  /// ✅ Read metadata JSON if exists
  Future<Map<String, dynamic>?> loadMetadata(String videoPath) async {
    final jsonPath = videoPath.replaceAll('.mp4', '.json');
    final jsonFile = File(jsonPath);

    if (await jsonFile.exists()) {
      final content = await jsonFile.readAsString();
      return jsonDecode(content);
    }
    return null;
  }

  String getFormattedDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
  }

  void playVideo(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoPath: path),
      ),
    ).then((_) => loadVideoFiles());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved Recordings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: videoFiles == null
          ? const Center(child: CircularProgressIndicator())
          : videoFiles!.isEmpty
              ? const Center(child: Text('No recordings found.'))
              : ListView.builder(
                  itemCount: videoFiles!.length,
                  itemBuilder: (context, index) {
                    final file = File(videoFiles![index].path);
                    final fileName = file.path.split('/').last;
                    final lastModified = file.statSync().modified;

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: loadMetadata(file.path),
                      builder: (context, snapshot) {
                        final metadata = snapshot.data;
                        final email = metadata?['email'] ?? 'Unknown';
                        final timestamp = metadata?['timestamp'] != null
                            ? DateTime.tryParse(metadata!['timestamp'])
                            : null;
                        final location = metadata?['location'] != null
                            ? "${metadata!['location']['latitude']}, ${metadata['location']['longitude']}"
                            : 'Location: N/A';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(Icons.videocam,
                                color: Colors.blueAccent),
                            title: Text(fileName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('User: $email',
                                    style: const TextStyle(fontSize: 13)),
                                Text('📍 $location',
                                    style: const TextStyle(fontSize: 13)),
                                Text(
                                  timestamp != null
                                      ? '📅 ${getFormattedDate(timestamp)}'
                                      : '📅 ${getFormattedDate(lastModified)}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteVideo(file.path),
                            ),
                            onTap: () => playVideo(file.path),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

/// ------------------------
/// 🎥 Video Player Screen
/// ------------------------
class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playback')),
      body: Center(
        child: _controller.value.isInitialized
            ? Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.black54,
                      child: const Text(
                        'GuardianEye',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
