import 'package:intl/intl.dart';

class Formatters {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '$',
    decimalDigits: 2,
  );

  static final _dateFormat = DateFormat('EEEE, MMM d');
  static final _timeFormat = DateFormat('h:mm a');

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      return _dateFormat.format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatTime(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      return _timeFormat.format(dateTime);
    } catch (_) {
      return '';
    }
  }

  static String timeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final diff = DateTime.now().difference(date);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      return '${diff.inDays} days ago';
    } catch (_) {
      return '';
    }
  }
}
