import 'package:flutter/material.dart';

/// Search bar widget for filtering the friends list.
class FriendsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool hasQuery;

  const FriendsSearchBar({
    super.key,
    required this.controller,
    required this.hasQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha:0.2),
          ),
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search friends...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha:0.7)),
          prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha:0.7)),
          suffixIcon: hasQuery
              ? IconButton(
                  onPressed: () {
                    controller.clear();
                  },
                  icon: Icon(Icons.clear, color: Colors.white.withValues(alpha:0.7)),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          fillColor: Colors.white.withValues(alpha:0.1),
          filled: true,
        ),
      ),
    );
  }
}
