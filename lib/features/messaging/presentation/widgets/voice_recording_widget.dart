import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../domain/services/voice_recording_service.dart';

class VoiceRecordingWidget extends StatefulWidget {
  final VoiceRecordingService voiceService;
  final Function(String audioUrl, int duration, List<double> waveform)? onVoiceMessageReady;
  final bool isEnabled;

  const VoiceRecordingWidget({
    super.key,
    required this.voiceService,
    this.onVoiceMessageReady,
    this.isEnabled = true,
  });

  @override
  State<VoiceRecordingWidget> createState() => _VoiceRecordingWidgetState();
}

class _VoiceRecordingWidgetState extends State<VoiceRecordingWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<bool>? _recordingStateSubscription;
  
  // UI state
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeService();
    _setupListeners();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _durationSubscription?.cancel();
    _recordingStateSubscription?.cancel();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));
  }

  Future<void> _initializeService() async {
    final success = await widget.voiceService.initialize();
    setState(() {
      _isInitialized = success;
      if (!success) {
        _errorMessage = 'Microphone permission required';
      }
    });
  }

  void _setupListeners() {
    _durationSubscription = widget.voiceService.recordingDurationStream.listen((duration) {
      setState(() {
        _recordingDuration = duration;
      });
    });
    
    _recordingStateSubscription = widget.voiceService.recordingStateStream.listen((isRecording) {
      setState(() {
        _isRecording = isRecording;
      });
      
      if (isRecording) {
        _pulseController.repeat(reverse: true);
        _waveController.repeat();
      } else {
        _pulseController.stop();
        _waveController.stop();
        _pulseController.reset();
        _waveController.reset();
      }
    });
  }

  Future<void> _startRecording() async {
    if (!_isInitialized || !widget.isEnabled) return;
    
    HapticFeedback.mediumImpact();
    final success = await widget.voiceService.startRecording();
    
    if (!success) {
      setState(() {
        _errorMessage = 'Failed to start recording';
      });
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    
    HapticFeedback.lightImpact();
    final recordingPath = await widget.voiceService.stopRecording();
    
    if (recordingPath != null && widget.onVoiceMessageReady != null) {
      // Process the recording
      await _processRecording(recordingPath);
    }
    
    setState(() {
      _recordingDuration = Duration.zero;
    });
  }

  Future<void> _cancelRecording() async {
    if (!_isRecording) return;
    
    HapticFeedback.lightImpact();
    await widget.voiceService.cancelRecording();
    
    setState(() {
      _recordingDuration = Duration.zero;
    });
  }

  Future<void> _processRecording(String recordingPath) async {
    try {
      // Get audio duration
      final duration = await widget.voiceService.getAudioDuration(recordingPath);
      
      // Generate waveform
      final waveform = await widget.voiceService.generateWaveform(recordingPath);
      
      // For demo purposes, we'll use a mock URL
      // In a real app, you would upload to your file service first
      final audioUrl = 'file://$recordingPath';
      
      widget.onVoiceMessageReady?.call(audioUrl, duration, waveform);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to process recording';
      });
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.mic_off, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              _errorMessage ?? 'Initializing microphone...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: _isRecording ? Colors.red.withValues(alpha:0.1) : Colors.grey.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: _isRecording ? Colors.red : Colors.grey.withValues(alpha:0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Recording button
          GestureDetector(
            onTapDown: (_) => _startRecording(),
            onTapUp: (_) => _stopRecording(),
            onTapCancel: () => _cancelRecording(),
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isRecording ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.red : const Color(0xFF8B4513),
                      shape: BoxShape.circle,
                      boxShadow: _isRecording ? [
                        BoxShadow(
                          color: Colors.red.withValues(alpha:0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ] : null,
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Recording state and duration
          Expanded(
            child: _isRecording ? 
              _buildRecordingIndicator() : 
              _buildIdleState(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Row(
      children: [
        // Animated waveform
        AnimatedBuilder(
          animation: _waveAnimation,
          builder: (context, child) {
            return Row(
              children: List.generate(5, (index) {
                final height = 4.0 + (20.0 * (1 + (index / 5) * _waveAnimation.value * 2)) % 20;
                return Container(
                  width: 3,
                  height: height,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            );
          },
        ),
        
        const SizedBox(width: 12),
        
        // Duration
        Text(
          _formatDuration(_recordingDuration),
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        
        const SizedBox(width: 8),
        
        const Text(
          'Recording...',
          style: TextStyle(
            color: Colors.red,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildIdleState() {
    return const Row(
      children: [
        Icon(
          Icons.keyboard_voice,
          color: Color(0xFF8B4513),
          size: 18,
        ),
        SizedBox(width: 8),
        Text(
          'Hold to record voice message',
          style: TextStyle(
            color: Color(0xFF8B4513),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
} 