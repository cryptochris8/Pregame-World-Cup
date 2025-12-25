import 'package:flutter/material.dart';
import '../../domain/entities/social_connection.dart';

class FriendSuggestionsSection extends StatelessWidget {
  final List<FriendSuggestion> suggestions;
  final Function(FriendSuggestion) onSuggestionPressed;
  final Function(String) onConnectPressed;

  const FriendSuggestionsSection({
    super.key,
    required this.suggestions,
    required this.onSuggestionPressed,
    required this.onConnectPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'People You May Know',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return _buildSuggestionCard(suggestion);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(FriendSuggestion suggestion) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: InkWell(
          onTap: () => onSuggestionPressed(suggestion),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: suggestion.profileImageUrl != null
                      ? NetworkImage(suggestion.profileImageUrl!)
                      : null,
                  child: suggestion.profileImageUrl == null
                      ? Text(suggestion.displayName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  suggestion.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  suggestion.suggestionText,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 