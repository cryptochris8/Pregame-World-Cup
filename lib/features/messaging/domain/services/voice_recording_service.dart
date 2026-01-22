import 'dart:async';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../entities/voice_message.dart';
import '../../../../core/services/performance_monitor.dart';
import '../../../../core/services/logging_service.dart';

class VoiceRecordingService {
  static const String _logTag = 'VoiceRecordingService';
  
  final RecorderController _recorder = RecorderController();
  final AudioPlayer _player = AudioPlayer();
  
  // Recording state
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentRecordingPath;
  String? _currentPlayingMessageId;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  
  // Playback state management
  final Map<String, VoiceMessage> _playbackStates = {};
  
  // Stream controllers for real-time updates
  final StreamController<Duration> _recordingDurationController = StreamController<Duration>.broadcast();
  final StreamController<bool> _recordingStateController = StreamController<bool>.broadcast();
  final StreamController<Map<String, VoiceMessage>> _playbackStateController = 
      StreamController<Map<String, VoiceMessage>>.broadcast();

  // Getters
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  Duration get recordingDuration => _recordingDuration;
  
  // Streams
  Stream<Duration> get recordingDurationStream => _recordingDurationController.stream;
  Stream<bool> get recordingStateStream => _recordingStateController.stream;
  Stream<Map<String, VoiceMessage>> get playbackStateStream => _playbackStateController.stream;

