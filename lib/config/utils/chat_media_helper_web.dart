import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_media_helper_stub.dart';

class ChatAudioPlayerWeb implements ChatAudioPlayer {
  web.HTMLAudioElement? _audioElement;
  String? _currentUrl;
  void Function(double duration, double position, bool isPlaying)? _onUpdate;
  bool _isPlaying = false;

  @override
  void play(String url, void Function(double duration, double position, bool isPlaying) onUpdate) {
    if (_currentUrl == url) {
      if (_isPlaying) {
        pause();
      } else {
        _audioElement?.play();
        _isPlaying = true;
        _onUpdate = onUpdate;
        _triggerUpdate();
      }
      return;
    }

    stop();
    _currentUrl = url;
    _onUpdate = onUpdate;
    _audioElement = web.document.createElement('audio') as web.HTMLAudioElement;
    _audioElement!.src = url;

    _audioElement!.addEventListener('timeupdate', (web.Event e) {
      _triggerUpdate();
    }.toJS);

    _audioElement!.addEventListener('ended', (web.Event e) {
      _isPlaying = false;
      _triggerUpdate();
    }.toJS);

    _audioElement!.addEventListener('pause', (web.Event e) {
      _isPlaying = false;
      _triggerUpdate();
    }.toJS);

    _audioElement!.addEventListener('play', (web.Event e) {
      _isPlaying = true;
      _triggerUpdate();
    }.toJS);

    _audioElement!.play();
    _isPlaying = true;
    _triggerUpdate();
  }

  void _triggerUpdate() {
    if (_audioElement == null || _onUpdate == null) return;
    final dur = _audioElement!.duration;
    final duration = dur.isFinite && !dur.isNaN ? dur : 0.0;
    final position = _audioElement!.currentTime;
    _onUpdate!(duration, position, _isPlaying);
  }

  @override
  void pause() {
    _audioElement?.pause();
    _isPlaying = false;
    _triggerUpdate();
  }

  @override
  void seek(double seconds) {
    if (_audioElement != null) {
      _audioElement!.currentTime = seconds;
      _triggerUpdate();
    }
  }

  @override
  void stop() {
    if (_audioElement != null) {
      _audioElement!.pause();
      _audioElement = null;
      _isPlaying = false;
      if (_onUpdate != null) {
        _onUpdate!(0.0, 0.0, false);
      }
      _currentUrl = null;
      _onUpdate = null;
    }
  }

  @override
  bool isPlaying(String url) => _currentUrl == url && _isPlaying;

  @override
  double getPosition(String url) => _currentUrl == url && _audioElement != null ? _audioElement!.currentTime : 0.0;

  @override
  double getDuration(String url) {
    if (_currentUrl == url && _audioElement != null) {
      final dur = _audioElement!.duration;
      return dur.isFinite && !dur.isNaN ? dur : 0.0;
    }
    return 0.0;
  }
}

class ChatAudioRecorderWeb implements ChatAudioRecorder {
  web.MediaRecorder? _mediaRecorder;
  web.MediaStream? _mediaStream;
  final List<web.Blob> _chunks = [];
  bool _isRecording = false;

  @override
  bool get isRecording => _isRecording;

