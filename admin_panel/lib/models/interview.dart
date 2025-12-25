class Interview {
  final String id;
  final String officerId;
  final String suspectId;
  final String videoUrl;
  final String transcript; // optional text transcript
  final DateTime timestamp;

  Interview({
    required this.id,
    required this.officerId,
    required this.suspectId,
    required this.videoUrl,
    required this.transcript,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'officerId': officerId,
      'suspectId': suspectId,
      'videoUrl': videoUrl,
      'transcript': transcript,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static Interview fromMap(String id, Map<String, dynamic> map) {
    return Interview(
      id: id,
      officerId: map['officerId'] ?? '',
      suspectId: map['suspectId'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      transcript: map['transcript'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