  /// Initialize the service and request permissions
  Future<bool> initialize() async {
    try {
      PerformanceMonitor.startApiCall('voice_service_init');
      
      // Request microphone permission
      final micPermission = await Permission.microphone.request();
      if (micPermission != PermissionStatus.granted) {
        PerformanceMonitor.endApiCall('voice_service_init', success: false);
        return false;
      }
      
      // Set up audio player listener
      _player.positionStream.listen((position) {
        _updatePlaybackPosition(position);
      });
      
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _stopCurrentPlayback();
        }
      });
      
      PerformanceMonitor.endApiCall('voice_service_init', success: true);
      return true;
    } catch (e) {
      LoggingService.error('Failed to initialize voice service: $e', tag: _logTag);
      PerformanceMonitor.endApiCall('voice_service_init', success: false);
      return false;
    }
  }

  /// Start recording a voice message
  Future<bool> startRecording() async {
    try {
      if (_isRecording) return false;
      
      PerformanceMonitor.startApiCall('voice_recording_start');
      
      // Stop any current playback
      await stopPlayback();
      
      // Get temporary directory for recording
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${tempDir.path}/voice_message_$timestamp.m4a';
      
      // Configure recorder settings
      _recorder
        ..androidEncoder = AndroidEncoder.aac
        ..androidOutputFormat = AndroidOutputFormat.mpeg4
        ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
        ..sampleRate = 44100;

      // Start recording with audio_waveforms
      await _recorder.record(path: _currentRecordingPath!);
      
      _isRecording = true;
      _recordingDuration = Duration.zero;
      _recordingStateController.add(true);
      
      // Start duration timer
      _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        _recordingDuration = Duration(milliseconds: timer.tick * 100);
        _recordingDurationController.add(_recordingDuration);
      });
      
      PerformanceMonitor.endApiCall('voice_recording_start', success: true);
      return true;
    } catch (e) {
      LoggingService.error('Failed to start recording: $e', tag: _logTag);
      PerformanceMonitor.endApiCall('voice_recording_start', success: false);
      return false;
    }
  }

  /// Stop recording and return the file path
  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return null;
      
      PerformanceMonitor.startApiCall('voice_recording_stop');
      
      // Stop recording
      final recordedPath = await _recorder.stop();
      
      _isRecording = false;
      _recordingTimer?.cancel();
      _recordingStateController.add(false);
      
      final finalPath = recordedPath ?? _currentRecordingPath;
      _currentRecordingPath = null;
      
      PerformanceMonitor.endApiCall('voice_recording_stop', success: true);
      return finalPath;
    } catch (e) {
      LoggingService.error('Failed to stop recording: $e', tag: _logTag);
      PerformanceMonitor.endApiCall('voice_recording_stop', success: false);
      return null;
    }
  }

  /// Cancel current recording
  Future<void> cancelRecording() async {
    try {
      if (!_isRecording) return;
      
      await _recorder.stop();
      _isRecording = false;
      _recordingTimer?.cancel();
      _recordingStateController.add(false);
      
      // Delete the temporary file
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      _currentRecordingPath = null;
    } catch (e) {
      LoggingService.error('Failed to cancel recording: $e', tag: _logTag);
    }
  }

  /// Play a voice message
  Future<bool> playVoiceMessage(VoiceMessage voiceMessage) async {
    try {
      PerformanceMonitor.startApiCall('voice_message_play');
      
      // Stop any current playback
      await stopPlayback();
      
      // Set the audio source
      await _player.setUrl(voiceMessage.audioUrl);
      
      // Update state
      _currentPlayingMessageId = voiceMessage.messageId;
      _isPlaying = true;
      
      final updatedVoice = voiceMessage.copyWith(isPlaying: true);
      _playbackStates[voiceMessage.messageId] = updatedVoice;
      _playbackStateController.add(Map.from(_playbackStates));
      
      // Start playback
      await _player.play();
      
      PerformanceMonitor.endApiCall('voice_message_play', success: true);
      return true;
    } catch (e) {
      LoggingService.error('Failed to play voice message: $e', tag: _logTag);
      PerformanceMonitor.endApiCall('voice_message_play', success: false);
      return false;
    }
  }

  /// Stop current playback
  Future<void> stopPlayback() async {
    try {
      if (_currentPlayingMessageId != null) {
        await _player.stop();
        _stopCurrentPlayback();
      }
    } catch (e) {
      LoggingService.error('Failed to stop playback: $e', tag: _logTag);
    }
  }

  /// Pause current playback
  Future<void> pausePlayback() async {
    try {
      if (_isPlaying) {
        await _player.pause();
        _isPlaying = false;
        
        if (_currentPlayingMessageId != null) {
          final current = _playbackStates[_currentPlayingMessageId!];
          if (current != null) {
            final updated = current.copyWith(isPlaying: false);
            _playbackStates[_currentPlayingMessageId!] = updated;
            _playbackStateController.add(Map.from(_playbackStates));
          }
        }
      }
    } catch (e) {
      LoggingService.error('Failed to pause playback: $e', tag: _logTag);
    }
  }

  /// Resume current playback
  Future<void> resumePlayback() async {
    try {
      if (!_isPlaying && _currentPlayingMessageId != null) {
        await _player.play();
        _isPlaying = true;
        
        final current = _playbackStates[_currentPlayingMessageId!];
        if (current != null) {
          final updated = current.copyWith(isPlaying: true);
          _playbackStates[_currentPlayingMessageId!] = updated;
          _playbackStateController.add(Map.from(_playbackStates));
        }
      }
    } catch (e) {
      LoggingService.error('Failed to resume playback: $e', tag: _logTag);
    }
  }

  /// Seek to a specific position in the current playback
  Future<void> seekToPosition(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      LoggingService.error('Failed to seek to position: $e', tag: _logTag);
    }
  }

  /// Get audio duration from file
  Future<int> getAudioDuration(String filePath) async {
    try {
      PerformanceMonitor.startApiCall('audio_duration_analysis');
      
      final tempPlayer = AudioPlayer();
      await tempPlayer.setFilePath(filePath);
      final duration = tempPlayer.duration;
      await tempPlayer.dispose();
      
      PerformanceMonitor.endApiCall('audio_duration_analysis', success: true);
      return duration?.inSeconds ?? 0;
    } catch (e) {
      LoggingService.error('Failed to get audio duration: $e', tag: _logTag);
      PerformanceMonitor.endApiCall('audio_duration_analysis', success: false);
      return 0;
    }
  }

  /// Generate waveform data from audio file (using audio_waveforms PlayerController)
  Future<List<double>> generateWaveform(String filePath, {int samples = 100}) async {
    try {
      PerformanceMonitor.startApiCall('waveform_generation');

      // Use PlayerController to extract waveform data from file
      final playerController = PlayerController();
      await playerController.preparePlayer(
        path: filePath,
        shouldExtractWaveform: true,
        noOfSamples: samples,
      );

      // Get the extracted waveform data
      final waveformData = playerController.waveformData;
      playerController.dispose();

      if (waveformData.isNotEmpty) {
        PerformanceMonitor.endApiCall('waveform_generation', success: true);
        return waveformData;
      }

      // Fallback to generated waveform if extraction returns empty
      throw Exception('Waveform data empty');
    } catch (e) {
      LoggingService.error('Failed to generate waveform: $e', tag: _logTag);
      PerformanceMonitor.endApiCall('waveform_generation', success: false);
      // Fallback to synthetic waveform if extraction fails
      return _generateSyntheticWaveform(samples);
    }
  }

  /// Generate a synthetic waveform pattern for fallback
  List<double> _generateSyntheticWaveform(int samples) {
    return List<double>.generate(samples, (index) {
      final normalizedIndex = index / samples;
      // Create a natural-looking voice waveform pattern
      final base = 0.3 + 0.4 * normalizedIndex;
      final variation = 0.3 * ((index % 7) / 7);
      return (base + variation).clamp(0.1, 1.0);
    });
  }

  /// Get the current playback state for a voice message
  VoiceMessage? getPlaybackState(String messageId) {
    return _playbackStates[messageId];
  }

  /// Update playback position for current playing message
  void _updatePlaybackPosition(Duration position) {
    if (_currentPlayingMessageId != null) {
      final current = _playbackStates[_currentPlayingMessageId!];
      if (current != null) {
        final updated = current.copyWith(
          currentPosition: position.inSeconds,
        );
        _playbackStates[_currentPlayingMessageId!] = updated;
        _playbackStateController.add(Map.from(_playbackStates));
      }
    }
  }

  /// Stop current playback and reset state
  void _stopCurrentPlayback() {
    _isPlaying = false;
    
    if (_currentPlayingMessageId != null) {
      final current = _playbackStates[_currentPlayingMessageId!];
      if (current != null) {
        final updated = current.copyWith(
          isPlaying: false,
          currentPosition: 0,
        );
        _playbackStates[_currentPlayingMessageId!] = updated;
        _playbackStateController.add(Map.from(_playbackStates));
      }
      _currentPlayingMessageId = null;
    }
  }

  /// Dispose of resources
  void dispose() {
    _recordingTimer?.cancel();
    _recorder.dispose();
    _player.dispose();
    _recordingDurationController.close();
    _recordingStateController.close();
    _playbackStateController.close();
  }
} 