import 'package:flutter/material.dart';
import '../../domain/entities/message.dart';
import '../../domain/services/messaging_service.dart';
import '../../../../core/services/logging_service.dart';

class MessageSearchWidget extends StatefulWidget {
  final String chatId;
  final Function(Message) onMessageSelected;

  const MessageSearchWidget({
    super.key,
    required this.chatId,
    required this.onMessageSelected,
  });

  @override
  State<MessageSearchWidget> createState() => _MessageSearchWidgetState();
}

class _MessageSearchWidgetState extends State<MessageSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final MessagingService _messagingService = MessagingService();
  List<Message> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.brown[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.brown[800],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Text(
                  'Search Messages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search in conversation...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.search, color: Colors.orange[300]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _searchResults.clear();
                          });
                        },
                        icon: const Icon(Icons.clear, color: Colors.white54),
                      )
                    : null,
                filled: true,
                fillColor: Colors.brown[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          
          // Search results
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.white.withValues(alpha:0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Start typing to search messages',
              style: TextStyle(
                color: Colors.white.withValues(alpha:0.6),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white.withValues(alpha:0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages found',
              style: TextStyle(
                color: Colors.white.withValues(alpha:0.6),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords',
              style: TextStyle(
                color: Colors.white.withValues(alpha:0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final message = _searchResults[index];
        return _buildSearchResultItem(message);
      },
    );
  }

  Widget _buildSearchResultItem(Message message) {
    final highlightedContent = _highlightSearchQuery(
      message.content,
      _searchQuery,
    );

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orange[300],
        backgroundImage: message.senderImageUrl != null
            ? NetworkImage(message.senderImageUrl!)
            : null,
        child: message.senderImageUrl == null
            ? Icon(
                Icons.person,
                color: Colors.brown[800],
              )
            : null,
      ),
      title: Text(
        message.senderName,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          highlightedContent,
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(message.createdAt),
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        widget.onMessageSelected(message);
      },
    );
  }

  Widget _highlightSearchQuery(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        style: const TextStyle(color: Colors.white70),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    
    int start = 0;
    int index;
    
    while ((index = lowerText.indexOf(lowerQuery, start)) != -1) {
      // Add text before match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: const TextStyle(color: Colors.white70),
        ));
      }
      
      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          color: Colors.orange[300],
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.orange[300]?.withValues(alpha:0.2),
        ),
      ));
      
      start = index + query.length;
    }
    
    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: const TextStyle(color: Colors.white70),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      final hour = timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return _getDayName(timestamp.weekday);
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }

  void _onSearchChanged(String value) async {
    setState(() {
      _searchQuery = value;
    });

    if (value.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    if (value.length < 2) return; // Wait for at least 2 characters

    setState(() {
      _isSearching = true;
    });

    try {
      final allMessages = await _messagingService.getMessages(widget.chatId);
      final filtered = allMessages.where((message) {
        return message.content.toLowerCase().contains(value.toLowerCase()) &&
               !message.isDeleted &&
               message.type == MessageType.text;
      }).toList();

      // Sort by relevance (exact matches first, then partial matches)
      filtered.sort((a, b) {
        final aExact = a.content.toLowerCase().startsWith(value.toLowerCase()) ? 0 : 1;
        final bExact = b.content.toLowerCase().startsWith(value.toLowerCase()) ? 0 : 1;
        
        if (aExact != bExact) {
          return aExact.compareTo(bExact);
        }
        
        // Then sort by recency
        return b.createdAt.compareTo(a.createdAt);
      });

      if (mounted) {
        setState(() {
          _searchResults = filtered.take(50).toList(); // Limit to 50 results
          _isSearching = false;
        });
      }
    } catch (e) {
      LoggingService.error('Error searching messages: $e', tag: 'MessageSearch');
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }
} 