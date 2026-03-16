import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../../l10n/app_localizations.dart';

class AdminVenueClaimsScreen extends StatefulWidget {
  const AdminVenueClaimsScreen({super.key});

  @override
  State<AdminVenueClaimsScreen> createState() => _AdminVenueClaimsScreenState();
}

class _AdminVenueClaimsScreenState extends State<AdminVenueClaimsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingClaims = [];
  List<Map<String, dynamic>> _pendingDisputes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final claimsSnapshot = await FirebaseFirestore.instance
          .collection('venue_enhancements')
          .where('claimStatus', isEqualTo: 'pendingReview')
          .orderBy('claimedAt', descending: false)
          .get();

      final disputesSnapshot = await FirebaseFirestore.instance
          .collection('venue_disputes')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: false)
          .get();

      setState(() {
        _pendingClaims = claimsSnapshot.docs.map((doc) {
          final data = doc.data();
          data['docId'] = doc.id;
          return data;
        }).toList();

        _pendingDisputes = disputesSnapshot.docs.map((doc) {
          final data = doc.data();
          data['docId'] = doc.id;
          return data;
        }).toList();

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorLoadingData(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).venueClaims),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context).claimsTab),
                  if (_pendingClaims.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _buildBadge(_pendingClaims.length),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context).disputesTab),
                  if (_pendingDisputes.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _buildBadge(_pendingDisputes.length),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildClaimsTab(theme),
                _buildDisputesTab(theme),
              ],
            ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildClaimsTab(ThemeData theme) {
    if (_pendingClaims.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).noPendingClaims, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context).allVenueClaimsReviewed, style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingClaims.length,
        itemBuilder: (context, index) => _buildClaimCard(theme, _pendingClaims[index]),
      ),
    );
  }

  Widget _buildClaimCard(ThemeData theme, Map<String, dynamic> claim) {
    final venueId = claim['docId'] as String;
    final businessName = claim['businessName'] as String? ?? AppLocalizations.of(context).unknown;
    final ownerRole = claim['ownerRole'] as String? ?? '';
    final contactEmail = claim['contactEmail'] as String? ?? '';
    final contactPhone = claim['contactPhone'] as String? ?? '';
    final venueType = claim['venueType'] as String? ?? '';
    final claimedAt = claim['claimedAt'] is Timestamp
        ? (claim['claimedAt'] as Timestamp).toDate()
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.store, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    businessName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppLocalizations.of(context).adminPending,
                    style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.badge, AppLocalizations.of(context).adminRole, ownerRole),
            _buildInfoRow(Icons.email, AppLocalizations.of(context).adminEmail, contactEmail),
            if (contactPhone.isNotEmpty) _buildInfoRow(Icons.phone, AppLocalizations.of(context).adminPhone, contactPhone),
            _buildInfoRow(Icons.category, AppLocalizations.of(context).adminType, venueType),
            _buildInfoRow(Icons.key, AppLocalizations.of(context).adminVenueId, venueId),
            if (claimedAt != null)
              _buildInfoRow(
                Icons.calendar_today,
                AppLocalizations.of(context).adminClaimed,
                '${claimedAt.month}/${claimedAt.day}/${claimedAt.year}',
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(venueId, businessName),
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(AppLocalizations.of(context).reject),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _reviewClaim(venueId, 'approve', ''),
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(AppLocalizations.of(context).approve),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(String venueId, String businessName) {
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).rejectVenueConfirm(businessName)),
        content: TextField(
          controller: notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).rejectionReasonHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _reviewClaim(venueId, 'reject', notesController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(AppLocalizations.of(context).reject),
          ),
        ],
      ),
    );
  }

  Future<void> _reviewClaim(String venueId, String action, String adminNotes) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('reviewVenueClaim');
      await callable.call({
        'venueId': venueId,
        'action': action,
        'adminNotes': adminNotes,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'approve'
                ? AppLocalizations.of(context).claimApprovedSuccessfully
                : AppLocalizations.of(context).claimRejectedSuccessfully),
            backgroundColor: action == 'approve' ? Colors.green : Colors.orange,
          ),
        );
      }

      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorWithMessage(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildDisputesTab(ThemeData theme) {
    if (_pendingDisputes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).noPendingDisputes, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context).allVenueDisputesReviewed, style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingDisputes.length,
        itemBuilder: (context, index) => _buildDisputeCard(theme, _pendingDisputes[index]),
      ),
    );
  }

  Widget _buildDisputeCard(ThemeData theme, Map<String, dynamic> dispute) {
    final venueId = dispute['venueId'] as String? ?? '';
    final reason = dispute['reason'] as String? ?? '';
    final details = dispute['details'] as String? ?? '';
    final disputerId = dispute['disputerId'] as String? ?? '';
    final currentOwnerId = dispute['currentOwnerId'] as String? ?? '';
    final createdAt = dispute['createdAt'] is Timestamp
        ? (dispute['createdAt'] as Timestamp).toDate()
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).disputeLabel(reason),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.key, AppLocalizations.of(context).adminVenueId, venueId),
            _buildInfoRow(Icons.person, AppLocalizations.of(context).adminDisputer, disputerId),
            _buildInfoRow(Icons.person_outline, AppLocalizations.of(context).adminCurrentOwner, currentOwnerId),
            if (details.isNotEmpty) _buildInfoRow(Icons.notes, AppLocalizations.of(context).adminDetails, details),
            if (createdAt != null)
              _buildInfoRow(
                Icons.calendar_today,
                AppLocalizations.of(context).adminFiled,
                '${createdAt.month}/${createdAt.day}/${createdAt.year}',
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _resolveDispute(dispute['docId'] as String, 'dismissed'),
                    child: Text(AppLocalizations.of(context).dismiss),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _resolveDispute(dispute['docId'] as String, 'upheld'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(AppLocalizations.of(context).upholdAction),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resolveDispute(String disputeId, String resolution) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('resolveVenueDispute');
      await callable.call({
        'disputeId': disputeId,
        'resolution': resolution,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).disputeResolution(resolution)),
            backgroundColor: resolution == 'upheld' ? Colors.orange : Colors.grey,
          ),
        );
      }

      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorWithMessage(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }
}
