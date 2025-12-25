import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/services/file_upload_service.dart';
import '../../domain/services/voice_recording_service.dart';
import '../../domain/entities/file_attachment.dart';
import '../../domain/entities/video_message.dart';
import 'voice_recording_widget.dart';

class MessageAttachmentPicker extends StatefulWidget {
  final String chatId;
  final Function(FileAttachment)? onImageSelected;
  final Function(VideoMessage)? onVideoSelected;
  final Function(FileAttachment)? onFileSelected;
  final Function(String audioUrl, int duration, List<double> waveform)? onVoiceRecorded;
  final VoiceRecordingService? voiceService;

  const MessageAttachmentPicker({
    super.key,
    required this.chatId,
    this.onImageSelected,
    this.onVideoSelected,
    this.onFileSelected,
    this.onVoiceRecorded,
    this.voiceService,
  });

  @override
  State<MessageAttachmentPicker> createState() => _MessageAttachmentPickerState();
}

class _MessageAttachmentPickerState extends State<MessageAttachmentPicker>
    with TickerProviderStateMixin {
  
  final FileUploadService _fileService = FileUploadService();
  late AnimationController _overlayController;
  late Animation<double> _overlayAnimation;
  
  bool _isUploading = false;
  String? _uploadProgress;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _overlayAnimation = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeInOut,
    );
  }

  void _showAttachmentOptions() {
    _overlayController.forward();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildAttachmentSheet(),
    ).then((_) {
      _overlayController.reverse();
    });
  }

  Widget _buildAttachmentSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.attach_file, color: Color(0xFF8B4513)),
                  SizedBox(width: 8),
                  Text(
                    'Attach Media',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Loading indicator
            if (_isUploading)
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _uploadProgress ?? 'Uploading...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              // Attachment options grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildAttachmentOption(
                            icon: Icons.camera_alt,
                            label: 'Camera',
                            color: Colors.blue,
                            onTap: () => _pickImage(ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildAttachmentOption(
                            icon: Icons.photo_library,
                            label: 'Gallery',
                            color: Colors.green,
                            onTap: () => _pickImage(ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAttachmentOption(
                            icon: Icons.videocam,
                            label: 'Video',
                            color: Colors.purple,
                            onTap: () => _pickVideo(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildAttachmentOption(
                            icon: Icons.insert_drive_file,
                            label: 'File',
                            color: Colors.orange,
                            onTap: () => _pickFile(),
                          ),
                        ),
                      ],
                    ),
                    if (widget.voiceService != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildAttachmentOption(
                              icon: Icons.keyboard_voice,
                              label: 'Voice',
                              color: Colors.red,
                              onTap: () => _showVoiceRecorder(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Container()), // Empty space for alignment
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    
    setState(() {
      _isUploading = true;
      _uploadProgress = 'Selecting image...';
    });

    try {
      final attachment = await _fileService.pickAndUploadImage(
        chatId: widget.chatId,
        source: source,
      );

      if (attachment != null) {
        widget.onImageSelected?.call(attachment);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to upload image');
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = null;
      });
    }
  }

  Future<void> _pickVideo() async {
    Navigator.pop(context);
    
    setState(() {
      _isUploading = true;
      _uploadProgress = 'Selecting video...';
    });

    try {
      final messageId = '${widget.chatId}_${DateTime.now().millisecondsSinceEpoch}';
      final videoMessage = await _fileService.pickAndUploadVideo(
        chatId: widget.chatId,
        messageId: messageId,
        source: ImageSource.gallery,
      );

      if (videoMessage != null) {
        widget.onVideoSelected?.call(videoMessage);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to upload video');
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = null;
      });
    }
  }

  Future<void> _pickFile() async {
    Navigator.pop(context);
    
    setState(() {
      _isUploading = true;
      _uploadProgress = 'Selecting file...';
    });

    try {
      final attachment = await _fileService.pickAndUploadFile(
        chatId: widget.chatId,
      );

      if (attachment != null) {
        widget.onFileSelected?.call(attachment);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to upload file');
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = null;
      });
    }
  }

  void _showVoiceRecorder() {
    Navigator.pop(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) => _buildVoiceRecorderSheet(),
    );
  }

  Widget _buildVoiceRecorderSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Voice recorder widget
              if (widget.voiceService != null)
                VoiceRecordingWidget(
                  voiceService: widget.voiceService!,
                  onVoiceMessageReady: (audioUrl, duration, waveform) {
                    Navigator.pop(context);
                    widget.onVoiceRecorded?.call(audioUrl, duration, waveform);
                  },
                ),
              
              const SizedBox(height: 20),
              
              // Cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showAttachmentOptions,
      child: AnimatedBuilder(
        animation: _overlayAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_overlayAnimation.value * 0.1),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF8B4513),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B4513).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.attach_file,
                color: Colors.white,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }
} 