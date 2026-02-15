import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../domain/services/voice_recording_service.dart';
import '../../domain/entities/voice_message.dart';

class VoiceMessageWidget extends StatefulWidget {
  final VoiceMessage voiceMessage;
  final VoiceRecordingService voiceService;
  final bool isSentByCurrentUser;
  final Color primaryColor;
  final Color secondaryColor;

  const VoiceMessageWidget({
    super.key,
    required this.voiceMessage,
    required this.voiceService,
    this.isSentByCurrentUser = false,
    this.primaryColor = const Color(0xFF8B4513),
    this.secondaryColor = const Color(0xFFFF8C00),
  });

  @override
  State<VoiceMessageWidget> createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _playButtonController;
  late Animation<double> _playButtonAnimation;
  
  VoiceMessage? _currentState;
  StreamSubscription<Map<String, VoiceMessage>>? _playbackSubscription;
  
  bool get _isPlaying => _currentState?.isPlaying ?? false;
  double get _progress => _currentState?.progress ?? 0.0;

  @override
  void initState() {
    super.initState();
    _currentState = widget.voiceMessage;
    _initializeAnimations();
    _setupPlaybackListener();
  }

  @override
  void dispose() {
    _playButtonController.dispose();
    _playbackSubscription?.cancel();
    super.dispose();
  }

  void _initializeAnimations() {
    _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _playButtonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _playButtonController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupPlaybackListener() {
    _playbackSubscription = widget.voiceService.playbackStateStream.listen((states) {
      final messageState = states[widget.voiceMessage.messageId];
      if (messageState != null) {
        setState(() {
          _currentState = messageState;
        });
      }
    });
  }

  Future<void> _togglePlayback() async {
    HapticFeedback.lightImpact();
    _playButtonController.forward().then((_) {
      _playButtonController.reverse();
    });

    if (_isPlaying) {
      await widget.voiceService.pausePlayback();
    } else {
      await widget.voiceService.playVoiceMessage(_currentState ?? widget.voiceMessage);
    }
  }

  void _onWaveformTap(double position) {
    if (_currentState != null) {
      final seekPosition = Duration(
        seconds: (position * _currentState!.durationSeconds).round(),
      );
      widget.voiceService.seekToPosition(seekPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMessage = _currentState ?? widget.voiceMessage;
    
    return Container(
      padding: const EdgeInsets.all(12.0),
      constraints: const BoxConstraints(maxWidth: 280, minWidth: 200),
      decoration: BoxDecoration(
        color: widget.isSentByCurrentUser 
            ? widget.primaryColor.withValues(alpha:0.1)
            : Colors.grey.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isSentByCurrentUser 
              ? widget.primaryColor.withValues(alpha:0.3)
              : Colors.grey.withValues(alpha:0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with voice icon and duration
          Row(
            children: [
              Icon(
                Icons.keyboard_voice,
                size: 16,
                color: widget.isSentByCurrentUser 
                    ? widget.primaryColor 
                    : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                'Voice Message',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: widget.isSentByCurrentUser 
                      ? widget.primaryColor 
                      : Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                currentMessage.formattedDuration,
                style: TextStyle(
                  fontSize: 12,
                  color: widget.isSentByCurrentUser 
                      ? widget.primaryColor 
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Playback controls and waveform
          Row(
            children: [
              // Play/Pause button
              AnimatedBuilder(
                animation: _playButtonAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _playButtonAnimation.value,
                    child: GestureDetector(
                      onTap: _togglePlayback,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: widget.isSentByCurrentUser 
                              ? widget.primaryColor 
                              : widget.secondaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (widget.isSentByCurrentUser 
                                  ? widget.primaryColor 
                                  : widget.secondaryColor).withValues(alpha:0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(width: 12),
              
              // Waveform and progress
              Expanded(
                child: _buildWaveform(currentMessage),
              ),
            ],
          ),
          
          // Progress time display
          if (_isPlaying || _progress > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  const SizedBox(width: 48), // Align with waveform
                  Text(
                    _formatCurrentTime(),
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.isSentByCurrentUser 
                          ? widget.primaryColor.withValues(alpha:0.7)
                          : Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  if (_isPlaying)
                    Icon(
                      Icons.volume_up,
                      size: 12,
                      color: widget.isSentByCurrentUser 
                          ? widget.primaryColor.withValues(alpha:0.7)
                          : Colors.grey[500],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWaveform(VoiceMessage message) {
    final waveformData = message.waveformData;
    
    if (waveformData.isEmpty) {
      // Fallback for messages without waveform data
      return _buildProgressBar();
    }
    
    return GestureDetector(
      onTapDown: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        final waveformWidth = box.size.width - 60; // Account for play button and padding
        final tapPosition = (localPosition.dx - 60) / waveformWidth;
        if (tapPosition >= 0 && tapPosition <= 1) {
          _onWaveformTap(tapPosition.clamp(0.0, 1.0));
        }
      },
      child: SizedBox(
        height: 40,
        child: CustomPaint(
          painter: WaveformPainter(
            waveformData: waveformData,
            progress: _progress,
            primaryColor: widget.isSentByCurrentUser 
                ? widget.primaryColor 
                : widget.secondaryColor,
            backgroundColor: (widget.isSentByCurrentUser 
                ? widget.primaryColor 
                : widget.secondaryColor).withValues(alpha:0.3),
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: (widget.isSentByCurrentUser 
            ? widget.primaryColor 
            : widget.secondaryColor).withValues(alpha:0.3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: _progress,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: widget.isSentByCurrentUser 
                ? widget.primaryColor 
                : widget.secondaryColor,
          ),
        ),
      ),
    );
  }

  String _formatCurrentTime() {
    final currentSeconds = (_progress * widget.voiceMessage.durationSeconds).round();
    final minutes = currentSeconds ~/ 60;
    final seconds = currentSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final double progress;
  final Color primaryColor;
  final Color backgroundColor;

  WaveformPainter({
    required this.waveformData,
    required this.progress,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / waveformData.length;
    final progressIndex = (progress * waveformData.length).floor();

    for (int i = 0; i < waveformData.length; i++) {
      final barHeight = waveformData[i] * size.height * 0.8;
      final x = i * barWidth;
      final y = (size.height - barHeight) / 2;

      // Use primary color for played portion, background color for unplayed
      paint.color = i <= progressIndex ? primaryColor : backgroundColor;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth * 0.8, barHeight),
        const Radius.circular(1),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.waveformData != waveformData ||
           oldDelegate.primaryColor != primaryColor ||
           oldDelegate.backgroundColor != backgroundColor;
  }
} 