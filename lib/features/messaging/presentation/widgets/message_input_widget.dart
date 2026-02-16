import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/services/messaging_service.dart';
import '../../domain/services/file_upload_service.dart';
import '../../domain/entities/message.dart';
import 'message_reply_preview.dart';
import 'message_emoji_picker.dart';
import 'message_attachment_sheet.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class MessageInputWidget extends StatefulWidget {
  final String chatId;
  final String? replyToMessageId;
  final VoidCallback onMessageSent;
  final VoidCallback? onCancelReply;

  const MessageInputWidget({
    super.key,
    required this.chatId,
    this.replyToMessageId,
    required this.onMessageSent,
    this.onCancelReply,
  });

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final MessagingService _messagingService = MessagingService();
  final FileUploadService _fileUploadService = FileUploadService();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;
  Timer? _typingTimer;
  bool _isTyping = false;
  bool _showEmojiPicker = false;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    // Stop typing indicator when widget is disposed
    if (_isTyping) {
      _messagingService.setTypingIndicator(widget.chatId, false);
    }
    super.dispose();
  }

  void _onTextChanged(String text) {
    setState(() {});

    // Handle typing indicators
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      _messagingService.setTypingIndicator(widget.chatId, true);
    }

    // Cancel previous timer
    _typingTimer?.cancel();

    if (text.isNotEmpty) {
      // Set a timer to stop typing indicator after 2 seconds of inactivity
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (_isTyping) {
          _isTyping = false;
          _messagingService.setTypingIndicator(widget.chatId, false);
        }
      });
    } else if (_isTyping) {
      // Stop typing indicator immediately if text is empty
      _isTyping = false;
      _messagingService.setTypingIndicator(widget.chatId, false);
    }
  }

  void _insertEmoji(String emoji) {
    final text = _textController.text;
    final selection = _textController.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      emoji,
    );
    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + emoji.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4C1D95), // Deep purple
            Color(0xFF7C3AED), // Vibrant purple
            Color(0xFF3B82F6), // Electric blue
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply preview
            if (widget.replyToMessageId != null) ...[
              MessageReplyPreview(onCancelReply: widget.onCancelReply),
              const SizedBox(height: 8),
            ],

            // Emoji picker
            if (_showEmojiPicker)
              MessageEmojiPicker(onEmojiSelected: _insertEmoji),

            // Input row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attachment button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha:0.3)),
                    ),
                    child: IconButton(
                      onPressed: _showAttachmentOptions,
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Text input
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 48,
                        maxHeight: 120,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha:0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              maxLines: null,
                              textInputAction: TextInputAction.newline,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                                hintStyle: TextStyle(
                                  color: Colors.white54,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onChanged: _onTextChanged,
                            ),
                          ),

                          // Emoji button
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _showEmojiPicker = !_showEmojiPicker;
                              });
                              if (_showEmojiPicker) {
                                _focusNode.unfocus();
                              }
                            },
                            icon: Icon(
                              _showEmojiPicker
                                  ? Icons.keyboard
                                  : Icons.emoji_emotions_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: _textController.text.trim().isNotEmpty
                          ? const LinearGradient(
                              colors: [Color(0xFFEA580C), Color(0xFFFBBF24)],
                            )
                          : null,
                      color: _textController.text.trim().isEmpty
                          ? Colors.white.withValues(alpha:0.3)
                          : null,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _textController.text.trim().isNotEmpty && !_isLoading
                          ? _sendMessage
                          : null,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(
                              Icons.send,
                              color: _textController.text.trim().isNotEmpty
                                  ? Colors.white
                                  : Colors.white54,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MessageAttachmentSheet(
        onCameraSelected: () => _selectPhoto(ImageSource.camera),
        onGallerySelected: () => _selectPhoto(ImageSource.gallery),
        onVideoSelected: _selectVideo,
        onLocationSelected: _shareLocation,
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Stop typing indicator
    if (_isTyping) {
      _isTyping = false;
      _messagingService.setTypingIndicator(widget.chatId, false);
    }

    try {
      await _messagingService.sendMessage(
        chatId: widget.chatId,
        content: _textController.text.trim(),
        replyToMessageId: widget.replyToMessageId,
      );

      _textController.clear();
      widget.onMessageSent();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectPhoto(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _sendImageMessage(image);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to select photo: $e');
    }
  }

  Future<void> _selectVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        await _sendVideoMessage(video);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to select video: $e');
    }
  }

  Future<void> _sendVideoMessage(XFile videoFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final videoMessage = await _fileUploadService.pickAndUploadVideo(
        chatId: widget.chatId,
        messageId: '${widget.chatId}_${DateTime.now().millisecondsSinceEpoch}',
        source: ImageSource.gallery,
      );

      if (videoMessage != null) {
        await _messagingService.sendMessage(
          chatId: widget.chatId,
          content: _textController.text.trim().isNotEmpty ? _textController.text.trim() : '🎥 Video',
          type: MessageType.video,
          replyToMessageId: widget.replyToMessageId,
          metadata: {
            'videoUrl': videoMessage.videoUrl,
            'thumbnailUrl': videoMessage.thumbnailUrl,
            'durationSeconds': videoMessage.durationSeconds,
            'width': videoMessage.width,
            'height': videoMessage.height,
            'fileSizeBytes': videoMessage.fileSizeBytes,
          },
        );

        widget.onMessageSent();
        _textController.clear();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to send video: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _shareLocation() {
    // Location sharing requires geolocator package integration and a map
    // preview widget. Planned for post-launch update (v1.1).
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Location sharing coming soon!'),
        backgroundColor: Colors.orange[600],
      ),
    );
  }

  Future<void> _sendImageMessage(XFile imageFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final attachment = await _fileUploadService.pickAndUploadImage(
        chatId: widget.chatId,
        source: ImageSource.gallery,
      );

      if (attachment != null) {
        await _messagingService.sendMessage(
          chatId: widget.chatId,
          content: _textController.text.trim().isNotEmpty ? _textController.text.trim() : '📷 Photo',
          type: MessageType.image,
          replyToMessageId: widget.replyToMessageId,
          metadata: {
            'imageUrl': attachment.fileUrl,
            'fileName': attachment.fileName,
            'fileSizeBytes': attachment.fileSizeBytes,
          },
        );

        widget.onMessageSent();
        _textController.clear();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to send image: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
      ),
    );
  }
}