  @override
  Future<bool> requestPermissions() async {
    try {
      final constraints = web.MediaStreamConstraints(audio: true.toJS);
      final stream = await web.window.navigator.mediaDevices.getUserMedia(constraints).toDart;
      final tracks = stream.getAudioTracks().toDart;
      for (var i = 0; i < tracks.length; i++) {
        final track = tracks[i];
        track.stop();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> startRecording() async {
    if (_isRecording) return;
    _chunks.clear();

    final constraints = web.MediaStreamConstraints(audio: true.toJS);
    _mediaStream = await web.window.navigator.mediaDevices.getUserMedia(constraints).toDart;
    
    String? mimeType;
    if (web.MediaRecorder.isTypeSupported('audio/ogg;codecs=opus')) {
      mimeType = 'audio/ogg;codecs=opus';
    } else if (web.MediaRecorder.isTypeSupported('audio/webm;codecs=opus')) {
      mimeType = 'audio/webm;codecs=opus';
    } else if (web.MediaRecorder.isTypeSupported('audio/webm')) {
      mimeType = 'audio/webm';
    }

    final options = mimeType != null 
        ? web.MediaRecorderOptions(mimeType: mimeType)
        : null;

    if (options != null) {
      _mediaRecorder = web.MediaRecorder(_mediaStream!, options);
    } else {
      _mediaRecorder = web.MediaRecorder(_mediaStream!);
    }

    _mediaRecorder!.addEventListener('dataavailable', (web.BlobEvent e) {
      if (e.data.size > 0) {
        _chunks.add(e.data);
      }
    }.toJS);

    _mediaRecorder!.start();
    _isRecording = true;
  }

  @override
  Future<void> stopRecording(void Function(List<int> bytes, String mimeType) onComplete) async {
    if (!_isRecording || _mediaRecorder == null) return;

    final completer = Completer<void>();
    _mediaRecorder!.addEventListener('stop', (web.Event e) {
      completer.complete();
    }.toJS);

    _mediaRecorder!.stop();
    await completer.future;

    final tracks = _mediaStream?.getAudioTracks().toDart ?? [];
    for (var i = 0; i < tracks.length; i++) {
      final track = tracks[i];
      track.stop();
    }

    _isRecording = false;

    final mimeType = _mediaRecorder!.mimeType.isNotEmpty 
        ? _mediaRecorder!.mimeType 
        : 'audio/webm';
        
    final blob = web.Blob(_chunks.toJS, web.BlobPropertyBag(type: mimeType));
    
    final arrayBuffer = await blob.arrayBuffer().toDart;
    final byteBuffer = arrayBuffer.toDart;
    final bytes = byteBuffer.asUint8List();

    onComplete(bytes, mimeType);
  }

  @override
  void cancelRecording() {
    if (!_isRecording || _mediaRecorder == null) return;
    _mediaRecorder!.stop();
    final tracks = _mediaStream?.getAudioTracks().toDart ?? [];
    for (var i = 0; i < tracks.length; i++) {
      final track = tracks[i];
      track.stop();
    }
    _isRecording = false;
    _chunks.clear();
  }
}

final ChatAudioPlayer audioPlayer = ChatAudioPlayerWeb();
final ChatAudioRecorder audioRecorder = ChatAudioRecorderWeb();

Future<String> uploadChatMedia({
  required List<int> bytes,
  required String fileName,
  required String mimeType,
  required String businessSlug,
}) async {
  final dio = Dio();
  const bucketName = 'catalogo-virtual-app.firebasestorage.app';
  final path = 'tenants/$businessSlug/media/$fileName';
  final encodedPath = Uri.encodeComponent(path);
  
  final url = 'https://firebasestorage.googleapis.com/v0/b/$bucketName/o/$encodedPath';
  
  final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
  final headers = <String, dynamic>{
    'Content-Type': mimeType,
  };
  if (idToken != null) {
    headers['Authorization'] = 'Firebase $idToken';
  }
  
  try {
    final response = await dio.post<Map<String, dynamic>>(
      url,
      data: Uint8List.fromList(bytes),
      options: Options(
        headers: headers,
      ),
    );
    final data = response.data;
    if (data == null) {
      throw Exception('Failed to upload file to Firebase Storage');
    }
    final downloadTokens = data['downloadTokens'] as String?;
    if (downloadTokens == null || downloadTokens.isEmpty) {
      throw Exception('No download token returned from storage');
    }
    final token = downloadTokens.split(',').first;
    return 'https://firebasestorage.googleapis.com/v0/b/$bucketName/o/$encodedPath?alt=media&token=$token';
  } on DioException catch (e) {
    final responseData = e.response?.data;
    throw Exception('Upload failed: ${e.message}. Response: $responseData');
  }
}
