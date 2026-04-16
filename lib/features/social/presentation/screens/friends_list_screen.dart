import '../../../../config/app_theme.dart';
import 'package:flutter/material.dart';

class FriendsListScreen extends StatefulWidget {
  final String userId;
  final String initialTab;

  const FriendsListScreen({
    super.key,
    required this.userId,
    required this.initialTab,
  });

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        backgroundColor: AppTheme.backgroundDark,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Friends List Screen\n(Coming Soon)',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
} 