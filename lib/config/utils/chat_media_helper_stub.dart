import 'dart:async';

abstract class ChatAudioPlayer {
  void play(String url, void Function(double duration, double position, bool isPlaying) onUpdate);
  void pause();
  void seek(double seconds);
  void stop();
  bool isPlaying(String url);
  double getPosition(String url);
  double getDuration(String url);
}

abstract class ChatAudioRecorder {
  Future<bool> requestPermissions();
  Future<void> startRecording();
  Future<void> stopRecording(void Function(List<int> bytes, String mimeType) onComplete);
  void cancelRecording();
  bool get isRecording;
}

class ChatAudioPlayerStub implements ChatAudioPlayer {
  @override
  void play(String url, void Function(double duration, double position, bool isPlaying) onUpdate) {}
  @override
  void pause() {}
  @override
  void seek(double seconds) {}
  @override
  void stop() {}
  @override
  bool isPlaying(String url) => false;
  @override
  double getPosition(String url) => 0.0;
  @override
  double getDuration(String url) => 0.0;
}

class ChatAudioRecorderStub implements ChatAudioRecorder {
  @override
  bool get isRecording => false;
  @override
  Future<bool> requestPermissions() async => false;
  @override
  Future<void> startRecording() async {}
  @override
  Future<void> stopRecording(void Function(List<int> bytes, String mimeType) onComplete) async {}
  @override
  void cancelRecording() {}
}

final ChatAudioPlayer audioPlayer = ChatAudioPlayerStub();
final ChatAudioRecorder audioRecorder = ChatAudioRecorderStub();

Future<String> uploadChatMedia({
  required List<int> bytes,
  required String fileName,
  required String mimeType,
  required String businessSlug,
}) async {
  return '';
}
