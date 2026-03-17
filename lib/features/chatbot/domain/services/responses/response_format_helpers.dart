/// Helper functions for formatting text and data in chatbot responses.
///
/// These utilities are used across different response generators to maintain
/// consistent formatting.

/// Capitalize each word in a string.
String capitalize(String s) {
  if (s.isEmpty) return s;
  return s.split(' ').map((word) =>
      word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}'
  ).join(' ');
}

/// Format a date string like "2026-06-11" to "Jun 11".
String formatDate(String isoDate) {
  if (isoDate.isEmpty) return '';
  try {
    final parts = isoDate.split('-');
    if (parts.length < 3) return isoDate;
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[month]} $day';
  } catch (_) {
    return isoDate;
  }
}

/// Format a large number with K/M suffix.
String formatNumber(dynamic value) {
  if (value == null) return '?';
  final num n = value is num ? value : num.tryParse(value.toString()) ?? 0;
  if (n >= 1e9) return '${(n / 1e9).toStringAsFixed(1)}B';
  if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(1)}M';
  if (n >= 1e3) return '${(n / 1e3).toStringAsFixed(0)}K';
  return n.toString();
}
