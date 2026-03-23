import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';

/// Screen that requires users to accept the Terms of Service and EULA
/// before accessing any user-generated content features.
///
/// This is required by Apple Guideline 1.2 for apps with UGC.
/// The acceptance timestamp is stored in the user's Firestore profile.
class TermsAcceptanceScreen extends StatefulWidget {
  final VoidCallback onAccepted;

  const TermsAcceptanceScreen({super.key, required this.onAccepted});

  @override
  State<TermsAcceptanceScreen> createState() => _TermsAcceptanceScreenState();
}

class _TermsAcceptanceScreenState extends State<TermsAcceptanceScreen> {
  bool _isLoading = false;
  bool _hasScrolledToBottom = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (!_hasScrolledToBottom) {
        setState(() => _hasScrolledToBottom = true);
      }
    }
  }

  Future<void> _acceptTerms() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Store acceptance in Firestore
      await FirebaseFirestore.instance
          .collection('social_profiles')
          .doc(user.uid)
          .set({
        'termsAcceptedAt': FieldValue.serverTimestamp(),
        'termsVersion': '1.0',
      }, SetOptions(merge: true));

      widget.onAccepted();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openTermsUrl() async {
    final uri = Uri.parse('https://pregameworldcup.com/terms');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openPrivacyUrl() async {
    final uri = Uri.parse('https://pregameworldcup.com/privacy');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Header
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: const Image(
                    image: AssetImage('assets/logos/pregame_logo.png'),
                    height: 80,
                    width: 80,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.termsOfService,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please review and accept our terms to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // Scrollable terms content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          'End User License Agreement',
                          'By using Pregame, you agree to be bound by these terms. '
                              'This app is licensed to you, not sold, for use under these terms. '
                              'Pregame reserves all rights not expressly granted to you.',
                        ),
                        _buildSection(
                          'Community Guidelines',
                          'Pregame is a community for football fans. To keep it safe and enjoyable for everyone, '
                              'you must follow these guidelines when using any social features including '
                              'chat, comments, activity posts, watch parties, and messaging.',
                        ),
                        _buildSection(
                          'Zero Tolerance Policy',
                          'We have ZERO TOLERANCE for objectionable content or abusive behavior. '
                              'The following are strictly prohibited:\n\n'
                              '\u2022 Hate speech, discrimination, or harassment of any kind\n'
                              '\u2022 Threats of violence or intimidation\n'
                              '\u2022 Sexually explicit or pornographic content\n'
                              '\u2022 Spam, scams, or misleading content\n'
                              '\u2022 Impersonation of other users or public figures\n'
                              '\u2022 Sharing personal information of others without consent\n'
                              '\u2022 Content that promotes illegal activities\n'
                              '\u2022 Any content that violates the rights of others',
                        ),
                        _buildSection(
                          'Content Moderation',
                          'All user-generated content is subject to automated filtering and human review. '
                              'Users can report objectionable content and block abusive users at any time. '
                              'Reported content is reviewed within 24 hours.',
                        ),
                        _buildSection(
                          'Enforcement',
                          'Violations of these terms will result in enforcement action, which may include:\n\n'
                              '\u2022 Content removal\n'
                              '\u2022 Temporary muting (24 hours to 7 days)\n'
                              '\u2022 Account suspension\n'
                              '\u2022 Permanent ban\n\n'
                              'Severe violations (hate speech, threats, illegal content) may result '
                              'in immediate permanent ban without warning.',
                        ),
                        _buildSection(
                          'Your Responsibilities',
                          'You are solely responsible for all content you post, share, or send through Pregame. '
                              'You agree not to post any content that is objectionable, abusive, or violates these terms. '
                              'You understand that violations may result in removal of your content and/or your account.',
                        ),
                        _buildSection(
                          'Privacy',
                          'Your use of Pregame is also governed by our Privacy Policy. '
                              'By accepting these terms, you also acknowledge that you have reviewed our Privacy Policy.',
                        ),
                        const SizedBox(height: 8),
                        // Links to full documents
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: _openTermsUrl,
                              child: Text(
                                'Full Terms',
                                style: TextStyle(
                                  color: Colors.orange[400],
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: _openPrivacyUrl,
                              child: Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  color: Colors.orange[400],
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Accept button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: (_hasScrolledToBottom && !_isLoading)
                      ? _acceptTerms
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    disabledBackgroundColor:
                        Colors.orange.withValues(alpha: 0.3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _hasScrolledToBottom
                              ? 'I Agree to the Terms of Service'
                              : 'Scroll down to review all terms',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 8),

              // Decline option
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                child: Text(
                  'Decline and Sign Out',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
