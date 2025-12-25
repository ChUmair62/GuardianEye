import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();

  bool isAvailable = false;
  bool isListening = false;

  String finalTranscript = "";
  Function(String finalText, String interimText)? onUpdate;

  Future<void> initSpeech() async {
    isAvailable = await _speech.initialize(
      onError: (err) => print("❌ Speech error: $err"),
      onStatus: (status) {
        print("🎤 Speech status: $status");
        if (status == "done" && isListening) {
          // Auto-restart listening if it stops
          startListening();
        }
      },
    );
    print("🎤 Speech available: $isAvailable");
  }

  void setOnSpeechUpdate(Function(String, String) callback) {
    onUpdate = callback;
  }

  void startListening() {
    if (!isAvailable) {
      print("❌ Speech not available");
      return;
    }

    isListening = true;
    finalTranscript = "";

    _speech.listen(
      listenMode: ListenMode.dictation,
      partialResults: true,
      onResult: (result) {
        if (result.finalResult) {
          finalTranscript += " ${result.recognizedWords}";
          onUpdate?.call(finalTranscript.trim(), "");
        } else {
          onUpdate?.call(finalTranscript.trim(), result.recognizedWords);
        }
      },
    );
    print("🎤 Speech listening started");
  }

  void stopListening() {
    isListening = false;
    _speech.stop();
    print("🎤 Speech stopped");
  }
}
