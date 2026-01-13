import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../config/app_theme.dart';
import '../../domain/services/world_cup_payment_service.dart';

/// Screen displaying user's payment transaction history
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final WorldCupPaymentService _paymentService = WorldCupPaymentService();

  List<PaymentTransaction> _transactions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final transactions = await _paymentService.getTransactionHistory();
      if (mounted) {
        setState(() {
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.receipt_long, color: AppTheme.accentGold, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Transaction History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: _loadTransactions,
            icon: const Icon(Icons.refresh, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentGold),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_transactions.isEmpty) {
      return _buildEmptyState();
    }

    return _buildTransactionList();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error loading transactions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white60),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTransactions,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long,
                size: 64,
                color: AppTheme.accentGold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Transactions Yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your purchase history will appear here\nonce you make your first transaction.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.star),
              label: const Text('Explore Fan Pass'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentGold,
                side: const BorderSide(color: AppTheme.accentGold),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    // Group transactions by month
    final grouped = <String, List<PaymentTransaction>>{};
    for (final tx in _transactions) {
      final monthKey = DateFormat('MMMM yyyy').format(tx.createdAt);
      grouped.putIfAbsent(monthKey, () => []).add(tx);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final monthKey = grouped.keys.elementAt(index);
        final monthTransactions = grouped[monthKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                monthKey,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ...monthTransactions.map((tx) => _buildTransactionCard(tx)),
          ],
        );
      },
    );
  }

  Widget _buildTransactionCard(PaymentTransaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTransactionDetails(transaction),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: transaction.type.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    transaction.type.icon,
                    color: transaction.type.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.productName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            DateFormat('MMM d, yyyy').format(transaction.createdAt),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 13,
                            ),
                          ),
                          if (transaction.subtitle != null) ...[
                            Text(
                              ' • ',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                transaction.subtitle!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount and status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      transaction.displayAmount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: transaction.status.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction.status.displayName,
                        style: TextStyle(
                          color: transaction.status.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(PaymentTransaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TransactionDetailsSheet(transaction: transaction),
    );
  }
}

/// Bottom sheet showing transaction details
class _TransactionDetailsSheet extends StatelessWidget {
  final PaymentTransaction transaction;

  const _TransactionDetailsSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: transaction.type.color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    transaction.type.icon,
                    color: transaction.type.color,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),

                // Product name
                Text(
                  transaction.productName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (transaction.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.subtitle!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 15,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Amount
                Text(
                  transaction.displayAmount,
                  style: const TextStyle(
                    color: AppTheme.accentGold,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: transaction.status.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        transaction.status == TransactionStatus.completed
                            ? Icons.check_circle
                            : transaction.status == TransactionStatus.pending
                                ? Icons.schedule
                                : transaction.status == TransactionStatus.refunded
                                    ? Icons.replay
                                    : Icons.error,
                        color: transaction.status.color,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        transaction.status.displayName,
                        style: TextStyle(
                          color: transaction.status.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Details rows
                _buildDetailRow('Transaction ID', transaction.id.substring(0, 20)),
                _buildDetailRow('Type', transaction.type.displayName),
                _buildDetailRow(
                  'Date',
                  DateFormat('MMMM d, yyyy • h:mm a').format(transaction.createdAt),
                ),
                _buildDetailRow('Currency', transaction.currency.toUpperCase()),

                const SizedBox(height: 24),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
