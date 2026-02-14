import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/services/messaging_service.dart';
import '../../domain/services/file_upload_service.dart';
import '../../domain/entities/message.dart';

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

  // Common emoji categories for quick access
  final List<String> _recentEmojis = ['😀', '😂', '❤️', '👍', '🔥', '🎉', '😍', '👏'];
  final List<String> _sportsEmojis = ['🏈', '🏆', '🎯', '⚡', '🔥', '💪', '🙌', '🎊'];
  final List<String> _foodEmojis = ['🍕', '🍔', '🍟', '🌮', '🍗', '🥤', '🍺', '🎂'];

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
              _buildReplyPreview(),
              const SizedBox(height: 8),
            ],
            
            // Emoji picker
            if (_showEmojiPicker) _buildEmojiPicker(),
            
            // Input row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attachment button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
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
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
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
                          ? Colors.white.withOpacity(0.3) 
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

  Widget _buildReplyPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEA580C), Color(0xFFFBBF24)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Replying to',
                  style: TextStyle(
                    color: Color(0xFFFBBF24),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Original message content...', // In real app, fetch the original message
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onCancelReply,
            icon: Icon(
              Icons.close,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent emojis
          const Text(
            'Recent',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _recentEmojis.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _insertEmoji(_recentEmojis[index]),
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _recentEmojis[index],
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sports emojis
          const Text(
            'Sports',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _sportsEmojis.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _insertEmoji(_sportsEmojis[index]),
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _sportsEmojis[index],
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Food emojis
          const Text(
            'Food & Drinks',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _foodEmojis.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _insertEmoji(_foodEmojis[index]),
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _foodEmojis[index],
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            const Text(
              'Share Media',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Options grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.photo_camera,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _selectPhoto(ImageSource.camera);
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _selectPhoto(ImageSource.gallery);
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.videocam,
                  label: 'Video',
                  onTap: () {
                    Navigator.pop(context);
                    _selectVideo();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.location_on,
                  label: 'Location',
                  onTap: () {
                    Navigator.pop(context);
                    _shareLocation();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
        // Send video message using MessagingService
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
        // Send image message using MessagingService
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